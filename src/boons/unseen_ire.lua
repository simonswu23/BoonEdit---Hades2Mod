---@meta _
---@diagnostic disable: lowercase-global


once('UnseenIreCooldown', function()
	if not config.BoonChanges.UnseenIre.Enabled then return end

	game.TraitData.HadesInvisibilityRetaliateBoon.OnSelfDamagedFunction.FunctionArgs.Cooldown =
		mod.tuning.UnseenIre.Cooldown
end)
