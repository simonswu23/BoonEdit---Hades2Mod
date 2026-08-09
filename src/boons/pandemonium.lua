---@meta _
---@diagnostic disable: lowercase-global

-- Pandemonium (Chaos, Legendary) -- a new boon rather than an edit of one. Every god is in the pool
-- for the night, no boon asks you to hold anything first, core boons stop taking each other's slots,
-- and doors offer blessings more often.
--
-- Built on `ChaosLastStandBlessing`, vanilla's own Legendary Chaos boon, down to asking that Chaos
-- has already blessed you once.

PANDEMONIUM = 'BoonEditPandemoniumBlessing'

-- The blessings vanilla lists on the Chaos loot. Read rather than hardcoded, so a blessing added by
-- anything else counts towards the prerequisite too.
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


-- Copies each god entry in the run-progress table, gated on holding the boon. Guarded against
-- running twice, or a reload would grow the table again.
--
-- Defined above the `once` block on purpose: `once` runs its function immediately, so anything it
-- calls must already exist.
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
				-- replaces whatever the original asked for: this copy exists only for holders
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

	-- Chaos already offers Legendary (`TrialUpgrade.BoonRaritiesOverride`), so one Legendary entry in
	-- RarityLevels is all that sets the rarity. `DebugOnly` is cleared because the `ChaosBlessing`
	-- base carries it to keep itself from being offered, and it would otherwise be inherited.
	game.TraitData[PANDEMONIUM] = {
		InheritFrom = { 'ChaosBlessing' },
		DebugOnly = false,
		Icon = 'Boon_Chaos_59',
		FlavorText = 'BoonEditPandemoniumFlavorText',

		RarityLevels = {
			Legendary = { MinMultiplier = 1, MaxMultiplier = 1 },
		},

		-- Offered only once Chaos has already given you something, the way its Legendary does.
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

	-- `RunProgress` carries no weights -- a reward's share is how many entries it has -- so more god
	-- entries is the only lever. Each duplicate is gated on holding the boon rather than added on
	-- pickup: that table outlives the run, and gating needs no cleanup.
	pandemonium_boost_doors()

	-- `HasTraitRequirements` is the single place `TraitRequirements` is enforced, so answering it as
	-- met is the whole of "no boon asks for anything".
	modutil.mod.Path.Wrap("HasTraitRequirements", function(base, traitName)
		if pandemonium_held() then return true end
		return base(traitName)
	end)

	-- **Chaos has no weights to raise.** `SetTransformingTraitsOnLoot` fills its options with
	-- `RemoveRandomValue(permanentTraits)` (`TraitLogic.lua:1713`) -- a flat draw, so a blessing's
	-- share is one in however many are eligible and there is no field to nudge.
	--
	-- So the roll is made here and the result forced in, which is what vanilla's own `PriorityChance`
	-- does for ordinary boons. Wrapped after the fact rather than before: the options have to exist
	-- before one can be replaced, and replacing the last keeps the count exactly as Chaos set it.
	modutil.mod.Path.Wrap("SetTransformingTraitsOnLoot", function(base, lootData, upgradeChoiceData)
		base(lootData, upgradeChoiceData)
		pandemonium_favour_keepsake(lootData)
	end)
end)


-- A boon claims a slot purely by carrying `TraitData[name].Slot`, so clearing it is the whole of
-- letting two Attack boons coexist -- which is why debug-granting two already worked. `OriginalSlot`
-- keeps what was cleared, as 1andonlyWeaver's BoonStacker does.
--
-- `TraitData` outlives the run, so this syncs from the room hook rather than applying once: held it
-- is on, and a run without the boon puts every slot back.
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


-- `GetEligibleLootNames` narrows to the gods you have met once `ReachedMaxGods` is true, and that is
-- only a `>=` against `CurrentRun.MaxGodsPerRun`. Raising the run's own ceiling is enough, and is
-- re-asserted each encounter in case the field is rebuilt.
function mod.Pandemonium()
	if not pandemonium_held() then return end
	if not game.CurrentRun then return end

	local ceiling = mod.tuning.Pandemonium.MaxGodsPerRun
	if (game.CurrentRun.MaxGodsPerRun or 0) < ceiling then
		game.CurrentRun.MaxGodsPerRun = ceiling
	end
end


-- Chaos' own keepsake tilts its blessings towards Pandemonium. Rolled once per offer, and only while
-- the keepsake is equipped -- `RandomBlessingKeepsake` is the trait it grants.
--
-- Nothing happens if Pandemonium is already among the options, already held, or not yet earnable:
-- what it is gated on is a `GameStateRequirements` check, so `IsTraitEligible` is asked here rather
-- than assumed, and a run that has not met Chaos is left alone.
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

	-- the last one, so the first choice read is still whatever Chaos rolled
	options[#options].ItemName = PANDEMONIUM
end
