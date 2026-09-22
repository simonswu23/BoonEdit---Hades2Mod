---@meta _
---@diagnostic disable: lowercase-global


once('RisingHelix', function()
	if not config.HammerChanges.RisingHelix.Enabled then return end

	game.TraitData.TorchLongevityTrait.AddOutgoingDamageModifiers.LifetimeMultiplier.BaseValue =
		mod.tuning.RisingHelix.MaxDamageBonus
end)
