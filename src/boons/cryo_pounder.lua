---@meta _
---@diagnostic disable: lowercase-global


-- Cryo Pounder (Demeter x Hephaestus): its bonus damage against Frozen foes covers hammer strikes as
-- well, not only volcanic blasts.

once('CryoPounderHammers', function()
	if not config.BoonChanges.CryoPounder.Enabled then return end

	local modifiers = game.TraitData.ClearRootBoon.AddOutgoingDamageModifiers

	table.insert(modifiers.ValidProjectiles, 'HephCastBlast')
	modifiers.ValidProjectilesLookup = game.ToLookup(modifiers.ValidProjectiles)
end)
