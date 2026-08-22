---@meta _
---@diagnostic disable: lowercase-global


if config.BoonChanges.GlamourGain.Enabled then
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

if config.BoonChanges.HeartyAppetite.Enabled then
	boon_text({
		Traits = {
			MaxHealthDamageBoon = {
				Description = 'You deal more damage with your {$Keywords.WeaponSet} the more {!Icons.HealthUpTotal} ' ..
					'you have. A hearty meal appears now and every ' ..
					'{$TooltipData.ExtractData.TooltipEncountersPerFood} {$Keywords.EncounterPluralAlt}, ' ..
					'and your healing effects are more powerful for the rest of the night.',
			},
		},
		StatLines = {
			BoonEditHeartyAppetiteHealingStatDisplay = { Name = 'Healing Bonus:', Index = 2 },
		},
	})
end

if config.BoonChanges.CarnalPleasure.Enabled then
	boon_text({
		Traits = {
			BloodManaBurstBoon = {
				Description = 'Your {$Keywords.HeartBurst} are larger and deal more damage, plus ' ..
					'extra for any {!Icons.BloodDropIcon} you hold.',
			},
		},
		StatLines = {
			BoonEditCarnalPleasurePlasmaStatDisplay = { Name = 'Bonus Damage:', Index = 1 },
		},
	})
end

if config.BoonChanges.CarnalPleasure.Enabled and mod.tuning.CarnalPleasure.ShowHeartthrobCapacity then
	boon_text({
		StatLines = {
			BoonEditCarnalPleasureCapacityStatDisplay = { Name = 'Max Heartthrobs:', Index = 2 },
		},
	})
end

if config.BoonChanges.SmolderingForge.Enabled then
	boon_text({
		Traits = {
			SlamManaBurstBoon = {
				DisplayName = 'Smoldering Forge',
				Description = 'Damaging a foe with {$Keywords.DelayedKnockback} may create ' ..
					'a {$Keywords.HeartBurst}.',
			},
		},
		StatLines = {
			BoonEditSmolderingForgeStatDisplay = { Name = '{$Keywords.HeartBurst} Chance:', Index = 1 },
		},
		Flavor = {
			BoonEditSmolderingForgeFlavorText = 'Struck while the iron is hot.',
		},
	})
end

if config.BoonChanges.EcstaticObsession.Enabled then
	boon_text({
		Traits = {
			RandomStatusBoon = {
				DisplayName = 'Ecstatic Obsession',
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
			BoonEditObsessionChanceStatDisplay = { Name = '{$Keywords.Charm} Chance:', Index = 1 },
		},
	})
end

if config.BoonChanges.MeatGrinder.Enabled then
	boon_text({
		Traits = {
			AresExCastBoon = {
				Description = 'Your {$Keywords.CastEX} also creates a {$Keywords.BladeRift} in the ' ..
					'binding circle, and your {$Keywords.BladeRift} may spill {!Icons.BloodDropIcon}.',
			},
		},
		StatLines = {
			BoonEditMeatGrinderPlasmaStatDisplay = { Name = 'Spill Chance:', Index = 2 },
		},
	})
end

if config.BoonChanges.ProfuseBleeding.Enabled then
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

if config.BoonChanges.BloodSpree.Enabled then
	boon_text({
		Traits = {
			LowHealthLifestealBoon = {
				Description = 'While you have less than ' ..
					'{$TooltipData.ExtractData.ReportedRequirement}{!Icons.Health}, your ' ..
					'{$Keywords.AttackSet} and {$Keywords.SpecialSet} restore {!Icons.Health}. ' ..
					'Whenever you slay a foe, gain a chance to deal ' ..
					'{$TraitData.AresStatusDoubleDamageBoon.DamagePercent:F} damage for the rest of ' ..
					'the {$Keywords.EncounterAlt}.',
			},
		},
		StatLines = {
			BoonEditBloodSpreeCritStatDisplay = { Name = 'Damage Chance per Kill:', Index = 2 },
		},
	})
end

if config.BoonChanges.HostileEnvironment.Enabled then
	boon_text({
		Traits = {
			SelfCastBoon = {
				Description = 'Your {$Keywords.CastEX} is stronger, and your {$Keywords.CastSet} always follows you.',
			},
		},
	})
end

if config.BoonChanges.SunWorshiper.Enabled then
	boon_text({
		Traits = {
			RaiseDeadBoon = {
				Description = 'In each {$Keywords.EncounterAlt}, the first foe you slay returns to fight for you'
					.. '; later ones may as well.',
			},
		},
		StatLines = {
			BoonEditRepeatRaiseStatDisplay = { Name = 'Repeat Revival Chance:', Index = 2 },
		},
	})
end

if config.BoonChanges.LocalClimate.Enabled then
	boon_text({
		Traits = {
			CastAttachBoon = {
				Description = 'Your {$Keywords.CastSet} deal more damage. If you are in the binding circle, the bonus is doubled.',
			},
		},
	})
end

if config.BoonChanges.TranquilGain.Enabled then
	boon_text({
		Traits = {
			DemeterManaBoon = {
				Description = 'While channeling an {$Keywords.OmegaAlt} for {#BoldFormat}{$TooltipData.ExtractData.TooltipMovePenaltyDuration} Sec.{#Prev}, rapidly restore {!Icons.Mana} until you release it.',
			},
		},
	})
end

if config.BoonChanges.NaturalSelection.Enabled then
	local poms = mod.tuning.NaturalSelection
	boon_text({
		Traits = {
			GoodStuffBoon = {
				Description = 'Gain {#AltUpgradeFormat}' .. poms.PomsOnPickup .. '{!Icons.Pom} {#Prev}worth {#AltUpgradeFormat}+'
					.. poms.LevelsPerPom .. '{#Prev}{$Keywords.PomLevel} each, then {#AltUpgradeFormat}1 {#Prev}more every {#AltUpgradeFormat}'
					.. poms.EncountersPerPom .. ' {#Prev}{$Keywords.EncounterPlural}.',
			},
		},
		StatLines = {
			BoonEditNaturalSelectionStatDisplay = { Name = '{$Keywords.EncounterPlural} per {!Icons.Pom}:', Index = 1 },
		},
	})
end

if config.BoonChanges.CryoPounder.Enabled then
	boon_text({
		Traits = {
			ClearRootBoon = {
				Description = 'Your blast effects and hammer strikes from {#BoldFormatGraft}Hephaestus {#Prev}deal more damage to {$Keywords.Root}-afflicted foes.',
			},
		},
	})
end

if config.BoonChanges.AnvilRing.Enabled then
	boon_text({
		Traits = {
			HephaestusCastBoon = {
				Description = 'Your {$Keywords.CastSet} deal damage {$TooltipData.ExtractData.Detonations} times in succession to foes in the binding circle, inflicting {$Keywords.DelayedKnockback}.',
			},
		},
	})
end

if config.BoonChanges.SmithyRush.Enabled then
	boon_text({
		Traits = {
			HephaestusSprintBoon = {
				Description = '{$Keywords.DashSet} damages surrounding foes and inflicts {$Keywords.DelayedKnockback}, and again once you stop.',
			},
		},
	})
end

if config.BoonChanges.HeavyMetal.Enabled then
	boon_text({
		Traits = {
			HeavyArmorBoon = {
				Description = 'Your {$Keywords.WeaponSet} deals more damage based on ' ..
					'{$TooltipData.ExtractData.TooltipBonus:F} of your {!Icons.ArmorTotal}, and you gain ' ..
					'some now. Foes\' blows cannot knock you back.',
			},
		},
	})
end

if config.BoonChanges.MoltenTouch.Enabled then
	boon_text({
		Traits = {
			AntiArmorBoon = {
				Description = 'Your {$Keywords.AttackSet} and {$Keywords.SpecialSet} deal more damage to ' ..
					'{$Keywords.Armor}, and half as much more to foes with {$Keywords.DelayedKnockback}.',
			},
		},
	})
end

if config.BoonChanges.PremiumService.Enabled then
	boon_text({
		Traits = {
			WeaponUpgradeBoon = {
				Description = 'Your {$Keywords.Aspect} of the {#BoldFormatGraft}Nocturnal Arms {#Prev}is even stronger, '
					.. 'your {!Icons.RandomHammer} upgrades all gain rank if possible. Gain an {#BoldFormatGraft}Anvil of Fate {#Prev}.',
			},
		},
	})
end

if config.BoonChanges.ChainReaction.Enabled then
	boon_text({
		Traits = {
			DoubleMassiveAttackBoon = {
				Description = 'Any {$Keywords.GodBoon} effects that recharge over time have a chance to skip the recharge entirely.',
			},
		},
		StatLines = {
			BoonEditCooldownSkipStatDisplay = { Name = 'Recharge Skip Chance:', Index = 1 },
		},
		CombatText = {
			BoonEditChainReactionCombatText = '{#CombatTextHighlightFormat}Chain Reaction',
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

if config.BoonChanges.RousingReception.Enabled and mod.tuning.RousingReception.HitchOnly then
	boon_text({
		Traits = {
			SpawnCastDamageBoon = {
				Description = 'Your {$Keywords.CastSet} damage any foes as they join the ' ..
					'{$Keywords.EncounterAlt}, wherever they appear.',
			},
		},
	})
end

if config.BoonChanges.AllTogether.Enabled then
	boon_text({
		Traits = {
			AllElementalBoon = {
				Description = 'Gain {#BoldFormatGraft}2 {#Prev}of each {$Keywords.AllElements}, and {#BoldFormatGraft}1 {#Prev}{$Keywords.Synergy} {$Keywords.GodBoonNoTooltip} for each.',
			},
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

if config.BoonChanges.PostHaste.Enabled then
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

if config.BoonChanges.CardioGain.Enabled then
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

if config.BoonChanges.BreakerRush.Enabled then
	boon_text({
		Traits = {
			PoseidonSprintBoon = {
				Description = '{$Keywords.DashSet} damages surrounding foes and inflicts {$Keywords.KnockbackAmplify}, and again once you stop.',
			},
		},
	})
end

if config.BoonChanges.ArterialSpray.Enabled then
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

if config.BoonChanges.RippleEffect.Enabled then
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

if config.BoonChanges.ShockingLoss.Enabled then
	boon_text({
		Traits = {
			SpawnKillBoon = {
				Description = 'Whenever you first deal damage to susceptible foes, you may destroy them outright.',
			},
		},
	})
end

if config.BoonChanges.KillerCurrent.Enabled then
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

if config.BoonChanges.PowerSurge.Enabled then
	boon_text({
		Traits = {
			ZeusManaBoltBoon = {
				Description = 'Whenever you use or restore {!Icons.Mana}, a random surrounding foe is struck by lightning.',
			},
		},
	})
end

if config.BoonChanges.AirQuality.Enabled then
	boon_text({
		Traits = {
			ElementalDamageFloorBoon = {
				Description = 'While you have at least {$TraitData.ElementalDamageFloorBoon.ActivationRequirements.1.Value}{!Icons.CurseAir}, your base damage is never less than the limit.',
			},
		},
	})
end

if config.BoonChanges.ThermalDynamics.Enabled then
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

local gloriousOn = config.BoonChanges.GloriousDisaster
if gloriousOn ~= nil and gloriousOn.Enabled then
	boon_text({
		Traits = {
			ApolloSecondStageCastBoon = {
				Description = 'Your {$Keywords.CastEX} repeatedly strikes foes with lightning bolts.',
			},
		},
	})
end

local ionicGainOn = config.BoonChanges.IonicGain
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

if config.BoonChanges.HarmForTheAfflicted.Enabled then
	boon_text({
		Traits = {
			NewStatusDamage = {
				Description = 'Inflicting a {$Keywords.Status} deals {#BoldFormat}{$TooltipData.ExtractData.Damage} {#Prev}damage.',
			},
		},
	})
end


if config.BoonChanges.ScaldingVapor.Enabled then
	boon_text({
		Traits = {
			SteamBoon = {
				Description = 'If foes with {$Keywords.KnockbackAmplify} are struck by your fireball effects ' ..
					'from {#BoldFormatGraft}Hestia{#Prev}, they are engulfed in {$Keywords.Steam}.',
			},
		},
		Keywords = {
			Steam = {
				Description = 'A burning cloud that rapidly deals damage. Lasts {#BoldFormatGraft}{$TooltipData.ExtractData.Duration} Sec.',
			},
		},
	})
end


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
