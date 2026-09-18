# Reference code: cut and changed traits

Implementations lifted out of the build archive, for mining. Two kinds of file:

- `<Name>.lua` — a **cut** trait, taken from the last build that had it.
- `<Name>.original.lua` — a trait that still exists but **changed**, taken from the
  earliest build that had it, so you can read what it used to do.

Each file's header names the build and the source file it came from.

A trait that merely moved between data files is not listed as cut — presence is
checked against every `TraitData*.lua` in the current build, not just its own.


## Hammer upgrades

Identified by `InheritFrom = { "WeaponTrait", "<Weapon>HammerTrait" }`.

| Weapon | Live now | Cut | Changed |
| --- | ---: | ---: | ---: |
| Staff | 16 | 2 | 14 |
| Dagger | 15 | 2 | 12 |
| Torch | 13 | 4 | 11 |
| Axe | 14 | 1 | 10 |
| Lob | 17 | 1 | 13 |
| Suit | 17 | 1 | 17 |

**Staff cut:** `StaffReserveManaBoostTrait`, `StaffSlowExTrait`

**Dagger cut:** `DaggerRepeatStrikeTrait`, `DaggerSpecialRangeTrait`

**Torch cut:** `TorchConsecutiveStrikeTrait`, `TorchHomingAttackTrait`, `TorchOrbitDistanceTrait`, `TorchSpinAttackAltTrait`

**Axe cut:** `AxeComboSwingTrait`

**Lob cut:** `LobSpecialAspect`

**Suit cut:** `SuitComboThresholdTrait`


## Boons

| File | Live now | Cut | Changed |
| --- | ---: | ---: | ---: |
| Aphrodite | 13 | 0 | 12 |
| Apollo | 13 | 1 | 11 |
| Ares | 14 | 0 | 12 |
| Artemis | 9 | 0 | 9 |
| Athena | 8 | 0 | 7 |
| Chaos | 37 | 2 | 37 |
| Demeter | 13 | 0 | 12 |
| Dionysus | 8 | 1 | 7 |
| Hephaestus | 13 | 2 | 13 |
| Hera | 13 | 4 | 13 |
| Hermes | 12 | 3 | 12 |
| Hestia | 13 | 1 | 13 |
| Poseidon | 13 | 2 | 13 |
| Zeus | 13 | 1 | 13 |
| Duo | 37 | 9 | 33 |
| Aspect | 24 | 2 | 23 |

**Apollo cut:** `ApolloMissStrikeBoon`

**Chaos cut:** `ChaosSpecialBaseBlessing`, `ChaosWeaponBaseBlessing`

**Dionysus cut:** `RandomDuoBoon`

**Hephaestus cut:** `ChargeCounterBoon`, `HeavyArmorExpired`

**Hera cut:** `FullManaExBoostBoon`, `HeraManaShieldBoon`, `ReserveReductionBoon`, `SwapBonusBoon`

**Hermes cut:** `BonusDashBoon`, `HexCooldownBuffBoon`, `PerfectDodgeSlowBoon`

**Hestia cut:** `SacrificeBoon`

**Poseidon cut:** `MinorLootBoon`, `SlamExplosionBoon`

**Zeus cut:** `ZeusExCastBoon`

**Duo cut:** `BurnOmegaBoon`, `CastRampBoon`, `DoubleBurnBoon`, `EchoAllBoon`, `EmptySlotDamageBoon`, `FirstHitHealBoon`, `MassiveAoEIncrease`, `MaximumShareBoon`, `ShadeMercFireballBoon`

**Aspect cut:** `LobSpecialAspect`, `TorchSingleStrikeAspect`


## Rebuilding

    python harvest.py    # rewrites this directory from scratch

`harvest.py` lives beside the archive tooling. It reads every build in `manifests.txt`
order, so adding a build widens the search automatically.
