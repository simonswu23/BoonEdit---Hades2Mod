---@meta _
---@diagnostic disable: lowercase-global

-- Heavy Metal (Hephaestus) plants you where you stand again: while you hold it, foes' blows no
-- longer shove you around. The game keeps its own switch for this, named by flag so that several
-- holders may ask for it at once -- nothing else asks for it on a boon's behalf.

local HEAVY_ARMOR_TRAIT = 'HeavyArmorBoon'

local HEAVY_ARMOR_FLAG = 'BoonEditHeavyArmor'


once('HeavyArmorKnockback', function()
	modutil.mod.Path.Wrap("HeavyArmorInitialPresentation", function(base, ...)
		local result = base(...)
		heavy_armor_sync()
		return result
	end)

	modutil.mod.Path.Wrap("SetupHeroObject", function(base, ...)
		local result = base(...)
		heavy_armor_sync()
		return result
	end)
end)


function heavy_armor_sync()
	if not config.BoonChanges.HeavyMetal.Enabled then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or not hero.ObjectId or not hero.ImmuneToForceFlags then return end

	if game.HeroHasTrait(HEAVY_ARMOR_TRAIT) then
		game.AddPlayerImmuneToForce(HEAVY_ARMOR_FLAG)
	elseif hero.ImmuneToForceFlags[HEAVY_ARMOR_FLAG] then
		game.RemovePlayerImmuneToForce(HEAVY_ARMOR_FLAG)
	end
end
