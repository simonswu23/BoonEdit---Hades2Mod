---@meta _
---@diagnostic disable: lowercase-global

-- Love Handles (Aphrodite x Hephaestus): heartthrobs come from hammer strikes landing -- Anvil
-- Ring's and Anvil Rush's -- rather than from volcanic blasts going off.

mod.tuning.LoveHandles = {
	HeartthrobChance = 0.30,
}

once('LoveHandlesHammerStrikes', function()
	if not config.BoonChanges.LoveHandlesHammerStrikes.Enabled then return end

	local loveHandles = game.TraitData.SlamManaBurstBoon

	loveHandles.BoonEditHeartthrob = loveHandles.OnProjectileCreationFunction.Args
	loveHandles.OnProjectileCreationFunction = nil

	loveHandles.BoonEditHeartthrob.DamageMultiplier = 1.0

	-- Not DropManaBurstChance: Carnal Pleasure sums that across traits, so the two would inflate
	-- each other.
	loveHandles.BoonEditHeartthrobChance = mod.tuning.LoveHandles.HeartthrobChance
	loveHandles.StatLines = { 'ManaBurstChanceStatDisplay1' }
	loveHandles.ExtractValues = {
		{
			Key = 'BoonEditHeartthrobChance',
			ExtractAs = 'Chance',
			Format = 'LuckModifiedPercent',
			HideSigns = true,
		},
		{
			Key = 'ReportedMultiplier',
			ExtractAs = 'Damage',
			Format = 'MultiplyByBase',
			BaseType = 'Projectile',
			BaseName = 'AphroditeBurst',
			BaseProperty = 'Damage',
			SkipAutoExtract = true,
		},
	}

	local blast = game.ProjectileData.HephCastBlast
	blast.OnHitFunctionNames = blast.OnHitFunctionNames or {}
	table.insert(blast.OnHitFunctionNames, _PLUGIN.guid .. '.LoveHandlesHeartthrob')

	-- rebuilt rather than edited: HephaestusMassiveTraits is shared
	game.TraitRequirements.SlamManaBurstBoon = {
		OneFromEachSet = {
			game.LinkedTraitData.AphroditeCoreTraits,
			{ 'HephaestusCastBoon', 'HephaestusSprintBoon' },
		},
	}
end)


-- On any HephCastBlast landing, so it rolls once per foe struck.
---@diagnostic disable-next-line: unused-local
function mod.LoveHandlesHeartthrob(victim, _victimId, triggerArgs)
	if not config.BoonChanges.LoveHandlesHammerStrikes.Enabled then return end
	if not game.HeroHasTrait('SlamManaBurstBoon') then return end

	local trait = game.GetHeroTrait('SlamManaBurstBoon')
	local args = trait and trait.BoonEditHeartthrob
	if not args then return end
	if not rolls(trait.BoonEditHeartthrobChance or mod.tuning.LoveHandles.HeartthrobChance) then return end

	game.QueueManaBurst(triggerArgs, args)
end


if config.BoonChanges.LoveHandlesHammerStrikes.Enabled then
	boon_text({
		Traits = {
			SlamManaBurstBoon = {
				Description = 'Whenever your hammer strikes from {#BoldFormatGraft}Hephaestus {#Prev}hit a foe, you may create a {$Keywords.HeartBurst}.',
			},
		},
	})
end
