---@meta _
---@diagnostic disable: lowercase-global


-- Controlled Burn fires on an Omega Attack as well as an Omega Special, and charges its Magick on
-- both. `CheckFireballSpawn` does its own `IsExWeapon` test (`PowersLogic.lua:3545`), so widening the
-- weapon list is the whole of it -- the Omega gating is already inside the function.
--
-- The lookups are rewritten alongside the lists: `ManaCostModifiers` is read through
-- `WeaponNamesLookup` (`ManaLogic.lua:154`) and never through `WeaponNames`, so a list changed on its
-- own would fire the fireball on an Omega Attack and charge nothing for it.


once('ControlledBurnOmegaAttack', function()
	if not config.BoonChanges.ControlledBurn.Enabled then return end

	local burn = game.TraitData.FireballManaSpecialBoon
	local weapons = game.WeaponSets.HeroPrimarySecondaryWeapons

	burn.OnWeaponFiredFunctions.ValidWeapons = game.DeepCopyTable(weapons)
	burn.OnWeaponFiredFunctions.ValidWeaponsLookup = game.ToLookup(weapons)

	burn.ManaCostModifiers.WeaponNames = game.DeepCopyTable(weapons)
	burn.ManaCostModifiers.WeaponNamesLookup = game.ToLookup(weapons)
end)
