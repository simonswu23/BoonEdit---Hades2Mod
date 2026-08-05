# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Every change below can be switched off independently in
`ReturnOfModding/config/SWu-BoonEdits.cfg`, where each one is described in in-game terms.

### Aphrodite

- **Glamour Gain** — New Effect: you pulse every 1 second to inflict Weak on nearby foes. Gain mana for each foe weakened.

### Ares

- **Profuse Bleeding** — Reverted: foes with wounds have a small chance to drop plasma after taking damage.
- **Stabbing Rush** — Falling blades keep dropping for the whole duration of your sprint, rather than a fixed three at the start.

### Demeter

- **Local Climate** — Additionally, buff your regular cast as well.
- **Tranquil Gain** — New Effect: when channeling your Omega moves for 0.5 seconds, rapidly restore mana.

### Hades

- **Unseen Ire** — Cooldown reduced to 30 seconds.

### Hephaestus

- **Anvil Ring** — Additionally inflicts Glow in exchange for a slight decrease in power.
- **Molten Touch** — Additionally deals bonus damage to foes afflicted with Glow.
- **Smithy Rush** — New Effect: when you start and stop dashing, a hammer strikes the area, dealing damage and inflicting Glow.

### Hera

- **Rousing Reception** — Additionally, inflicts Hitch on the foes it damages.

### Hermes

- **Hard Target → Post Haste** — Replaced: reduces boon effect cooldowns by 20%/2%5/30%/35%.

### Hestia

- **Cardio Gain** — also restores mana when sprinting.

### Medea

- **Harm for the Afflicted** — Damage triggers on every new curse inflicted on a foe. The interval is reduced from 1 second to 0.3, and is now counted separately for each foe and each curse, rather than being shared across the encounter.

### Poseidon

- **Breaker Rush** — New Effect: when you start and stop dashing, deal damage with a watery splash that knocks back foes and inflicts Froth.

### Zeus

- **Air Quality** — now floors your base damage, instead of flooring the finished hit after all multipliers.

### Duo Boons

- **Arterial Spray** (Poseidon × Ares) — The second wave's strike chance is improved to 100%, in exchange for its power reduced to 30%.
- **Brave Face** (Hephaestus × Hera) — Resists up to 50% of any damage rather than 30%, and each point resisted costs 5 Magick instead of 10.
- **Chain Reaction** (Hestia × Hephaestus) — New Effect: Boon effect cooldowns have a 30% chance of being skipped.
- **Carnal Pleasure** (Aphrodite × Ares) — Additionally, collecting Plasma restores 1 health.
- **Cherished Heirloom** (Demeter × Hera) — Additionally, keepsake effects don't expire tonight. Equip an extra one on pickup.
- **Cryo Pounder** (Demeter × Hephaestus) — Additionally, frozen foes also take more damage from Hephaestus' hammer strikes.
- **Ecstatic Obsession → Obsessive Devotion** (Aphrodite × Hera) — Replaced: Weak afflicted foes are also Hitched; deal 10% more damage for each Hitched target at a time, up to 100%.
- **Hostile Environment** (Demeter × Ares) — Additionally, your regular cast also follows you around.
- **Killer Current** (Zeus × Poseidon) — New Effect: Froth-afflicted foes have a 30% chance of being struck by lightning after taking damage.
- **Love Handles → Smoldering Forge** (Aphrodite × Hephaestus) — Replaced: you deal 50% more damage to nearby foes afflicted with Glow.
- **Natural Selection** (Demeter × Poseidon) — New Effect: on pickup, gain 3 triple-poms. Every 10 encounters, gain another one.
- **Ripple Effect** (Hera × Poseidon) — New Effect: the bonus effects your Omega Moves trigger have a 50% chance to occur again, and each repeat rolls again at half the chance — 50% / 25% / 12.5% / 6.25%, up to 4 extra times. Covers Ocean Swell, Fine Line, Controlled Burn, Cut Above and Explosive Intent.
- **Seismic Servo → Seismic Hammer** (Hephaestus × Poseidon) — Replaced: Your cast erupts into your omega cast after being struck by a Hephaestus explosion.
- **Sun Worshiper** (Apollo × Hera) — Additional foes have a 30% chance to also be summoned in combat after being slain. Summons are Hitched.
- **Scalding Vapor** (Hestia × Poseidon) — Additionally halves the cooldown for Froth Activation, and Steam itself can now proc Froth without consuming the curse.
- **Thermal Dynamics** (Hestia × Zeus) — Now applies to every lightning effect from Zeus rather than only Blitz, and the Scorch inflicted is 60% of the damage.

### Legendary Boons

- **All Together** (Hera) — Gain an additional essence of each type upon pickup.
- **Fire Away → Burning Meteor** (Hestia) — Replaced: Fireball effects from Hestia are 50% larger and stronger, and inflict Scorch equal to the damage they deal.
- **Paid Dues → Second Wind** (Hermes) — Replaced: You can cast and dash an additional time.
- **Premium Service** (Hephaestus) — Additionally, all weapon upgrades increase in rank tonight, and gain an Anvil of Fates on pickup.
- **Shocking Loss** (Zeus) — If this activates against a guardian, they take 999 damage instead.
- **Winter Harvest** (Demeter) — Executes from 15% rather than 10%, and sums boss HP across all phases for calculation. Can now skip more boss phases (Prometheus, Zagreus, Typhon).

### Other

- **Anvil of Fates** — Instead of random chance, choose from up to 3 hammer upgrades to sacrifice / gain.
- **Glow** — Now stacks: each further application makes a foe take 5% more damage, up to 35%. Each stack expires independently.
