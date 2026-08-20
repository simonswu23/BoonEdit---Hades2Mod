---@meta _
---@diagnostic disable: lowercase-global


once('CryoPounderHammers', function()
	if not config.BoonChanges.CryoPounder.Enabled then return end

	local modifiers = game.TraitData.ClearRootBoon.AddOutgoingDamageModifiers

	table.insert(modifiers.ValidProjectiles, 'HephCastBlast')
	modifiers.ValidProjectilesLookup = game.ToLookup(modifiers.ValidProjectiles)
end)
