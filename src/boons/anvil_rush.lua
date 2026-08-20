---@meta _
---@diagnostic disable: lowercase-global


once('AnvilRing', function()
	if not config.BoonChanges.AnvilRing.Enabled then return end

	local blast = game.ProjectileData.HephCastBlast
	blast.OnHitFunctionNames = blast.OnHitFunctionNames or {}
	table.insert(blast.OnHitFunctionNames, _PLUGIN.guid .. '.AnvilGlow')

	local cast = game.TraitData.HephaestusCastBoon

	local baseDamage = game.GetBaseDataValue({ Type = 'Projectile', Name = 'HephCastBlast', Property = 'Damage' })
	if type(baseDamage) ~= 'number' or baseDamage <= 0 then
		baseDamage = 60
	end
	local cut = 10 / baseDamage

	for _, level in pairs(cast.RarityLevels) do
		level.Multiplier = level.Multiplier - cut
	end
end)


once('SmithyRush', function()
	if not config.BoonChanges.SmithyRush.Enabled then return end

	local cast = game.TraitData.HephaestusCastBoon
	local dash = game.TraitData.HephaestusSprintBoon

	local castArgs = cast.OnWeaponFiredFunctions.FunctionArgs
	local halved = {
		BaseValue = castArgs.DamageMultiplier.BaseValue / 2,
		DecimalPlaces = 3,
		AbsoluteStackValues = {},
	}
	for i, value in pairs(castArgs.DamageMultiplier.AbsoluteStackValues) do
		halved.AbsoluteStackValues[i] = value / 2
	end

	dash.RarityLevels = {}
	for rarity, level in pairs(cast.RarityLevels) do
		dash.RarityLevels[rarity] = { Multiplier = level.Multiplier }
	end

	dash.SetupFunction = nil
	dash.BlastReadyVfx = nil
	dash.BlastReadyDarkVfx = nil

	dash.OnWeaponFiredFunctions = {
		ValidWeapons = { 'WeaponBlink' },
		ValidWeaponsLookup = game.ToLookup({ 'WeaponBlink' }),
		ExcludeLinked = true,
		FunctionName = _PLUGIN.guid .. '.AnvilRushStart',
		FunctionArgs = {
			ProjectileName = castArgs.ProjectileName,
			DamageMultiplier = halved,
			ReportValues = { ReportedMultiplier = 'DamageMultiplier' },
		},
	}
	dash.OnSprintEndAction = { FunctionName = _PLUGIN.guid .. '.AnvilRushEnd' }
	dash.OnBlinkEndAction = {
		FunctionName = _PLUGIN.guid .. '.AnvilRushEnd',
		FunctionArgs = {
			CheckSprint = true,
			TraitName = 'HephaestusSprintBoon',
			Name = 'AnvilRushNoCooldown',
			Cooldown = 0,
		},
	}

	dash.StatLines = { 'BlastDamageStatDisplay1' }
	dash.ExtractValues = {
		{
			Key = 'ReportedMultiplier',
			ExtractAs = 'Damage',
			Format = 'MultiplyByBase',
			BaseType = 'Projectile',
			BaseName = 'HephCastBlast',
			BaseProperty = 'Damage',
		},
	}
end)


local ANVIL_RUSH_SCALE = 0.5

local ANVIL_RUSH_WINDUP = 0.35

function anvil_rush_presentation(locationX, locationY)
	local centerId = game.SpawnObstacle({ Name = 'BlankObstacle', LocationX = locationX, LocationY = locationY })
	local playSpeed = 1 / ANVIL_RUSH_WINDUP
	game.SetAnimation({ Name = 'HephMassiveHitHammerCast', DestinationId = centerId, Scale = ANVIL_RUSH_SCALE, PlaySpeed = playSpeed })
	game.waitUnmodified(ANVIL_RUSH_WINDUP)
	game.SetAnimation({ Name = 'HephMassiveHitFixed', DestinationId = centerId, Scale = ANVIL_RUSH_SCALE, PlaySpeed = playSpeed })
	game.DestroyOnDelay({ centerId }, 1)
end

function fire_anvil_rush_strike(args, triggerArgs)
	if args and args.CheckSprint and game.ConfigOptionCache.SprintAutoHold and game.SessionMapState.SprintActive then
		return
	end
	if not game.ConfigOptionCache.SprintAutoHold
		and ((triggerArgs and triggerArgs.Canceled) or (args and args.CheckSprint and game.SessionMapState.SprintActive)) then
		return
	end

	local trait = game.GetHeroTrait('HephaestusSprintBoon')
	local traitArgs = trait and trait.OnWeaponFiredFunctions and trait.OnWeaponFiredFunctions.FunctionArgs
	if not traitArgs then return end

	local dataProperties = nil
	local castRadius = game.GetBaseDataValue({ Type = 'Projectile', Name = 'ProjectileCast', Property = 'DamageRadius' })
	if type(castRadius) == 'number' and castRadius > 0 then
		dataProperties = { DamageRadius = castRadius * ANVIL_RUSH_SCALE }
	end

	game.CreateProjectileFromUnit({
		Name = traitArgs.ProjectileName,
		Id = game.CurrentRun.Hero.ObjectId,
		DestinationId = game.CurrentRun.Hero.ObjectId,
		FireFromTarget = true,
		DamageMultiplier = traitArgs.DamageMultiplier,
		DataProperties = dataProperties,
	})

	local location = game.GetLocation({ Id = game.CurrentRun.Hero.ObjectId })
	if location then
		game.thread(anvil_rush_presentation, location.X, location.Y)
	end

	game.SessionMapState.BoonEditAnvilRushStarted = nil
end

function mod.AnvilRushStart(args, triggerArgs)
	fire_anvil_rush_strike(args, triggerArgs)
	game.SessionMapState.BoonEditAnvilRushStarted = true
end

function mod.AnvilRushEnd(args, triggerArgs)
	if not game.SessionMapState.BoonEditAnvilRushStarted then return end
	fire_anvil_rush_strike(args, triggerArgs)
end

local GLOW_EFFECT = 'DelayedKnockbackEffect'

local function glow_data()
	local effect = game.EffectData[GLOW_EFFECT]
	return effect and effect.EffectData
end

local function glow_apply(victim)
	local base = glow_data()
	if not base or not victim or not victim.ObjectId then return end

	local stacks = victim.BoonEditGlowStacks or 0
	if stacks <= 0 then
		game.ClearEffect({ Id = victim.ObjectId, Name = GLOW_EFFECT })
		return
	end

	local tuning = mod.tuning.AnvilRush
	local modifier = math.min(base.Modifier + (stacks - 1) * tuning.GlowPerStack, tuning.GlowMax)

	game.ApplyEffect({
		DestinationId = victim.ObjectId,
		Id = game.CurrentRun.Hero.ObjectId,
		EffectName = GLOW_EFFECT,
		DataProperties = game.MergeAllTables({ base, { Modifier = modifier } }),
	})
end

function glow_expire(victim)
	local base = glow_data()
	game.wait((base and base.Duration) or 5, game.RoomThreadName)

	if not victim or victim.IsDead then return end
	victim.BoonEditGlowStacks = math.max((victim.BoonEditGlowStacks or 1) - 1, 0)
	glow_apply(victim)
end

---@diagnostic disable-next-line: unused-local
function mod.AnvilGlow(victim, _victimId, triggerArgs)
	if not config.BoonChanges.AnvilRing.Enabled then return end
	if not victim or not victim.ObjectId then return end

	victim.BoonEditGlowStacks = (victim.BoonEditGlowStacks or 0) + 1
	glow_apply(victim)
	game.thread(glow_expire, victim)
end
