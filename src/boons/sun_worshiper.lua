---@meta _
---@diagnostic disable: lowercase-global

-- Sun Worshiper (Apollo x Hera): after the first foe is raised in an encounter, later slain foes
-- have a chance to rise too.
--
-- **The `SunWorshiperHitch` half is gone.** It tried to make your summons behave as foes do where
-- Hitch is concerned -- strikeable, Hitchable, sharing damage along the rope. Melinoe's blows did
-- reach them, but nothing ever succeeded in Hitching one, so the rope half never happened.
--
-- It is deleted rather than left switched off because of what it did on the way: to make a summon
-- strikeable it joined `EnemyTeam` and set `TriggersOnDamageEffects`, and anything aimed at that
-- group then found your own side. Glamour Gain pulses at `DestinationName = 'EnemyTeam'`, so it was
-- inflicting Weak on your summons. The config key stays, and stays off, so nothing reading it breaks.
once('SunWorshiper', function()
	local raiseDead = game.TraitData.RaiseDeadBoon

	-- appended, so the vanilla servant-damage line stays first
	if config.BoonChanges.SunWorshiperRepeat.Enabled then
		raiseDead.BoonEditRepeatChance = mod.tuning.SunWorshiper.RepeatChance
		table.insert(raiseDead.StatLines, 'BoonEditRepeatRaiseStatDisplay')
		table.insert(raiseDead.ExtractValues, {
			Key = 'BoonEditRepeatChance',
			ExtractAs = 'Chance',
			Format = 'LuckModifiedPercent',
			HideSigns = true,
		})
	end

	-- Only the first kill of an encounter rises, gated on RaiseDeadCount. Clearing it lets more through.
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


-- The first raise is vanilla, so only roll once the counter is already set.
--
-- Capped per encounter. Clearing `RaiseDeadCount` is what lets a second servant rise at all, and
-- with it cleared there is nothing left counting them -- so the tally is kept here instead. On
-- `MapState`, which is the encounter's own table, so it empties itself between fights.
--
-- Counted on the roll succeeding rather than on the raise landing: `RaiseKilledEnemy` is what this
-- answers, and it is called for exactly one servant each time it passes.
function sun_worshiper_should_repeat()
	if not config.BoonChanges.SunWorshiperRepeat.Enabled then return false end
	if not game.MapState.RaiseDeadCount then return false end

	local raised = game.MapState.BoonEditSunWorshiperRepeats or 0
	if raised >= mod.tuning.SunWorshiper.MaxRepeats then return false end

	if not rolls(mod.tuning.SunWorshiper.RepeatChance) then return false end

	game.MapState.BoonEditSunWorshiperRepeats = raised + 1
	return true
end
