---@meta _
---@diagnostic disable: lowercase-global


function boon_list_set(list, traitName, wanted)
	if not list then return end

	local at = nil
	for i, name in ipairs(list) do
		if name == traitName then
			at = i
			break
		end
	end

	if wanted and not at then
		table.insert(list, traitName)
	elseif not wanted and at then
		table.remove(list, at)
	end
end


function boon_group_set(groupName, traitName, wanted)
	boon_list_set(game.LinkedTraitData[groupName], traitName, wanted)
end


local BOON_EDIT_GROUPS = {
	'AresSwordTraits', 'AresBloodDropTraits', 'PoseidonSplashTraits', 'HeraLinkTraits',
	'HephaestusMassiveTraits',
}

once('BoonEditGroupShapes', function()
	mod.BoonEditGroupShapes = {}
	for _, groupName in ipairs(BOON_EDIT_GROUPS) do
		mod.BoonEditGroupShapes[groupName] = game.ShallowCopyTable(game.LinkedTraitData[groupName] or {})
	end
end)


local function same_members(a, b)
	if #a ~= #b then return false end

	local members = game.ToLookup(a)
	for _, name in ipairs(b) do
		if not members[name] then return false end
	end
	return true
end


local function boon_edit_live_group(set, groups)
	if groups[set] then return set end

	for groupName, shape in pairs(mod.BoonEditGroupShapes or {}) do
		local live = game.LinkedTraitData[groupName]
		if live and (same_members(set, shape) or same_members(set, live)) then return live end
	end
	return set
end


function boon_edit_relink_groups()
	local groups = {}
	for _, group in pairs(game.LinkedTraitData) do
		if type(group) == 'table' then groups[group] = true end
	end

	for _, requirement in pairs(game.TraitRequirements) do
		if type(requirement) == 'table' then
			if type(requirement.OneOf) == 'table' then
				requirement.OneOf = boon_edit_live_group(requirement.OneOf, groups)
			end
			for i, set in ipairs(requirement.OneFromEachSet or {}) do
				requirement.OneFromEachSet[i] = boon_edit_live_group(set, groups)
			end
		end
	end
end


function boon_edit_sync_groups()
	local changes = config.BoonChanges

	boon_edit_relink_groups()

	boon_group_set('AresBloodDropTraits', 'AresExCastBoon', changes.MeatGrinder.Enabled == true)

	local rewritten = changes.ProfuseBleeding.Enabled == true
	boon_group_set('AresBloodDropTraits', 'RendBloodDropBoon', rewritten)
	boon_group_set('AresSwordTraits', 'RendBloodDropBoon', not rewritten)

	boon_group_set('PoseidonSplashTraits', 'PoseidonSprintBoon', changes.BreakerRush.Enabled == true)

	boon_group_set('PoseidonSplashTraits', 'PoseidonSplashSprintBoon', changes.BeachBall.Enabled == true)

	boon_group_set('HeraLinkTraits', 'SpawnCastDamageBoon', changes.RousingReception.Enabled == true)

	boon_group_set('HephaestusMassiveTraits', 'HephaestusSprintBoon', changes.SmithyRush.Enabled ~= true)

	boon_edit_splash_no_duo()
	boon_edit_splash_requirement()
	boon_edit_blood_requirement()
	boon_edit_chance_requirement()
end


function boon_edit_blood_requirement()
	local rend = game.LinkedTraitData.AresRendTraits

	if config.BoonChanges.ProfuseBleeding.Enabled then
		game.TraitRequirements.RendBloodDropBoon = { OneOf = rend }
	else
		game.TraitRequirements.RendBloodDropBoon = {
			OneOf = game.CombineTables(rend, game.LinkedTraitData.AresBloodDropTraits),
		}
	end
end


local function boon_edit_rolls(change, chance)
	return change.Enabled == true and type(chance) == 'number' and chance > 0 and chance < 1
end

function boon_edit_chance_requirement()
	local lucky = game.TraitRequirements.LuckyBoon and game.TraitRequirements.LuckyBoon.OneOf
	if not lucky then return end

	local changes = config.BoonChanges
	local tuning = mod.tuning

	boon_list_set(lucky, 'DoubleMassiveAttackBoon', boon_edit_rolls(changes.ChainReaction, tuning.ChainReaction.SkipChance))
	boon_list_set(lucky, 'AresExCastBoon', boon_edit_rolls(changes.MeatGrinder, tuning.MeatGrinder.PlasmaChance))
	boon_list_set(lucky, 'RendBloodDropBoon', boon_edit_rolls(changes.ProfuseBleeding, tuning.ProfuseBleeding.SpillChance))
	boon_list_set(lucky, 'LowHealthLifestealBoon', boon_edit_rolls(changes.BloodSpree, tuning.BloodSpree.KillHealChance))
	boon_list_set(lucky, 'LightningVulnerabilityBoon', boon_edit_rolls(changes.KillerCurrent, tuning.KillerCurrent.BoltChance))
	boon_list_set(lucky, 'RandomStatusBoon', boon_edit_rolls(changes.EcstaticObsession, tuning.EcstaticObsession.CharmChance))
	boon_list_set(lucky, 'SlamManaBurstBoon', boon_edit_rolls(changes.SmolderingForge, tuning.SmolderingForge.HeartthrobChance))
	boon_list_set(lucky, 'RaiseDeadBoon', boon_edit_rolls(changes.SunWorshiper, tuning.SunWorshiper.RepeatChance))

	boon_list_set(lucky, 'DoubleSplashBoon', changes.ArterialSpray.Enabled ~= true)
	boon_list_set(lucky, 'BlindChanceBoon',
		changes.DazzlingDisplay.Enabled ~= true or tuning.DazzlingDisplay.Chance < 1)
	boon_list_set(lucky, 'BloodManaBurstBoon',
		changes.CarnalPleasure.Enabled ~= true or tuning.CarnalPleasure.HeartthrobChance < 1)
end


function boon_edit_glow_traits()
	local traits = { 'MassiveKnockupBoon' }

	if config.BoonChanges.AnvilRing.Enabled then
		table.insert(traits, 'HephaestusCastBoon')
		if config.BoonChanges.SmithyRush.Enabled then
			table.insert(traits, 'HephaestusSprintBoon')
		end
	end

	return traits
end


function boon_edit_splash_requirement()
	if config.BoonChanges.DuoRequirements.Enabled then
		game.TraitRequirements.DoubleSplashBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.AresCoreTraits,
				boon_edit_splash_no_duo(),
			},
		}
	else
		game.TraitRequirements.DoubleSplashBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.AresCoreTraits,
				game.LinkedTraitData.PoseidonSplashTraits,
			},
		}
	end
end


SPLASH_NO_DUO = 'BoonEditSplashNoDuoTraits'


function boon_edit_splash_no_duo()
	game.LinkedTraitData[SPLASH_NO_DUO] = game.LinkedTraitData[SPLASH_NO_DUO] or {}
	local list = game.LinkedTraitData[SPLASH_NO_DUO]

	for i = #list, 1, -1 do
		list[i] = nil
	end

	for _, name in ipairs(game.LinkedTraitData.PoseidonSplashTraits or {}) do
		local data = game.TraitData[name]
		if not (data and data.IsDuoBoon) then
			table.insert(list, name)
		end
	end

	return list
end


once('BoonRequirements', function()

	if config.BoonChanges.RousingReception.Enabled then
		game.TraitRequirements.SpawnCastDamageBoon = {
			OneOf = { 'HeraCastBoon' },
		}
	end

	if config.BoonChanges.DuoRequirements.Enabled then
		game.TraitRequirements.PoseidonSplashSprintBoon = {
			OneFromEachSet = {
				{ 'ApolloSprintBoon', 'PoseidonSprintBoon' },
				{ 'PoseidonWeaponBoon', 'PoseidonSpecialBoon', 'PoseidonSprintBoon' },
				{ 'ApolloWeaponBoon', 'ApolloSpecialBoon', 'ApolloSprintBoon' },
			},
		}

		game.TraitRequirements.ManaShieldBoon = {
			OneFromEachSet = {
				{ 'DamageShareRetaliateBoon', 'BoonDecayBoon', 'CommonGlobalDamageBoon' },
				{ 'ArmorBoon', 'HeavyArmorBoon', 'EncounterStartDefenseBuffBoon', 'ManaToHealthBoon' },
			},
		}

		game.TraitRequirements.KeepsakeLevelBoon = {
			OneFromEachSet = {
				{ 'ReserveManaHitShieldBoon', 'PlantHealthBoon', 'BoonGrowthBoon' },
				{ 'CommonGlobalDamageBoon', 'BoonDecayBoon', 'DamageShareRetaliateBoon' },
			},
		}

		game.TraitRequirements.ClearRootBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.HephaestusCoreTraits,
				{ 'DemeterWeaponBoon', 'DemeterSpecialBoon', 'DemeterCastBoon' },
			},
		}

		game.TraitRequirements.FireballRendBoon = {
			OneFromEachSet = {
				{ 'AresWeaponBoon', 'AresSpecialBoon' },
				{ 'FireballManaSpecialBoon', 'CastProjectileBoon' },
			},
		}

		game.TraitRequirements.MaxHealthDamageBoon = {
			OneFromEachSet = {
				{ 'AphroditeWeaponBoon', 'AphroditeSpecialBoon', 'DemeterWeaponBoon', 'DemeterSpecialBoon' },
				{ 'HealthRewardBonusBoon', 'FocusRawDamageBoon', 'HighHealthOffenseBoon' },
				{ 'PlantHealthBoon', 'ReserveManaHitShieldBoon', 'BoonGrowthBoon' },
			},
		}

		game.TraitRequirements.SelfCastBoon = {
			OneFromEachSet = {
				{ 'AresExCastBoon', 'AresCastBoon' },
				{ 'CastNovaBoon', 'DemeterCastBoon' },
			},
		}

		game.TraitRequirements.AllCloseBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.PoseidonCoreTraits,
				{ 'AphroditeWeaponBoon', 'AphroditeSpecialBoon', 'AphroditeManaBoon' },
			},
		}

		game.TraitRequirements.LightningVulnerabilityBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.PoseidonKnockbackAmplifyTraits,
				{ 'ZeusWeaponBoon', 'ZeusSpecialBoon' },
			},
		}

		game.TraitRequirements.GoodStuffBoon = {
			OneFromEachSet = {
				{ 'RoomRewardBonusBoon', 'DoubleRewardBoon' },
				{ 'PlantHealthBoon', 'BoonGrowthBoon', 'ReserveManaHitShieldBoon' },
			},
		}

		game.TraitRequirements.RaiseDeadBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.HeraCoreTraits,
				game.LinkedTraitData.ApolloCoreTraits,
			},
		}

		game.TraitRequirements.BloodRetentionBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.AresBloodDropTraits,
				game.LinkedTraitData.HeraCoreTraits,
			},
		}

		game.TraitRequirements.CoverRegenerationBoon = {
			OneFromEachSet = {
				{ 'ApolloCastBoon', 'ApolloSprintBoon', 'ApolloRetaliateBoon', 'BlindChanceBoon' },
				{ 'BurnArmorBoon', 'BurnExplodeBoon', 'AloneDamageBoon' },
			},
		}

		game.TraitRequirements.AllElementalBoon = {
			OneFromEachSet = {
				{ 'HeraWeaponBoon', 'HeraSpecialBoon', 'HeraCastBoon', 'HeraSprintBoon' },
				{ 'BoonDecayBoon', 'CommonGlobalDamageBoon', 'DamageShareRetaliateBoon' },
				{ 'DamageSharePotencyBoon', 'LinkedDeathDamageBoon', 'SpawnCastDamageBoon' },
			},
		}

		game.TraitRequirements.CharmCrowdBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.HeraCoreTraits,
				{ 'AphroditeManaBoon', 'AphroditeSprintBoon', 'AphroditeCastBoon' },
			},
		}

		game.TraitRequirements.RandomStatusBoon = {
			OneFromEachSet = {
				{ 'AphroditeWeaponBoon', 'AphroditeSpecialBoon' },
				{ 'AphroditeManaBoon', 'AphroditeSprintBoon', 'AphroditeCastBoon' },
				{ 'WeakVulnerabilityBoon', 'WeakPotencyBoon' },
			},
		}

		game.TraitRequirements.DoubleBloodDropBoon = {
			OneFromEachSet = {
				{ 'AresWeaponBoon', 'AresSpecialBoon' },
				game.LinkedTraitData.AresBloodDropTraits,
				{ 'LowHealthLifestealBoon', 'AresStatusDoubleDamageBoon', 'MissingHealthCritBoon' },
			},
		}
	end

	if config.BoonChanges.SmolderingForge.Enabled then
		game.TraitRequirements.SlamManaBurstBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.AphroditeCoreTraits,
				boon_edit_glow_traits(),
			},
		}
	end

	if config.BoonChanges.CryoPounder.Enabled then
		game.TraitRequirements.ClearRootBoon = {
			OneFromEachSet = {
				boon_edit_glow_traits(),
				game.LinkedTraitData.DemeterRootTraits,
			},
		}
	end

	if config.BoonChanges.DazzlingDisplay.Enabled then
		game.TraitRequirements.BlindChanceBoon = {
			PriorityChance = 0.25,
			OneOf = { 'ApolloWeaponBoon', 'ApolloSpecialBoon' },
		}
	end

	if config.BoonChanges.GloriousDisaster.Enabled then
		game.TraitRequirements.ApolloSecondStageCastBoon = {
			OneFromEachSet = {
				{ 'ApolloExCastBoon' },
				{ 'ZeusWeaponBoon', 'ZeusSpecialBoon', 'ZeusCastBoon', 'ZeusSprintBoon', 'ZeusManaBoon' },
			},
		}
	end

	if config.BoonChanges.CarnalPleasure.Enabled then
		game.TraitRequirements.BloodManaBurstBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.AresBloodDropTraits,
				game.LinkedTraitData.AphroditeCoreTraits,
			},
		}
	end

	if config.BoonChanges.ScaldingVapor.Enabled then
		game.TraitRequirements.SteamBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.PoseidonKnockbackAmplifyTraits,
				{ 'CastProjectileBoon', 'FireballManaSpecialBoon' },
			},
		}
	end

	if config.BoonChanges.SeismicHammer.Enabled then
		game.TraitRequirements.MassiveCastBoon = {
			OneFromEachSet = {
				{ 'HephaestusWeaponBoon', 'HephaestusSpecialBoon' },
				{ 'PoseidonExCastBoon' },
			},
		}
	end

	if config.BoonChanges.PostHaste.Enabled then
		game.TraitRequirements.SlowProjectileBoon = {
			OneOf = {
				'TimedCritVulnerabilityBoon',
				'RetaliateInvulnerabilityBoon',
				'AthenaProjectileBoon',
				'PowerDrinkBoon',
				'FogDamageBonusBoon',
				'HephaestusWeaponBoon',
				'HephaestusSpecialBoon',
				'PoseidonManaBoon',
				'ZeusManaBoon',
				'AutoRevengeBoon',
				'HadesInvisibilityRetaliateBoon',
			},
		}
	end

	if config.BoonChanges.BurningMeteor.Enabled then
		local extras = { 'BurnExplodeBoon', 'BurnArmorBoon' }
		if not config.BoonChanges.VolcanicCrown.Enabled then
			table.insert(extras, 'AloneDamageBoon')
		end

		game.TraitRequirements.BurnSprintBoon = {
			OneFromEachSet = {
				{ 'HestiaWeaponBoon', 'HestiaSpecialBoon', 'HestiaCastBoon' },
				{ 'CastProjectileBoon', 'FireballManaSpecialBoon' },
				extras,
			},
		}
	end

	if config.BoonChanges.BreakerRush.Enabled then
		game.TraitRequirements.AmplifyConeBoon = {
			OneFromEachSet = {
				{
					'PoseidonWeaponBoon',
					'PoseidonSpecialBoon',
					'PoseidonSprintBoon',
				},
				{
					'PoseidonStatusBoon',
					'PoseidonCastBoon',
				},
				{
					'PoseidonExCastBoon',
					'FocusDamageShaveBoon',
					'OmegaPoseidonProjectileBoon',
				},
			},
		}
	else
		game.TraitRequirements.AmplifyConeBoon.OneFromEachSet[1] = { 'PoseidonWeaponBoon', 'PoseidonSpecialBoon' }
	end

	game.TraitRequirements.PoseidonStatusBoon = {
		PriorityChance = 0.25,
		OneOf = { 'PoseidonWeaponBoon', 'PoseidonSpecialBoon' },
	}
	if config.BoonChanges.BreakerRush.Enabled then
		table.insert(game.TraitRequirements.PoseidonStatusBoon.OneOf, 'PoseidonSprintBoon')
	end

	if config.BoonChanges.VolcanicCrown.Enabled then
		local fireballBoons = game.ToLookup({ 'CastProjectileBoon', 'FireballManaSpecialBoon' })

		for _, requirements in pairs(game.TraitRequirements) do
			local lists = { requirements.OneOf }
			for _, set in ipairs(requirements.OneFromEachSet or {}) do
				table.insert(lists, set)
			end

			for _, list in pairs(lists) do
				local asks = false
				for _, name in ipairs(list) do
					asks = asks or fireballBoons[name] == true
				end
				if asks and not game.Contains(list, 'AloneDamageBoon') then
					table.insert(list, 'AloneDamageBoon')
				end
			end
		end
	end

	if config.BoonChanges.BreakerRush.Enabled then
		for _, requirements in pairs(game.TraitRequirements) do
			local lists = { requirements.OneOf }
			for _, set in ipairs(requirements.OneFromEachSet or {}) do
				table.insert(lists, set)
			end

			for _, list in pairs(lists) do
				if game.Contains(list, 'PoseidonWeaponBoon') and game.Contains(list, 'PoseidonSpecialBoon') then
					boon_list_set(list, 'PoseidonSprintBoon', true)
				end
			end
		end
	end

	local infection = game.TraitData.PolymorphCurseTalent
	local curses = infection and infection.SetupFunction and infection.SetupFunction.Args
		and infection.SetupFunction.Args.StatusTraitNames
	if curses then
		for _, traitName in ipairs(boon_edit_glow_traits()) do
			boon_list_set(curses.DelayedKnockbackEffect, traitName, true)
		end
		boon_list_set(curses.DamageShareEffect, 'SpawnCastDamageBoon', config.BoonChanges.RousingReception.Enabled == true)
	end

	if config.BoonChanges.SmithyRush.Enabled then
		local function withoutAnvilRush(list)
			local kept, dropped = {}, false
			for _, candidate in ipairs(list) do
				if candidate == 'HephaestusSprintBoon' then
					dropped = true
				else
					table.insert(kept, candidate)
				end
			end
			return kept, dropped
		end

		local massiveTraits = { 'MassiveDamageBoon', 'MassiveKnockupBoon', 'DoubleMassiveAttackBoon' }
		if not config.BoonChanges.CryoPounder.Enabled then
			table.insert(massiveTraits, 'ClearRootBoon')
		end
		table.insert(massiveTraits, 'BlindClearBoon')

		for _, traitName in ipairs(massiveTraits) do
			local requirements = game.TraitRequirements[traitName]
			if requirements then
				if requirements.OneOf then
					local kept, dropped = withoutAnvilRush(requirements.OneOf)
					if dropped then
						requirements.OneOf = kept
					end
				end
				local sets = requirements.OneFromEachSet
				for i, set in ipairs(sets or {}) do
					local kept, dropped = withoutAnvilRush(set)
					if dropped then
						sets[i] = kept
					end
				end
			end
		end
	end
end)
