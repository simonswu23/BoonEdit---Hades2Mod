---@meta _
---@diagnostic disable: lowercase-global


local PHIAL = 'FountainRarityKeepsake'

once('AromaticPhial', function()
	if not config.KeepsakeChanges.AromaticPhial.Enabled then return end

	local phial = game.TraitData[PHIAL]
	if not phial or not phial.RarityLevels or not phial.RarityLevels.Epic then return end

	phial.RarityLevels.Heroic = phial.RarityLevels.Heroic
		or { Multiplier = phial.RarityLevels.Epic.Multiplier }
end)


if config.KeepsakeChanges.AromaticPhial.Enabled then
	---@diagnostic disable-next-line: undefined-global
	HEIRLOOM_KEEPSAKE_REFRESH[PHIAL] = function(trait)
		trait.Uses = (trait.Uses or 0) + mod.tuning.AromaticPhial.RefreshUses
		game.UpdateTraitNumber(trait)
	end
end


function aromatic_phial_apply()
	if not config.KeepsakeChanges.AromaticPhial.Enabled then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local trait = game.GetHeroTrait(PHIAL)
	if not trait or not trait.FountainRarity then return end

	trait.FountainRarity.NumTraits = trait.Rarity == 'Heroic'
		and mod.tuning.AromaticPhial.HeroicBlessings
		or mod.tuning.AromaticPhial.Blessings

	game.ExtractValues(hero, trait, trait)
end
