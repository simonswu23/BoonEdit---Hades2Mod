---@meta _
---@diagnostic disable: lowercase-global

-- Which boons the game will offer you, and what you must already hold to be offered them. Nothing
-- here changes what a boon does -- the numbers are in `tuning.lua`, the wording in `text.lua`, the
-- behaviour in each boon's own file.
--
-- Two shapes turn up. `game.TraitRequirements[trait]` is what the game checks before offering that
-- trait: `OneOf` for a single list, `OneFromEachSet` for one pick out of each of several.
-- `game.LinkedTraitData` holds the named groups those requirements are usually written against --
-- `AresBloodDropTraits`, `HephaestusMassiveTraits` and so on, all listed in `TRAIT_NAMES.md`.
-- Editing a group reaches every requirement that reads it, which is usually the point and is always
-- worth saying out loud.
--
-- Imported from `reload.lua` after the boons, so it has the last word on any requirement they set.
-- Each block carries the config guard of the change it belongs to.

once('BoonRequirements', function()

	-- Aphrodite x Hephaestus -- Smoldering Forge
	if config.BoonChanges.SmolderingForge.Enabled then
		-- Rebuilt rather than edited, since HephaestusMassiveTraits is shared. Furnace Blast is the
		-- vanilla source of Glow; Anvil Ring and Smithy Rush inflict it once AnvilGlowAndDash is on.
		game.TraitRequirements.SlamManaBurstBoon = {
			OneFromEachSet = {
				game.LinkedTraitData.AphroditeCoreTraits,
				{ 'MassiveKnockupBoon', 'HephaestusCastBoon', 'HephaestusSprintBoon' },
			},
		}
	end

	-- Ares -- Profuse Bleeding.
	--
	-- It moves in the offer chain: it asks for the attack or the special, and in exchange counts as
	-- a Plasma source for the boons that want one. Vanilla offers it for any one of the attack, the
	-- special, Grisly Gain or Visceral Impact -- the last two being the Plasma set that Sanguinary
	-- Savor, Universal Donor and Carnal Pleasure read. Asking for the weapon boons instead makes it
	-- the way into that set rather than a sibling of it.
	if config.BoonChanges.ProfuseBleedingRequirements.Enabled then
		game.TraitRequirements.RendBloodDropBoon = { OneOf = game.LinkedTraitData.AresRendTraits }

		-- Only a Plasma source once it spills any. All three of those boons hold the same table, so
		-- the one insert reaches every one of them.
		if config.BoonChanges.ProfuseBleedingBloodSpill.Enabled then
			table.insert(game.LinkedTraitData.AresBloodDropTraits, 'RendBloodDropBoon')
		end
	end

	-- Hephaestus x Poseidon -- Seismic Hammer
	if config.BoonChanges.SeismicHammer.Enabled then
		game.TraitRequirements.MassiveCastBoon = {
			OneFromEachSet = {
				{ 'HephaestusWeaponBoon', 'HephaestusSpecialBoon' },
				{ 'PoseidonExCastBoon' },
			},
		}
	end

	-- Hermes -- Post Haste, offered off any boon it actually speeds up
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

	-- Hestia -- Burning Meteor
	if config.BoonChanges.BurningMeteor.Enabled then
		game.TraitRequirements.BurnSprintBoon = {
			OneFromEachSet = {
				{ 'HestiaWeaponBoon', 'HestiaSpecialBoon', 'HestiaCastBoon' },   -- Flame Strike / Flourish / Smolder Ring
				{ 'CastProjectileBoon', 'FireballManaSpecialBoon' },             -- Glowing Coal / Controlled Burn
				{ 'BurnExplodeBoon', 'BurnArmorBoon', 'AloneDamageBoon' },       -- Flash Fry / Hot Pot / Snuffed Candle
			},
		}
	end

	-- Poseidon -- Breaker Rush joins Tidal Ring and Slippery Slope as a Froth boon, so it can earn
	-- Steam and Killer Current. King Tide's second and third sets are regrouped around Geyser Spout
	-- and Froth, and Hydraulic Might and Flood Gain no longer count towards it.
	if config.BoonChanges.PoseidonFrothRequirements.Enabled then
		-- edited in place: Steam and Killer Current read this same list, and both should be offered
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

	-- Hephaestus -- Smithy Rush. Last of all on purpose: this strips a name out of requirements the
	-- blocks above may have rebuilt, so it has to see their finished versions.
	if config.BoonChanges.AnvilGlowAndDash.Enabled then
		-- Smithy Rush is no longer a massive blast, so it stops earning the offers that need one.
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

		-- Premium Service is left in: it upgrades hammers, not blasts.
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
