---@meta _
---@diagnostic disable: lowercase-global


once('ArcticGaleArea', function()
	if not config.BoonChanges.ArcticGale.Enabled then return end

	modutil.mod.Path.Wrap('DemeterCastBlast', function(base, weaponData, traitArgs, triggerArgs)
		traitArgs.BlastRadiusMultiplier = cast_area_multiplier()
		return base(weaponData, traitArgs, triggerArgs)
	end)
end)
