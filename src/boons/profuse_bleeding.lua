---@meta _
---@diagnostic disable: lowercase-global


-- Profuse Bleeding (Ares): `CheckAresBloodDrop` already rolls to spill a Blood Drop; vanilla just never
-- points a trait at it.

once('ProfuseBleedingBloodSpill', function()
	if not config.BoonChanges.ProfuseBleeding.Enabled then return end

	local rend = game.TraitData.RendBloodDropBoon

	rend.RarityLevels = {
		Common = { Multiplier = 1.0 },
		Rare = { Multiplier = 1.5 },
		Epic = { Multiplier = 2.0 },
		Heroic = { Multiplier = 2.5 },
	}

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
