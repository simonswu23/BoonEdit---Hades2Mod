---@meta _
---@diagnostic disable: lowercase-global


function concave_stone_active()
	return config.KeepsakeChanges.ConcaveStone.Enabled and game.HeroHasTrait('UnpickedBoonKeepsake')
end


once('ConcaveStone', function()
	modutil.mod.Path.Wrap('HandleUpgradeChoiceSelection', function(base, screen, button, args)
		args = args or {}
		local doubling = not args.BoonEditConcaveStoneDouble and concave_stone_active()
		local trait = doubling and game.GetHeroTrait('UnpickedBoonKeepsake')
		local chance = trait and trait.DoubleBoonChance
		if trait then trait.DoubleBoonChance = 0 end

		base(screen, button, args)

		if trait then trait.DoubleBoonChance = chance end
		if not doubling or not trait or not trait.Uses or trait.Uses <= 0 then return end
		if not button.LootData or button.LootData.BlockDoubleBoon then return end
		if not (button.LootData.GodLoot or button.LootData.TreatAsGodLootByShops or button.LootData.StackOnly) then return end
		if not game.RandomChance(chance * game.GetTotalHeroTraitValue('LuckMultiplier', { IsMultiplier = true })) then return end

		game.ReduceTraitUses(trait)
		game.thread(game.DoubleBoonPresentation, screen, button)
		base(screen, button, { BoonEditConcaveStoneDouble = true })
	end)
end)
