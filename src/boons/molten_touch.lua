---@meta _
---@diagnostic disable: lowercase-global


-- Molten Touch (Hephaestus) also bites into Glow, for half of what it gets out of Armor -- a second
-- modifier entry, since vanilla's rides `HealthBufferDamageMultiplier` and is gated on the buffer alone.

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
