---@meta _
---@diagnostic disable: lowercase-global

-- Profuse Bleeding (Ares): CheckAresBloodDrop already rolls to spill a Blood Drop; vanilla just
-- never points a trait at it. RarityLevels swaps to the standard 10/15/20/25% set.
-- It also moves in the offer chain: it asks for the attack or the special, and in exchange counts
-- as a Plasma source for the boons that want one.

mod.tuning.ProfuseBleeding = {
	SpillChance = 0.10,
}

-- Vanilla offers this for any one of the attack, the special, Grisly Gain or Visceral Impact -- the
-- last two being the Plasma set that Sanguinary Savor, Universal Donor and Carnal Pleasure read.
-- Asking for the weapon boons instead makes it the way into that set rather than a sibling of it.
once('ProfuseBleedingRequirements', function()
	if not config.BoonChanges.ProfuseBleedingRequirements.Enabled then return end

	game.TraitRequirements.RendBloodDropBoon = { OneOf = game.LinkedTraitData.AresRendTraits }

	-- Only a Plasma source once it spills any. All three of those boons hold the same table, so the
	-- one insert reaches every one of them.
	if config.BoonChanges.ProfuseBleedingBloodSpill.Enabled then
		table.insert(game.LinkedTraitData.AresBloodDropTraits, 'RendBloodDropBoon')
	end
end)


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
