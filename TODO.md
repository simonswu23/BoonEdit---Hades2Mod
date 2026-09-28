# TODO (temporary — delete when done)

Needs the vanilla game scripts (`Hades II/Content/Scripts`), so pick this up on the Windows machine.
The full investigation lives in MoreDuos' `TODO.md`; do both together.

## Tranquil Gain: 0.5s channel hold should scale with every channel-speed source

- [ ] `tranquil_gain_hold` (`src/boons/tranquil_gain.lua`) is a copy of MoreDuos' `channel_hold`
      (`src/reload.lua`). Once that helper is corrected against `DoWeaponCharge` (see MoreDuos
      `TODO.md`), apply the same fix here, so `HoldSeconds` (0.5s, `src/tuning.lua`) scales exactly as
      the Omega's own charge does — including base + Omega speed-ups like the Rapid Thrasher hammer.
- [ ] Check the same double-counting question here (`GetLuaWeaponSpeedMultiplier` ×
      `GlobalAttackSpecialSpeed`).


## Others
- redesign carnal pleasure
- redesign shocking loss, gated on lightning only -- and maybe rate limit it as well?
- cherished Heirloom: double check the double-dipping logic

- concave stone: gate to copy only your next boon / hammer reward
- metallic droplet: extra move speed bonuses only active while still held