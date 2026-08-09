---@meta _
---@diagnostic disable: lowercase-global

-- Every word the boon changes put on screen: renamed boons, rewritten descriptions, keyword
-- tooltips, stat-line labels and flavour text. Each block keeps the config guard it was written
-- with, so text only lands for a change that is switched on -- and a few build their wording out of
-- `mod.tuning`, which is why these are statements rather than a plain table.
--
-- Imported last from `reload.lua`: `boon_text` has to exist, and the tuning it reads has to be set.

if config.BoonChanges.GlamourGainPulse.Enabled then
	boon_text({
		Traits = {
			AphroditeManaBoon = {
				Description = 'Every second, inflict {$Keywords.Weak} on nearby foes, restoring {!Icons.Mana} for {#AltUpgradeFormat}each {#Prev}.',
			},
		},
		StatLines = {
			BoonEditGlamourManaStatDisplay = { Name = 'Magick per Foe:', Index = 1 },
		},
	})
end

if config.BoonChanges.CarnalPleasureHealing.Enabled then
	boon_text({
		Traits = {
			BloodManaBurstBoon = {
				Description = 'Whenever you collect {!Icons.BloodDropIcon}, you restore {!Icons.Health} and may create a {$Keywords.HeartBurst}.',
			},
		},
		StatLines = {
			BoonEditCarnalPleasureHealStatDisplay = { Name = 'Health per Plasma:', Index = 2 },
		},
	})
end

if config.BoonChanges.CarnalPleasurePlasmaBursts.Enabled then
	boon_text({
		Traits = {
			BloodManaBurstBoon = {
				-- No mention of creating one: the pickup roll is zeroed, so the boon is purely what
				-- it does to Hearts made by Heart Breaker and Smoldering Forge. "Larger" is the flat
				-- doubling, which carries no figure of its own on purpose.
				Description = 'Your {$Keywords.HeartBurst} are larger and deal more damage, plus ' ..
					'extra for any {!Icons.BloodDropIcon} you hold.',
			},
		},
		-- The trait carries this line either way; without an entry here it printed its own text id.
		-- Index 2, not 4: vanilla's last two ExtractValues both carry SkipAutoExtract, and
		-- StatDisplayN counts only the ones actually extracted.
		StatLines = {
			BoonEditCarnalPleasurePlasmaStatDisplay = { Name = 'Bonus Damage:', Index = 2 },
		},
	})
end

if config.BoonChanges.SmolderingForge.Enabled then
	boon_text({
		Traits = {
			SlamManaBurstBoon = {
				DisplayName = 'Smoldering Forge',
				-- Was "You deal much more damage to nearby foes with Glow" -- the close-range damage
				-- bonus an earlier pass gave this boon. The Hearts replaced that bonus and the
				-- wording never followed; the stat line named damage too, while the value beneath
				-- it has always been the Heart chance.
				Description = 'Damaging a foe with {$Keywords.DelayedKnockback} may create ' ..
					'a {$Keywords.HeartBurst}.',
			},
		},
		StatLines = {
			BoonEditSmolderingForgeStatDisplay = { Name = '{$Keywords.HeartBurst} Chance:', Index = 1 },
		},
		-- Love Handles' flavour was about volcanic blasts; Hearts are what this throws now.
		Flavor = {
			BoonEditSmolderingForgeFlavorText = 'Struck while the iron is hot.',
		},
	})
end

if config.BoonChanges.ObsessiveDevotion.Enabled then
	boon_text({
		Traits = {
			-- The Legendary carries Obsessive Devotion now, and the Duo carries Nervous Wreck. The
			-- traits stay where they are -- only the name, wording and behaviour moved. See
			-- `obsessive_devotion.lua`.
			RandomStatusBoon = {
				DisplayName = 'Obsessive Devotion',
				Description = 'When you inflict {$Keywords.Weak}, you may inflict {$Keywords.Charm} ' ..
					'instead. You deal more damage for each nearby character fighting for you.',
			},
			CharmCrowdBoon = {
				DisplayName = 'Nervous Wreck',
				Description = 'Whenever you inflict {$Keywords.Weak}, also randomly inflict ' ..
					'{$Keywords.StatusPlural} from other Olympians.',
			},
		},
		StatLines = {
			-- A keyword expands to its own formatted run, so suffixing it with letters breaks the
			-- format rather than reading "Charmed". Say "-afflicted".
			BoonEditDevotionChanceStatDisplay = { Name = '{$Keywords.Charm} Chance:', Index = 1 },
		},
	})
end

if config.BoonChanges.ProfuseBleedingBloodSpill.Enabled then
	boon_text({
		Traits = {
			RendBloodDropBoon = {
				Description = 'Whenever a foe afflicted by {$Keywords.Rend} takes damage, they may spill {!Icons.BloodDropIcon}.',
			},
			RendBloodDropBoon_Tray = {
				Description = 'Whenever a foe afflicted by {$Keywords.Rend} takes damage, they may spill {!Icons.BloodDropWithCountIcon}.',
			},
		},
		StatLines = {
			BoonEditBloodSpillChanceStatDisplay = { Name = 'Spill Chance:', Index = 1 },
		},
	})
end

if config.BoonChanges.HostileEnvironmentCastFollows.Enabled then
	boon_text({
		Traits = {
			SelfCastBoon = {
				Description = 'Your {$Keywords.CastEX} is stronger, and your {$Keywords.CastSet} always follows you.',
			},
		},
	})
end

if config.BoonChanges.SunWorshiperRepeat.Enabled or config.BoonChanges.SunWorshiperHitch.Enabled then
	local repeated = ''
	if config.BoonChanges.SunWorshiperRepeat.Enabled then
		repeated = '; later ones may as well'
	end

	-- Nothing is said about the summons being strikeable or Hitchable. The toggle that would do it is
	-- off and unfinished -- the Hitch never lands -- so promising it in the tooltip would be a lie.
	local hitched = ''

	boon_text({
		Traits = {
			RaiseDeadBoon = {
				Description = 'In each {$Keywords.EncounterAlt}, the first foe you slay returns to fight for you'
					.. repeated .. '.' .. hitched,
			},
		},
	})
end

if config.BoonChanges.SunWorshiperRepeat.Enabled then
	boon_text({
		StatLines = {
			BoonEditRepeatRaiseStatDisplay = { Name = 'Repeat Revival Chance:', Index = 2 },
		},
	})
end

if config.BoonChanges.LocalClimateCoversCastBoons.Enabled then
	boon_text({
		Traits = {
			CastAttachBoon = {
				Description = 'Your {$Keywords.CastSet} deal more damage. If you are in the binding circle, the bonus is doubled.',
			},
		},
	})
end

if config.BoonChanges.TranquilGainChannel.Enabled then
	boon_text({
		Traits = {
			DemeterManaBoon = {
				Description = 'While channeling an {$Keywords.OmegaAlt} for {#BoldFormat}{$TooltipData.ExtractData.TooltipMovePenaltyDuration} Sec.{#Prev}, rapidly restore {!Icons.Mana} until you release it.',
			},
		},
	})
end

if config.BoonChanges.NaturalSelectionPoms.Enabled then
	local poms = mod.tuning.NaturalSelection
	boon_text({
		Traits = {
			GoodStuffBoon = {
				Description = 'Gain {#AltUpgradeFormat}' .. poms.PomsOnPickup .. '{!Icons.Pom} {#Prev}worth {#AltUpgradeFormat}+'
					.. poms.LevelsPerPom .. '{#Prev}{$Keywords.PomLevel} each, then {#AltUpgradeFormat}1 {#Prev}more every {#AltUpgradeFormat}'
					.. poms.EncountersPerPom .. ' {#Prev}{$Keywords.EncounterPlural}.',
			},
		},
		-- The interval is the one part of this you wait on, so it gets the line; the Pom counts are
		-- fixed and already spelled out above.
		StatLines = {
			BoonEditNaturalSelectionStatDisplay = { Name = '{$Keywords.EncounterPlural} per {!Icons.Pom}:', Index = 1 },
		},
	})
end

if config.BoonChanges.CryoPounderHammers.Enabled then
	boon_text({
		Traits = {
			ClearRootBoon = {
				Description = 'Your blast effects and hammer strikes from {#BoldFormatGraft}Hephaestus {#Prev}deal more damage to {$Keywords.Root}-afflicted foes.',
			},
		},
	})
end

if config.BoonChanges.AnvilGlowAndDash.Enabled then
	boon_text({
		Traits = {
			HephaestusCastBoon = {
				Description = 'Your {$Keywords.CastSet} deal damage {$TooltipData.ExtractData.Detonations} times in succession to foes in the binding circle, inflicting {$Keywords.DelayedKnockback}.',
			},
			HephaestusSprintBoon = {
				Description = '{$Keywords.DashSet} damages surrounding foes and inflicts {$Keywords.DelayedKnockback}, and again once you stop.',
			},
		},
	})
end

if config.BoonChanges.MoltenTouchGlow.Enabled then
	boon_text({
		Traits = {
			AntiArmorBoon = {
				Description = 'Your {$Keywords.AttackSet} and {$Keywords.SpecialSet} deal more damage to ' ..
					'{$Keywords.Armor}, and half as much more to foes with {$Keywords.DelayedKnockback}.',
			},
		},
	})
end

if config.BoonChanges.PremiumServiceHammers.Enabled then
	boon_text({
		Traits = {
			WeaponUpgradeBoon = {
				Description = 'Your {$Keywords.Aspect} of the {#BoldFormatGraft}Nocturnal Arms {#Prev}is even stronger, '
					.. 'your {!Icons.RandomHammer} upgrades all gain rank if possible. Gain an {#BoldFormatGraft}Anvil of Fate {#Prev}.',
			},
		},
	})
end

if config.BoonChanges.ChainReactionCooldownSkip.Enabled then
	boon_text({
		Traits = {
			DoubleMassiveAttackBoon = {
				Description = 'Any {$Keywords.GodBoon} effects that recharge over time have a chance to skip the recharge entirely.',
			},
		},
		StatLines = {
			BoonEditCooldownSkipStatDisplay = { Name = 'Recharge Skip Chance:', Index = 1 },
		},
	})
end

if config.BoonChanges.SeismicHammer.Enabled then
	boon_text({
		Traits = {
			MassiveCastBoon = {
				DisplayName = 'Seismic Hammer',
				Description = 'Your blast effects from {#BoldFormatGraft}Hephaestus {#Prev}make your ' ..
					'{$Keywords.Cast} erupt like your {$Keywords.CastEX}.',
			},
		},
		StatLines = {
			BoonEditSeismicHammerStatDisplay = { Name = 'Blast Recharge Reduction (Sec.):', Index = 1 },
		},
	})
end

-- Only the flat Hitch version can be written down; the per-Cast one reads differently for every
-- Cast boon, so it is left with vanilla's wording.
if config.BoonChanges.RousingReceptionCastCurse.Enabled and mod.tuning.RousingReception.HitchOnly then
	boon_text({
		Traits = {
			SpawnCastDamageBoon = {
				Description = 'Your {$Keywords.CastSet} damage any foes as they join the ' ..
					'{$Keywords.EncounterAlt}, wherever they appear.',
			},
		},
	})
end

if config.BoonChanges.AllTogetherDoubleElements.Enabled then
	boon_text({
		Traits = {
			AllElementalBoon = {
				Description = 'Gain {#BoldFormatGraft}2 {#Prev}of each {$Keywords.AllElements}, and {#BoldFormatGraft}1 {#Prev}{$Keywords.Synergy} {$Keywords.GodBoonNoTooltip} for each.',
			},
			-- this stat line hardcodes "+1"
			AllElementStatDisplay = {
				Description = '{#UpgradeFormat}+2',
			},
		},
	})
end

if config.BoonChanges.CherishedHeirloom.Enabled then
	local extra = ''
	if mod.tuning.CherishedHeirloom.ExtraKeepsake then
		extra = ' Equip one now.'
	end

	boon_text({
		Traits = {
			KeepsakeLevelBoon = {
				Description = 'Your {$Keywords.Keepsakes} are stronger {#ItalicFormat}(if possible) {#Prev}and do not expire this night.' .. extra,
			},
		},
	})
end

if config.BoonChanges.HardTargetBecomesPostHaste.Enabled then
	boon_text({
		Traits = {
			SlowProjectileBoon = {
				DisplayName = 'Post Haste',
				Description = 'Any {$Keywords.GodBoon} effects that recharge over time recharge faster.',
			},
		},
	})
end

if config.BoonChanges.SecondWind.Enabled then
	boon_text({
		Traits = {
			TimeStopLastStandBoon = {
				DisplayName = 'Second Wind',
				Description = 'Gain an extra {$Keywords.Cast} and {$Keywords.Dash}.',
			},
		},
		-- Paid Dues' flavour was about its money shield, which Second Wind no longer has.
		Flavor = {
			BoonEditSecondWindFlavorText = 'Double Time, and enemies Double Pay the price.',
		},
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
			BoonEditMeteorDamageStatDisplay = { Name = 'Fireball Damage:', Index = 1 },
		},
	})
end

if config.BoonChanges.CardioGainSprintMana.Enabled then
	boon_text({
		Traits = {
			HestiaManaBoon = {
				Description = 'Whenever your {$Keywords.Attack} or {$Keywords.Special} deal damage, or you {$Keywords.Dash}, restore {!Icons.Mana}.',
			},
		},
		StatLines = {
			BoonEditCardioGainSprintStatDisplay = { Name = 'Magick on Sprint:', Index = 2 },
		},
	})
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

if config.BoonChanges.ArterialSprayAlwaysDouble.Enabled then
	boon_text({
		Traits = {
			DoubleSplashBoon = {
				Description = 'Your splash effects from {#BoldFormatGraft}Poseidon {#Prev}hit a second time with reduced power {#ItalicLightFormat}(and take the color of the River Styx).',
			},
		},
		StatLines = {
			BoonEditSecondSplashStatDisplay = { Name = 'Second Splash Damage:', Index = 1 },
		},
	})
end

if config.BoonChanges.RippleEffectOmegaBoons.Enabled then
	boon_text({
		Traits = {
			MoneyDamageBoon = {
				Description = 'The bonus effects your {$Keywords.Omega} trigger may occur again, up to '
					.. '{#AltUpgradeFormat}' .. mod.tuning.RippleEffect.MaxRepeats .. ' {#Prev}more times.',
			},
		},
		StatLines = {
			BoonEditRippleRepeatStatDisplay = { Name = 'Repeat Chance:', Index = 1 },
		},
	})
end

if config.BoonChanges.ShockingLossGuardians.Enabled then
	boon_text({
		Traits = {
			SpawnKillBoon = {
				Description = 'Whenever you first deal damage to susceptible foes, you may destroy them outright.',
			},
		},
	})
end

if config.BoonChanges.KillerCurrentBolt.Enabled then
	boon_text({
		Traits = {
			LightningVulnerabilityBoon = {
				Description = 'Damaging a {$Keywords.KnockbackAmplify}-afflicted foe may strike it with lightning.',
			},
		},
		StatLines = {
			BoonEditKillerCurrentStatDisplay = { Name = 'Strike Chance:', Index = 1 },
		},
	})
end

if config.BoonChanges.AirQualityAdditiveFloor.Enabled then
	boon_text({
		Traits = {
			ElementalDamageFloorBoon = {
				Description = 'While you have at least {$TraitData.ElementalDamageFloorBoon.ActivationRequirements.1.Value}{!Icons.CurseAir}, your base damage is never less than the limit.',
			},
		},
	})
end

if config.BoonChanges.ThermalDynamicsAllLightning.Enabled then
	boon_text({
		Traits = {
			EchoBurnBoon = {
				Description = 'Your lightning effects from {#BoldFormatGraft}Zeus {#Prev}inflict ' ..
					'{$Keywords.Burn} for a share of the damage they deal.',
			},
		},
		StatLines = {
			BoonEditThermalScorchStatDisplay = { Name = 'Scorch per Damage Dealt:', Index = 1 },
		},
	})
end

-- Vanilla's wording is built around the charge that is gone: "You can Hold +45 Magick into your
-- Omega Cast to...". With no rung left to hold, the Cast simply is the disaster.
-- Nil-safe: this key may not be in the generated .cfg yet.
local gloriousOn = config.BoonChanges.GloriousDisasterAlwaysSupercharged
if gloriousOn ~= nil and gloriousOn.Enabled then
	boon_text({
		Traits = {
			ApolloSecondStageCastBoon = {
				Description = 'Your {$Keywords.CastEX} repeatedly strikes foes with lightning bolts.',
			},
		},
	})
end

-- Nil-safe: this key may not be in the generated .cfg yet.
local ionicGainOn = config.BoonChanges.IonicGainProximity
if ionicGainOn ~= nil and ionicGainOn.Enabled then
	boon_text({
		Traits = {
			ZeusManaBoon = {
				Description = 'In each {$Keywords.EncounterAlt}, an {$Keywords.ManaDropZeus} appears in the ' ..
					'area. Standing near it restores {!Icons.Mana}, and using it restores {#ItalicFormat}all ' ..
					'{#Prev}{!Icons.Mana}.',
			},
		},
		StatLines = {
			BoonEditIonicGainRegenStatDisplay = { Name = 'Magick per Sec. Nearby:', Index = 2 },
		},
	})
end

if config.BoonChanges.HarmForTheAfflictedEveryStatus.Enabled then
	boon_text({
		Traits = {
			NewStatusDamage = {
				-- No interval in the text: at 0.3 sec. per foe and per curse it almost never bites.
				Description = 'Inflicting a {$Keywords.Status} deals {#BoldFormat}{$TooltipData.ExtractData.Damage} {#Prev}damage.',
			},
		},
	})
end


-- Froth's own keyword is left to vanilla: Scalding Vapor supplies FontChance, FontDamage and
-- KnockbackAmplifyDuration itself, so those numbers already follow your luck and your other boons.
-- Only Steam's keyword is wrong once either toggle is on, since vanilla has it removing the Froth.
local procs_froth = config.BoonChanges.SteamProcsFroth.Enabled

local keeps_froth = config.BoonChanges.ScaldingVaporKeepsFroth.Enabled

if procs_froth or keeps_froth then
	local held = ''
	if procs_froth and keeps_froth then
		held = ', which keeps the {$Keywords.KnockbackAmplify} and sets it off more often'
	elseif keeps_froth then
		held = ', which keeps the {$Keywords.KnockbackAmplify}'
	else
		held = ', which sets off the {$Keywords.KnockbackAmplify} more often'
	end

	local steam = 'A burning cloud that rapidly deals damage'
	if not keeps_froth then
		steam = 'A burning cloud that removes {$Keywords.KnockbackAmplify} from foes and rapidly deals damage'
	end
	if procs_froth then
		steam = steam .. ', and counts as a hit for {$Keywords.KnockbackAmplify}'
	end

	boon_text({
		Traits = {
			SteamBoon = {
				Description = 'If foes with {$Keywords.KnockbackAmplify} are struck by your fire effects from ' ..
					'{#BoldFormatGraft}Hestia{#Prev}, they are engulfed in {$Keywords.Steam}' .. held .. '.',
			},
		},
		Keywords = {
			Steam = {
				Description = steam .. '. Lasts {#BoldFormatGraft}{$TooltipData.ExtractData.Duration} Sec.',
			},
		},
	})
end


-- Not a rewrite of vanilla's text like the rest of this file: Pandemonium is a new boon, so without
-- an entry here the game would print the raw text id.
if config.BoonChanges.Pandemonium.Enabled then
	boon_text({
		Traits = {
			---@diagnostic disable-next-line: undefined-global
			[PANDEMONIUM] = {
				DisplayName = 'Pandemonium',
				Description = '???',
			},
		},
		Flavor = {
			BoonEditPandemoniumFlavorText = 'All of them at once, then. Why not?',
		},
	})
end
