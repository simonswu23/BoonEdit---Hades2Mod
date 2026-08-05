---@meta _
---@diagnostic disable: lowercase-global

-- Love Handles (Aphrodite x Hephaestus) becomes "Smoldering Forge": no Heartthrobs from volcanic
-- blasts, and instead your strikes hit much harder into Glowing foes you are standing close to.

-- Glow's own effect name, as anvil_rush.lua uses.
local GLOW_EFFECT = 'DelayedKnockbackEffect'

once('SmolderingForge', function()
	if not config.BoonChanges.SmolderingForge.Enabled then return end

	local forge = game.TraitData.SlamManaBurstBoon
	local tuning = mod.tuning.SmolderingForge

	forge.OnProjectileCreationFunction = nil

	-- Unscoped by weapon on purpose: everything you deal counts, not only Attack and Special. What
	-- limits it is the proximity test itself, which needs a distance to measure -- a source the
	-- game hands no DistanceToAttackerSquared for is simply not covered.
	forge.AddOutgoingDamageModifiers = {
		ValidActiveEffects = { GLOW_EFFECT },
		ProximityThreshold = tuning.Radius,
		-- Wide Appeal turns every foe into a close one, and this reads as close range like any
		-- other Aphrodite bonus, so it honours that too.
		ProximityThresholdExclusionBoon = 'AllCloseBoon',
		ProximityMultiplier = tuning.DamageMultiplier,
		ReportValues = { BoonEditReportedForgeMultiplier = 'ProximityMultiplier' },
	}

	forge.FlavorText = 'BoonEditSmolderingForgeFlavorText'
	forge.StatLines = { 'BoonEditSmolderingForgeStatDisplay' }
	forge.ExtractValues = {
		{
			Key = 'BoonEditReportedForgeMultiplier',
			ExtractAs = 'DamageIncrease',
			Format = 'PercentDelta',
		},
	}
end)
