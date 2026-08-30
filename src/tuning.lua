---@meta _
---@diagnostic disable: lowercase-global


mod.tuning = {}

mod.tuning.CarnalPleasure = {
	BaseDamage = 50,
	DamagePerPlasma = 1,
	BaseRadius = 1.20,
	RadiusPerPlasma = 0.01,
	PlasmaCeiling = 999,
	PlasmaManaValue = 10,
	HeartthrobCapacity = 12,
	ShowHeartthrobCapacity = true,
}

mod.tuning.PowerSurge = {
	RestoreCooldown = 0.35,
}

mod.tuning.HeartyAppetite = {
	HealingBonus = 1.5,

	Food = 'HealBigDrop',
	FoodOnPickup = 1,
	EncountersPerFood = 5,

	Spread = 190,
	Delay = 0.5,
}

mod.tuning.SmolderingForge = {
	HeartthrobChance = 0.20,
}

mod.tuning.EcstaticObsession = {
	CharmChance = 0.30,
	CharmDuration = 5,
	InterruptCooldown = 5,

	-- How long a Guardian is left alone after being Charmed. Lesser foes have none: they shake it
	-- off on their own and there is nothing to protect. A Guardian shakes it off several times
	-- faster (`CharmBreakModifier`, `Enemies.sjson`), so without this the next Weak to land could
	-- put it straight back under and hold a boss out of the fight indefinitely.
	GuardianCharmCooldown = 5,
	DamagePerFriendly = 0.10,
	MaxDamageBonus = 0.50,

	AllyRange = 430,

	SpareBosses = false,
}

mod.tuning.MeatGrinder = {
	PlasmaChance = 0.10,
	PlasmaCooldown = 0.5,
}

mod.tuning.ProfuseBleeding = {
	SpillChance = 0.10,
}

mod.tuning.BloodSpree = {
	KillHealChance = 0.20,
}

mod.tuning.IonicGain = {
	ManaPerSecond = 6,

	Range = 450,
	Interval = 0.25,

	RarityScale = {
		Common = 1.00,
		Rare = 1.34,
		Epic = 1.67,
		Heroic = 2.00,
	},
}

mod.tuning.BeachBall = {
	BlastDamage = 400,

	-- `ProjectileSprintBall`'s own `DamageRadius`, fallen back on when the ball is already gone by
	-- the time its death is reported.
	BlastRadius = 250,

	-- What the splash boons' extra wave is fired as. The ball itself is a steered, growing orb and
	-- cannot simply be made twice; the radial splinter is the same shape its blast leaves and the
	-- same one Tidal Ring's waves are.
	WaveProjectile = 'PoseidonCastSplashSplinter',
}

mod.tuning.GloriousDisaster = {
	SkipSuperchargeCondition = true,
	BoltDamage = 50,
}

mod.tuning.SeismicHammer = {
	BlastCooldownReduction = 1,

	MinimumBlastCooldown = 0.1,
}

mod.tuning.SunWorshiper = {
	RepeatChance = 0.30,

	MaxRepeats = 10,

	WardSummons = true,
}

mod.tuning.TranquilGain = {
	HoldSeconds = 0.5,
}

mod.tuning.WinterHarvest = {
	ExecuteThreshold = 0.15,
}

mod.tuning.NaturalSelection = {
	PomsOnPickup = 3,

	LevelsPerPom = 3,
	EncountersPerPom = 8,
}

mod.tuning.UnseenIre = {
	Cooldown = 30,
}

mod.tuning.AnvilRush = {
	GlowPerStack = 0.05,
	GlowMax = 1.35,
	TrailInterval = 0.5,
}

mod.tuning.MoltenTouch = {
	GlowMultiplier = 1.2,
	GlowStackValues = { 1.1, 1.05 },
}

mod.tuning.AnvilOfFates = {
	SacrificeChoices = 3,
	Discoveries = 2,
}

-- 15 / 20 / 25 / 30% across the rarities, off a Common of 0.15
mod.tuning.DazzlingDisplay = {
	Chance = 0.15,

	RarityMultipliers = {
		Common = 1.0,
		Rare = 20 / 15,
		Epic = 25 / 15,
		Heroic = 30 / 15,
	},
}

mod.tuning.ChainReaction = {
	SkipChance = 0.50,

	TextDuration = 1.45,
	TextCooldown = 0.5,
}

mod.tuning.BraveFace = {
	DamageBlocked = 0.50,
	ManaPerDamage = 5,
}

mod.tuning.RousingReception = {
	CastDurationMultiplier = 1.5,

	HitchOnly = true,
	UseCastStrikes = true,
	DamageScaledCurseMultiplier = 1.0,
}

mod.tuning.CherishedHeirloom = {
	ExtraKeepsake = true,
	ExtraKeepsakeInMenuOnly = true,
}

mod.tuning.SecondWind = {
	KeepsakeOfferChance = 0.10,
	ExtraCasts = 1,
	ExtraDashes = 1,
	DashRechargeMultiplier = 0.90,
	DashCooldownMultiplier = 0.40,
}

mod.tuning.BurningMeteor = {
	FireballMultiplier = 1.5,
	SizeMultiplier = 2.0,
}

mod.tuning.CardioGain = {
	SprintManaGain = 0.75,
}

mod.tuning.Fireballs = {
	Projectiles = { 'ProjectileCastFireball', 'ProjectileFireball', 'SWuHestiaFireball' },

	Traits = { 'FireballRendBoon', 'SteamBoon' },
}

-- Shared by every splash this mod fires itself. `ConeModifier` is only ever read inside vanilla's own
-- splash functions, so a boon that fires straight has to do the reading -- and three of ours now do.
-- Easy Shot's piercing arrow. The boon reports its damage as a multiple of `ArtemisCastVolley`'s own
-- 50, so doubling the multiplier doubles the printed figure at every rarity: 50/60/70/80 becomes
-- 100/120/140/160. Poms cannot be spent on this boon at all -- see `easy_shot.lua`.
mod.tuning.EasyShot = {
	DamageMultiplier = 2.0,
	CritChance = 0.20,
}

mod.tuning.PoseidonSplash = {
	-- Our own radial red nova, registered in `sjson_PoseidonVfx`. Arterial Spray's own marker is a
	-- cone, which is the right shape for the Attack and Special splash and the wrong one for these:
	-- they go off all round, and the cone pointed one way across a circle that did not.
	RedNova = 'SWuPoseidonRedNova',

	-- The gap between one wave and the next. Vanilla's own spacing (`PowersLogic.lua:3826`).
	WaveDelay = 0.1,
}

mod.tuning.TidalRing = {
	-- What `CheckPoseidonCastSplash` falls back to when the Cast is gone (`PowersLogic.lua:1859`)
	Radius = 430,
}

mod.tuning.TidalRush = {
	WaveDamage = { Common = 50, Rare = 55, Epic = 60, Heroic = 65 },

	-- What a Pom of Power adds, in damage: the first one, then every one after it. Vanilla's own
	-- figures for this boon (20 then 10 against an 80-damage blast); they are written here in damage
	-- and divided by the splash's base below, because `AbsoluteStackValues` are multipliers.
	PomDamage = { First = 20, Rest = 10 },

	-- How often the sprint lays a splash behind it, on top of the two at either end.
	TrailInterval = 0.5,

	Radius = 400,
	Knockback = 2000,
}

mod.tuning.PassionRush = {
	TrailInterval = 0.5,
}

mod.tuning.ArterialSpray = {
	SecondWavePower = 0.30,
}

mod.tuning.StabbingRush = {
	ProjectileCap = 30,
}

mod.tuning.RippleEffect = {
	RepeatChance = 0.50,

	Falloff = 0.5,
	MaxRepeats = 4,
}

mod.tuning.ShockingLoss = {
	GuardianDamage = 9999,
}

mod.tuning.KillerCurrent = {
	BoltChance = 0.30,
	BoltPower = 30,

	-- The shortest gap between two bolts. Froth sits on a foe for a while and every hit that lands
	-- on it rolls again, so a fast weapon into a Frothed crowd rolled many times a second.
	BoltCooldown = 0.5,
}

mod.tuning.ThermalDynamics = {
	ScorchFraction = 0.30,
}

mod.tuning.HarmForTheAfflicted = {
	Interval = 0.3,
}

mod.tuning.Pandemonium = {
	KeepsakeOfferChance = 0.10,

	MaxGodsPerRun = 99,

	ExtraDoorEntries = 1,
}
