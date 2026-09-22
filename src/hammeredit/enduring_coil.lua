---@meta _
---@diagnostic disable: lowercase-global


once('EnduringCoil', function()
	if not config.HammerChanges.EnduringCoil.Enabled then return end

	local enduringCoil = game.TraitData.TorchSpecialImpactTrait

	for _, property in ipairs(enduringCoil.PropertyChanges) do
		if property.ProjectileProperty == 'Fuse' then
			property.ProjectileName = nil
			property.ChangeType = 'Multiply'
			property.ChangeValue = mod.tuning.EnduringCoil.FuseMultiplier
			property.BaseValue = nil
		end
	end

	for _, extract in ipairs(enduringCoil.ExtractValues) do
		if extract.Key == 'ReportedIncrease' then
			extract.Format = 'PercentDelta'
			extract.IncludeSigns = true
		end
	end
end)
