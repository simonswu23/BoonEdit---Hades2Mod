---@meta _
---@diagnostic disable: lowercase-global


function heirloom_requip_fresh(trait)
	local traitName = trait.Name
	local rarity = game.GetRarityKey(game.GetKeepsakeLevel(traitName, true))
	game.UnequipKeepsake(game.CurrentRun.Hero, traitName, { SkipValidateHealth = true, AdvanceKeepsakeMoment = true })
	game.EquipKeepsake(game.CurrentRun.Hero, traitName, { ForceRarity = rarity, FromLoot = true })
	return game.GetHeroTrait(traitName)
end


HEIRLOOM_KEEPSAKE_REFRESH = {
	ManaOverTimeRefundKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	BossPreDamageKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	LowHealthCritKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	SpellTalentKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	ArmorGainKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	TempHammerKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	FountainRarityKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	UnpickedBoonKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	SkipEncounterKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	BossMetaUpgradeKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	AthenaEncounterKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	DecayingBoostKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	ReincarnationKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	TimedBuffKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	RarifyKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	GoldifyKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	HadesAndPersephoneKeepsake = function(trait) heirloom_requip_fresh(trait) end,
	DoorHealReserveKeepsake = function(trait) heirloom_requip_fresh(trait) end,

	BonusMoneyKeepsake = function(trait)
		game.AddResource('Money', game.round(trait.BonusMoney * game.GetTotalHeroTraitValue('MoneyMultiplier', { IsMultiplier = true })), 'BonusMoneyKeepsake')
	end,

	RandomBlessingKeepsake = function(trait)
		local fresh = heirloom_requip_fresh(trait)
		if fresh then fresh.CurrentRoom = 0 end
	end,

	EscalatingKeepsake = function(trait)
		local oldRate = trait.EscalatingKeepsakeGrowthPerRoom
		local increments = (oldRate and oldRate > 0) and (trait.EscalatingKeepsakeValue - 1.0) / oldRate or 0
		local fresh = heirloom_requip_fresh(trait)
		if fresh and increments > 0 then
			fresh.EscalatingKeepsakeValue = 1.0 + increments * fresh.EscalatingKeepsakeGrowthPerRoom
		end
	end,

	DeathVengeanceKeepsake = function() end,
	BlockDeathKeepsake = function() end,
	DamagedDamageBoostKeepsake = function() end,
}


HEIRLOOM_FORCE_GOD_DATA = {
	ForceZeusBoonKeepsake = { CoreTraits = 'ZeusCoreTraits', Legendary = 'SpawnKillBoon', Wrath = 'ZeusWrathBoon' },
	ForceHeraBoonKeepsake = { CoreTraits = 'HeraCoreTraits', Legendary = 'AllElementalBoon', Wrath = 'HeraWrathBoon' },
	ForceAresBoonKeepsake = { CoreTraits = 'AresCoreTraits', Legendary = 'DoubleBloodDropBoon', Wrath = 'AresWrathBoon' },
	ForcePoseidonBoonKeepsake = { CoreTraits = 'PoseidonCoreTraits', Legendary = 'AmplifyConeBoon', Wrath = 'PoseidonWrathBoon' },
	ForceApolloBoonKeepsake = { CoreTraits = 'ApolloCoreTraits', Legendary = 'DoubleExManaBoon', Wrath = 'ApolloWrathBoon' },
	ForceDemeterBoonKeepsake = { CoreTraits = 'DemeterCoreTraits', Legendary = 'InstantRootKill', Wrath = 'DemeterWrathBoon' },
	ForceAphroditeBoonKeepsake = { CoreTraits = 'AphroditeCoreTraits', Legendary = 'RandomStatusBoon', Wrath = 'AphroWrathBoon' },
	ForceHephaestusBoonKeepsake = { CoreTraits = 'HephaestusCoreTraits', Legendary = 'WeaponUpgradeBoon', Wrath = 'HephWrathBoon' },
	ForceHestiaBoonKeepsake = { CoreTraits = 'HestiaCoreTraits', Legendary = 'BurnSprintBoon', Wrath = 'HestiaWrathBoon' },
}

for godKeepsakeName, _ in pairs(HEIRLOOM_FORCE_GOD_DATA) do
	HEIRLOOM_KEEPSAKE_REFRESH[godKeepsakeName] = function(trait)
		local fresh = heirloom_requip_fresh(trait)
		if not fresh or fresh.Rarity ~= 'Heroic' then return end

		fresh.BoonEditHeirloomGodRarify = fresh.BoonEditHeirloomGodRarify or { Uses = 0 }
		fresh.BoonEditHeirloomGodRarify.Uses = fresh.BoonEditHeirloomGodRarify.Uses + 1
	end
end


function heirloom_force_god_boon_data(traitName)
	if not traitName then return nil, nil end
	for keepsakeName, data in pairs(HEIRLOOM_FORCE_GOD_DATA) do
		if game.Contains(game.LinkedTraitData[data.CoreTraits] or {}, traitName) then
			return keepsakeName, data
		end
	end
	return nil, nil
end


function heirloom_force_god_transform(screen, mouseOverButton, data, trait)
	trait.BoonEditHeirloomGodRarify.Uses = trait.BoonEditHeirloomGodRarify.Uses - 1

	local targetName = nil
	if not game.HeroHasTrait(data.Legendary) then
		targetName = data.Legendary
	elseif game.TraitData[data.Wrath] and not game.HeroHasTrait(data.Wrath) then
		targetName = data.Wrath
	end

	if not targetName then
		mod.HeirloomForceGodHeroicActive = true
		game.TryUpgradeBoon(screen.Source, screen, mouseOverButton)
		mod.HeirloomForceGodHeroicActive = nil
		return
	end

	local heldTraitName = mouseOverButton.Data.Name
	game.RemoveTrait(game.CurrentRun.Hero, heldTraitName)
	local processed = game.GetProcessedTraitData({ Unit = game.CurrentRun.Hero, TraitName = targetName })
	game.AddTraitToHero({ TraitData = processed, FromLoot = true })
end


once('CherishedHeirloomForceGod', function()
	modutil.mod.Path.Wrap('UpgradeMouseOverUpgradeChoice', function(base, screen, button)
		if not config.BoonChanges.CherishedHeirloom.Enabled or not screen or screen.MouseOverButton == nil then
			return base(screen, button)
		end

		local lootData = screen.Source
		if not lootData or (not lootData.GodLoot and not lootData.TreatAsGodLootByShops) then
			return base(screen, button)
		end

		local mouseOverButton = screen.MouseOverButton
		local heldTraitName = mouseOverButton.Data and mouseOverButton.Data.Name
		local keepsakeName, data = heirloom_force_god_boon_data(heldTraitName)
		if not keepsakeName then return base(screen, button) end

		local trait = game.GetHeroTrait(keepsakeName)
		if not trait or trait.Rarity ~= 'Heroic' or not trait.BoonEditHeirloomGodRarify
			or not trait.BoonEditHeirloomGodRarify.Uses or trait.BoonEditHeirloomGodRarify.Uses <= 0 then
			return base(screen, button)
		end

		heirloom_force_god_transform(screen, mouseOverButton, data, trait)
	end)

	modutil.mod.Path.Wrap('GetUpgradedRarity', function(base, baseRarity, rarityUpgradeOrder)
		if mod.HeirloomForceGodHeroicActive and baseRarity ~= 'Heroic' then
			return 'Heroic'
		end
		return base(baseRarity, rarityUpgradeOrder)
	end)
end)


function heirloom_refresh_keepsake(traitName)
	local refresh = HEIRLOOM_KEEPSAKE_REFRESH[traitName]
	if not refresh then return end

	local trait = game.GetHeroTrait(traitName)
	if trait then refresh(trait) end
end


once('CherishedHeirloom', function()
	if config.BoonChanges.CherishedHeirloom.Enabled then
		game.TraitData.KeepsakeLevelBoon.AcquireFunctionName = _PLUGIN.guid .. '.CherishedHeirloomAcquire'
	end

	modutil.mod.Path.Wrap("KeepsakeScreenClose", function(base, screen, button)
		if cherished_heirloom_extra_pending()
			and screen and screen.LastTrait == mod.HeirloomPriorKeepsake then
			return
		end

		local extra = cherished_heirloom_extra_pending()
		local incoming = nil
		local priorKeepsake = mod.HeirloomPriorKeepsake
		if extra then
			mod.HeirloomSkipUnequip = true
			mod.HeirloomExtraPending = nil

			incoming = game.GameState.LastAwardTrait
			if incoming ~= screen.LastTrait then
				mod.HeirloomIncoming = incoming
			end
		end

		local blocked = extra and game.CurrentRun and game.CurrentRun.BlockedKeepsakes
		local blockedCount = blocked and #blocked or 0

		base(screen, button)

		if extra then
			mod.HeirloomSkipUnequip = nil
			mod.HeirloomIncoming = nil
			mod.HeirloomPriorKeepsake = nil

			if blocked and incoming and #blocked > blockedCount and blocked[#blocked] == screen.LastTrait then
				blocked[#blocked] = incoming
			end

			if game.CurrentRun and screen.LastTrait and game.HeroHasTrait(screen.LastTrait) then
				game.GameState.LastAwardTrait = screen.LastTrait
				heirloom_confirm_special_keepsake(screen.LastTrait)
			end

			if mod.tuning.CherishedHeirloom.RefreshHeldKeepsake and incoming and incoming == priorKeepsake then
				heirloom_refresh_keepsake(incoming)
			end

			cherished_heirloom_place_keepsakes()
		end
	end)

	modutil.mod.Path.Wrap("IsShownInHUD", function(base, trait)
		if heirloom_hides_from_hud(trait) then return false end
		return base(trait)
	end)

	modutil.mod.Path.Wrap("UnequipKeepsake", function(base, heroUnit, traitName, args)
		if mod.HeirloomSkipUnequip then
			mod.HeirloomSkipUnequip = nil
			return
		end
		return base(heroUnit, traitName, args)
	end)
end)


local HEIRLOOM_HOLD_ENCOUNTERS = 9999

local HEIRLOOM_MENU_DELAY = 1.2

function cherished_heirloom_active()
	if not config.BoonChanges.CherishedHeirloom.Enabled then return false end
	if not game.CurrentRun or not game.CurrentRun.Hero then return false end
	return game.HeroHasTrait('KeepsakeLevelBoon')
end

function cherished_heirloom_extra_pending()
	return mod.HeirloomExtraPending and mod.tuning.CherishedHeirloom.ExtraKeepsake
end

function heirloom_demote_keepsake(trait)
	if not trait or not trait.Name then return end

	game.TraitUIRemove(trait)
	trait.Slot = nil
	trait.ActiveSlotOffsetIndex = nil
	trait.HideInRunHistory = nil
	trait.Ordered = nil
	game.SessionMapState.HUDTraitsShown[trait.Name] = nil

	if mod.tuning.CherishedHeirloom.ExtraKeepsakeInMenuOnly then
		trait.ShowInHUD = nil
		trait.BoonEditHeirloomExtra = true
		return
	end

	trait.BoonEditHeirloomExtra = nil
	game.TraitUIAdd(trait)
end

function heirloom_hides_from_hud(trait)
	if not trait then return false end
	if trait.BoonEditHeirloomExtra then return true end
	return mod.HeirloomIncoming ~= nil and trait.Name == mod.HeirloomIncoming
end

function heirloom_hold_keepsake(trait)
	if trait.UsesAsEncounters and trait.RemainingUses then
		trait.HoldRemainingRooms = HEIRLOOM_HOLD_ENCOUNTERS
	end
end

function heirloom_special_keepsake()
	return game.CurrentRun and game.CurrentRun.BoonEditHeirloomSpecialKeepsake
end

function heirloom_is_special_keepsake(traitName)
	return traitName ~= nil and traitName == heirloom_special_keepsake()
end

function heirloom_confirm_special_keepsake(traitName)
	if not game.CurrentRun then return end
	game.CurrentRun.BoonEditHeirloomSpecialKeepsake = traitName

	local trait = game.GetHeroTrait(traitName)
	if trait then trait.BoonEditHeirloomSpecial = true end
end

function cherished_heirloom_place_keepsakes()
	if not cherished_heirloom_active() then return end

	local equipped = game.GameState.LastAwardTrait
	local special = heirloom_special_keepsake()
	for _, trait in ipairs(game.CurrentRun.Hero.Traits or {}) do
		if game.GetKeepsakeData(trait.Name) then
			if mod.tuning.CherishedHeirloom.KeepAllKeepsakes then
				heirloom_hold_keepsake(trait)
			end
			if trait.Name == special then
				trait.BoonEditHeirloomSpecial = true
			end
			if trait.Name ~= equipped and trait.ActiveSlotOffsetIndex ~= nil then
				heirloom_demote_keepsake(trait)
			end
		end
	end
end

function heirloom_equipped_keepsake()
	if not game.CurrentRun or not game.CurrentRun.Hero then return nil end
	for _, trait in ipairs(game.CurrentRun.Hero.Traits or {}) do
		if game.GetKeepsakeData(trait.Name) and trait.ActiveSlotOffsetIndex ~= nil then
			return trait.Name
		end
	end
	return nil
end

function mod.CherishedHeirloomAcquire(args, traitData)
	game.AttemptAdvanceKeepsake(args, traitData)

	cherished_heirloom_place_keepsakes()

	if not mod.tuning.CherishedHeirloom.ExtraKeepsake then return end
	mod.HeirloomExtraPending = true
	mod.HeirloomPriorKeepsake = heirloom_equipped_keepsake()
	game.thread(cherished_heirloom_open_rack)
end

function cherished_heirloom_open_rack()
	---@diagnostic disable-next-line: undefined-global
	wait_for_screens(HEIRLOOM_MENU_DELAY)
	if not cherished_heirloom_extra_pending() then return end
	game.OpenKeepsakeRackScreen(nil)
end
