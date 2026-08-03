---@meta _
---@diagnostic disable: lowercase-global

-- Sun Worshiper (Apollo x Hera): after the first foe is raised in an encounter, later slain foes
-- have a chance to rise too, and the servants are Hitched for as long as they last.

mod.tuning.SunWorshiper = {
	RepeatChance = 0.30,
}

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

	-- Refreshed on a loop rather than applied on the raise, since the effect expires on its own.
	if config.BoonChanges.SunWorshiperHitch.Enabled then
		raiseDead.SetupFunction = {
			Threaded = true,
			Name = _PLUGIN.guid .. '.SunWorshiperHitch',
			Args = {
				Interval = 0.3,
			},
		}
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
function sun_worshiper_should_repeat()
	if not config.BoonChanges.SunWorshiperRepeat.Enabled then return false end
	if not game.MapState.RaiseDeadCount then return false end
	return rolls(mod.tuning.SunWorshiper.RepeatChance)
end

function is_raised_summon(unit)
	if not is_allied_summon(unit) then return false end
	return not game.Contains(game.MapState.SpellSummons or {}, unit)
end

-- Runs with or without Obsessive Devotion.
function mod.SunWorshiperHitch(hero, args)
	local interval = (args and args.Interval) or 0.3

	while game.CurrentRun and game.CurrentRun.CurrentRoom and game.CurrentRun.Hero
		and not game.CurrentRun.Hero.IsDead and game.HeroHasTrait('RaiseDeadBoon') do

		for _, unit in pairs(game.ActiveEnemies or {}) do
			if unit and unit.ObjectId and not unit.IsDead and unit.ActiveEffects
				and is_raised_summon(unit) then
				apply_hitch(unit)
			end
		end

		game.wait(interval, game.RoomThreadName)
	end
end


if config.BoonChanges.SunWorshiperRepeat.Enabled or config.BoonChanges.SunWorshiperHitch.Enabled then
	local hitched = ''
	if config.BoonChanges.SunWorshiperHitch.Enabled then
		hitched = ' with {$Keywords.Link}'
	end

	local repeated = ''
	if config.BoonChanges.SunWorshiperRepeat.Enabled then
		repeated = '; later slain foes may as well'
	end

	boon_text({
		Traits = {
			RaiseDeadBoon = {
				Description = 'In each {$Keywords.EncounterAlt}, the first foe you slay returns to fight for you'
					.. hitched .. repeated .. '.',
			},
		},
	})
end

if config.BoonChanges.SunWorshiperRepeat.Enabled then
	boon_text({
		StatLines = {
			BoonEditRepeatRaiseStatDisplay = { Name = 'Repeat Revival Chance:', Index = 2 },
		},
	})
end
