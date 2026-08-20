---@meta _
---@diagnostic disable: lowercase-global


once('BoonRequirements', function()

	if config.BoonChanges.RousingReception.Enabled then
		game.TraitRequirements.SpawnCastDamageBoon = {
			OneOf = { 'HeraCastBoon' },
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

	if config.BoonChanges.GloriousDisaster.Enabled then
		game.TraitRequirements.ApolloSecondStageCastBoon = {
			OneFromEachSet = {
				{ 'ApolloExCastBoon' },
				{ 'ZeusWeaponBoon', 'ZeusSpecialBoon', 'ZeusCastBoon', 'ZeusSprintBoon' },
			},
		}
	end

	if config.BoonChanges.CarnalPleasure.Enabled then
		game.TraitRequirements.BloodManaBurstBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.AresBloodDropTraits,
				{ 'ManaBurstBoon' },
			},
		}
	end

	if config.BoonChanges.ProfuseBleeding.Enabled then
		game.TraitRequirements.RendBloodDropBoon = { OneOf = game.LinkedTraitData.AresRendTraits }
		table.insert(game.LinkedTraitData.AresBloodDropTraits, 'RendBloodDropBoon')
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

	if config.BoonChanges.BeachBall.Enabled then
		if not game.Contains(game.LinkedTraitData.PoseidonSplashTraits, 'PoseidonSplashSprintBoon') then
			table.insert(game.LinkedTraitData.PoseidonSplashTraits, 'PoseidonSplashSprintBoon')
		end
	end

	if config.BoonChanges.BreakerRush.Enabled then
		table.insert(game.LinkedTraitData.PoseidonKnockbackAmplifyTraits, 'PoseidonSprintBoon')

		game.TraitRequirements.AmplifyConeBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.PoseidonSplashTraits,
				{
					'PoseidonExCastBoon',
					'FocusDamageShaveBoon',
					'OmegaPoseidonProjectileBoon',
				},
				{
					'PoseidonCastBoon',
					'PoseidonStatusBoon',
					'PoseidonSprintBoon',
				},
			},
		}
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
