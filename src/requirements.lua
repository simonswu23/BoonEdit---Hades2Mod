---@meta _
---@diagnostic disable: lowercase-global

-- Every requirement edit -- what the game will offer you and what you must hold to be offered it.
-- There is no second place to look. Editing a `LinkedTraitData` group reaches every requirement
-- reading it, and Smithy Rush's removals run last so they see what the blocks above rebuilt.

once('BoonRequirements', function()

	-- Engagement Ring alone, replacing vanilla's "any Cast boon".
	if config.BoonChanges.RousingReceptionRequirements.Enabled then
		game.TraitRequirements.SpawnCastDamageBoon = {
			OneOf = { 'HeraCastBoon' }, -- Engagement Ring
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

	if config.BoonChanges.GloriousDisasterRequirements.Enabled then
		game.TraitRequirements.ApolloSecondStageCastBoon = {
			OneFromEachSet = {
				{
					'ApolloExCastBoon',   -- Nova Burst
					'ApolloManaBoon',     -- Lucid Gain
					'ApolloCastAreaBoon', -- Super Nova
				},
				{ 'ZeusWeaponBoon', 'ZeusSpecialBoon', 'ZeusCastBoon', 'ZeusSprintBoon' },
			},
		}
	end

	if config.BoonChanges.CarnalPleasurePlasmaBursts.Enabled then
		game.TraitRequirements.BloodManaBurstBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.AresBloodDropTraits,
				{ 'ManaBurstBoon' }, -- Heart Breaker
			},
		}
	end

	if config.BoonChanges.ProfuseBleedingRequirements.Enabled then
		game.TraitRequirements.RendBloodDropBoon = { OneOf = game.LinkedTraitData.AresRendTraits }

		if config.BoonChanges.ProfuseBleedingBloodSpill.Enabled then
			table.insert(game.LinkedTraitData.AresBloodDropTraits, 'RendBloodDropBoon')
		end
	end

	if config.BoonChanges.SeismicHammer.Enabled then
		game.TraitRequirements.MassiveCastBoon = {
			OneFromEachSet = {
				{ 'HephaestusWeaponBoon', 'HephaestusSpecialBoon' },
				{ 'PoseidonExCastBoon' },
			},
		}
	end

	if config.BoonChanges.HardTargetBecomesPostHaste.Enabled then
		game.TraitRequirements.SlowProjectileBoon = {
			OneOf = {
				'TimedCritVulnerabilityBoon',    -- Death Warrant
				'RetaliateInvulnerabilityBoon',  -- Defensive Posture
				'AthenaProjectileBoon',          -- Phalanx Shot
				'PowerDrinkBoon',                -- Bottomless Drink
				'FogDamageBonusBoon',            -- Happy Haze
				'HephaestusWeaponBoon',          -- Volcanic Strike
				'HephaestusSpecialBoon',         -- Volcanic Flourish
				'PoseidonManaBoon',              -- Flood Gain
				'ZeusManaBoon',                  -- Ionic Gain
				'AutoRevengeBoon',               -- Heinous Affront
				'HadesInvisibilityRetaliateBoon',-- Unseen Ire
			},
		}
	end

	if config.BoonChanges.BurningMeteor.Enabled then
		game.TraitRequirements.BurnSprintBoon = {
			OneFromEachSet = {
				{ 'HestiaWeaponBoon', 'HestiaSpecialBoon', 'HestiaCastBoon' },   -- Flame Strike / Flourish / Smolder Ring
				{ 'CastProjectileBoon', 'FireballManaSpecialBoon' },             -- Glowing Coal / Controlled Burn
				{ 'BurnExplodeBoon', 'BurnArmorBoon', 'AloneDamageBoon' },       -- Flash Fry / Hot Pot / Snuffed Candle
			},
		}
	end

	if config.BoonChanges.BeachBallCountsAsSplash.Enabled then
		if not game.Contains(game.LinkedTraitData.PoseidonSplashTraits, 'PoseidonSplashSprintBoon') then
			table.insert(game.LinkedTraitData.PoseidonSplashTraits, 'PoseidonSplashSprintBoon')
		end
	end

	if config.BoonChanges.PoseidonFrothRequirements.Enabled then
		table.insert(game.LinkedTraitData.PoseidonKnockbackAmplifyTraits, 'PoseidonSprintBoon')

		game.TraitRequirements.AmplifyConeBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.PoseidonSplashTraits,
				{
					'PoseidonExCastBoon',          -- Geyser Spout
					'FocusDamageShaveBoon',        -- High Surf
					'OmegaPoseidonProjectileBoon', -- Ocean Swell
				},
				{
					'PoseidonCastBoon',   -- Tidal Ring
					'PoseidonStatusBoon', -- Slippery Slope
					'PoseidonSprintBoon', -- Breaker Rush
				},
			},
		}
	end

	if config.BoonChanges.AnvilGlowAndDash.Enabled then
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
			'MassiveDamageBoon',       -- Grand Caldera
			'MassiveKnockupBoon',      -- Furnace Blast
			'BlindClearBoon',          -- Rude Awakening
			'ClearRootBoon',           -- Cryo Pounder
			'DoubleMassiveAttackBoon', -- Chain Reaction
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
