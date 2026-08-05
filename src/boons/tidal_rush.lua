---@meta _
---@diagnostic disable: lowercase-global

-- Breaker Rush (Poseidon) gains Tidal Ring's splash on starting a Dash and again on stopping,
-- knocking foes away and inflicting Froth. It keeps its own name; only what it does is changed.

mod.tuning.TidalRush = {
	WaveDamage = { Common = 20, Rare = 25, Epic = 30, Heroic = 35 },
	Radius = 400,
	Knockback = 2000,
}

once('BreakerRushWaves', function()
	if not config.BoonChanges.BreakerRushWaves.Enabled then return end

	local breaker = game.TraitData.PoseidonSprintBoon

	breaker.OnEnemyDamagedAction = nil

	local waveDamage = game.GetBaseDataValue({ Type = 'Projectile', Name = 'PoseidonCastSplashSplinter', Property = 'Damage' })
	if type(waveDamage) ~= 'number' or waveDamage <= 0 then
		waveDamage = 60
	end

	breaker.RarityLevels = {}
	for rarity, damage in pairs(mod.tuning.TidalRush.WaveDamage) do
		breaker.RarityLevels[rarity] = { Multiplier = damage / waveDamage }
	end

	breaker.OnWeaponFiredFunctions = {
		ValidWeapons = { 'WeaponBlink' },
		ValidWeaponsLookup = game.ToLookup({ 'WeaponBlink' }),
		ExcludeLinked = true,
		FunctionName = _PLUGIN.guid .. '.BreakerRushStart',
		FunctionArgs = {
			ProjectileName = 'PoseidonCastSplashSplinter',
			DamageMultiplier = { BaseValue = 1, DecimalPlaces = 3 },
			ReportValues = { ReportedMultiplier = 'DamageMultiplier' },
		},
	}
	breaker.OnSprintEndAction = { FunctionName = _PLUGIN.guid .. '.BreakerRushEnd' }
	breaker.OnBlinkEndAction = {
		FunctionName = _PLUGIN.guid .. '.BreakerRushEnd',
		FunctionArgs = {
			CheckSprint = true,
			TraitName = 'PoseidonSprintBoon',
			Name = 'BreakerRushNoCooldown',
			Cooldown = 0,
		},
	}

	breaker.StatLines = { 'SplashDamageStatDisplay1' }
	breaker.ExtractValues = {
		{
			Key = 'ReportedMultiplier',
			ExtractAs = 'Damage',
			Format = 'MultiplyByBase',
			BaseType = 'Projectile',
			BaseName = 'PoseidonCastSplashSplinter',
			BaseProperty = 'Damage',
		},
	}

	-- Froth by Tidal Ring's own means: the splash applies ImpactSlow and this converts it
	breaker.OnEffectApplyFunction = {
		FunctionName = 'CheckSlipApply',
		FunctionArgs = {
			EffectName = 'AmplifyKnockbackEffect',
		},
	}
end)


-- Guards and latch mirror Smithy Rush's, but the two boons keep separate latches.
function fire_breaker_rush_wave(args, triggerArgs)
	if args and args.CheckSprint and game.ConfigOptionCache.SprintAutoHold and game.SessionMapState.SprintActive then
		return
	end
	if not game.ConfigOptionCache.SprintAutoHold
		and ((triggerArgs and triggerArgs.Canceled) or (args and args.CheckSprint and game.SessionMapState.SprintActive)) then
		return
	end

	local trait = game.GetHeroTrait('PoseidonSprintBoon')
	local traitArgs = trait and trait.OnWeaponFiredFunctions and trait.OnWeaponFiredFunctions.FunctionArgs
	if not traitArgs then return end

	-- Set outright: Tidal Ring overrides the radius anyway, and the splash has no knockback.
	local dataProperties = {
		DamageRadius = mod.tuning.TidalRush.Radius,
		ImpactVelocity = mod.tuning.TidalRush.Knockback,
	}

	game.CreateProjectileFromUnit({
		Name = traitArgs.ProjectileName,
		Id = game.CurrentRun.Hero.ObjectId,
		DestinationId = game.CurrentRun.Hero.ObjectId,
		FireFromTarget = true,
		DamageMultiplier = traitArgs.DamageMultiplier,
		DataProperties = dataProperties,
	})

	game.SessionMapState.BoonEditBreakerRushStarted = nil
end

function mod.BreakerRushStart(args, triggerArgs)
	fire_breaker_rush_wave(args, triggerArgs)
	game.SessionMapState.BoonEditBreakerRushStarted = true
end

function mod.BreakerRushEnd(args, triggerArgs)
	if not game.SessionMapState.BoonEditBreakerRushStarted then return end
	fire_breaker_rush_wave(args, triggerArgs)
end


if config.BoonChanges.BreakerRushWaves.Enabled then
	boon_text({
		Traits = {
			-- keeps its own name; only what it does is changed
			PoseidonSprintBoon = {
				Description = '{$Keywords.DashSet} damages surrounding foes and inflicts {$Keywords.KnockbackAmplify}, and again once you stop.',
			},
		},
	})
end
