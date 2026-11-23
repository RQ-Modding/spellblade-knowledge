# Testing Spellblade Knowledge

For people and agents who test the mod in the game. Check `logs\rqmod.log` for
`Loading spellblade-knowledge` first.

## What it adds

No buttons and no `rq.agent.control` ids. Do not invent controls for it. It adds the knowledge skill
**960** and the attack skills Spellblade Attack (961 to 965) and Magic Thrust (966 to 970).

## How to check it

1. Only Elenoa (10), Wichita (11), Rizna (12) and Kisara (80) are offered it in the skill shop. On
   Wichita it can be on page 2 (see Potential Skill Pages' TESTING.md): press `potential-skill-pages.next`,
   then buy the `offer-N` whose `value` is `960`.
2. Rank 2 with a sword: +100 Magic and +10 Accuracy; the attack still says Melee. With a club: no
   Magic, no Accuracy.
3. Rank 3 with a sword or a dagger: Spellblade Attack, front row only. The same with a spear and no
   Spear Knowledge.
4. Both knowledges at rank 3 with a glove: Magic Thrust, back row allowed.
5. Take the weapon off: the attacks go back to Melee (Strike Attack for Kisara).
6. A hanny takes half damage. Rizna still takes the hit (physical, not magic).
7. Elenoa with Magic Thrust 1 at 5 uses: the skill shop sells Magic Thrust 1 (not Melee Attack 1) at
   the price of a sixth use, and buying it raises the same row to 6. Erase Spear Knowledge: the row
   shows Spellblade Attack 1 and keeps its uses.

## Forcing it for a test

Use Skill Again (Skill Again in Shop keeps it in Frostbuy) to buy the ranks again. A throwaway test
mod can `rq.chara.grant(iic, 960, rank)`. Work on a copy of the save.

## Tested in the game

The Test Lab's scenario `spellblade`: a dagger turns Melee into Spellblade Attack, and its Magic and
Accuracy need one of its weapons. The scenario `skill-forms`: on Elenoa, the shop's list and the
engine's tries with both knowledges sell and price the row she holds, whatever attack it shows.
