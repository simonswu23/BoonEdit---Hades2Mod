---@meta _
---@diagnostic disable: lowercase-global

-- Hard Target (Hermes) becomes "Divine Haste": instead of slowing enemy shots, anything that
-- recharges over time recharges faster.

once('HardTargetBecomesDivineHaste', function()
	if config.BoonChanges.HardTargetBecomesDivineHaste.Enabled then
		local haste = game.TraitData.SlowProjectileBoon

		haste.EnemyProjectileSpeedMultiplier = nil

		-- 20/25/30/35% faster. Lower is faster here, so each rarity is solved back from its speed-up.
		local function speedup(factor)
			return (1 - 1 / factor) / (1 - 1 / 1.20)
		end

		haste.OlympianRechargeMultiplier = { BaseValue = 1 / 1.20, SourceIsMultiplier = true }
		haste.RarityLevels = {
			Common = { Multiplier = speedup(1.20) },
			Rare   = { Multiplier = speedup(1.25) },
			Epic   = { Multiplier = speedup(1.30) },
			Heroic = { Multiplier = speedup(1.35) },
		}

		-- offered off any boon this actually speeds up
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

		haste.StatLines = { 'RechargeSpeedStatDisplay' }
		haste.ExtractValues = {
			{
				Key = 'OlympianRechargeMultiplier',
				ExtractAs = 'RechargeMultiplier',
				Format = 'PercentReciprocalDelta',
			},
		}
	end

	modutil.mod.Path.Wrap("HadesRetaliate", function(base, unit, args, triggerArgs)
		return base(unit, divine_haste_recharge(args), triggerArgs)
	end)
end)


-- Unseen Ire checks its own cooldown directly, so the recharge multiplier never reached it.
function divine_haste_recharge(args)
	if not config.BoonChanges.HardTargetBecomesDivineHaste.Enabled then return args end
	if not args or not args.Cooldown then return args end

	local multiplier = game.GetTotalHeroTraitValue('OlympianRechargeMultiplier', { IsMultiplier = true })
	if multiplier == 1 then return args end

	local scaled = game.ShallowCopyTable(args)
	scaled.Cooldown = args.Cooldown * multiplier
	return scaled
end


if config.BoonChanges.HardTargetBecomesDivineHaste.Enabled then
	boon_text({
		Traits = {
			SlowProjectileBoon = {
				DisplayName = 'Divine Haste',
				Description = 'Any {$Keywords.GodBoon} effects that recharge over time recharge faster.',
			},
		},
	})
end
