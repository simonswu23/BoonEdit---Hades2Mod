---@meta _
---@diagnostic disable: lowercase-global

-- Love Handles (Aphrodite x Hephaestus) becomes "Smoldering Forge": damaging a foe that has Glow
-- can throw a Heartthrob. Vanilla hung its Hearts on volcanic blasts specifically; this asks only
-- that the foe be Glowing, whatever put the damage on it.
--
-- **A replacement, not an addition.** An earlier pass gave this boon a close-range damage bonus
-- against Glowing foes instead of its Hearts. The Hearts are the boon now, and that bonus is gone --
-- it is not sitting behind a flag, because two unrelated effects on one boon was the thing being
-- corrected.

-- Glow's own effect name, as anvil_rush.lua uses.
local GLOW_EFFECT = 'DelayedKnockbackEffect'

once('SmolderingForge', function()
	if not config.BoonChanges.SmolderingForge.Enabled then return end

	local forge = game.TraitData.SlamManaBurstBoon
	local tuning = mod.tuning.SmolderingForge

	-- Vanilla hangs the Hearts on an `OnProjectileCreationFunction` listing four Hephaestus blast
	-- projectiles. Its `Args` are read out before the field goes, since they carry the projectile
	-- name and the doubled damage a Love Handles Heart is worth -- the trigger changes, not the Heart.
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


-- Any damage you deal to a Glowing foe can throw a Heart. Rolled per damaging hit rather than per
-- foe, so a blast catching a crowd gets a roll for each of them -- which is the Hephaestus half of
-- the pairing paying for the Aphrodite half.
--
-- `rolls` applies the luck multiplier, as every other chance in this mod does.
---@diagnostic disable-next-line: unused-local
function mod.SmolderingForgeHeartthrob(victim, functionArgs, triggerArgs)
	if not config.BoonChanges.SmolderingForge.Enabled then return end

	if not victim or not victim.ActiveEffects or not victim.ActiveEffects[GLOW_EFFECT] then return end
	if not rolls(mod.tuning.SmolderingForge.HeartthrobChance) then return end

	local forge = game.GetHeroTrait('SlamManaBurstBoon')
	create_heartthrob(forge and forge.BoonEditBurstArgs)
end
