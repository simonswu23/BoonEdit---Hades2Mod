---@meta _
---@diagnostic disable: lowercase-global

-- Breaker Rush joins Tidal Ring and Slippery Slope as a Froth boon, so it can earn Steam and Killer
-- Current. King Tide's second and third sets are regrouped around Geyser Spout and Froth, and
-- Hydraulic Might and Flood Gain no longer count towards it.

once('PoseidonFrothRequirements', function()
	if not config.BoonChanges.PoseidonFrothRequirements.Enabled then return end

	-- edited in place: Steam and Killer Current read this same list, and both should be offered
	table.insert(game.LinkedTraitData.PoseidonKnockbackAmplifyTraits, 'PoseidonSprintBoon')

	game.TraitRequirements.AmplifyConeBoon = {
		OneFromEachSet = {
			game.LinkedTraitData.PoseidonSplashTraits,
			{
				'PoseidonExCastBoon',          -- Geyser Spout
				'FocusDamageShaveBoon',        -- High Surf
				'OmegaPoseidonProjectileBoon', -- Ocean Swell
			},
			{
				'PoseidonCastBoon',   -- Tidal Ring
				'PoseidonStatusBoon', -- Slippery Slope
				'PoseidonSprintBoon', -- Breaker Rush
			},
		},
	}
end)
