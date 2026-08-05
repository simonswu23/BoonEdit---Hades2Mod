---@meta _
---@diagnostic disable: lowercase-global

-- Brave Face (Hephaestus x Hera) resists half of every hit rather than a third, at 5 Magick a point
-- instead of 10.
once('BraveFace', function()
	if not config.BoonChanges.BraveFace.Enabled then return end

	-- both numbers are reported through vanilla's own ReportValues, so the tooltip follows on its own
	local braveFace = game.TraitData.ManaShieldBoon
	braveFace.ManaShieldData.DamageBlocked = mod.tuning.BraveFace.DamageBlocked
	braveFace.ManaShieldData.ManaPerDamageBlocked = mod.tuning.BraveFace.ManaPerDamage
end)
