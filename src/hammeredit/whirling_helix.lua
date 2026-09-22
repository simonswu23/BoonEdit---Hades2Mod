---@meta _
---@diagnostic disable: lowercase-global


once('WhirlingHelix', function()
	if not config.HammerChanges.WhirlingHelix.Enabled then return end

	local whirlingHelix = game.TraitData.TorchOrbitPointTrait

	for _, property in ipairs(whirlingHelix.PropertyChanges) do
		if property.ProjectileProperty == 'Speed' then
			property.BaseValue = mod.tuning.WhirlingHelix.SpeedMultiplier
		end
	end
end)
