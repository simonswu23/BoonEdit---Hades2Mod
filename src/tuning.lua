---@meta _
---@diagnostic disable: lowercase-global

-- Every number behind the boon changes, and nothing else. The config decides which changes are on;
-- this decides how much each one does, including the flags that pick between two behaviours.
-- Imported from `reload.lua` ahead of the boons themselves, which read these as they set up.

mod.tuning = {}

mod.tuning.CarnalPleasure = {
	HealPerDrop = 1,
}

mod.tuning.SmolderingForge = {
	-- a whole multiplier, as Aphrodite's own close-range boons are
	DamageMultiplier = 1.50,
	-- Aphrodite's close range, the same figure Flutter Strike and Heart Rend use
	Radius = 430,
}

mod.tuning.ObsessiveDevotion = {
	DamagePerFoe = 0.10,
	MaxBonus = 1.00,
}

mod.tuning.ProfuseBleeding = {
	SpillChance = 0.10,
}

mod.tuning.SunWorshiper = {
	RepeatChance = 0.30,
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
	EncountersPerPom = 10,
}

mod.tuning.UnseenIre = {
	Cooldown = 30,
}

mod.tuning.AnvilRush = {
	-- Both are whole multipliers, not additions to the 1.2 Glow starts at. The ceiling is on the
	-- vulnerability only -- stacks past it keep the Glow up rather than deepen it.
	GlowPerStack = 0.05,
	GlowMax = 1.35,
}

mod.tuning.MoltenTouch = {
	-- Whole multipliers, as vanilla's 1.4 against Armor is -- half its bonus, not half its value.
	-- The stack values halve the same way, from vanilla's 1.2 and 1.1.
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
	-- Switch this off to go back to reading the curse off your Cast boon.
	HitchOnly = true,
	UseCastStrikes = true,
	DamageScaledCurseMultiplier = 1.0,
}

mod.tuning.CherishedHeirloom = {
	ExtraKeepsake = true,
	ExtraKeepsakeInMenuOnly = true,
}

mod.tuning.SecondWind = {
	ExtraCasts = 1,
	ExtraDashes = 1,
	DashRechargeMultiplier = 0.90,
}

mod.tuning.BurningMeteor = {
	FireballMultiplier = 1.5,
	SizeMultiplier = 1.5,
}

mod.tuning.CardioGain = {
	-- a quarter of the old flat 3, banked as a fraction since Magick pays out in whole numbers
	SprintManaGain = 0.75,
}

mod.tuning.SteamProcsFroth = {
	FontCooldown = 0.3,
}

mod.tuning.TidalRush = {
	WaveDamage = { Common = 20, Rare = 25, Epic = 30, Heroic = 35 },
	Radius = 400,
	Knockback = 2000,
}

mod.tuning.ArterialSpray = {
	SecondWavePower = 0.30,
}

mod.tuning.RippleEffect = {
	RepeatChance = 0.50,
	-- each repeat is this much as likely as the one before it
	Falloff = 0.5,
	MaxRepeats = 4,
}

mod.tuning.ShockingLoss = {
	GuardianDamage = 999,
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
