---@meta _
---@diagnostic disable: lowercase-global

-- Carnal Pleasure (Aphrodite x Ares) no longer throws a Heartthrob on Plasma pickup; instead every
-- Heartthrob from elsewhere is stronger and larger, and increases with any Plasma you carry.
-- Also raises the Heartthrob cap from 6 to 12.

once('CarnalPleasurePlasmaBursts', function()
	if not config.BoonChanges.CarnalPleasurePlasmaBursts.Enabled then return end

	local carnal = game.TraitData.BloodManaBurstBoon

	carnal.BoonEditPlasmaBonus = mod.tuning.CarnalPleasure.BaseBonus

	carnal.DropManaBurstChance = 0

	modutil.mod.Path.Wrap("BloodDropUse", function(base, args, consumable)
		local result = base(args, consumable)
		carnal_pleasure_count_plasma()
		return result
	end)

	carnal.StatLines = {}
	table.insert(carnal.StatLines, 'BoonEditCarnalPleasurePlasmaStatDisplay')
	table.insert(carnal.ExtractValues, {
		Key = 'BoonEditPlasmaBonus',
		ExtractAs = 'TooltipPlasmaBonus',
		Format = 'Percent',
	})

	if mod.tuning.CarnalPleasure.ShowHeartthrobCapacity then
		carnal.BoonEditHeartthrobCapacity = mod.tuning.CarnalPleasure.HeartthrobCapacity
		table.insert(carnal.StatLines, 'BoonEditCarnalPleasureCapacityStatDisplay')
		table.insert(carnal.ExtractValues, {
			Key = 'BoonEditHeartthrobCapacity',
			ExtractAs = 'TooltipHeartthrobCapacity',
		})
	end
end)


function carnal_pleasure_plasma_boost()
	if not config.BoonChanges.CarnalPleasurePlasmaBursts.Enabled then return 1 end
	if not game.HeroHasTrait('BloodManaBurstBoon') then return 1 end

	local tuning = mod.tuning.CarnalPleasure
	local room = game.CurrentRun and game.CurrentRun.CurrentRoom

	local plasma = 0
	if room and tuning.PlasmaCeiling > 0 then
		plasma = math.min(room.BloodDropCount or 0, tuning.PlasmaCeiling)
	end

	local scaled = 0
	if tuning.PlasmaCeiling > 0 then
		scaled = tuning.PlasmaBonus * (plasma / tuning.PlasmaCeiling)
	end

	return 1 + tuning.BaseBonus + scaled
end


function carnal_pleasure_heartthrob_cap()
	if not config.BoonChanges.CarnalPleasurePlasmaBursts.Enabled then return nil end
	if not game.HeroHasTrait('BloodManaBurstBoon') then return nil end

	return mod.tuning.CarnalPleasure.HeartthrobCapacity
end


function carnal_pleasure_size_boost()
	if not config.BoonChanges.CarnalPleasurePlasmaBursts.Enabled then return 1 end
	if not game.HeroHasTrait('BloodManaBurstBoon') then return 1 end

	return mod.tuning.CarnalPleasure.HeartSizeMultiplier
end


function carnal_pleasure_count_plasma()
	if not config.BoonChanges.CarnalPleasurePlasmaBursts.Enabled then return end
	if not game.HeroHasTrait('BloodManaBurstBoon') then return end

	local heartBreaker = game.GetHeroTrait('ManaBurstBoon')
	local args = heartBreaker and heartBreaker.OnManaSpendAction and heartBreaker.OnManaSpendAction.FunctionArgs
	if not args then return end

	game.CheckManaBurst(args, mod.tuning.CarnalPleasure.PlasmaManaValue)
end
