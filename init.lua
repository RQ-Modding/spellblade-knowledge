-- Spellblade Knowledge. Shop-only for Elenoa, Wichita, Rizna and Kisara.
-- C registers the ids and calls Lua from recalc, the skill shop, physical
-- damage (before defense), accuracy, and final-damage percent.
-- The weapons it needs, by item kind (rq.ids.item_kind): Sword, Shortsword (daggers), Spear
-- (a naginata is a Spear too) and Glove.

local SK, CH = rq.ids.skill, rq.ids.chara
-- 960 to 970 are the engine's own numbers for this mod's skills, not the base game's.
local KNOW = 960
local BUYERS = {
  [CH.ELENOA_RAN] = true, [CH.WICHITA_SKATE] = true, [CH.RIZNA_LANFBIT] = true, [CH.KISARA_COPLEY] = true,
}
local SPEAR = SK.SPEAR_KNOWLEDGE
local KIND = rq.ids.item_kind
local SWORD, DAGGER, SPEAR_W, GLOVE = KIND.SWORD, KIND.SHORTSWORD, KIND.SPEAR, KIND.GLOVE
local HANNY = rq.ids.race.HANNY
local MELEE = { SK.MELEE_ATTACK_1, SK.MELEE_ATTACK_2, SK.MELEE_ATTACK_3, SK.MELEE_ATTACK_4, SK.MELEE_ATTACK_5 }
local THRUST = { SK.THRUST_ATTACK_1, SK.THRUST_ATTACK_2, SK.THRUST_ATTACK_3, SK.THRUST_ATTACK_4, SK.THRUST_ATTACK_5 }
-- Brawlers (class 7) learn Strike Attack in the place of Melee (Ｔ購入スキル登録).
local STRIKE = { SK.STRIKE_ATTACK_1, SK.STRIKE_ATTACK_2, SK.STRIKE_ATTACK_3, SK.STRIKE_ATTACK_4, SK.STRIKE_ATTACK_5 }
local BRAWLER = rq.ids.class.BRAWLER
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

rq.log("Spellblade Knowledge: shop for chars 10/11/12/80; rewrite at rank>=3")

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
  desc = "Specialized for swords, daggers, spears,$"
    .. "and gloves.$"
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

for i = 1, 5 do
  if not rq.skill.sort_as(SB[i], MELEE[i]) or not rq.skill.sort_as(MT[i], MELEE[i]) then
    error("spellblade-knowledge: skill list sort hook missing")
  end
  -- Forms of Melee Attack N (and of Thrust Attack N, the game's own form of it): the row keeps its
  -- uses, its purchase record and its hotbar place when on_recalc swaps it, the buy list prices and
  -- raises the row held, and a planner (Loadouts) follows the row through the swap. Strike Attack is
  -- not one of them: a class change can leave a character with Melee N and Strike N side by side.
  rq.skill.form_of(SB[i], MELEE[i])
  rq.skill.form_of(MT[i], MELEE[i])
end

local INDEX = {}
local IS_STRIKE = {}
for i = 1, 5 do
  INDEX[MELEE[i]] = i
  INDEX[THRUST[i]] = i
  INDEX[STRIKE[i]] = i
  INDEX[SB[i]] = i
  INDEX[MT[i]] = i
  IS_STRIKE[STRIKE[i]] = true
end

local FORMULA = {
  function(atk, mag) return atk // 2 + mag end,
  function(atk, mag) return atk + mag end,
  function(atk, mag) return atk + mag + 200 end,
  function(atk, mag) return atk + mag + 300 end,
  function(atk, mag) return (atk * 3) // 2 + mag + 300 end,
}

local function weapon_ok(detail)
  return detail == SWORD or detail == DAGGER or detail == SPEAR_W or detail == GLOVE
end

-- Same choice Spear makes in Ｃ再計算 / Ｔ購入スキル登録, then Spellblade on top.
-- Rewrites an existing Melee, Thrust or Strike id. Never grants a second skill.
-- Without Spellblade a brawler gets Strike back, everyone else Melee.
local function want_basic(idx, spell_rank, spear_rank, detail, brawler)
  local spell = spell_rank >= 3 and weapon_ok(detail)
  local spear_thrust = spear_rank >= 3 and detail == SPEAR_W
  if spell and spear_rank >= 3 then
    return MT[idx]
  end
  if spell then
    return SB[idx]
  end
  if brawler then
    return STRIKE[idx]
  end
  if spear_thrust then
    return THRUST[idx]
  end
  return MELEE[idx]
end

local function pick_keep(group)
  local keep = group[1]
  for i = 2, #group do
    local s = group[i]
    local sbar = s.bar or 0
    local kbar = keep.bar or 0
    if sbar ~= 0 and kbar == 0 then
      keep = s
    elseif (sbar ~= 0) == (kbar ~= 0) and s.slot < keep.slot then
      keep = s
    end
  end
  return keep
end

-- One slot per rank. Extra copies from a stale Melee buy are folded in
-- (uses summed, cap 99) and cleared. The hotbar entry moves with the keeper.
local function is_brawler(iic)
  return (rq.chara.get(iic) or {}).class == BRAWLER
end

local function collapse_owned(iic, spell_rank, spear_rank, detail)
  local brawler = is_brawler(iic)
  local groups = {}
  for _, s in ipairs(rq.chara.slots(iic)) do
    local idx = INDEX[s.skill]
    if idx then
      local g = groups[idx]
      if not g then
        g = {}
        groups[idx] = g
      end
      g[#g + 1] = s
    end
  end
  for idx, group in pairs(groups) do
    local want = want_basic(idx, spell_rank, spear_rank, detail, brawler)
    local keep = pick_keep(group)
    if #group == 1 then
      if keep.skill ~= want then
        rq.chara.set_slot(iic, keep.slot, want)
        rq.chara.set_flavor(iic, keep.slot)
      end
    else
      local maxu, cur, bar = 0, 0, 0
      for _, s in ipairs(group) do
        maxu = maxu + (s.max or 0)
        cur = cur + (s.uses or 0)
        if bar == 0 and (s.bar or 0) ~= 0 then
          bar = s.bar
        end
      end
      if maxu > 99 then maxu = 99 end
      if maxu < 1 then maxu = 1 end
      if cur > maxu then cur = maxu end
      if keep.skill ~= want then
        rq.chara.set_slot(iic, keep.slot, want)
        rq.chara.set_flavor(iic, keep.slot)
      end
      rq.chara.set_uses(iic, keep.slot, cur, maxu)
      if (keep.bar or 0) == 0 and bar ~= 0 then
        rq.chara.set_bar(iic, keep.slot, bar)
      end
      for _, s in ipairs(group) do
        if s.slot ~= keep.slot then
          rq.chara.clear_slot(iic, s.slot)
        end
      end
    end
  end
end

-- Vanilla スキルポン bumps the point cost only when the row's id is already
-- owned. Since loader 2.66.0 the list sells the form a character holds (the forms
-- above), priced from that row, so this is left for a brawler: the list sells
-- Strike Attack, which is no form of Spellblade Attack, and the row looks unowned.
-- Reapply that curve to the rewritten id.
local function use_cost(base, uses, char_no, skill)
  if uses <= 0 then
    return base
  end
  local cost = base
  if uses >= 3 then cost = cost + 1 end
  if uses >= 5 then cost = cost + 1 end
  if uses >= 7 then cost = cost + 1 end
  if char_no == CH.TOMATO_PUREE then cost = cost + 1 end
  if skill == SK.DEFENSIVE_STANCE then cost = 1 end
  if cost > 9 then cost = 9 end
  return cost
end

-- Vanilla already filled the buy list with Melee, or Thrust if Spear ★★ + spear.
-- Swap that id in place so the level lock stays, and price extra uses off the
-- rewritten id. A second family row for the same rank is dropped.
local function rewrite_shop(iic, char_no, spell_rank, spear_rank, detail)
  local brawler = is_brawler(iic)
  local seen = {}
  for _, row in ipairs(rq.chara.offers()) do
    local idx = INDEX[row.skill]
    if idx then
      local want = want_basic(idx, spell_rank, spear_rank, detail, brawler)
      local points = row.points or 0
      -- A form of the row held was priced from it (loader 2.66.0), even when collapse_owned
      -- has just renamed that row; only Strike Attack was priced as new.
      if want ~= row.skill and IS_STRIKE[row.skill] and rq.chara.max_uses(iic, row.skill) <= 0 then
        points = use_cost(points, rq.chara.max_uses(iic, want), char_no, want)
      end
      if seen[want] then
        rq.chara.set_offer(row.index, 0, 0)
      else
        seen[want] = true
        if want ~= row.skill or points ~= (row.points or 0) then
          rq.chara.set_offer(row.index, want, points)
        end
      end
    end
  end
end

rq.chara.on_recalc(function(iic)
  local rank = rq.chara.rank(iic, KNOW)
  local detail = rq.chara.weapon_detail(iic)
  -- As Spear Knowledge in Ｃ再計算: nothing without one of the weapons.
  if not weapon_ok(detail) then
    rank = 0
  end
  if rank >= 1 then
    local mag = MAGIC_TOTAL[rank] or MAGIC_TOTAL[4]
    rq.chara.apply_mod(iic, 14, mag)
  end
  if rank >= 2 then
    rq.chara.apply_mod(iic, 8, 10)
  end
  collapse_owned(iic, rank, rq.chara.rank(iic, SPEAR), detail)
end)

rq.chara.on_offer(function(ctx)
  local rank = rq.chara.rank(ctx.iic, KNOW)
  local spear = rq.chara.rank(ctx.iic, SPEAR)
  local detail = rq.chara.weapon_detail(ctx.iic)
  collapse_owned(ctx.iic, rank, spear, detail)
  rewrite_shop(ctx.iic, ctx.no, rank, spear, detail)
  if not BUYERS[ctx.no] then
    return nil
  end
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
