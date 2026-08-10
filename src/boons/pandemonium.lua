---@meta _
---@diagnostic disable: lowercase-global


-- Pandemonium (Chaos, Legendary) -- a new boon rather than an edit of one. Every god is in the pool for
-- the night, no boon asks you to hold anything first, core boons stop taking each other's slots, and
-- doors offer blessings more often. Built on vanilla's `ChaosLastStandBlessing`.

PANDEMONIUM = 'BoonEditPandemoniumBlessing'

local function pandemonium_blessings()
	local trial = game.LootData.TrialUpgrade
	local blessings = {}
	for _, name in ipairs((trial and trial.PermanentTraits) or {}) do
		if name ~= PANDEMONIUM then
			table.insert(blessings, name)
		end
	end
	return blessings
end


function pandemonium_held()
	return config.BoonChanges.Pandemonium.Enabled and game.HeroHasTrait(PANDEMONIUM)
end


function pandemonium_boost_doors()
	local progress = game.RewardStoreData and game.RewardStoreData.RunProgress
	if not progress or mod.PandemoniumDoorsBoosted then return end
	mod.PandemoniumDoorsBoosted = true

	local extra = mod.tuning.Pandemonium.ExtraDoorEntries
	local added = {}

	for _, entry in ipairs(progress) do
		local loot = entry.Name and game.LootData[entry.Name]
		if loot and loot.GodLoot then
			for _ = 1, extra do
				local copy = game.DeepCopyTable(entry)
				copy.GameStateRequirements = {
					{ PathTrue = { 'CurrentRun', 'Hero', 'TraitDictionary', PANDEMONIUM } },
				}
				table.insert(added, copy)
			end
		end
	end

	for _, entry in ipairs(added) do
		table.insert(progress, entry)
	end
end


once('Pandemonium', function()
	if not config.BoonChanges.Pandemonium.Enabled then return end

	local trial = game.LootData.TrialUpgrade
	if not trial then return end

	game.TraitData[PANDEMONIUM] = {
		InheritFrom = { 'ChaosBlessing' },
		DebugOnly = false,
		Icon = 'Boon_Chaos_59',
		FlavorText = 'BoonEditPandemoniumFlavorText',

		RarityLevels = {
			Legendary = { MinMultiplier = 1, MaxMultiplier = 1 },
		},

		GameStateRequirements = {
			{
				Path = { 'CurrentRun', 'Hero', 'TraitDictionary' },
				HasAny = pandemonium_blessings(),
			},
		},

		SetupFunction = {
			Name = _PLUGIN.guid .. '.Pandemonium',
			RepeatOnEncounterStart = true,
		},
	}

	table.insert(trial.PermanentTraits, PANDEMONIUM)
	if trial.TraitSortOrder then
		table.insert(trial.TraitSortOrder, 1, PANDEMONIUM)
	end

	pandemonium_boost_doors()

	modutil.mod.Path.Wrap("HasTraitRequirements", function(base, traitName)
		if pandemonium_held() then return true end
		return base(traitName)
	end)

	modutil.mod.Path.Wrap("SetTransformingTraitsOnLoot", function(base, lootData, upgradeChoiceData)
		base(lootData, upgradeChoiceData)
		pandemonium_favour_keepsake(lootData)
	end)
end)


local PANDEMONIUM_SLOTS = { Melee = true, Secondary = true, Ranged = true, Rush = true, Mana = true }

function pandemonium_sync_slots()
	if not game.TraitData then return end

	if pandemonium_held() then
		for _, trait in pairs(game.TraitData) do
			local slot = trait.Slot or trait.OriginalSlot
			if slot and PANDEMONIUM_SLOTS[slot] then
				if not trait.OriginalSlot then trait.OriginalSlot = trait.Slot end
				trait.Slot = nil
			end
		end
		return
	end

	for _, trait in pairs(game.TraitData) do
		if trait.OriginalSlot then
			trait.Slot = trait.OriginalSlot
			trait.OriginalSlot = nil
		end
	end
end


function mod.Pandemonium()
	if not pandemonium_held() then return end
	if not game.CurrentRun then return end

	local ceiling = mod.tuning.Pandemonium.MaxGodsPerRun
	if (game.CurrentRun.MaxGodsPerRun or 0) < ceiling then
		game.CurrentRun.MaxGodsPerRun = ceiling
	end
end


function pandemonium_favour_keepsake(lootData)
	if not config.BoonChanges.Pandemonium.Enabled then return end
	if not game.HeroHasTrait('RandomBlessingKeepsake') then return end
	if game.HeroHasTrait(PANDEMONIUM) then return end

	local options = lootData and lootData.UpgradeOptions
	if not options or game.IsEmpty(options) then return end

	for _, option in ipairs(options) do
		if option.ItemName == PANDEMONIUM then return end
	end

	if not game.IsTraitEligible(game.TraitData[PANDEMONIUM]) then return end
	if not game.RandomChance(mod.tuning.Pandemonium.KeepsakeOfferChance) then return end

	options[#options].ItemName = PANDEMONIUM
end
