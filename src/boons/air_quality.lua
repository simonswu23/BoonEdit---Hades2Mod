---@meta _
---@diagnostic disable: lowercase-global


-- Air Quality (Elemental legendary): the floor goes under the *base* damage, not the finished
-- figure, which vanilla clamps after multipliers.

once('AirQualityAdditiveFloor', function()
	if config.BoonChanges.AirQuality.Enabled then
		local airQuality = game.TraitData.ElementalDamageFloorBoon
		airQuality.BoonEditBaseDamageFloor = airQuality.ActivatedDamageFloor
		airQuality.ActivatedDamageFloor = nil
		airQuality.ExtractValues[1].Key = 'BoonEditBaseDamageFloor'
	end

	modutil.mod.Path.Wrap("CalculateBaseDamage", function(base, attacker, victim, triggerArgs)
		local damage = base(attacker, victim, triggerArgs)
		if not config.BoonChanges.AirQuality.Enabled then return damage end
		if attacker == nil or attacker ~= game.CurrentRun.Hero then return damage end

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
