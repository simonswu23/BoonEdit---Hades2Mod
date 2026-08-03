---@meta _
---@diagnostic disable: lowercase-global

-- Fire Away (Hestia legendary) becomes "Burning Meteor": Hestia's fireballs are half again as large
-- and as strong, and inflict Scorch equal to the damage they deal. Its old effect is parked on
-- mod.FireAwayEffect, with no boon left to sit on.

mod.tuning.BurningMeteor = {
	FireballMultiplier = 1.5,
	SizeMultiplier = 1.5,
}

once('BurningMeteor', function()
	local combustion = game.TraitData.BurnSprintBoon

	mod.FireAwayEffect = {
		OnBlockDamageFunction     = combustion.OnBlockDamageFunction,
		OnWeaponFiredFunctions    = combustion.OnWeaponFiredFunctions,
		OnProjectileDeathFunction = combustion.OnProjectileDeathFunction,
		StatLines                 = combustion.StatLines,
		ExtractValues             = combustion.ExtractValues,
	}

	-- its Scorch lands for 999 rather than 400
	if config.BoonChanges.FireAwayScorch.Enabled then
		mod.FireAwayEffect.OnBlockDamageFunction.Args.EffectArgs.NumStacks = 999
	end

	if not config.BoonChanges.BurningMeteor.Enabled then return end

	local fireballs = { 'ProjectileCastFireball', 'ProjectileFireball' }

	combustion.OnBlockDamageFunction = nil
	combustion.OnWeaponFiredFunctions = nil
	combustion.OnProjectileDeathFunction = nil

	combustion.AddOutgoingDamageModifiers = {
		ValidProjectiles = fireballs,
		ValidProjectilesLookup = game.ToLookup(fireballs),
		ValidWeaponMultiplier = mod.tuning.BurningMeteor.FireballMultiplier,
	}

	combustion.OnDamageEnemyFunction = {
		FunctionName = _PLUGIN.guid .. '.BurningMeteor',
		FunctionArgs = {
			ValidProjectilesLookup = game.ToLookup(fireballs),
		},
	}

	combustion.OnProjectileCreationFunction = {
		ValidProjectiles = fireballs,
		ValidProjectilesLookup = game.ToLookup(fireballs),
		Name = _PLUGIN.guid .. '.BurningMeteorSize',
		Args = {
			AreaMultiplier = mod.tuning.BurningMeteor.SizeMultiplier,
		},
	}

	game.TraitRequirements.BurnSprintBoon = {
		OneFromEachSet = {
			{ 'HestiaWeaponBoon', 'HestiaSpecialBoon', 'HestiaCastBoon' },   -- Flame Strike / Flourish / Smolder Ring
			{ 'CastProjectileBoon', 'FireballManaSpecialBoon' },             -- Glowing Coal / Controlled Burn
			{ 'BurnExplodeBoon', 'BurnArmorBoon', 'AloneDamageBoon' },       -- Flash Fry / Hot Pot / Snuffed Candle
		},
	}

	combustion.BoonEditFireballMultiplier = mod.tuning.BurningMeteor.FireballMultiplier
	combustion.StatLines = { 'BoonEditMeteorDamageStatDisplay' }
	combustion.ExtractValues = {
		{
			Key = 'BoonEditFireballMultiplier',
			ExtractAs = 'TooltipFireballDamage',
			Format = 'PercentDelta',
		},
	}
end)


function burning_meteor_active()
	return config.BoonChanges.BurningMeteor.Enabled and game.HeroHasTrait('BurnSprintBoon')
end

-- Scorch is pending damage one for one, so a fireball deals its damage twice over.
function mod.BurningMeteor(args, attacker, victim, triggerArgs)
	if not burning_meteor_active() then return end
	-- ApplyBurn reads ActiveEffects unguarded, and a fireball can hit something with none
	if not victim or not victim.ObjectId or victim.IsDead or not victim.ActiveEffects then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or attacker ~= hero then return end

	-- Burn damage arrives here too, and would otherwise keep topping itself back up
	if not triggerArgs or triggerArgs.EffectName then return end

	local fireballs = args and args.ValidProjectilesLookup
	if not fireballs or not fireballs[triggerArgs.SourceProjectile] then return end

	local damage = triggerArgs.DamageAmount
	if type(damage) ~= 'number' or damage <= 0 then return end

	game.ApplyBurn(victim, {
		EffectName = 'BurnEffect',
		NumStacks = math.floor(damage + 0.5),
	}, triggerArgs)
end

-- Size is engine-side, so the projectile is widened once it exists. Fraction multiplies.
function mod.BurningMeteorSize(triggerArgs, args)
	if not burning_meteor_active() then return end
	if not triggerArgs or not triggerArgs.ProjectileId then return end

	game.SetDamageRadiusMultiplier({
		Id = triggerArgs.ProjectileId,
		Fraction = args and args.AreaMultiplier or 1,
		Duration = 0,
	})
end


if config.BoonChanges.BurningMeteor.Enabled then
	boon_text({
		Traits = {
			BurnSprintBoon = {
				DisplayName = 'Burning Meteor',
				Description = 'Your fireball effects from {#BoldFormatGraft}Hestia {#Prev}are larger, deal more damage, and inflict {$Keywords.Burn} equal to the damage they deal.',
			},
		},
		StatLines = {
			BoonEditMeteorDamageStatDisplay = 'Fireball Damage:',
		},
	})
end
