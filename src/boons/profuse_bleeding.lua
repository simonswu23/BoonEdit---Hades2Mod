---@meta _
---@diagnostic disable: lowercase-global

-- Profuse Bleeding (Ares): CheckAresBloodDrop already rolls to spill a Blood Drop; vanilla just
-- never points a trait at it. RarityLevels swaps to the standard 10/15/20/25% set.

mod.tuning.ProfuseBleeding = {
	SpillChance = 0.10,
}

once('ProfuseBleedingBloodSpill', function()
	if not config.BoonChanges.ProfuseBleedingBloodSpill.Enabled then return end

	local rend = game.TraitData.RendBloodDropBoon

	rend.RarityLevels = {
		Common = { Multiplier = 1.0 },
		Rare = { Multiplier = 1.5 },
		Epic = { Multiplier = 2.0 },
		Heroic = { Multiplier = 2.5 },
	}

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


if config.BoonChanges.ProfuseBleedingBloodSpill.Enabled then
	boon_text({
		Traits = {
			RendBloodDropBoon = {
				Description = 'Whenever a foe afflicted by {$Keywords.Rend} takes damage, they may spill {!Icons.BloodDropIcon}.',
			},
			RendBloodDropBoon_Tray = {
				Description = 'Whenever a foe afflicted by {$Keywords.Rend} takes damage, they may spill {!Icons.BloodDropWithCountIcon}.',
			},
		},
		StatLines = {
			BoonEditBloodSpillChanceStatDisplay = 'Spill Chance:',
		},
	})
end
