---@meta _
---@diagnostic disable: lowercase-global

-- Chain Reaction (Hestia x Hephaestus) no longer makes blasts strike twice; instead anything that
-- recharges over time may skip its recharge outright.

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
			return 0
		end
		return base(propertyName, args)
	end)
end)


function chain_reaction_skips()
	if not config.BoonChanges.ChainReactionCooldownSkip.Enabled then return false end
	if not game.CurrentRun or not game.CurrentRun.Hero then return false end
	if not game.HeroHasTrait('DoubleMassiveAttackBoon') then return false end
	return rolls(mod.tuning.ChainReaction.SkipChance)
end
