---@meta _
---@diagnostic disable: lowercase-global


-- Glamour Gain (Aphrodite) becomes a pulse: it inflicts Weak on everything nearby once every Weak
-- duration and restores Magick per foe caught.

once('GlamourGainPulse', function()
	if not config.BoonChanges.GlamourGain.Enabled then return end

	local glamour = game.TraitData.AphroditeManaBoon

	glamour.SetupFunction.Name = _PLUGIN.guid .. '.GlamourGainPulse'

	glamour.SetupFunction.Args.Interval = game.EffectData.WeakEffect.EffectData.Duration

	glamour.SetupFunction.Args.ActiveFx = nil
	glamour.SetupFunction.Args.ManaRegenStartFx = nil

	glamour.StatLines = { 'BoonEditGlamourManaStatDisplay' }
end)


local GLAMOUR_PULSE_FX = 'AphroditeDashNova'

local GLAMOUR_UNLIMITED_RANGE = 3000

function glamour_pulse_active()
	local room = game.CurrentRun.CurrentRoom
	if game.IsCombatEncounterActive(game.CurrentRun) then return true end
	if not room.Encounter then return true end
	if room.Encounter.DelayedStart and room.Encounter.StartTime then return true end
	return not game.IsEmpty(game.MapState.AggroedUnits)
end

function mod.GlamourGainPulse(hero, args)
	local interval = (args and args.Interval) or 1

	while game.CurrentRun and game.CurrentRun.CurrentRoom and game.CurrentRun.Hero
		and not game.CurrentRun.Hero.IsDead and game.HeroHasTrait('AphroditeManaBoon') do

		if glamour_pulse_active() then
			local range = args.Range
			if game.HeroHasTrait(args.ProximityThresholdExclusionBoon) then
				range = GLAMOUR_UNLIMITED_RANGE
			end

			local nearby = game.GetClosestIds({
				Id = game.CurrentRun.Hero.ObjectId,
				DestinationName = 'EnemyTeam',
				IgnoreInvulnerable = true,
				StopsProjectiles = true,
				IgnoreHomingIneligible = true,
				IgnoreSelf = true,
				Distance = range,
				PreciseCollision = true,
			})

			local struck = 0
			for _, id in pairs(nearby) do
				local enemy = game.ActiveEnemies[id]
				if enemy and not enemy.IsDead and not enemy.SkipModifiers then
					game.ApplyEffect({
						Id = game.CurrentRun.Hero.ObjectId,
						DestinationId = enemy.ObjectId,
						EffectName = args.EffectName,
						DataProperties = game.EffectData[args.EffectName].EffectData,
					})
					struck = struck + 1
				end
			end

			if struck > 0 then
				game.CreateAnimation({
					Name = GLAMOUR_PULSE_FX,
					DestinationId = game.CurrentRun.Hero.ObjectId,
					ScaleRadius = args.Range,
				})

				game.ManaDelta(args.ManaRegen * struck)
			end
		end

		game.wait(interval, game.RoomThreadName)
	end
end
