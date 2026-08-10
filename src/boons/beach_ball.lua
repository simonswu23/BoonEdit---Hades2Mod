---@meta _
---@diagnostic disable: lowercase-global


-- Beach Ball (Apollo x Poseidon): the globe hits harder when it goes off. Written to the projectile
-- rather than the boon, so the tooltip figure rises with it -- and via sjson, since projectile numbers
-- are data rather than Lua.

function beach_ball_rebalanced()
	local toggle = config.BoonChanges.BeachBallDamage
	return toggle ~= nil and toggle.Enabled == true
end
