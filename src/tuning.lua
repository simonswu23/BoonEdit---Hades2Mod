---@meta _
---@diagnostic disable: lowercase-global

-- Every number behind the boon changes, and nothing else: the config decides which changes are on,
-- this decides how much each does. Imported from `reload.lua` ahead of the boons that read it.

mod.tuning = {}

-- Shared by every Heartthrob, whichever boon made it -- they all draw on one pool.
mod.tuning.Heartthrob = {
	-- how many may be in the air before making one cancels the oldest. Vanilla hardcodes 6.
	Capacity = 12,
}

mod.tuning.CarnalPleasure = {
	-- What a Heartthrob gains in damage with no Plasma held at all. The floor, not the ceiling:
	-- holding Plasma takes it higher rather than switching it on. This is the figure the boon's one
	-- stat line shows.
	BaseBonus = 0.50,
	-- added on top of the base, scaling linearly with held Plasma and reaching all of it at the
	-- ceiling below -- so 0.30 here means +50% at no Plasma and +80% at full
	PlasmaBonus = 0.30,
	-- where the game itself stops counting Plasma, so the bonus stops climbing there too
	PlasmaCeiling = 50,
	-- **Size is flat and separate from the damage.** Twice the blast, held there whether or not you
	-- are carrying Plasma -- so it is not extracted and gets no line, since a number that never
	-- moves reads as though it might. The description says "larger" and means exactly this.
	HeartSizeMultiplier = 2.0,
	-- What one Plasma is worth towards Heart Breaker's own Magick goal. Undocumented on purpose --
	-- no line, no wording -- since it is a quiet tie between the two boons rather than a promise.
	PlasmaManaValue = 10,
}

mod.tuning.SmolderingForge = {
	-- chance for damaging a Glowing foe to throw a Heart, rolled per damaging hit and luck-scaled
	HeartthrobChance = 0.20,
}

mod.tuning.ObsessiveDevotion = {
	-- chance for the Weak you inflict to come out as Charm instead; luck-scaled, as every roll is
	CharmChance = 0.30,
	CharmDuration = 5,
	-- What a foe that cannot be Charmed gets instead: its current attack broken off. On a timer of
	-- its own, since Weak lands often enough that an uncapped stagger would hold a boss still.
	InterruptCooldown = 5,
	-- All your damage rises by this much for every character fighting on your side, up to the
	-- ceiling below. Charmed foes are counted among them, which is what ties the two halves of the
	-- boon together: every Charm it steals is also a step up this. Melinoe is not counted, so the
	-- bonus is always something you turned or summoned rather than something you were handed.
	DamagePerFriendly = 0.10,
	MaxDamageBonus = 0.50,
	-- How close an ally has to be to count. Kindled Spirit's 430 is the nearest thing this mod has
	-- to a house "nearby", so it is reused rather than invented.
	AllyRange = 430,
}

mod.tuning.ProfuseBleeding = {
	SpillChance = 0.10,
}

mod.tuning.IonicGain = {
	-- Magick a second while you stand by the drop, before rarity. The Unseen restores 6 a second and
	-- asks nothing of where you stand, so this sits at the same figure and charges you the standing.
	ManaPerSecond = 6,
	-- How close is close. The drop's own spawn keeps it 450 or further out, so this is that distance
	-- read back -- near enough to be a place you choose to fight, not a passive aura.
	Range = 450,
	Interval = 0.25,
	-- **The Unseen's ladder, not Ionic Gain's own.** The trait's `RarityLevels` scale its respawn
	-- interval and so run downward -- Heroic is 7/10 -- which on a regen rate would mean a rarer boon
	-- restoring less. These are `ManaOverTimeMetaUpgrade`'s figures verbatim.
	RarityScale = {
		Common = 1.00,
		Rare = 1.34,
		Epic = 1.67,
		Heroic = 2.00,
	},
}

mod.tuning.BeachBall = {
	-- What the globe hits for when it goes off, against vanilla's 300. Written to the projectile
	-- rather than to the boon's `DamageMultiplier`, so the tooltip -- which reads this same entry
	-- through `MultiplyByBase` -- shows the new figure without a text change of its own.
	BlastDamage = 400,
}

mod.tuning.GloriousDisaster = {
	-- On, the second stage no longer has to be channelled for -- every Omega Cast is one. The extra
	-- charge stage is what broke, so the condition is stepped over rather than repaired.
	SkipSuperchargeCondition = true,
	-- What each bolt hits for, against vanilla's 20. The figure lives in
	-- `Game/Projectiles/PlayerProjectiles.sjson`, not in Lua, so it is written through an sjson hook
	-- -- and the tooltip reads the same entry, so the number on the boon follows it by itself.
	BoltDamage = 50,
}

mod.tuning.SeismicHammer = {
	-- Seconds off the recharge of Volcanic Strike and Volcanic Flourish. Flat rather than a
	-- multiplier: `OlympianRechargeMultiplier` is the multiplier field and it belongs to Post Haste,
	-- so a second helping of it would be the same effect twice under two names.
	BlastCooldownReduction = 1,
	-- never shorter than this, so the reduction cannot drive a recharge to zero
	MinimumBlastCooldown = 0.1,
}

mod.tuning.SunWorshiper = {
	RepeatChance = 0.30,
	-- How many extra servants the repeat may raise in one encounter. Vanilla raises exactly one and
	-- the repeat lifts that gate entirely, so a long fight could fill the room -- this is the ceiling
	-- that was missing. Counted per encounter, and does not include vanilla's own first raise.
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
	-- how much longer your Cast ring lasts. Its tick rate is untouched, so twice as long is twice
	-- as many ticks.
	CastDurationMultiplier = 2.0,
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
	-- Chance for Hermes' own keepsake to force Second Wind into an offer, on top of the draw it would
	-- get anyway. Its requirements are waived outright while the keepsake is worn, so the roll is the
	-- only thing left deciding whether it turns up.
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
	-- a quarter of the old flat 3, banked as a fraction since Magick pays out in whole numbers
	SprintManaGain = 0.75,
}

mod.tuning.SteamProcsFroth = {
	-- how much of its own cooldown the Font keeps while Scalding Vapor is held. Vanilla's is 0.6s,
	-- so a half is 0.3s.
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
	-- How many blades may be in the air before making one cancels the oldest. Vanilla's six suits the
	-- three a dash drops, but a sprint wants about eight up at once, and thirty leaves room for the
	-- Ares sword modifiers that keep a blade alive across several detonations.
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
	-- Chance for Chaos' own keepsake to put Pandemonium among the blessings offered, on top of the
	-- flat draw it would get anyway. Chaos weights nothing, so this is rolled by hand.
	KeepsakeOfferChance = 0.10,
	-- The run's own ceiling on how many gods may turn up. Vanilla's is HeroData.MaxGodsPerRun and
	-- narrowing to the gods you have already met is what it causes, so this simply has to clear the
	-- number of gods that exist.
	MaxGodsPerRun = 99,
	-- Extra copies of each god entry in the run-progress reward table. That table has no weights --
	-- a reward's share is how many entries it has -- so 1 here roughly doubles the blessing share,
	-- 2 roughly triples it.
	ExtraDoorEntries = 1,
}
