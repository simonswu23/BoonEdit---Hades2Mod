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
- **Profuse Bleeding** — New(?) Effect: Foes with wounds have a small chance to drop plasma after taking damage. Inflicting wounds also gets the same chance. Counts as a plasma boon.
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
- **Snuffed Candle** replaced with: **Volcanic Crown**: when your Omega Cast fires, release a ring of 5 fireballs from the center that hit for 100 / 125 / 150 / 175 damage each bounce. Their blasts and burning ground grow with Super Nova.

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
- **Chain Reaction** (Hestia × Hephaestus) — New Effect: Boon effect cooldowns have a 30% chance of being skipped.
- **Carnal Pleasure** (Aphrodite × Ares) — Reworked: each Plasma collected counts as 20 Magick used toward Heart Breaker, and Heartthrobs gain +1 power for each Plasma you have.
- **Cherished Heirloom** (Demeter × Hera) — Every keepsake is upgraded by one rarity this night, and your current one is refreshed at its new rarity. Additionally, choose another to keep for the rest of the night on pickup.
- **Cryo Pounder** (Demeter × Hephaestus) — Reworked: Frozen foes with Glow take 50% extra damage.
- **Ecstatic Obsession** replaced with **Nervous Wreck** (Aphrodite x Hera): same effect as before (as Aphrodite's legendary), but kept Ecstatic Obession's old requirements.
- **Glorious Disaster** (Apollo × Zeus) — No longer needs the extra channeled Magick, and bolts hit for 50 each (up fro 20).
- **Hearty Appetite** — Additionally grants a large healing drop on pickup, and again every 5 encounters, and all healing is improved by 50% tonight.
- **Hostile Environment** (Demeter × Ares) — Additionally, your regular cast also follows you around. With Circe's Staff aspect, also follows Familiars.
- **Killer Current** (Zeus × Poseidon) — New Effect: Froth-afflicted foes have a 30% chance of being struck by lightning after taking damage (30 damage per bolt).
- **Love Handles** replaced with **Smoldering Forge** (Aphrodite × Hephaestus) — striking a foe with Glow with Weapon has a 25% chance to create a Heartthrob.
- **Natural Selection** (Demeter × Poseidon) — New Effect: on pickup, gain 3 triple-poms. Every 8 encounters, gain another one.
- **Ripple Effect** (Hera × Poseidon): Projectile repeat effect has a 50% chance to strike again, and again with 25% / 12.5% / 6.25%, up to 4 times total. Repeatable projectile list is expanded to include Ocean Swell, Fine Line, Easy Shot and Controlled Burn.
- **Seismic Servo** replaed with **Seismic Hammer** (Hephaestus × Poseidon) — Replaced: your Cast erupts into your Omega Cast after being struck by a Hephaestus blast. Also flatly reduces the cooldowns of Volcanic Strike and Volcanic Flourish by 1 second.
- **Sun Worshiper** (Apollo × Hera) — Additional foes have a 30% chance to also be summoned in combat after being slain, up to 10 per encounter.
- **Scalding Vapor** (Hestia × Poseidon) — Reworked: Steam no longer consumes Froth when activated, and steam damage can stack up to 5 times per foe + proc Froth. Steam can now only be created by Fireballs instead of any fire source.
- **Thermal Dynamics** (Hestia × Zeus) — Scorch share from Blitz increased to 100% of Blitz damage.


### Legendary Boons

- **All Together** (Hera) — Gains +1 elemental essence of each type upon pickup.
- **Fire Away** replaced with **Burning Meteor** (Hestia): Fireball effects from Hestia are 50% larger and stronger, and inflict Scorch equal to the damage they deal.
- **Paid Dues** replaced with **Second Wind** (Hermes): You can cast and dash an additional time.
- **Premium Service** (Hephaestus) — Additionally, all weapon upgrades increase in rank tonight, and gain an Anvil of Fates on pickup.
- **Shocking Loss** (Zeus) — 2.5% chance to destroy foes outright when your lightning (not chain lightning) strikes them; the first strike on each has a 25% chance instead. Now deals 9999 damage to guardians instead of destroying them.
- **Winter Harvest** (Demeter) — Executes from 15% rather than 10%, and sums boss HP across all phases for calculation. Can now skip more boss phases (Prometheus, Zagreus, Typhon).
- **Nervous Wreck** replaced with **Ecstatic Obsession** (Aphrodite): when you inflict Weak, you have a 30% chance to inflict Charm for 5 seconds instead. 5-second cooldown between Charming the same foe again, and Charmed foes cannot damage Melinoe.

### Keepsakes
- **Aromatic Phial** (Narcissus) — New Heroic rarity, where it raises **two** Common blessings at the next fountain rather than one.
- **Olympian Keepsakes** - New Heroic rarity, can transform boons of any rarity into Legendary (or Heroic, if Legendary is already offered / held) instead.


### Other
- **Anvil of Fates** — Instead of random chance, choose from up to 3 hammer upgrades to sacrifice / gain.
- **Glow** — Now stacks: each further stack makes the target take 5% more damage, up to 35%, and expires independently.

### Offer Requirements

Boons whose offer requirements differ from the base game. Where a boon has several groups (sub-bullets), it needs one boon from each.

- **All Together**
  - Sworn Strike, Sworn Flourish, Engagement Ring, Nexus Rush
  - Bridal Glow, Uncommon Grace, Extended Family
  - Hereditary Bane, Dying Wish, Rousing Reception
- **Arterial Spray**
  - Vicious Strike, Vicious Flourish, Sword Ring, Stabbing Rush, Grisly Gain
  - Wave Strike, Wave Flourish, Breaker Rush
- **Beach Ball**
  - Blinding Rush, Breaker Rush
  - Wave Strike, Wave Flourish, Breaker Rush
  - Nova Strike, Nova Flourish, Blinding Rush
- **Brave Face**
  - Extended Family, Bridal Glow, Uncommon Grace
  - Trusty Shield, Heavy Metal, Security System, Uncanny Fortitude
- **Burning Meteor**
  - Flame Strike, Flame Flourish, Smolder Ring
  - Glowing Coal, Controlled Burn, Volcanic Crown
  - Flash Fry, Hot Pot
- **Carnal Pleasure**
  - Grisly Gain, Visceral Impact, Meat Grinder, Profuse Bleeding
  - Heart Breaker
- **Chain Reaction**
  - Volcanic Strike, Volcanic Flourish
  - Flame Strike, Flame Flourish, Smolder Ring, Heat Rush, Cardio Gain
- **Coffin Nail**
  - Sword Ring, Stabbing Rush, Cut Above
  - Volcanic Strike, Volcanic Flourish, Anvil Ring, Smithy Rush, Tough Gain
- **Cryo Pounder**
  - Furnace Blast, Anvil Ring, Smithy Rush
  - Ice Strike, Ice Flourish, Arctic Ring
- **Cutting Edge**
  - Sword Ring, Stabbing Rush, Cut Above
  - Nova Strike, Nova Flourish, Solar Ring, Blinding Rush, Lucid Gain
- **Dazzling Display** — Nova Strike or Nova Flourish.
- **Dying Wish** — Sworn Strike, Sworn Flourish, Engagement Ring, Nexus Rush or Rousing Reception.
- **Ecstatic Obsession**
  - Flutter Strike, Flutter Flourish
  - Glamour Gain, Passion Rush, Rapture Ring
  - Sweet Surrender, Broken Resolve
- **Fourth Degree**
  - Vicious Strike, Vicious Flourish
  - Glowing Coal, Controlled Burn, Volcanic Crown
- **Furnace Blast** — Volcanic Strike or Volcanic Flourish.
- **Glorious Disaster**
  - Prominence Flare
  - Heaven Strike, Heaven Flourish, Storm Ring, Thunder Rush, Ionic Gain
- **Grand Caldera** — Volcanic Strike or Volcanic Flourish.
- **Hereditary Bane** — Sworn Strike, Sworn Flourish, Engagement Ring, Nexus Rush or Rousing Reception.
- **Hostile Environment**
  - Meat Grinder, Sword Ring
  - Arctic Gale, Arctic Ring
- **Incandescent Aura**
  - Sworn Strike, Sworn Flourish, Engagement Ring, Nexus Rush, Rousing Reception
  - Flame Strike, Flame Flourish, Smolder Ring, Heat Rush, Cardio Gain
- **Island Getaway**
  - Wave Strike, Wave Flourish, Tidal Ring, Breaker Rush, Flood Gain
  - Flutter Strike, Flutter Flourish, Glamour Gain
- **Killer Current**
  - Tidal Ring, Slippery Slope
  - Heaven Strike, Heaven Flourish
- **King Tide**
  - Wave Strike, Wave Flourish, Breaker Rush
  - Slippery Slope, Tidal Ring
  - Geyser Spout, High Surf, Ocean Swell
- **Nervous Wreck**
  - Sworn Strike, Sworn Flourish, Engagement Ring, Nexus Rush, Born Gain
  - Glamour Gain, Passion Rush, Rapture Ring
- **Post Haste** — Death Warrant, Defensive Posture, Phalanx Shot, Bottomless Drink, Happy Haze, Volcanic Strike, Volcanic Flourish, Flood Gain, Ionic Gain, Heinous Affront or Unseen Ire.
- **Premium Service**
  - Volcanic Strike, Volcanic Flourish
  - Heavy Metal, Trusty Shield, Security System
  - Grand Caldera, Molten Touch, Furnace Blast
- **Profuse Bleeding** — Vicious Strike or Vicious Flourish.
- **Rousing Reception** — Engagement Ring.
- **Rude Awakening**
  - Volcanic Strike, Volcanic Flourish
  - Solar Ring, Blinding Rush, Light Smite, Dazzling Display
- **Sanguinary Savor**
  - Vicious Strike, Vicious Flourish
  - Grisly Gain, Visceral Impact, Meat Grinder, Profuse Bleeding
  - Blood Spree, Grievous Blow, Mutual Destruction
- **Scalding Vapor**
  - Tidal Ring, Slippery Slope
  - Glowing Coal, Controlled Burn, Volcanic Crown
- **Second Wind** — Nimble Limbs, Racing Thoughts, Winner's Circle, Nitro Boost, Stutter Step, Hasty Retreat, Post Haste, Quick Buck, Mean Streak, Travel Deal or Success Rate, or while holding Metallic Droplet.
- **Seismic Hammer**
  - Volcanic Strike, Volcanic Flourish
  - Geyser Spout
- **Slippery Slope** — Wave Strike, Wave Flourish or Breaker Rush.
- **Smoldering Forge**
  - Flutter Strike, Flutter Flourish, Rapture Ring, Passion Rush, Glamour Gain
  - Furnace Blast, Anvil Ring, Smithy Rush
- **Success Rate** — Sea Star, Tidal Ring, Slippery Slope, Divine Vengeance, Double Strike, Shocking Loss, Extra Dose, Pressure Points, Vital Signs, Lethal Snare, Death Warrant, Killing Stroke, Shadow Pounce, Whispered Prayer, Grisly Gain, Visceral Impact, Mutual Destruction, Grievous Blow, Ripple Effect, Chain Reaction, Meat Grinder, Profuse Bleeding, Blood Spree, Killer Current, Ecstatic Obsession, Smoldering Forge or Sun Worshiper.
- **Sun Worshiper**
  - Sworn Strike, Sworn Flourish, Engagement Ring, Nexus Rush, Born Gain
  - Nova Strike, Nova Flourish, Solar Ring, Blinding Rush, Lucid Gain
- **Universal Donor**
  - Grisly Gain, Visceral Impact, Meat Grinder, Profuse Bleeding
  - Sworn Strike, Sworn Flourish, Engagement Ring, Nexus Rush, Born Gain
- **Warm Breeze**
  - Solar Ring, Blinding Rush, Light Smite, Dazzling Display
  - Hot Pot, Flash Fry, Volcanic Crown

## Experimental

***Warning: WIP, less tested, disabled by default***

### Hammer Upgrades

- **Dual Moonshot** (Staff) — No longer costs range and fuse to fire the extra projectile.
- **Reaper Knives → Hook Knives** (Dagger) — Reverted to its EA-launch implementation.
- **Hidden Knives** (Dagger) — Fires in a Spiral pattern around you (like Spiral Knives in EA-launch), with extra knives. Firing angle overridden by Sureshot Flurry if also held.
- **Enduring Coil** (Torch) — Special projectiles last +100% longer (double) rather than adding a flat +2 Sec., and applies to the regular special projectile as well.
- **Hidden Helix** (Torch) — Gain +2 extra projectiles instead of +1.
- **Rising Helix** (Torch) — Makes bonus damage increased to 50%.
- **Whirling Helix** (Torch) — Projectile speed bonus increased to 100%.

### Weapon Aspects

- **Aspect of Supay** (Umbral Flames) — Rush-boon damage bonus restored to EA levels.

### Keepsakes
- **Concave Stone** (Echo) — New Effect: Chance to copy your next Boon or Hammer instead.
- **Calling Card** (Zagreus) — Now rarifies all boons straight to Heroic.
- **Metallic Droplet** (Hermes) — Now keeps half its move/strike/cast speed boost once the timer runs out while held.
- **White Antler** (Artemis) — Keeps its effects as long as its held.
