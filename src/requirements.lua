---@meta _
---@diagnostic disable: lowercase-global


function boon_group_set(groupName, traitName, wanted)
	local group = game.LinkedTraitData[groupName]
	if not group then return end

	local at = nil
	for i, name in ipairs(group) do
		if name == traitName then
			at = i
			break
		end
	end

	if wanted and not at then
		table.insert(group, traitName)
	elseif not wanted and at then
		table.remove(group, at)
	end
end


function boon_edit_sync_groups()
	local changes = config.BoonChanges

	-- Meat Grinder drops plasma only because this mod makes it.
	boon_group_set('AresBloodDropTraits', 'AresExCastBoon', changes.MeatGrinder.Enabled == true)

	local rewritten = changes.ProfuseBleeding.Enabled == true
	boon_group_set('AresBloodDropTraits', 'RendBloodDropBoon', rewritten)
	boon_group_set('AresSwordTraits', 'RendBloodDropBoon', not rewritten)

	-- Breaker Rush Froths, and splashes, only as this mod rewrites it.
	boon_group_set('PoseidonKnockbackAmplifyTraits', 'PoseidonSprintBoon', changes.BreakerRush.Enabled == true)
	boon_group_set('PoseidonSplashTraits', 'PoseidonSprintBoon', changes.BreakerRush.Enabled == true)

	boon_group_set('PoseidonSplashTraits', 'PoseidonSplashSprintBoon', changes.BeachBall.Enabled == true)
	boon_group_set('PoseidonSplashTraits', 'PoseidonCastBoon', changes.TidalRing.Enabled == true)
	boon_group_set('PoseidonSplashTraits', 'FocusDamageShaveBoon', changes.HighSurf.Enabled == true)

	-- After the memberships above, since it is derived from them.
	boon_edit_splash_no_duo()
	boon_edit_splash_requirement()
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
				{ 'PoseidonCastBoon', 'PoseidonStatusBoon', 'PoseidonSprintBoon' },
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
				{ 'AresManaBoon', 'BloodDropRevengeBoon', 'RendBloodDropBoon', 'AresExCastBoon' },
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
				{ 'AresManaBoon', 'BloodDropRevengeBoon', 'RendBloodDropBoon', 'AresExCastBoon' },
				{ 'LowHealthLifestealBoon', 'AresStatusDoubleDamageBoon', 'MissingHealthCritBoon' },
			},
		}
	end

	if config.BoonChanges.SmolderingForge.Enabled then
		game.TraitRequirements.SlamManaBurstBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.AphroditeCoreTraits,
				{ 'MassiveKnockupBoon', 'HephaestusCastBoon', 'HephaestusSprintBoon' },
			},
		}
	end

	if config.BoonChanges.ChainReaction.Enabled then
		local lucky = game.TraitRequirements.LuckyBoon
		if lucky and lucky.OneOf and not game.Contains(lucky.OneOf, 'DoubleMassiveAttackBoon') then
			table.insert(lucky.OneOf, 'DoubleMassiveAttackBoon')
		end
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

	if config.BoonChanges.ProfuseBleeding.Enabled then
		game.TraitRequirements.RendBloodDropBoon = { OneOf = game.LinkedTraitData.AresRendTraits }
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
		game.TraitRequirements.BurnSprintBoon = {
			OneFromEachSet = {
				{ 'HestiaWeaponBoon', 'HestiaSpecialBoon', 'HestiaCastBoon' },
				{ 'CastProjectileBoon', 'FireballManaSpecialBoon' },
				{ 'BurnExplodeBoon', 'BurnArmorBoon', 'AloneDamageBoon' },
			},
		}
	end

	if config.BoonChanges.BreakerRush.Enabled then
		game.TraitRequirements.AmplifyConeBoon = {
			OneFromEachSet = {
				{
					'PoseidonWeaponBoon',
					'PoseidonSpecialBoon',
				},
				{
					'PoseidonStatusBoon',
					'PoseidonCastBoon',
					'PoseidonSprintBoon',
				},
				{
					'PoseidonExCastBoon',
					'FocusDamageShaveBoon',
					'OmegaPoseidonProjectileBoon',
				},
			},
		}
	end

	game.TraitRequirements.PoseidonStatusBoon = {
		PriorityChance = 0.25,
		OneOf = { 'PoseidonWeaponBoon', 'PoseidonSpecialBoon' },
	}

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

		for _, traitName in ipairs({
			'MassiveDamageBoon',
			'MassiveKnockupBoon',
			'BlindClearBoon',
			'ClearRootBoon',
			'DoubleMassiveAttackBoon',
		}) do
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
