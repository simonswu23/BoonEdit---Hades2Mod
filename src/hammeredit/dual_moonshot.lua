---@meta _
---@diagnostic disable: lowercase-global


once('DualMoonshot', function()
	if not config.HammerChanges.DualMoonshot.Enabled then return end

	local dualMoonshot = game.TraitData.StaffTripleShotTrait
	local changes = dualMoonshot.PropertyChanges

	for index = #changes, 1, -1 do
		local property = changes[index]
		if property.WeaponName == 'WeaponStaffBall'
			and (property.ProjectileProperty == 'Fuse' or property.ProjectileProperty == 'Range') then
			table.remove(changes, index)
		end
	end

	for index = #dualMoonshot.ExtractValues, 1, -1 do
		if dualMoonshot.ExtractValues[index].Key == 'ReportedRangePenalty' then
			table.remove(dualMoonshot.ExtractValues, index)
		end
	end
end)
