---@meta _
---@diagnostic disable: lowercase-global

-- Molten Touch (Hephaestus) also bites into Glow, for half of what it gets out of Armor. Vanilla's
-- bonus rides HealthBufferDamageMultiplier, which is gated on the buffer alone, so the Glow half is
-- a second modifier entry keyed on the status instead.

-- Glow's own effect name, as anvil_rush.lua uses.
local GLOW_EFFECT = 'DelayedKnockbackEffect'

once('MoltenTouchGlow', function()
	if not config.BoonChanges.MoltenTouchGlow.Enabled then return end

	local moltenTouch = game.TraitData.AntiArmorBoon
	local tuning = mod.tuning.MoltenTouch

	-- A second entry rather than another field on vanilla's, since ValidActiveEffects gates a whole
	-- modifier and vanilla's is already spoken for by the Armor test.
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

	-- No second stat line. Vanilla already shows the Armor figure, and the Glow bonus is a fixed
	-- fraction of it -- "half as much" in the description says it without a number the player then
	-- has to compare against the one above it.
end)
