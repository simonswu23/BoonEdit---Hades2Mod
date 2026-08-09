# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Every change below can be switched off independently in
`ReturnOfModding/config/SWu-BoonEdits.cfg`, where each one is described in in-game terms.

### Aphrodite

- **Glamour Gain** — New Effect: Every 1 second, you inflict Weak on nearby foes. Gain mana for each one.

### Ares

- **Profuse Bleeding** — New(?) Effect: foes with wounds have a small chance to drop plasma after taking damage.
- **Stabbing Rush** — Falling blades keep dropping for the entire duration of your sprint.

### Demeter

- **Local Climate** — Additionally, buff your regular cast damage as well.
- **Tranquil Gain** — New Effect: when channeling your Omega moves for 0.5 seconds, rapidly restore mana.

### Hades

- **Unseen Ire** — Cooldown reduced to 30 seconds.

### Hephaestus

- **Anvil Ring** — Additionally, inflicts Glow in exchange for a slight decrease in power.
- **Molten Touch** — Additionally deals bonus damage to foes afflicted with Glow.
- **Smithy Rush** — New Effect: when you start and stop dashing, a hammer strikes the area, dealing damage and inflicting Glow.

### Hera

- **Rousing Reception** — Additionally, inflicts Hitch on the foes it damages. New dependency on Engagement Ring.

### Hermes

- **Hard Target → Post Haste** — Replaced: reduces boon effect cooldowns by 20%/2%5/30%/35%.

### Hestia

- **Cardio Gain** — Additionally, restores mana when sprinting.

### Medea

- **Harm for the Afflicted** — Damage triggers on every new curse inflicted on each individual foe.

### Poseidon

- **King Tide** — Adjusted requirements.
- **Breaker Rush** — New Effect: when you start and stop dashing, deal damage with a watery splash that knocks back foes and inflicts Froth.

### Zeus

- **Ionic Gain** — Additionally, standing near the Font slowly restores Magick.
- **Air Quality** — Now floors your base damage, instead of flooring the finished hit after all multipliers.

### Duo Boons

- **Arterial Spray** (Poseidon × Ares) — The second wave's strike chance is improved to 100%, in exchange for its power reduced to 30%.
- **Beach Ball** (Apollo × Poseidon) — Is now considered a Splash Boon, and max damage increased to 400.
- **Brave Face** (Hephaestus × Hera) — Resists up to 50% of any damage rather than 30%, and each point resisted costs 5 Magick instead of 10.
- **Chain Reaction** (Hestia × Hephaestus) — New Effect: Boon effect cooldowns have a 30% chance of being skipped.
- **Carnal Pleasure** (Aphrodite × Ares) — New Effect: Your Heartthrobs are larger and deal +50 damage, plus extra for any Plasma you hold. Picking up Plasma counts as 10 magic towards Heartbreaker.
- **Cherished Heirloom** (Demeter × Hera) — Additionally, keepsake effects don't expire tonight. Equip an extra one on pickup.
- **Cryo Pounder** (Demeter × Hephaestus) — Additionally, frozen foes also take more damage from Hephaestus' hammer strikes.
- **Nervous Wreck** (Aphrodite x Hera) — Swapped: same effect as before (as Aphrodite's legendary), but kept Ecstatic Obession's old requirements.
- **Glorious Disaster** (Apollo × Zeus) — No longer needs the extra channeled Magick, and bolts hit for 50 rather than 20 damage. Loosened offering requirements.
- **Hostile Environment** (Demeter × Ares) — Additionally, your regular cast also follows you around.
- **Killer Current** (Zeus × Poseidon) — New Effect: Froth-afflicted foes have a 30% chance of being struck by lightning after taking damage.
- **Love Handles → Smoldering Forge** (Aphrodite × Hephaestus) — Replaced: damaging a foe with Glow has a 20% chance to create a Heartthrob.
- **Natural Selection** (Demeter × Poseidon) — New Effect: on pickup, gain 3 triple-poms. Every 8 encounters, gain another one.
- **Ripple Effect** (Hera × Poseidon) — New Effect: the bonus effects your Omega Moves trigger have a 50% chance to occur again, up to 4 times, each with diminishing chances (50% / 25% / 12.5% / 6.25%). Includes Ocean Swell, Fine Line, Controlled Burn, Cut Above, and Explosive Intent.
- **Seismic Servo → Seismic Hammer** (Hephaestus × Poseidon) — Replaced: your Cast erupts into your Omega Cast after being struck by a Hephaestus explosion. Also reduces the cooldowns of Volcanic Strike, Volcanic Flourish, and Land Mine flatly by 1 second.
- **Sun Worshiper** (Apollo × Hera) — Additional foes have a 30% chance to also be summoned in combat after being slain, up to 10 extra per encounter.
- **Scalding Vapor** (Hestia × Poseidon) — Additionally, halves the cooldown for Froth Activation.
- **Thermal Dynamics** (Hestia × Zeus) — Additionally triggers on every lightning effect from Zeus rather than only Blitz.

### Legendary Boons

- **Pandemonium** (Chaos) — New Legendary: puts all gods in your pool tonight, removes all boon requirements, increases boon offering chances, and allows core boons to be stacked.
- **All Together** (Hera) — Gain an additional essence of each type upon pickup.
- **Fire Away → Burning Meteor** (Hestia) — Replaced: Fireball effects from Hestia are 50% larger and stronger, and inflict Scorch equal to the damage they deal.
- **Paid Dues → Second Wind** (Hermes) — Replaced: You can cast and dash an additional time.
- **Premium Service** (Hephaestus) — Additionally, all weapon upgrades increase in rank tonight, and gain an Anvil of Fates on pickup.
- **Shocking Loss** (Zeus) — If this activates against a guardian, they take 9999 damage instead.
- **Winter Harvest** (Demeter) — Executes from 15% rather than 10%, and sums boss HP across all phases for calculation. Can now skip more boss phases (Prometheus, Zagreus, Typhon).
- **Nervous Wreck → Obsessive Devotion** (Aphrodite × Hera) — Replaced: when you inflict Weak, you have a 30% chance to inflict Charm for 5 seconds instead. Charming Guardians interrupts their attack pattern (can only be applied every 5 seconds). Additionally, deal 10% more damage for each nearby character fighting for you, up to 50%.

### Other

- **Anvil of Fates** — Instead of random chance, choose from up to 3 hammer upgrades to sacrifice / gain.
- **Glow** — Now stacks: each further application makes a foe take 5% more damage, up to 35%. Each stack expires independently.
