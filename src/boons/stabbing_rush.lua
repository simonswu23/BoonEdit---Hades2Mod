---@meta _
---@diagnostic disable: lowercase-global

-- Stabbing Rush (Ares) drops a fixed three blades. Repeating the volley keeps them coming for as
-- long as the sprint lasts, and reuses vanilla's own modifier, sound and cap handling.

once('StabbingRushDuration', function()
	modutil.mod.Path.Wrap("StartAresSprintProjectile", function(base, weaponData, args, triggerArgs)
		if not stabbing_rush_active() then
			return base(weaponData, args, triggerArgs)
		end

		base(weaponData, args, triggerArgs)

		-- the whoosh belongs to the start of the sprint only; the blades keep their own drop sound
		local repeated = game.ShallowCopyTable(args)
		repeated.StartSound = nil

		-- Every blade carries `FizzleOldestProjectileCount = args.ProjectileCap`, so making one at the
		-- cap cancels the oldest -- and a fizzled blade never detonates. Vanilla's three never near
		-- its six, but a repeated volley clears it in a third of a second, so the cap is raised.
		repeated.ProjectileCap = mod.tuning.StabbingRush.ProjectileCap

		while stabbing_rush_sprinting() do
			base(weaponData, repeated, triggerArgs)
		end
	end)
end)


function stabbing_rush_active()
	return config.BoonChanges.StabbingRushDuration.Enabled and game.HeroHasTrait('AresSprintBoon')
end

-- SprintActive is cleared however the sprint ends, so the loop needs no end hook.
function stabbing_rush_sprinting()
	if not game.SessionMapState or not game.SessionMapState.SprintActive then return false end
	local hero = game.CurrentRun and game.CurrentRun.Hero
	return hero ~= nil and not hero.IsDead and game.CurrentRun.CurrentRoom ~= nil
end
