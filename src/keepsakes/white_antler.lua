---@meta _
---@diagnostic disable: lowercase-global


local ANTLER = 'LowHealthCritKeepsake'


function white_antler_active()
	return config.KeepsakeChanges.WhiteAntler.Enabled and game.HeroHasTrait(ANTLER)
end


function white_antler_persists()
	if not mod.tuning.WhiteAntler.HeirloomOnly then return true end

	---@diagnostic disable-next-line: undefined-global
	return heirloom_is_special_keepsake(ANTLER) == true
end


function white_antler_restore()
	if not white_antler_active() then return end
	if not white_antler_persists() then return end

	local trait = game.GetHeroTrait(ANTLER)
	if not trait or (trait.Uses and trait.Uses > 0) then return end

	heirloom_requip_fresh(trait)
end
