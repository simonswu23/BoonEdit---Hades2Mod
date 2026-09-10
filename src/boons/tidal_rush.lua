---@meta _
---@diagnostic disable: lowercase-global


local BREAKER_RUSH_WEAPONS = { 'WeaponBlink', 'WeaponSprint' }


once('BreakerRushWaves', function()
	if not config.BoonChanges.BreakerRush.Enabled then return end

	local breaker = game.TraitData.PoseidonSprintBoon

	local waveDamage = game.GetBaseDataValue({ Type = 'Projectile', Name = 'PoseidonCastSplashSplinter', Property = 'Damage' })
	if type(waveDamage) ~= 'number' or waveDamage <= 0 then
		waveDamage = 60
	end

	breaker.RarityLevels = {}
	for rarity, damage in pairs(mod.tuning.TidalRush.WaveDamage) do
		breaker.RarityLevels[rarity] = { Multiplier = damage / waveDamage }
	end

	breaker.OnWeaponFiredFunctions = {
		ValidWeapons = game.DeepCopyTable(BREAKER_RUSH_WEAPONS),
		ValidWeaponsLookup = game.ToLookup(BREAKER_RUSH_WEAPONS),
		ExcludeLinked = true,
		FunctionName = _PLUGIN.guid .. '.BreakerRushStart',
		FunctionArgs = {
			ProjectileName = 'PoseidonCastSplashSplinter',
			DamageMultiplier = {
				BaseValue = 1,
				DecimalPlaces = 3,

				AbsoluteStackValues = {
					[1] = mod.tuning.TidalRush.PomDamage.First / waveDamage,
					[2] = mod.tuning.TidalRush.PomDamage.Rest / waveDamage,
				},
			},
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
	breaker.ExtractValues = with_keyword_extracts({
		{
			Key = 'ReportedMultiplier',
			ExtractAs = 'Damage',
			Format = 'MultiplyByBase',
			BaseType = 'Projectile',
			BaseName = 'PoseidonCastSplashSplinter',
			BaseProperty = 'Damage',
		},
	}, 'KnockbackAmplify')

	breaker.OnEnemyDamagedAction = {
		ValidProjectiles = { 'PoseidonCastSplashSplinter' },
		FunctionName = _PLUGIN.guid .. '.BreakerRushFroth',
		Args = {},
	}
end)


---@diagnostic disable-next-line: unused-local
function mod.BreakerRushFroth(victim, _args, triggerArgs)
	if not config.BoonChanges.BreakerRush.Enabled then return end
	if not victim or not victim.ObjectId then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local effectName = 'AmplifyKnockbackEffect'
	local effect = game.EffectData[effectName]
	if not effect then return end

	game.ApplyEffect({
		DestinationId = victim.ObjectId,
		Id = hero.ObjectId,
		EffectName = effectName,
		ImpactAngle = math.rad((triggerArgs and triggerArgs.ImpactAngle) or 0),
		DataProperties = effect.EffectData,
	})
end


function fire_breaker_rush_wave(args, triggerArgs)
	if args and args.CheckSprint and game.ConfigOptionCache.SprintAutoHold and game.SessionMapState.SprintActive then
		return
	end
	if not game.ConfigOptionCache.SprintAutoHold
		and ((triggerArgs and triggerArgs.Canceled) or (args and args.CheckSprint and game.SessionMapState.SprintActive)) then
		return
	end

	breaker_rush_splash()

	game.SessionMapState.BoonEditBreakerRushStarted = nil
end


function breaker_rush_splash()
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local trait = game.GetHeroTrait('PoseidonSprintBoon')
	local traitArgs = trait and trait.OnWeaponFiredFunctions and trait.OnWeaponFiredFunctions.FunctionArgs
	if not traitArgs then return end

	---@diagnostic disable-next-line: undefined-global
	local scale, count, graphic = poseidon_splash_cone()

	---@diagnostic disable-next-line: undefined-global
	arterial_spray_begin({ ProjectileName = traitArgs.ProjectileName })

	local ok, err = pcall(function()
		for i = 1, count do
			game.CreateProjectileFromUnit({
				Name = traitArgs.ProjectileName,
				Id = hero.ObjectId,
				DestinationId = hero.ObjectId,
				FireFromTarget = true,
				DamageMultiplier = traitArgs.DamageMultiplier,
				ScaleMultiplier = scale,
				SpeedMultiplier = scale,
				DataProperties = {
					DamageRadius = mod.tuning.TidalRush.Radius,
					ImpactVelocity = mod.tuning.TidalRush.Knockback,
					StartFx = graphic,
					StartDelay = (i - 1) * mod.tuning.PoseidonSplash.WaveDelay,
				},
			})
		end
	end)

	---@diagnostic disable-next-line: undefined-global
	arterial_spray_end()
	if not ok then error(err) end
end


function mod.BreakerRushStart(weaponData, _args, _triggerArgs)
	if weaponData and weaponData.Name == 'WeaponSprint' then
		if game.CheckCooldown('BoonEditBreakerRushTrail', mod.tuning.TidalRush.TrailInterval) then
			breaker_rush_splash()
		end
		return
	end

	breaker_rush_splash()
	game.SessionMapState.BoonEditBreakerRushStarted = true
end

function mod.BreakerRushEnd(args, triggerArgs)
	if not game.SessionMapState.BoonEditBreakerRushStarted then return end
	fire_breaker_rush_wave(args, triggerArgs)
end
