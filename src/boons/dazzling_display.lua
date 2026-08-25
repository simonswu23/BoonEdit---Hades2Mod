---@meta _
---@diagnostic disable: lowercase-global


-- Dazzling Display blinds on the Attack alone, and asks for Nova Strike to be offered at all. It
-- now answers Nova Flourish as well: holding that widens the Blind onto the Special, so the boon is
-- worth taking on an Apollo Special build rather than dead in the hand.

local DAZZLING_TRAIT = 'BlindChanceBoon'
local NOVA_FLOURISH = 'ApolloSpecialBoon'


once('DazzlingDisplayCoversSpecial', function()
	if not config.BoonChanges.DazzlingDisplay.Enabled then return end

	local trait = game.TraitData[DAZZLING_TRAIT]
	local tuning = mod.tuning.DazzlingDisplay

	trait.OnEnemyDamagedAction.Chance.BaseValue = tuning.Chance

	for rarity, multiplier in pairs(tuning.RarityMultipliers) do
		if trait.RarityLevels[rarity] then
			trait.RarityLevels[rarity].Multiplier = multiplier
		end
	end

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
