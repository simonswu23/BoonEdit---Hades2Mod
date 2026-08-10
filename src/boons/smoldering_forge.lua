---@meta _
---@diagnostic disable: lowercase-global


-- Love Handles (Aphrodite x Hephaestus) becomes "Smoldering Forge": damaging a Glowing foe can throw a
-- Heartthrob, whatever put the damage on it.

local GLOW_EFFECT = 'DelayedKnockbackEffect'

once('SmolderingForge', function()
	if not config.BoonChanges.SmolderingForge.Enabled then return end

	local forge = game.TraitData.SlamManaBurstBoon
	local tuning = mod.tuning.SmolderingForge

	forge.BoonEditBurstArgs = forge.OnProjectileCreationFunction and forge.OnProjectileCreationFunction.Args
	forge.OnProjectileCreationFunction = nil

	forge.BoonEditHeartthrobChance = tuning.HeartthrobChance
	forge.OnEnemyDamagedAction = {
		FunctionName = _PLUGIN.guid .. '.SmolderingForgeHeartthrob',
	}

	forge.FlavorText = 'BoonEditSmolderingForgeFlavorText'
	forge.StatLines = { 'BoonEditSmolderingForgeStatDisplay' }
	forge.ExtractValues = {
		{
			Key = 'BoonEditHeartthrobChance',
			ExtractAs = 'Chance',
			Format = 'LuckModifiedPercent',
			HideSigns = true,
		},
	}
end)


---@diagnostic disable-next-line: unused-local
function mod.SmolderingForgeHeartthrob(victim, functionArgs, triggerArgs)
	if not config.BoonChanges.SmolderingForge.Enabled then return end

	if not victim or not victim.ActiveEffects or not victim.ActiveEffects[GLOW_EFFECT] then return end
	if not rolls(mod.tuning.SmolderingForge.HeartthrobChance) then return end

	local forge = game.GetHeroTrait('SlamManaBurstBoon')
	create_heartthrob(forge and forge.BoonEditBurstArgs)
end
