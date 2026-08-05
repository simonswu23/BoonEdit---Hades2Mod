---@meta _
---@diagnostic disable: lowercase-global

-- Air Quality (Elemental legendary): the floor is put under the *base* damage rather than under the
-- finished figure. Vanilla clamps the total at the very end, after multipliers, Crit and Double
-- Damage -- so the floor was the most those could ever be worth on a weak hit. Held under the base
-- instead, everything still multiplies it, and the flat additions from other boons land on top.

once('AirQualityAdditiveFloor', function()
	if config.BoonChanges.AirQualityAdditiveFloor.Enabled then
		-- renamed so the game's own end-of-pipeline check no longer finds it
		local airQuality = game.TraitData.ElementalDamageFloorBoon
		airQuality.BoonEditBaseDamageFloor = airQuality.ActivatedDamageFloor
		airQuality.ActivatedDamageFloor = nil
		airQuality.ExtractValues[1].Key = 'BoonEditBaseDamageFloor'
	end

	modutil.mod.Path.Wrap("CalculateBaseDamage", function(base, attacker, victim, triggerArgs)
		local damage = base(attacker, victim, triggerArgs)
		if not config.BoonChanges.AirQualityAdditiveFloor.Enabled then return damage end
		if attacker == nil or attacker ~= game.CurrentRun.Hero then return damage end

		-- a hit that was never going to land is not raised into one
		if type(damage) ~= 'number' or damage <= 0 then return damage end

		local sourceEffectData = triggerArgs.EffectName and game.EffectData[triggerArgs.EffectName]
		if sourceEffectData and sourceEffectData.BlockDamageFloor then return damage end

		local airQuality = game.GetHeroTrait('ElementalDamageFloorBoon')
		local floor = airQuality and airQuality.BoonEditBaseDamageFloor
		if not floor then return damage end

		if airQuality.ActivationRequirements and not game.IsGameStateEligible(airQuality, airQuality.ActivationRequirements) then
			return damage
		end

		if damage < floor then
			return floor
		end
		return damage
	end)
end)


if config.BoonChanges.AirQualityAdditiveFloor.Enabled then
	boon_text({
		Traits = {
			ElementalDamageFloorBoon = {
				Description = 'While you have at least {$TraitData.ElementalDamageFloorBoon.ActivationRequirements.1.Value}{!Icons.CurseAir}, your base damage is never less than the limit.',
			},
		},
	})
end
