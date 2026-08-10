---@meta _
---@diagnostic disable: lowercase-global

-- Every number behind the boon changes: the config decides which are on, this decides how much
-- each does.


mod.tuning = {}

mod.tuning.Heartthrob = {
	-- how many Heartthrobs may be in the air before making one cancels the oldest; vanilla hardcodes 6
	Capacity = 12,
}

mod.tuning.CarnalPleasure = {
	-- the floor, not the ceiling: holding Plasma takes it higher rather than switching it on
	BaseBonus = 0.50,
	PlasmaBonus = 0.30,
	-- where the game itself stops counting Plasma, so the bonus stops climbing there too
	PlasmaCeiling = 50,
	-- flat and separate from the damage, so it is not extracted and gets no stat line
	HeartSizeMultiplier = 2.0,
	PlasmaManaValue = 10,
}

mod.tuning.HeartyAppetite = {
	-- whole multiplier on all healing, summed with any other source the way Circe's 1.25 is
	HealingBonus = 1.5,
}

mod.tuning.SmolderingForge = {
	HeartthrobChance = 0.20,
}

mod.tuning.ObsessiveDevotion = {
	CharmChance = 0.30,
	CharmDuration = 5,
	InterruptCooldown = 5,
	DamagePerFriendly = 0.10,
	MaxDamageBonus = 0.50,
	-- the house "nearby" throughout both mods
	AllyRange = 430,
}

mod.tuning.ProfuseBleeding = {
	SpillChance = 0.10,
}

mod.tuning.IonicGain = {
	ManaPerSecond = 6,
	-- the drop's own spawn keeps it 450 or further out, so this is that distance read back
	Range = 450,
	Interval = 0.25,
	-- The Unseen's ladder, not Ionic Gain's own: the trait's `RarityLevels` scale a respawn interval
	-- and so run downward, which on a regen rate would mean a rarer boon restoring less.
	RarityScale = {
		Common = 1.00,
		Rare = 1.34,
		Epic = 1.67,
		Heroic = 2.00,
	},
}

mod.tuning.BeachBall = {
	-- written to the projectile rather than the boon, so the tooltip follows without a text change
	BlastDamage = 400,
}

mod.tuning.GloriousDisaster = {
	SkipSuperchargeCondition = true,
	-- lives in `PlayerProjectiles.sjson`, not Lua, so it is written through an sjson hook
	BoltDamage = 50,
}

mod.tuning.SeismicHammer = {
	-- flat, not a multiplier: `OlympianRechargeMultiplier` is the multiplier field and belongs to
	-- Post Haste, so a second helping would be the same effect twice under two names
	BlastCooldownReduction = 1,
	-- so the reduction cannot drive a recharge to zero
	MinimumBlastCooldown = 0.1,
}

mod.tuning.SunWorshiper = {
	RepeatChance = 0.30,
	-- per encounter, and not counting vanilla's own first raise
	MaxRepeats = 10,
}

mod.tuning.TranquilGain = {
	HoldSeconds = 0.5,
}

mod.tuning.WinterHarvest = {
	ExecuteThreshold = 0.15,
}

mod.tuning.NaturalSelection = {
	PomsOnPickup = 3,
	-- also picks which Pom item drops: 1 single, 2 pair, 3 cluster
	LevelsPerPom = 3,
	EncountersPerPom = 8,
}

mod.tuning.UnseenIre = {
	Cooldown = 30,
}

mod.tuning.AnvilRush = {
	-- whole multipliers, not additions to the 1.2 Glow starts at; the ceiling is on the
	-- vulnerability only, so stacks past it keep the Glow up rather than deepen it
	GlowPerStack = 0.05,
	GlowMax = 1.35,
}

mod.tuning.MoltenTouch = {
	-- whole multipliers, as vanilla's 1.4 against Armor is -- half its bonus, not half its value
	GlowMultiplier = 1.2,
	GlowStackValues = { 1.1, 1.05 },
}

mod.tuning.AnvilOfFates = {
	SacrificeChoices = 3,
	Discoveries = 2,
}

mod.tuning.ChainReaction = {
	SkipChance = 0.30,
}

mod.tuning.BraveFace = {
	DamageBlocked = 0.50,
	ManaPerDamage = 5,
}

mod.tuning.RousingReception = {
	-- the tick rate is untouched, so half again as long is half again as many ticks
	CastDurationMultiplier = 1.5,
	-- off, the curse is read off your Cast boon instead
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
}

mod.tuning.BurningMeteor = {
	FireballMultiplier = 1.5,
	SizeMultiplier = 1.5,
}

mod.tuning.CardioGain = {
	-- banked as a fraction, since Magick pays out in whole numbers
	SprintManaGain = 0.75,
}

mod.tuning.SteamProcsFroth = {
	-- fraction of the Font's own cooldown kept; vanilla's is 0.6s, so a half is 0.3s
	FontCooldownMultiplier = 0.5,
}

mod.tuning.TidalRush = {
	WaveDamage = { Common = 20, Rare = 25, Epic = 30, Heroic = 35 },
	Radius = 400,
	Knockback = 2000,
}

mod.tuning.ArterialSpray = {
	SecondWavePower = 0.30,
}

mod.tuning.StabbingRush = {
	-- blades in the air before making one cancels the oldest; high enough for the Ares sword modifiers
	ProjectileCap = 30,
}

mod.tuning.RippleEffect = {
	RepeatChance = 0.50,
	-- each repeat is this much as likely as the one before it
	Falloff = 0.5,
	MaxRepeats = 4,
}

mod.tuning.ShockingLoss = {
	GuardianDamage = 9999,
}

mod.tuning.KillerCurrent = {
	BoltChance = 0.30,
	BoltPower = 50,
}

mod.tuning.ThermalDynamics = {
	ScorchFraction = 0.60,
}

mod.tuning.HarmForTheAfflicted = {
	Interval = 0.3,
}

mod.tuning.Pandemonium = {
	KeepsakeOfferChance = 0.10,
	-- simply has to clear the number of gods that exist; vanilla's narrows to gods already met
	MaxGodsPerRun = 99,
	-- the run-progress reward table has no weights -- a reward's share is how many entries it has --
	-- so 1 roughly doubles the blessing share, 2 roughly triples it
	ExtraDoorEntries = 1,
}
