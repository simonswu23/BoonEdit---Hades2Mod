---@meta _
---@diagnostic disable: lowercase-global


local GLOW_EFFECT = 'DelayedKnockbackEffect'

once('MoltenTouchGlow', function()
	if not config.BoonChanges.MoltenTouch.Enabled then return end

	local moltenTouch = game.TraitData.AntiArmorBoon
	local tuning = mod.tuning.MoltenTouch

	moltenTouch.AddOutgoingDamageModifiersArray = {
		{
			ValidActiveEffects = { GLOW_EFFECT },
			ValidWeapons = game.WeaponSets.HeroPrimarySecondaryWeapons,
			ValidWeaponMultiplier = {
				BaseValue = tuning.GlowMultiplier,
				SourceIsMultiplier = true,
				AbsoluteStackValues = tuning.GlowStackValues,
			},
			ReportValues = { BoonEditReportedGlowMultiplier = 'ValidWeaponMultiplier' },
		},
	}

end)
