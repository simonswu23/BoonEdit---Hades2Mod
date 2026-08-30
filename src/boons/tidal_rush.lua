---@meta _
---@diagnostic disable: lowercase-global


-- `WeaponBlink` fires once as the dash goes off; `WeaponSprint` fires over and over for as long as a
-- sprint is held. Named here rather than inline because `breaker_rush_sync` needs the same list, and
-- it must not read it back off `TraitData` -- see there.
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

	-- Vanilla's own Breaker Rush laid its continuous trail off `WeaponSprint` with a `CheckCooldown`
	-- for a throttle rather than a thread (`PowersLogic.lua:1881`). The dispatch matches on
	-- `ValidWeaponsLookup`, not `ValidWeapons` (`CombatLogic.lua:3267`), so both are set.
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

				-- Without this a Pom adds `BaseValue * 1` -- a whole extra splash's worth of damage,
				-- +60 on a boon that deals 50 at Common. `AbsoluteStackValues` is how vanilla keeps
				-- a Pom sane: it replaces the base for every stack past the first, so [1] is what
				-- the first Pom adds and [2] what every one after it does. Vanilla's own Breaker
				-- Rush carried `{ [1] = 20/80, [2] = 10/80 }` against its 80-damage blast, and
				-- rewriting `FunctionArgs` wholesale is what dropped it.
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

	-- Froth off the splash itself, not off `CheckSlipApply`. That function only fires when the effect
	-- landing is `ImpactSlow` (`PowersLogic.lua:1906`), and `ImpactSlow` is the *Cast's* slow -- it is
	-- how the game knows a foe is standing in a binding circle. Tidal Ring is a Cast boon, so reading
	-- it works there; Breaker Rush is a dash boon and applies nothing of the sort, so the Froth landed
	-- only when a Cast happened to be slowing the same foe. Naming the splinter is what makes it the
	-- splash's own doing, every time.
	breaker.OnEnemyDamagedAction = {
		ValidProjectiles = { 'PoseidonCastSplashSplinter' },
		FunctionName = _PLUGIN.guid .. '.BreakerRushFroth',
		Args = {},
	}
end)


-- Applied by hand rather than through the `EffectName` the engine would apply for us. That path ends
-- at `PowersLogic.lua:192`, which does `math.rad(args.ImpactAngle)` with no guard -- and this splash
-- is an INSTANT, radial, `UseStartLocation` blast centred on Melinoe, so its damage arrives with no
-- impact angle at all and the game faults on it. Vanilla never meets this because Tidal Ring, the
-- only other boon firing this projectile, hangs its Froth off `OnEffectApplyFunction` instead.
--
-- The sibling branch at `:226` reads `args.ImpactAngle or 0`, so a nil angle is a case the game
-- itself expects everywhere except the line we were routed through.
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


-- One splash where Melinoe is standing. The splinter is INSTANT with `Fuse = 0.0`, so it goes off
-- on the spot and stays there -- which is the whole of the trail: fired on a beat while she runs, it
-- falls behind on its own.
function breaker_rush_splash()
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local trait = game.GetHeroTrait('PoseidonSprintBoon')
	local traitArgs = trait and trait.OnWeaponFiredFunctions and trait.OnWeaponFiredFunctions.FunctionArgs
	if not traitArgs then return end

	---@diagnostic disable-next-line: undefined-global
	local scale, count, graphic = poseidon_splash_cone()

	-- Arterial Spray's *power* half is separate from its extra wave: the wave comes out of
	-- `ConeModifier` above, but the reduction is a `CreateProjectileFromUnit` wrap that only arms
	-- itself for the length of a vanilla splash function. Opening the same window by hand is what
	-- keeps the second wave at the reduced power the tooltip promises rather than full strength.
	-- It reads the delay to tell the waves apart, which is why the first carries none.
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


-- Two separate reasons the weapon list goes stale, and this repairs both every room load.
--
-- `once` writes `mod.SetupDone[key]` and never runs its body again for the life of the process, so a
-- hot reload re-imports this file but does not re-apply the block above -- `TraitData` itself keeps
-- the old list until the game is relaunched. And a held boon is a snapshot: `AddTraitToHero`
-- deep-copies `TraitData` into `hero.Traits` at pickup and that copy lives in the save, so even after
-- a relaunch a Breaker Rush taken earlier keeps the one-weapon lookup and never hears `WeaponSprint`
-- -- you get the opening and closing splash and nothing in between.
--
-- So the constant is the source of truth here, not `TraitData`, which may itself be behind. The fire
-- dispatch reads `HeroTraitValuesCache` (`CombatLogic.lua:3266`) rather than the trait, so the cache
-- has to be rebuilt after the edit or nothing changes.
function breaker_rush_sync()
	if not config.BoonChanges.BreakerRush.Enabled then return end

	local repaired = false

	local source = game.TraitData.PoseidonSprintBoon
	if source and breaker_rush_weapons_stale(source.OnWeaponFiredFunctions) then
		breaker_rush_set_weapons(source.OnWeaponFiredFunctions)
		repaired = true
	end

	local held = game.GetHeroTrait('PoseidonSprintBoon')
	if held and breaker_rush_weapons_stale(held.OnWeaponFiredFunctions) then
		breaker_rush_set_weapons(held.OnWeaponFiredFunctions)
		game.UpdateHeroTraitDictionary()
		repaired = true
	end

	if repaired then
		print('[' .. _PLUGIN.guid .. '] Breaker Rush was carrying an older weapon list; refreshed it')
	end
end


function breaker_rush_weapons_stale(fired)
	if not fired then return false end

	local lookup = fired.ValidWeaponsLookup or {}
	for _, name in ipairs(BREAKER_RUSH_WEAPONS) do
		if not lookup[name] then return true end
	end
	return false
end


function breaker_rush_set_weapons(fired)
	fired.ValidWeapons = game.DeepCopyTable(BREAKER_RUSH_WEAPONS)
	fired.ValidWeaponsLookup = game.ToLookup(BREAKER_RUSH_WEAPONS)
end


-- `(weaponData, FunctionArgs, triggerArgs)` -- three, not two (`CombatLogic.lua:3268`). Both weapons
-- come through here, and which one fired is the only thing that tells the dash's opening splash
-- apart from a beat of the trail behind it.
function mod.BreakerRushStart(weaponData, _args, _triggerArgs)
	if weaponData and weaponData.Name == 'WeaponSprint' then
		if game.CheckCooldown('BoonEditBreakerRushTrail', mod.tuning.TidalRush.TrailInterval) then
			breaker_rush_splash()
		end
		return
	end

	-- The opening splash is unconditional, so it does not go through `fire_breaker_rush_wave`: those
	-- guards exist to decide whether the *closing* one is owed, and now that this handler is signed
	-- correctly it would be handing them a real `triggerArgs` to read `Canceled` off for the first
	-- time. The flag is what stops the two end actions from both paying out.
	breaker_rush_splash()
	game.SessionMapState.BoonEditBreakerRushStarted = true
end

function mod.BreakerRushEnd(args, triggerArgs)
	if not game.SessionMapState.BoonEditBreakerRushStarted then return end
	fire_breaker_rush_wave(args, triggerArgs)
end
