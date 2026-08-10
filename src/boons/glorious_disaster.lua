---@meta _
---@diagnostic disable: lowercase-global

-- Glorious Disaster (Apollo x Zeus) also fires from the Aspect of Charon's axe. The second stage is
-- normally decided when the Cast is created, so one the axe detonates was laid unmarked -- it is marked
-- at detonation instead, through vanilla's own `OnEarlyCastDetonation`.

once('GloriousDisasterAxe', function()
	if not config.BoonChanges.GloriousDisasterAxe.Enabled then return end

	game.TraitData.ApolloSecondStageCastBoon.OnEarlyCastDetonation = {
		FunctionName = _PLUGIN.guid .. '.GloriousDisasterEarlyDetonation',
	}
end)


function glorious_disaster_supercharged()
	local toggle = config.BoonChanges.GloriousDisasterAlwaysSupercharged
	return toggle ~= nil and toggle.Enabled == true
end


once('GloriousDisasterAlwaysSupercharged', function()
	if not glorious_disaster_supercharged() then return end

	modutil.mod.Path.Wrap("CheckArmedApolloCast", function(base, triggerArgs, functionArgs)
		if game.HeroHasTrait('ApolloSecondStageCastBoon') and game.HeroHasTrait('ApolloExCastBoon') then
			game.SessionMapState.SuperchargeCast = true
		end
		return base(triggerArgs, functionArgs)
	end)

	local disaster = game.TraitData.ApolloSecondStageCastBoon

	local arm = disaster.WeaponDataOverride and disaster.WeaponDataOverride.WeaponCastArm
	if arm and arm.ChargeWeaponStages then
		for index = #arm.ChargeWeaponStages, 2, -1 do
			table.remove(arm.ChargeWeaponStages, index)
		end
	end

	disaster.ChargeStageModifiers = nil
end)


---@diagnostic disable-next-line: unused-local
function mod.GloriousDisasterEarlyDetonation(projectileId, _args)
	if not config.BoonChanges.GloriousDisasterAxe.Enabled then return end

	if not game.HeroHasTrait('ApolloExCastBoon') then return end

	local marked = game.SessionMapState and game.SessionMapState.ValidSuperchargeCastIds
	if marked and projectileId then
		marked[projectileId] = true
	end
end
