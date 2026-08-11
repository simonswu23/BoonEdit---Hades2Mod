---@meta _
---@diagnostic disable: lowercase-global

-- Sun Worshiper (Apollo x Hera): after the first foe is raised in an encounter, later slain foes may
-- rise too. The `SunWorshiperHitch` half is deleted rather than switched off -- making a summon
-- strikeable put it in `EnemyTeam`, and anything aimed at that group then found your own side. Its
-- config key stays, and stays off.

once('SunWorshiper', function()
	local raiseDead = game.TraitData.RaiseDeadBoon

	if config.BoonChanges.SunWorshiper.Enabled then
		raiseDead.BoonEditRepeatChance = mod.tuning.SunWorshiper.RepeatChance
		table.insert(raiseDead.StatLines, 'BoonEditRepeatRaiseStatDisplay')
		table.insert(raiseDead.ExtractValues, {
			Key = 'BoonEditRepeatChance',
			ExtractAs = 'Chance',
			Format = 'LuckModifiedPercent',
			HideSigns = true,
		})
	end

	modutil.mod.Path.Wrap("RaiseKilledEnemy", function(base, enemy, args)
		if sun_worshiper_should_repeat() then
			local previous = game.MapState.RaiseDeadCount
			game.MapState.RaiseDeadCount = nil
			base(enemy, args)
			if not game.MapState.RaiseDeadCount then
				game.MapState.RaiseDeadCount = previous
			end
			return
		end
		return base(enemy, args)
	end)
end)


function sun_worshiper_should_repeat()
	if not config.BoonChanges.SunWorshiper.Enabled then return false end
	if not game.MapState.RaiseDeadCount then return false end

	local raised = game.MapState.BoonEditSunWorshiperRepeats or 0
	if raised >= mod.tuning.SunWorshiper.MaxRepeats then return false end

	if not rolls(mod.tuning.SunWorshiper.RepeatChance) then return false end

	game.MapState.BoonEditSunWorshiperRepeats = raised + 1
	return true
end
