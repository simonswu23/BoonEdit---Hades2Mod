---@meta _
---@diagnostic disable: lowercase-global



once('ControlledBurnOmegaAttack', function()
	if not config.BoonChanges.ControlledBurn.Enabled then return end

	local burn = game.TraitData.FireballManaSpecialBoon
	local weapons = game.WeaponSets.HeroPrimarySecondaryWeapons

	burn.OnWeaponFiredFunctions.ValidWeapons = game.DeepCopyTable(weapons)
	burn.OnWeaponFiredFunctions.ValidWeaponsLookup = game.ToLookup(weapons)

	burn.ManaCostModifiers.WeaponNames = game.DeepCopyTable(weapons)
	burn.ManaCostModifiers.WeaponNamesLookup = game.ToLookup(weapons)
end)
