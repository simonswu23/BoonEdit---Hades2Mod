---@meta _
---@diagnostic disable: lowercase-global


function white_antler_active()
	return config.KeepsakeChanges.WhiteAntler.Enabled and game.HeroHasTrait('LowHealthCritKeepsake')
end


function white_antler_restore()
	if not white_antler_active() then return end

	local trait = game.GetHeroTrait('LowHealthCritKeepsake')
	if not trait or (trait.Uses and trait.Uses > 0) then return end

	heirloom_requip_fresh(trait)
end
