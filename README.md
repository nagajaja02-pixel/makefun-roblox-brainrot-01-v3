[![roblox-brainrot-01](https://make.fun/bounty/roblox-brainrot-01/badge.svg)](https://make.fun/bounty/roblox-brainrot-01)
[![Rank](https://make.fun/bounty/roblox-brainrot-01/rank/nagajaja02-pixel/makefun-roblox-brainrot-01-v3.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard)
[![Reward](https://make.fun/bounty/roblox-brainrot-01/reward/nagajaja02-pixel/makefun-roblox-brainrot-01-v3.svg)](https://make.fun/bounty/roblox-brainrot-01)

# Brainrot Blitz

A 3D harbour tycoon game for the **roblox-brainrot-01** bounty on [make.fun](https://make.fun/bounty/roblox-brainrot-01). Buy absurd brainrot characters off a moving conveyor, park them on stands in your safehouse, and watch them earn money every second — while rival players try to steal them, a tsunami sweeps the island, and a shield keeps your base safe.

Play it live: https://www.roblox.com/games/105239944014039

The aerial thumbnail is live and approved on Roblox.

## The game

- **13 brainrot characters** with viral names, from Tung Tung Tung Sahur (Common) to Bombardiro Crocodilo (Mythic), across five rarities.
- **Conveyor**: new brainrots roll out every few seconds and ride the belt from the west dock to the east gate. Click one to buy it.
- **Safehouses**: six bases around the island, each with stands for your brainrots. Start with 4 stands, upgrade up to 8.
- **Steal**: grab a brainrot off someone else's stand and carry it home. A shield blocks raids for 26 seconds, then needs a 48-second cooldown.
- **Tsunami**: a wave sweeps the island on a schedule. Climb onto a base roof or the lookout deck to stay dry.
- **Mutations**: rare Gold (2x income) and Diamond (3x income) spawns.
- **Rebirth**: pay to multiply all income by 1.5x forever. Rebirths are saved between sessions.
- **Merchant**: a seller by the conveyor offers a random brainrot at a premium.
- **Sell**: cash out any brainrot on your own stand for half its price.

## Build

Requires [Rojo](https://rojo.space/) 7.7 and Node 22+.

```sh
rojo build -o game.rbxl
node main.ts
```

`rojo build` compiles `src/` into `game.rbxl`. `node main.ts` copies the place, `PLAY.json`, `src/` and `screenshots/` into the output directory and writes `dossier.json` there.

## How to play

- You start with **$150** and **4 stands** (up to 8 after upgrades).
- Click a brainrot on the conveyor to buy it onto a free stand.
- Stands earn money every second. Sell a brainrot for half its price.
- Press **SHIELD** to protect your base, **UPGRADE** to buy another stand, **REBIRTH** to boost all income, **INDEX** to see every character.
- When the tsunami warning sounds, climb high — anyone still low gets hit by the wave.
