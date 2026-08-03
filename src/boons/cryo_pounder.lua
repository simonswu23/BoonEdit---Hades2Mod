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


if config.BoonChanges.CryoPounderHammers.Enabled then
	boon_text({
		Traits = {
			ClearRootBoon = {
				Description = 'Your blast effects and hammer strikes from {#BoldFormatGraft}Hephaestus {#Prev}deal more damage to {$Keywords.Root}-afflicted foes.',
			},
		},
	})
end
