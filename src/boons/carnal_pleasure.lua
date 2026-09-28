---@meta _
---@diagnostic disable: lowercase-global


once('CarnalPleasure', function()
	if not config.BoonChanges.CarnalPleasure.Enabled then return end

	game.TraitData.BloodManaBurstBoon.DropManaBurstChance = mod.tuning.CarnalPleasure.HeartthrobChance
end)
