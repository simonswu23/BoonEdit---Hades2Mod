---@meta _
---@diagnostic disable: lowercase-global


once('StabbingRushDuration', function()
	modutil.mod.Path.Wrap("StartAresSprintProjectile", function(base, weaponData, args, triggerArgs)
		if not stabbing_rush_active() then
			return base(weaponData, args, triggerArgs)
		end

		base(weaponData, args, triggerArgs)

		local repeated = game.ShallowCopyTable(args)
		repeated.StartSound = nil

		repeated.ProjectileCap = mod.tuning.StabbingRush.ProjectileCap

		while stabbing_rush_sprinting() do
			base(weaponData, repeated, triggerArgs)
		end
	end)
end)


function stabbing_rush_active()
	return config.BoonChanges.StabbingRush.Enabled and game.HeroHasTrait('AresSprintBoon')
end

function stabbing_rush_sprinting()
	if not game.SessionMapState or not game.SessionMapState.SprintActive then return false end
	local hero = game.CurrentRun and game.CurrentRun.Hero
	return hero ~= nil and not hero.IsDead and game.CurrentRun.CurrentRoom ~= nil
end
