---@meta _
---@diagnostic disable: lowercase-global

-- Profuse Bleeding (Ares): CheckAresBloodDrop already rolls to spill a Blood Drop; vanilla just
-- never points a trait at it. RarityLevels swaps to the standard set, and its place in the offer
-- chain is set in `requirements.lua`.

once('ProfuseBleedingBloodSpill', function()
	if not config.BoonChanges.ProfuseBleedingBloodSpill.Enabled then return end

	local rend = game.TraitData.RendBloodDropBoon

	rend.RarityLevels = {
		Common = { Multiplier = 1.0 },
		Rare = { Multiplier = 1.5 },
		Epic = { Multiplier = 2.0 },
		Heroic = { Multiplier = 2.5 },
	}

	-- Vanilla counts this boon as a reason to keep the Plasma counter on the HUD
	-- (`CheckBloodDropDisplay`) but never gives it the hook that puts one there -- only Ares' other
	-- two Plasma boons carry that. Harmless while it dropped nothing; now that it does, it needs it.
	rend.AcquireFunctionName = 'SetupBloodDropDisplay'

	rend.BloodDropOrRendFallingBladeArgs = nil
	rend.OnEnemyDamagedAction = {
		FunctionName = 'CheckAresBloodDrop',
		Args = {
			Chance = { BaseValue = mod.tuning.ProfuseBleeding.SpillChance },
			RequiredEffect = 'AresStatus',
			Name = 'BloodDrop',
			ReportValues = { ReportedDropChance = 'Chance' },
		},
	}

	rend.StatLines = { 'BoonEditBloodSpillChanceStatDisplay' }
	rend.ExtractValues = {
		{
			Key = 'ReportedDropChance',
			ExtractAs = 'TooltipDropChance',
			Format = 'LuckModifiedPercent',
			HideSigns = true,
		},
	}
end)
