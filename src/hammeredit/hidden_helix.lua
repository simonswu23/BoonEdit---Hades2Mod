---@meta _
---@diagnostic disable: lowercase-global


once('HiddenHelix', function()
	if not config.HammerChanges.HiddenHelix.Enabled then return end

	local hiddenHelix = game.TraitData.TorchExSpecialCountTrait
	local extra = mod.tuning.HiddenHelix.ExtraProjectiles

	hiddenHelix.ChargeStageModifiers.IncreaseNumProjectiles.NumProjectiles = extra
	hiddenHelix.ChargeStageModifiers.AddWeaponProperties.ProjectileAngleOffset = math.rad(360 / 4)

	for _, property in ipairs(hiddenHelix.PropertyChanges) do
		if property.WeaponProperty == 'NumProjectiles' then
			property.ChangeValue = extra
		elseif property.WeaponProperty == 'ProjectileAngleOffset' then
			property.ChangeValue = math.rad(-360 / 3)
		end
	end
end)
