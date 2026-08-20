---@meta _
---@diagnostic disable: lowercase-global


function beach_ball_rebalanced()
	local toggle = config.BoonChanges.BeachBall
	return toggle ~= nil and toggle.Enabled == true
end
