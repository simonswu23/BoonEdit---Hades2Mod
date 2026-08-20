---@meta _
---@diagnostic disable: lowercase-global


once('CarnalPleasurePlasmaBursts', function()
	if not config.BoonChanges.CarnalPleasure.Enabled then return end

	local carnal = game.TraitData.BloodManaBurstBoon

	carnal.BoonEditBonusDamage = mod.tuning.CarnalPleasure.BaseDamage

	carnal.DropManaBurstChance = 0

	modutil.mod.Path.Wrap("BloodDropUse", function(base, args, consumable)
		local result = base(args, consumable)
		carnal_pleasure_count_plasma()
		return result
	end)

	for _, extract in ipairs(carnal.ExtractValues) do
		if extract.Key == 'DropManaBurstChance' then
			extract.SkipAutoExtract = true
		end
	end

	carnal.StatLines = {}
	table.insert(carnal.StatLines, 'BoonEditCarnalPleasurePlasmaStatDisplay')
	table.insert(carnal.ExtractValues, {
		Key = 'BoonEditBonusDamage',
		ExtractAs = 'TooltipBonusDamage',
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


local function carnal_pleasure_plasma()
	local tuning = mod.tuning.CarnalPleasure
	local room = game.CurrentRun and game.CurrentRun.CurrentRoom

	local plasma = (room and room.BloodDropCount) or 0
	if tuning.PlasmaCeiling > 0 then
		plasma = math.min(plasma, tuning.PlasmaCeiling)
	end

	return plasma
end


function carnal_pleasure_bonus_damage()
	if not config.BoonChanges.CarnalPleasure.Enabled then return 0 end
	if not game.HeroHasTrait('BloodManaBurstBoon') then return 0 end

	local tuning = mod.tuning.CarnalPleasure
	return tuning.BaseDamage + carnal_pleasure_plasma() * tuning.DamagePerPlasma
end


function carnal_pleasure_heartthrob_cap()
	if not config.BoonChanges.CarnalPleasure.Enabled then return nil end
	if not game.HeroHasTrait('BloodManaBurstBoon') then return nil end

	return mod.tuning.CarnalPleasure.HeartthrobCapacity
end


function carnal_pleasure_size_boost()
	if not config.BoonChanges.CarnalPleasure.Enabled then return 1 end
	if not game.HeroHasTrait('BloodManaBurstBoon') then return 1 end

	local tuning = mod.tuning.CarnalPleasure
	return tuning.BaseRadius + carnal_pleasure_plasma() * tuning.RadiusPerPlasma
end


function carnal_pleasure_count_plasma()
	if not config.BoonChanges.CarnalPleasure.Enabled then return end
	if not game.HeroHasTrait('BloodManaBurstBoon') then return end

	local heartBreaker = game.GetHeroTrait('ManaBurstBoon')
	local args = heartBreaker and heartBreaker.OnManaSpendAction and heartBreaker.OnManaSpendAction.FunctionArgs
	if not args then return end

	game.CheckManaBurst(args, mod.tuning.CarnalPleasure.PlasmaManaValue)
end
