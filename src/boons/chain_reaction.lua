---@meta _
---@diagnostic disable: lowercase-global

-- Chain Reaction (Hestia x Hephaestus) no longer makes blasts strike twice; instead anything that
-- recharges over time may skip its recharge outright, announcing itself when it does.

mod.ChainReactionDisplaying = mod.ChainReactionDisplaying or 0

once('ChainReactionCooldownSkip', function()
	if config.BoonChanges.ChainReactionCooldownSkip.Enabled then
		local chain = game.TraitData.DoubleMassiveAttackBoon

		chain.DoubleAttackInterval = nil
		chain.NumAttacks = nil

		chain.BoonEditSkipChance = mod.tuning.ChainReaction.SkipChance
		chain.StatLines = { 'BoonEditCooldownSkipStatDisplay' }
		chain.ExtractValues = {
			{
				Key = 'BoonEditSkipChance',
				ExtractAs = 'Chance',
				Format = 'LuckModifiedPercent',
				HideSigns = true,
			},
		}
	end

	modutil.mod.Path.Wrap("GetTotalHeroTraitValue", function(base, propertyName, args)
		if propertyName == 'OlympianRechargeMultiplier' and chain_reaction_skips() then
			chain_reaction_announce()
			return 0
		end
		return base(propertyName, args)
	end)

	for _, name in ipairs({ 'SetTraitTextData', 'TraitUIActivateTraits' }) do
		modutil.mod.Path.Wrap(name, function(base, ...)
			mod.ChainReactionDisplaying = mod.ChainReactionDisplaying + 1
			local ok, err = pcall(base, ...)
			mod.ChainReactionDisplaying = mod.ChainReactionDisplaying - 1
			if not ok then error(err, 0) end
		end)
	end
end)


function chain_reaction_skips()
	if not config.BoonChanges.ChainReactionCooldownSkip.Enabled then return false end
	if not game.CurrentRun or not game.CurrentRun.Hero then return false end
	if mod.ChainReactionDisplaying > 0 then return false end
	if not game.HeroHasTrait('DoubleMassiveAttackBoon') then return false end
	return rolls(mod.tuning.ChainReaction.SkipChance)
end


function chain_reaction_announce()
	local hero = game.CurrentRun.Hero
	if not hero.ObjectId then return end

	game.thread(game.InCombatTextArgs, {
		TargetId = hero.ObjectId,
		Text = 'BoonEditChainReactionCombatText',
		Duration = mod.tuning.ChainReaction.TextDuration,
		Cooldown = mod.tuning.ChainReaction.TextCooldown,
		PreDelay = 0.1,
	})
end
