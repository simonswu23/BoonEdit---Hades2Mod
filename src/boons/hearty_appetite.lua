---@meta _
---@diagnostic disable: lowercase-global

-- Hearty Appetite (Aphrodite x Demeter) keeps its damage-per-max-Life bonus and gains two things:
-- it fills your Life on pickup, and everything that heals you tonight heals for half again as much.

local HEARTY_APPETITE = 'MaxHealthDamageBoon'


once('HeartyAppetite', function()
	if not config.BoonChanges.HeartyAppetite.Enabled then return end

	local trait = game.TraitData[HEARTY_APPETITE]
	if not trait then return end

	trait.TraitHealingBonus = mod.tuning.HeartyAppetite.HealingBonus
	trait.AcquireFunctionName = _PLUGIN.guid .. '.HeartyAppetiteAcquire'

	trait.StatLines = trait.StatLines or {}
	table.insert(trait.StatLines, 'BoonEditHeartyAppetiteHealingStatDisplay')

	trait.ExtractValues = trait.ExtractValues or {}
	table.insert(trait.ExtractValues, {
		Key = 'TraitHealingBonus',
		ExtractAs = 'TooltipHealingBonus',
		Format = 'PercentDelta',
	})

	trait.CustomStatLinesWithShrineUpgrade = {
		ShrineUpgradeName = 'HealingReductionShrineUpgrade',
		StatLines = {
			'HealthDamageStatDisplay',
			'BoonEditHeartyAppetiteHealingStatDisplay',
			'HealingReductionNotice',
		},
	}
end)


---@diagnostic disable-next-line: unused-local
function mod.HeartyAppetiteAcquire(args, traitData, addArgs)
	if not config.BoonChanges.HeartyAppetite.Enabled then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	game.Heal(hero, { HealFraction = 1, SourceName = HEARTY_APPETITE })
end
