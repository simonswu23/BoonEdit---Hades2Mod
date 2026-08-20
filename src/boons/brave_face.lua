---@meta _
---@diagnostic disable: lowercase-global


once('BraveFace', function()
	if not config.BoonChanges.BraveFace.Enabled then return end

	local braveFace = game.TraitData.ManaShieldBoon
	braveFace.ManaShieldData.DamageBlocked = mod.tuning.BraveFace.DamageBlocked
	braveFace.ManaShieldData.ManaPerDamageBlocked = mod.tuning.BraveFace.ManaPerDamage
end)
