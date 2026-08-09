---@meta _
---@diagnostic disable: lowercase-global

-- Beach Ball (Apollo x Poseidon): the globe hits harder when it goes off.
--
-- **Written to the projectile, not to the boon.** `PoseidonSplashSprintBoon` carries a
-- `DamageMultiplier` of 1 and its stat line reads `MultiplyByBase` against
-- `ProjectileSprintBall.Damage`, so raising the projectile lifts both the damage and the figure the
-- tooltip shows. Multiplying the boon instead would have meant a fraction on the trait and the same
-- number on screen, arrived at less honestly.
--
-- The write itself happens in `sjson_PlayerProjectiles` -- projectile numbers are data rather than
-- Lua, so an sjson hook is the only place they can be reached.

-- Nil-safe, for the reason spelled out in `ionic_gain.lua`: Chalk keeps the .cfg it already wrote,
-- so a key added after that file exists is absent until it regenerates.
function beach_ball_rebalanced()
	local toggle = config.BoonChanges.BeachBallDamage
	return toggle ~= nil and toggle.Enabled == true
end
