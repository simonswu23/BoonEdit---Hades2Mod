---@meta _
---@diagnostic disable: lowercase-global


once('CarnalPleasure', function()
	if not config.BoonChanges.CarnalPleasure.Enabled then return end

	local carnal = game.TraitData.BloodManaBurstBoon

	carnal.DropManaBurstChance = mod.tuning.CarnalPleasure.HeartthrobChance
	carnal.BoonEditHealPerPlasma = mod.tuning.CarnalPleasure.HealPerPlasma

	table.insert(carnal.StatLines, 'BoonEditCarnalPleasureHealStatDisplay')
	table.insert(carnal.ExtractValues, {
		Key = 'BoonEditHealPerPlasma',
		ExtractAs = 'TooltipHealPerPlasma',
	})

	modutil.mod.Path.Wrap("BloodDropUse", function(base, args, consumable)
		carnal_pleasure_heal(game.GetTotalHeroTraitValue('BloodDropMultiplier', { IsMultiplier = true }))
		return base(args, consumable)
	end)
end)


function carnal_pleasure_heal(count)
	if not config.BoonChanges.CarnalPleasure.Enabled then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end
	if not game.HeroHasTrait('BloodManaBurstBoon') then return end

	local amount = (count or 1) * mod.tuning.CarnalPleasure.HealPerPlasma
	if amount <= 0 then return end

	game.Heal(hero, {
		HealAmount = game.round(amount * game.CalculateHealingMultiplier()),
		SourceName = 'BloodManaBurstBoon',
	})
end
