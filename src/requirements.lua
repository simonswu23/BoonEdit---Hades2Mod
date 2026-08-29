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

	-- Chain Reaction is a chance-based effect once BoonEdits has reworked it, so it belongs on the
	-- list of boons that make Success Rate worth offering. Luck already reaches the roll itself --
	-- rolls() scales every chance in this mod by LuckMultiplier -- it was only the offer that
	-- did not know about it.
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

		-- It is not a sword boon any more. Rewritten it drops plasma off wounded foes and never
		-- makes a falling blade, so it has no business unlocking the two duos that improve them:
		-- Coffin Nail (`RapidSwordBoon`) and Cutting Edge (`DoubleSwordBoon`) both ask
		-- `AresSwordTraits` (`TraitData.lua:615`, `:624`), and both hold that set by reference, so
		-- striking the name out of the set reaches both without touching either requirement.
		for i, name in ipairs(game.LinkedTraitData.AresSwordTraits) do
			if name == 'RendBloodDropBoon' then
				table.remove(game.LinkedTraitData.AresSwordTraits, i)
				break
			end
		end
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

	-- `PoseidonSplashTraits` is the group the game means by "a splash boon" when it decides what may
	-- be offered off one -- Slippery Slope reads it as its `OneOf`, King Tide and the Ares duo as one
	-- of their sets. Vanilla lists only Attack and Special, though several other boons plainly make a
	-- splash: they fire the same `PoseidonSplashSplinter` / `PoseidonCastSplashSplinter` the two core
	-- ones do, which is what King Tide's damage bonus and Slippery Slope's Froth key on. So the
	-- mechanics already treated them as splashes; only the offer requirements did not.
	local function counts_as_splash(traitName)
		if not game.Contains(game.LinkedTraitData.PoseidonSplashTraits, traitName) then
			table.insert(game.LinkedTraitData.PoseidonSplashTraits, traitName)
		end
	end

	if config.BoonChanges.BeachBall.Enabled then
		counts_as_splash('PoseidonSplashSprintBoon')
	end

	-- Tidal Ring, through `CheckPoseidonCastSplash`
	if config.BoonChanges.TidalRing.Enabled then
		counts_as_splash('PoseidonCastBoon')
	end

	-- High Surf, through `PoseidonAttackPunish` -- which already reads `ConeModifier`, so King Tide
	-- and Arterial Spray were shaping its splash before it counted as one
	if config.BoonChanges.HighSurf.Enabled then
		counts_as_splash('FocusDamageShaveBoon')
	end

	if config.BoonChanges.BreakerRush.Enabled then
		table.insert(game.LinkedTraitData.PoseidonKnockbackAmplifyTraits, 'PoseidonSprintBoon')

		-- reworked to fire `PoseidonCastSplashSplinter` on every dash, so it is a splash boon in
		-- everything but the group it was listed in
		counts_as_splash('PoseidonSprintBoon')

		-- Pinned to the two core splash boons by name rather than to `PoseidonSplashTraits`, which
		-- now holds Tidal Ring, Breaker Rush, High Surf and Beach Ball as well. `HasTraitRequirements`
		-- (`RunLogic.lua:80`) tests each set on its own with no deduplication, so one boon appearing in
		-- two sets satisfies both -- read off the widened group, High Surf and Tidal Ring between them
		-- covered all three sets and King Tide no longer needed an Attack or Special at all.
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

	-- Slippery Slope is pinned for the same reason King Tide is, and more sharply: its requirement is
	-- a bare `OneOf = PoseidonSplashTraits`, so every name added to that group above became a fresh
	-- way to unlock it -- Beach Ball, a duo, among them. It is the Froth that Wave Strike and Trident
	-- Flourish put on the water, so those two are what it asks for.
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
