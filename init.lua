-- Spellblade Knowledge. Shop-only for Elenoa (10), Wichita (11), Rizna (12).
-- C registers the ids and calls Lua from recalc, the skill shop, physical
-- damage (before defense), accuracy, and final-damage percent.
-- Weapon detail ids from Ｉ種類詳細／文字列: 2 Sword, 7 Spear (naginata is 7), 9 Glove.

local KNOW = 960
local SPEAR = 317
local SWORD, SPEAR_W, GLOVE = 2, 7, 9
local HANNY = 8
local MELEE = { 100, 102, 104, 106, 578 }
local THRUST = { 101, 103, 105, 107, 579 }
local SB = { 961, 962, 963, 964, 965 }
local MT = { 966, 967, 968, 969, 970 }

local MAGIC_TOTAL = { 50, 100, 100, 300 }

local function hover(long, modifier, acc, cap)
  local range = long and "Single enemy/Long range" or "Single enemy/Close range"
  local acc_line = ""
  if acc < 0 then
    acc_line = "$\tAccuracy " .. tostring(acc)
  end
  local limit = cap > 0 and (tostring(cap) .. " damage") or "None"
  return "A basic physical attack that$"
    .. "cuts with spell and steel.$$"
    .. "Target:\t" .. range
    .. "$Modifier:\t" .. modifier
    .. acc_line
    .. "$Dmg Mult:\t1.0x (0.5x vs hanny)"
    .. "$Limit:\t" .. limit
    .. "$Element:\tNone"
end

local ATTACKS = {
  { mod = "Attack x0.5 + Magic", acc = 0, cap = 500 },
  { mod = "Attack + Magic", acc = 0, cap = 1000 },
  { mod = "Attack + Magic + 200", acc = -5, cap = 2000 },
  { mod = "Attack + Magic + 300", acc = -10, cap = 0 },
  { mod = "Attack x1.5 + Magic + 300", acc = -10, cap = 0 },
}

rq.log("Spellblade Knowledge: shop for chars 10/11/12; rewrite at rank>=3")

if not rq.skill.install() then
  error("spellblade-knowledge: rq.skill.install failed")
end
if not rq.chara.install() then
  error("spellblade-knowledge: rq.chara.install failed")
end
if not rq.combat.install() then
  error("spellblade-knowledge: rq.combat.install failed")
end

rq.skill.define({
  id = KNOW,
  kind = "knowledge",
  name = "Spellblade Knowledge",
  flavor = "",
  desc = "Specialized for swords, spears, and gloves.$"
    .. "Effects manifest when one of those is equipped.$$"
    .. "Target:\tSelf$"
    .. "Effect:\tNo star\t... Magic +50$"
    .. "\t★\t... Magic +100$"
    .. "\t\t... Accuracy +10$"
    .. "\t★★\t... Magic +100, Accuracy +10$"
    .. "\t\t... Basic attacks become Spellblade (front)$"
    .. "\t\t... With Spear Knowledge ★★, Magic Thrust (long)$"
    .. "\t★★★\t... Magic +300, Accuracy +10$"
    .. "\t\t... Same Spellblade / Magic Thrust$"
    .. "Hanny takes half damage.",
})

for i = 1, 5 do
  local row = ATTACKS[i]
  rq.skill.define({
    id = SB[i],
    kind = "physical",
    name = "Spellblade Attack " .. i,
    flavor = "attacked with a spellblade.",
    desc = hover(false, row.mod, row.acc, row.cap),
    target = 1,
    bairitsu = 100,
    flat = 0,
    kinou = 0,
    cap = row.cap,
    basic = 1,
  })
  rq.skill.define({
    id = MT[i],
    kind = "physical",
    name = "Magic Thrust " .. i,
    flavor = "thrust a spellblade at the enemy.",
    desc = hover(true, row.mod, row.acc, row.cap),
    target = 2,
    bairitsu = 100,
    flat = 0,
    kinou = 0,
    cap = row.cap,
    basic = 1,
  })
end

local INDEX = {}
for i = 1, 5 do
  INDEX[MELEE[i]] = i
  INDEX[THRUST[i]] = i
  INDEX[SB[i]] = i
  INDEX[MT[i]] = i
end

local FORMULA = {
  function(atk, mag) return atk // 2 + mag end,
  function(atk, mag) return atk + mag end,
  function(atk, mag) return atk + mag + 200 end,
  function(atk, mag) return atk + mag + 300 end,
  function(atk, mag) return (atk * 3) // 2 + mag + 300 end,
}

local function weapon_ok(detail)
  return detail == SWORD or detail == SPEAR_W or detail == GLOVE
end

rq.chara.on_recalc(function(iic)
  local rank = rq.chara.rank(iic, KNOW)
  if rank >= 1 then
    local mag = MAGIC_TOTAL[rank] or MAGIC_TOTAL[4]
    rq.chara.apply_mod(iic, 14, mag)
  end
  if rank >= 2 then
    rq.chara.apply_mod(iic, 8, 10)
  end

  local spear = rq.chara.rank(iic, SPEAR)
  local detail = rq.chara.weapon_detail(iic)
  local spell = rank >= 3 and weapon_ok(detail)
  local both = spell and spear >= 3
  local spear_thrust = spear >= 3 and detail == SPEAR_W

  for _, s in ipairs(rq.chara.slots(iic)) do
    local idx = INDEX[s.skill]
    if idx then
      local want
      if both then
        want = MT[idx]
      elseif spell then
        want = SB[idx]
      elseif spear_thrust then
        want = THRUST[idx]
      else
        want = MELEE[idx]
      end
      if want ~= s.skill then
        rq.chara.set_slot(iic, s.slot, want)
        rq.chara.set_flavor(iic, s.slot)
      end
    end
  end
end)

rq.chara.on_offer(function(ctx)
  if ctx.no ~= 10 and ctx.no ~= 11 and ctx.no ~= 12 then
    return nil
  end
  local rank = rq.chara.rank(ctx.iic, KNOW)
  return { skill = KNOW, cost = 3, level = 10 + rank * 5 }
end)

rq.combat.on_physical(function(ctx)
  local idx = INDEX[ctx.skill]
  if not idx or (ctx.skill ~= SB[idx] and ctx.skill ~= MT[idx]) then
    return nil
  end
  local dmg = FORMULA[idx](ctx.attack or 0, ctx.magic or 0)
  local pct = (ctx.race == HANNY) and 50 or 100
  return dmg, pct
end)

rq.combat.on_accuracy(function(ctx)
  local idx = INDEX[ctx.skill]
  if not idx or (ctx.skill ~= SB[idx] and ctx.skill ~= MT[idx]) then
    return 0
  end
  return ATTACKS[idx].acc
end)
