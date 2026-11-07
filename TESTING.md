# Testing Spellblade Knowledge

For people and agents who test the mod in the game. Check `logs\rqmod.log` for
`Loading spellblade-knowledge` first.

## What it adds

No buttons and no `rq.agent.control` ids. Do not invent controls for it. It adds the knowledge skill
**960** and the attack skills Spellblade Attack (961 to 965) and Magic Thrust (966 to 970).

## How to check it

1. Only Elenoa (10), Wichita (11), Rizna (12) and Kisara (80) are offered it in the skill shop. On
   Wichita it can be on page 2 (see Potential Skill Pages' TESTING.md): press `skill-page-next`,
   then buy the `offer-N` whose `value` is `960`.
2. Rank 2 with a sword: +100 Magic and +10 Accuracy; the attack still says Melee. With a club: no
   Magic, no Accuracy.
3. Rank 3 with a sword or a dagger: Spellblade Attack, front row only. The same with a spear and no
   Spear Knowledge.
4. Both knowledges at rank 3 with a glove: Magic Thrust, back row allowed.
5. Take the weapon off: the attacks go back to Melee (Strike Attack for Kisara).
6. A hanny takes half damage. Rizna still takes the hit (physical, not magic).

## Forcing it for a test

Use Skill Again (Skill Again in Shop keeps it in Frostbuy) to buy the ranks again. A throwaway test
mod can `rq.chara.grant(iic, 960, rank)`. Work on a copy of the save.

## Test Lab

`agent-lab.ps1 run spellblade`: a dagger turns Melee into Spellblade Attack, and its Magic and
Accuracy need one of its weapons.
