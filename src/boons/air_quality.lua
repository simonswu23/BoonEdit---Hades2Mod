---@meta _
---@diagnostic disable: lowercase-global

-- Air Quality (Elemental legendary): the floor covers only the flat bonus damage from other boons,
-- so Crit and Double Damage still apply on top.

once('AirQualityAdditiveFloor', function()
	if config.BoonChanges.AirQualityAdditiveFloor.Enabled then
		-- renamed so the game's own floor check no longer finds it
		local airQuality = game.TraitData.ElementalDamageFloorBoon
		airQuality.BoonEditAdditiveDamageFloor = airQuality.ActivatedDamageFloor
		airQuality.ActivatedDamageFloor = nil
		airQuality.ExtractValues[1].Key = 'BoonEditAdditiveDamageFloor'
	end

	modutil.mod.Path.Wrap("CalculateDamageAdditions", function(base, attacker, victim, weaponData, triggerArgs)
		local additive = base(attacker, victim, weaponData, triggerArgs)
		if not config.BoonChanges.AirQualityAdditiveFloor.Enabled then return additive end
		if attacker == nil or attacker ~= game.CurrentRun.Hero then return additive end

		local sourceEffectData = triggerArgs.EffectName and game.EffectData[triggerArgs.EffectName]
		if sourceEffectData and sourceEffectData.BlockDamageFloor then return additive end

		local airQuality = game.GetHeroTrait('ElementalDamageFloorBoon')
		local floor = airQuality and airQuality.BoonEditAdditiveDamageFloor
		if not floor then return additive end

		if airQuality.ActivationRequirements and not game.IsGameStateEligible(airQuality, airQuality.ActivationRequirements) then
			return additive
		end

		if additive < floor then
			return floor
		end
		return additive
	end)
end)


if config.BoonChanges.AirQualityAdditiveFloor.Enabled then
	boon_text({
		Traits = {
			ElementalDamageFloorBoon = {
				Description = 'While you have at least {$TraitData.ElementalDamageFloorBoon.ActivationRequirements.1.Value}{!Icons.CurseAir}, the bonus damage from your other boons is never less than the limit.',
			},
		},
	})
end
