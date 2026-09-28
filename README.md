# BoonEdits

A Hades II mod that reworks and rebalances over 30 boons. Every change is independent and can be
switched off on its own.

## Features

- Reworks across every Olympian, plus duo and legendary boons — see [CHANGELOG.md](CHANGELOG.md)
  for the full list.
- One toggle per change in `ReturnOfModding/config/SWu-BoonEdits.cfg`. Nothing is all-or-nothing.
- Tooltips and stat lines are rewritten to match, so a boon always reads as it behaves.
- Debug helpers for granting boons by name at a chosen rarity and Pom level.

## Install

Install through a mod manager (Thunderstore or r2modman) and it will pull in the dependencies.

To install by hand, drop the folder into `ReturnOfModding/plugins/` and make sure these are present:
Hell2Modding, ENVY, Chalk, ReLoad, SJSON and ModUtil.

## Configuration

Launch the game once to generate `ReturnOfModding/config/SWu-BoonEdits.cfg`, then freely configure (enable/disable) any boon edits.

## Layout

`src/boons/` holds one file per boon, containing its trait edits, hooks, runtime logic and tooltip
text. `src/reload.lua` imports them and holds the shared helpers; `src/ready.lua` is plumbing only.

## Credits

Licence notices for everything this mod depends on, and a note on assets, are in
[CREDITS.md](CREDITS.md). No game art or another modder's code is redistributed here — everything is
referenced from Hades II's own data.

## Wiki

### Aphrodite

- **Glamour Gain** — New Effect: Every 1 second, you inflict Weak on nearby foes. Gain mana for each one.
- **Secret Crush** — Also applies to your special.

### Apollo

- **Easy Shot** — Piercing arrow damage increased to 100 / 120 / 140 / 160, and has a 20% chance to crit.
- **Dazzling Display** — Nova Flourish also applies Daze. Daze rate bumped up to 100%, and rarity scaling improves Daze potency by +3% / +6% / +9% / +12%.
- **Extra Dose** — Also applies to your special.

### Ares

- **Blood Spree** — Additionally, killing a foe has a 20% chance to restore health (equal to the base health restoration amount).
- **Meat Grinder** — Additionally, each hit of the blade rift per foe has a 20% chance to spill plasma. Counts as a plasma boon.
- **Profuse Bleeding** — New(?) Effect: foes with wounds have a small chance to drop plasma after taking damage. Counts as a plasma boon.
- **Stabbing Rush** — Falling blades drop for the entire duration of your sprint.

### Athena

- **Phalanx Shot** — Re-arm time decreased to 1 second.

### Demeter

- **Local Climate** — Also applies to your normal cast.
- **Tranquil Gain** — New Effect: when channeling your Omega moves for 0.5 seconds, rapidly restore mana.
- **Weed Killer** — Also applies to omega special.

### Dionysus

- **Festive Fog** — Also reduces taken damage by 40% while standing in the fog.
- **Grape Juice** — Also restores 20 health on pickup.

### Hades

- **Unseen Ire** — Cooldown reduced to 30 seconds.

### Hephaestus

- **Anvil Ring** — Additionally, inflicts Glow on each hit. Slightly decreased power.
- **Heavy Metal** — Additionally, prevents foes attacks from knocking you back.
- **Molten Touch** — Additionally, deals bonus damage to foes with Glow.
- **Smithy Rush** — New Effect: During your dash, a hammer strikes in your trail, dealing damage and inflicting Glow.

### Hera

- **Rousing Reception** — Additionally, inflicts Hitch on the foes it damages. New dependency on Engagement Ring.

### Hermes

- **Hard Target** replaced with: **Post Haste**: reduces boon effect cooldowns by 20%/25%/30%/35%.

### Hestia

- **Cardio Gain** — Additionally, restores mana while sprinting.
- **Controlled Burn** — Also applies to omega attack.
- **Snuffed Candle** replaced with: **Volcanic Crown**: when your Omega Cast fires, release a ring of 5 fireballs from the center that hit for 100 / 125 / 150 / 175 damage each bounce.

### Medea

- **Harm for the Afflicted** — Curse damage triggers on every new curse inflicted on each foe.

### Poseidon

- **Breaker Rush** — New Effect: Your dash creates a pulsing puddle that creates a wave when coming in contact with foes, knocking them back and dealing **20 / 25 / 30 / 35** damage. Counts as a splash boon.

### Zeus

- **Ionic Gain** — Additionally, standing near the Font slowly restores Magick.
- **Air Quality** — Now floors your base damage before all multipliers.
- **Arc Flash** — Extra Blitz damage is flatly applied to all Blitz instead of only ones triggered by omega attacks.

### Duo Boons

- **Arterial Spray** (Poseidon × Ares) — The second wave's strike chance is improved to 100%, in exchange for its power reduced to 30%.
- **Beach Ball** (Apollo × Poseidon) — Is now considered a Splash Boon, and max damage increased to 400.
- **Brave Face** (Hephaestus × Hera) — Resists up to 50% of any damage rather than 30%, and each point resisted costs 5 Magick instead of 10.
- **Burning Desire** — additionally lifts the ceiling on Scorch, from vanilla's 999.
- **Chain Reaction** (Hestia × Hephaestus) — New Effect: Boon effect cooldowns have a 50% chance of being skipped.
- **Carnal Pleasure** (Aphrodite × Ares) — 100% chance of creating heartthrobs on plasma pickup.
- **Cherished Heirloom** (Demeter × Hera) — When upgrading your current keepsake to Heroic, double-dip on its ability. Additionally, equip an extra keepsake on pickup, and gain its effects for the rest of the night.
- **Cryo Pounder** (Demeter × Hephaestus) — Reworked: Frozen foes with Glow take 50% extra damage.
- **Ecstatic Obsession** replaced with **Nervous Wreck** (Aphrodite x Hera): same effect as before (as Aphrodite's legendary), but kept Ecstatic Obession's old requirements.
- **Glorious Disaster** (Apollo × Zeus) — No longer needs the extra channeled Magick, and bolts hit for 50 each (up fro 20).
- **Hearty Appetite** — Additionally grants a large healing drop on pickup, and again every 5 encounters, and all healing is improved by 50% tonight.
- **Hostile Environment** (Demeter × Ares) — Additionally, your regular cast also follows you around. With Circe's Staff aspect, also follows Familiars.
- **Killer Current** (Zeus × Poseidon) — New Effect: Froth-afflicted foes have a 30% chance of being struck by lightning after taking damage (30 damage per bolt).
- **Love Handles** replaced with **Smoldering Forge** (Aphrodite × Hephaestus) — striking a foe with Glow with Weapon has a 25% chance to create a Heartthrob.
- **Natural Selection** (Demeter × Poseidon) — New Effect: on pickup, gain 3 triple-poms. Every 8 encounters, gain another one.
- **Ripple Effect** (Hera × Poseidon): Projectile repeat effect has a 50% chance to strike again, and again with 25% / 12.5% / 6.25%, up to 4 times total. Repeatable projectile list is expanded to include Ocean Swell, Fine Line, Easy Shot, Controlled Burn, Explosive Intent and Cut Above.
- **Seismic Servo** replaed with **Seismic Hammer** (Hephaestus × Poseidon) — Replaced: your Cast erupts into your Omega Cast after being struck by a Hephaestus blast. Also flatly reduces the cooldowns of Volcanic Strike and Volcanic Flourish by 1 second.
- **Sun Worshiper** (Apollo × Hera) — Additional foes have a 30% chance to also be summoned in combat after being slain, up to 10 per encounter.
- **Scalding Vapor** (Hestia × Poseidon) — Reworked: Steam no longer consumes Froth when activated, and steam damage can stack up to 5 times per foe + proc Froth. Steam can now only be created by Fireballs instead of any fire source.
- **Thermal Dynamics** (Hestia × Zeus) — Scorch share from Blitz increased to 100% of Blitz damage.


### Legendary Boons

- **All Together** (Hera) — Gains +1 elemental essence of each type upon pickup.
- **Fire Away** replaced with **Burning Meteor** (Hestia): Fireball effects from Hestia are 50% larger and stronger, and inflict Scorch equal to the damage they deal.
- **Paid Dues** replaced with **Second Wind** (Hermes): You can cast and dash an additional time.
- **Premium Service** (Hephaestus) — Additionally, all weapon upgrades increase in rank tonight, and gain an Anvil of Fates on pickup.
- **Shocking Loss** (Zeus) — 1% chance to destroy foes outright when they take damage from lightning, the first strike has a 25% chance instead. Now deals 9999 damage to guardians instead of destroying them.
- **Winter Harvest** (Demeter) — Executes from 15% rather than 10%, and sums boss HP across all phases for calculation. Can now skip more boss phases (Prometheus, Zagreus, Typhon).
- **Nervous Wreck** replaced with **Ecstatic Obsession** (Aphrodite): when you inflict Weak, you have a 30% chance to inflict Charm for 5 seconds instead. 5-second cooldown between Charming the same foe again, and Charmed foes cannot damage Melinoe.

### Hammer Upgrades

#### Disabled by Default:
- **Dual Moonshot** (Staff) — No longer costs range and fuse to fire the extra projectile.
- **Reaper Knives → Hook Knives** (Dagger) — Reverted to its EA-launch implementation.
- **Hidden Knives** (Dagger) — Fires in a Spiral pattern around you (like Spiral Knives in EA-launch), with extra knives. Firing angle overridden by Sureshot Flurry if also held.
- **Enduring Coil** (Torch) — Special projectiles last +100% longer (double) rather than adding a flat +2 Sec., and applies to the regular special projectile as well.
- **Hidden Helix** (Torch) — Gain +2 extra projectiles instead of +1.
- **Rising Helix** (Torch) — Makes bonus damage increased to 50%.
- **Whirling Helix** (Torch) — Projectile speed bonus increased to 100%.

### Weapon Aspects

#### Disabled by Default:
- **Aspect of Supay** (Umbral Flames) — Rush-boon damage bonus restored to EA levels.

### Keepsakes

#### Enabled by Default:
- **Aromatic Phial** (Narcissus) — New Heroic rarity, where it raises **two** Common blessings at the next fountain rather than one.
- **Olympian Keepsakes** - New Heroic rarity, can transform boons of any rarity into Legendary (or Heroic, if Legendary is already offered / held) instead.

#### Disabled by Default:
- **Concave Stone** (Echo) — New Effect: Chance to copy your next major reward instead.
- **Calling Card** (Zagreus) — Now rarifies all boons straight to Heroic.
- **Metallic Droplet** (Hermes) — Now keeps half its move/strike/cast speed boost once the timer runs out.
- **White Antler** (Artemis) — Keeps its effects as long as its held.

### Other
- **Anvil of Fates** — Instead of random chance, choose from up to 3 hammer upgrades to sacrifice / gain.
- **Glow** — Now stacks: each further stack makes the target take 5% more damage, up to 35%, and expires independently.
