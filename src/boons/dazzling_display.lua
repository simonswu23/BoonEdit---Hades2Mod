---@meta _
---@diagnostic disable: lowercase-global


local DAZZLING_TRAIT = 'BlindChanceBoon'
local NOVA_FLOURISH = 'ApolloSpecialBoon'
local BLIND_EFFECT = 'BlindEffect'


once('DazzlingDisplayCoversSpecial', function()
	if not config.BoonChanges.DazzlingDisplay.Enabled then return end

	local trait = game.TraitData[DAZZLING_TRAIT]
	local tuning = mod.tuning.DazzlingDisplay

	local chance = trait.OnEnemyDamagedAction.Chance
	chance.BaseValue = tuning.Chance
	chance.AbsoluteStackValues = nil

	for rarity, multiplier in pairs(tuning.CritRarityMultipliers) do
		if trait.RarityLevels[rarity] then
			trait.RarityLevels[rarity].Multiplier = multiplier
		end
	end

	local weapons = game.AddLinkedWeapons(game.WeaponSets.HeroPrimarySecondaryWeapons)

	trait.AddOutgoingCritModifiers = {
		ValidWeapons = weapons,
		ValidWeaponsLookup = game.ToLookup(weapons),
		ValidActiveEffects = { BLIND_EFFECT },
		Chance = {
			BaseValue = tuning.CritChance,
			AbsoluteStackValues = game.DeepCopyTable(tuning.CritStackValues),
		},
		ReportValues = { ReportedCritBonus = 'Chance' },
	}

	trait.StatLines = { 'BoonEditDazzlingCritStatDisplay' }

	for index = #trait.ExtractValues, 1, -1 do
		if trait.ExtractValues[index].Key == 'ReportedChance' then
			table.remove(trait.ExtractValues, index)
		end
	end

	table.insert(trait.ExtractValues, {
		Key = 'ReportedCritBonus',
		ExtractAs = 'CritBonus',
		Format = 'LuckModifiedPercent',
	})

	modutil.mod.Path.Wrap('AddTraitToHero', function(base, args)
		local added = base(args)
		dazzling_display_widen()
		return added
	end)
end)


function dazzling_display_widen()
	if not config.BoonChanges.DazzlingDisplay.Enabled then return end

	local trait = game.GetHeroTrait(DAZZLING_TRAIT)
	local action = trait and trait.OnEnemyDamagedAction
	if not action then return end

	local weapons = game.WeaponSets.HeroPrimaryWeapons
	if game.HeroHasTrait(NOVA_FLOURISH) then
		weapons = game.ConcatTableValues(
			game.ShallowCopyTable(weapons), game.WeaponSets.HeroSecondaryWeapons)
	end

	weapons = game.AddLinkedWeapons(weapons)
	action.ValidWeapons = weapons
	action.ValidWeaponsLookup = game.ToLookup(weapons)
end
