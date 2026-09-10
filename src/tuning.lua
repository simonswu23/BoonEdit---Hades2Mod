---@meta _
---@diagnostic disable: lowercase-global


mod.tuning = {}

mod.tuning.CarnalPleasure = {
	HeartthrobChance = 0.35,

	HealPerPlasma = 1,
}

mod.tuning.FestiveFog = {
	Shelter = 0.60,
}

mod.tuning.GrapeJuice = {
	Heal = 20,
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

	BlastRadius = 250,

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

	-- Cooldowns that belong to a boon but are not written in its trait data, so the sweep of held
	-- traits cannot find them. Ours, from the other two mods.
	ExtraCooldowns = { 'SWuLandMine', 'SWuSolarEclipse' },

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
	KeepAllKeepsakes = false,
	RefreshHeldKeepsake = true,
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
	Projectiles = {
		'ProjectileCastFireball', 'ProjectileFireball', 'SWuHestiaFireball', 'SWuVolcanicFireball',
	},

	Traits = { 'FireballRendBoon', 'SteamBoon' },
}

mod.tuning.EasyShot = {
	DamageMultiplier = 2.0,
	CritChance = 0.20,
}

mod.tuning.PoseidonSplash = {
	RedNova = 'SWuPoseidonRedNova',

	WaveDelay = 0.1,
}

mod.tuning.TidalRing = {
	Radius = 430,
}

mod.tuning.TidalRush = {
	WaveDamage = { Common = 50, Rare = 55, Epic = 60, Heroic = 65 },

	PomDamage = { First = 20, Rest = 10 },

	TrailInterval = 0.5,

	Radius = 400,
	Knockback = 2000,
}

mod.tuning.BurningDesire = {
	-- What Scorch may stack to while it is held, against vanilla's 999.
	ScorchCap = 9999,
}

mod.tuning.PassionRush = {
	TrailInterval = 0.2,
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

	BoltCooldown = 0.5,
}

mod.tuning.ThermalDynamics = {
	ScorchFraction = 0.30,
}

mod.tuning.HarmForTheAfflicted = {
	Interval = 0.3,
}

mod.tuning.ConcaveStone = {}

mod.tuning.CallingCard = {}

mod.tuning.WhiteAntler = {}

mod.tuning.MetallicDroplet = {
	ResidualFraction = 0.5,
}

mod.tuning.Pandemonium = {
	KeepsakeOfferChance = 0.10,

	MaxGodsPerRun = 99,

	ExtraDoorEntries = 1,
}
