# Spellblade Knowledge

Shop-only knowledge for **Elenoa Ran (10)**, **Wichita Skate (11)**, and **Rizna Lanfbit (12)**. Cost 3, level `10 + rank * 5` (same gate as Fighter Spear Knowledge).

Lua owns who can buy it, the slot rewrite, and the damage numbers. The engine only registers the skill ids and calls Lua from recalc, the skill shop, and the physical hit path.

| Rank | Stars | Magic (total, not stacked) | Accuracy | Bar |
| --- | --- | --- | --- | --- |
| 1 | none | +50 | — | Melee |
| 2 | ★ | +100 | +10 | Melee |
| 3 | ★★ | +100 | +10 | Spellblade Attack, front only |
| 4 | ★★★ | +300 | +10 | Spellblade Attack, front only |

Rewrite needs a **sword (detail 2)**, **dagger (3, "Shortsword")**, **spear / naginata (7)**, or **glove (9)**. Every known Melee (or Thrust) slot of that rank becomes Spellblade Attack of the same rank, one slot per rank (extra copies are merged, uses summed, cap 99). The buy list swaps those ids in place, the way Spear Knowledge swaps Melee for Thrust, including the paged-list cache the buttons read, so Melee is not offered beside Spellblade and a use-upgrade targets the rewritten id. Both this knowledge and Spear Knowledge at rank ≥ 3 turn those slots and shop rows into **Magic Thrust** (back line allowed). A club, or any other weapon, writes them back to one Melee row, or one Thrust row if Spear Knowledge still applies. Nothing is granted as an extra skill. Flame Slash is left alone. Attacks stay physical, so Rizna still takes damage. Every rank deals **half final damage** to a hanny.

Local-only git. No remote.

## Test

1. Only Elenoa, Wichita, and Rizna can buy it.
2. Rank 2: +100 Magic and +10 Accuracy. The bar still says Melee.
3. Rank 3 + sword or dagger: Spellblade Attack, front only. Same with a spear and no Spear Knowledge.
4. Both knowledges at rank 3 + glove: Magic Thrust, back line allowed.
5. Weapon off: ids revert.
6. A hanny takes half.
7. Rizna still takes the hit (physical, not magic).
