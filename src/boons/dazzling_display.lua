---@meta _
---@diagnostic disable: lowercase-global


-- Dazzling Display blinds on the Attack alone, and asks for Nova Strike to be offered at all. It
-- now answers Nova Flourish as well: holding that widens the Blind onto the Special, so the boon is
-- worth taking on an Apollo Special build rather than dead in the hand.
--
-- It also lands every hit rather than rolling for it. The roll it used to make is not thrown away
-- but moved: what the rarities buy is now the chance your Attack and Special land a Critical on a
-- foe already Blinded, so they still buy something and the boon reads as a pair -- it applies the
-- status, then pays you for hitting into it.

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

	-- `RunData.lua:736` fills in the linked weapons and the lookup for a crit modifier, but it does
	-- that once at load and this trait is edited long after -- so both are built here, the way
	-- Secret Crush builds its own.
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

	-- The Blind chance stat line goes with the roll it reported, and the crit takes its place. Only
	-- the new entry is auto-extracted -- the two Blind keyword extracts are external and skip
	-- extraction -- so the crit is what `StatDisplay1` resolves to.
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


-- The hero's trait is a deep copy of the template (TraitLogic.lua:139), so the widening is written
-- onto the held copy rather than the data -- and rewritten whenever a boon is taken, since Nova
-- Flourish can arrive after Dazzling Display has been sitting in the tray.
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
