---@meta _
---@diagnostic disable: lowercase-global


once('PhalanxShot', function()
	if not config.BoonChanges.PhalanxShot.Enabled then return end

	local phalanx = game.TraitData.AthenaProjectileBoon
	local args = phalanx and phalanx.OnWeaponFiredFunctions and phalanx.OnWeaponFiredFunctions.FunctionArgs
	if not args then return end

	args.Cooldown = mod.tuning.PhalanxShot.Cooldown
end)
