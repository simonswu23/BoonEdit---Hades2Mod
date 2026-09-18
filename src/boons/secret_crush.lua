---@meta _
---@diagnostic disable: lowercase-global


once('SecretCrush', function()
	if not config.BoonChanges.SecretCrush.Enabled then return end

	local crush = game.TraitData.FocusRawDamageBoon
	local modifiers = crush and crush.AddOutgoingDamageModifiers
	if not modifiers then return end

	local weapons = game.AddLinkedWeapons(game.WeaponSets.HeroPrimarySecondaryWeapons)
	modifiers.ValidWeapons = weapons
	modifiers.ValidWeaponsLookup = game.ToLookup(weapons)
end)
