---@meta _
---@diagnostic disable: lowercase-global

-- Cryo Pounder (Demeter x Hephaestus): the bonus damage it deals to Frozen foes covers your hammer
-- strikes as well, not only volcanic blasts.

once('CryoPounderHammers', function()
	if not config.BoonChanges.CryoPounderHammers.Enabled then return end

	local modifiers = game.TraitData.ClearRootBoon.AddOutgoingDamageModifiers

	table.insert(modifiers.ValidProjectiles, 'HephCastBlast')
	modifiers.ValidProjectilesLookup = game.ToLookup(modifiers.ValidProjectiles)
end)
