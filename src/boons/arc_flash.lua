---@meta _
---@diagnostic disable: lowercase-global


once('ArcFlashEveryBlitz', function()
	if config.BoonChanges.ArcFlash.Enabled then
		local arcFlash = game.TraitData.EchoExpirationBoon
		arcFlash.BoonEditBlitzDamageBonus = arcFlash.DamageEchoOmegaDamageBonus
		arcFlash.DamageEchoOmegaDamageBonus = nil
		arcFlash.StatLines = { 'BoonEditArcFlashStatDisplay' }

		for _, extract in ipairs(arcFlash.ExtractValues) do
			if extract.Key == 'DamageEchoOmegaDamageBonus' then
				extract.Key = 'BoonEditBlitzDamageBonus'
			end
		end
	end

	modutil.mod.Path.Wrap('DamageEchoTrigger', function(base, enemy, effectName, damageMultiplier, additiveDamageMultiplier, cooldown)
		if config.BoonChanges.ArcFlash.Enabled then
			local bonus = game.GetTotalHeroTraitValue('BoonEditBlitzDamageBonus', { IsMultiplier = true })
			additiveDamageMultiplier = (additiveDamageMultiplier or 1) * bonus
		end
		return base(enemy, effectName, damageMultiplier, additiveDamageMultiplier, cooldown)
	end)
end)
