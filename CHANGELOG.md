# Changelog

Each section is a version of the mod, the `version` in `mod.json`. The release workflow copies the
section of a tagged version into the release notes.

## 1.3.0

- Spellblade Attack N and Magic Thrust N are forms of Melee Attack N (`rq.skill.form_of`), as the
  game's Thrust Attack N is. The skill shop prices and raises the row Elenoa, Wichita or Rizna holds,
  and a planner such as Loadouts follows that row when the weapon or a knowledge changes the attack
  it shows: a loadout with Magic Thrust saved before the knowledges loads again. Needs loader 2.66.0.
- The shop's price for that row is the game's own, from the row held. The mod adds the rise per use
  (one more point at 3, 5 and 7 uses) only to Kisara's Strike Attack, which is not one of the forms (a
  class change can leave Melee and Strike side by side): before, a row the knowledge had just renamed
  could get the rise twice.

## 1.2.3

- The weapon kinds and the hanny's race come from `rq.ids.item_kind` and `rq.ids.race`. Needs
  loader 1.16.0. No change in the game.

## 1.2.2

- The code names the game's characters, skills, items and states with `rq.ids` instead of
  numbers. Needs loader 1.15.0. No change in the game.

## 1.2.1

- `mod.json` asks for loader 0.4.0, the first with `rq.chara.get`, which 1.2.0 uses for Kisara. It
  said 0.2.0, so an older loader would have run the mod and failed on a brawler.

## 1.2.0

- Kisara Copley (80) can buy it. A brawler's Strike Attack becomes Spellblade Attack, and Strike
  Attack comes back when the weapon does not qualify.

## 1.1.1

- The Magic and Accuracy bonuses need one of its weapons, as Spear Knowledge needs a spear.

## 1.1.0

- Daggers (weapon detail 3) qualify.

## 1.0.0

First version.

- Shop-only knowledge for Elenoa, Wichita and Rizna. From rank 3 a sword, spear or glove turns the
  known Melee and Thrust attacks into Spellblade Attack, and both knowledges at rank 3 into Magic
  Thrust. No extra skill is granted.
- Extra uses cost as Melee's do, and the shop keeps its order after the swap.
- The ranks merge back when the weapon changes.
- Attacks stay physical, with half final damage against hannies.
