---@meta _
---@diagnostic disable: lowercase-global

-- Unseen Ire (Hades) comes back around sooner; `ReportedCooldown` carries it, so the tooltip follows.

once('UnseenIreCooldown', function()
	if not config.BoonChanges.UnseenIreCooldown.Enabled then return end

	game.TraitData.HadesInvisibilityRetaliateBoon.OnSelfDamagedFunction.FunctionArgs.Cooldown =
		mod.tuning.UnseenIre.Cooldown
end)
