---@meta _
---@diagnostic disable: lowercase-global

-- Chain Reaction (Hestia x Hephaestus) no longer makes blasts strike twice; instead anything that
-- recharges over time -- the same effects Divine Haste speeds up -- may skip its recharge outright.

mod.tuning.ChainReaction = {
	SkipChance = 0.30,
}

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

	-- A multiplier of zero is the skip: the game reads a non-positive time as ready.
	modutil.mod.Path.Wrap("GetTotalHeroTraitValue", function(base, propertyName, args)
		if propertyName == 'OlympianRechargeMultiplier' and chain_reaction_skips() then
			return 0
		end
		return base(propertyName, args)
	end)
end)


-- Rolled per recharge rather than per boon, so a run of them can chain.
function chain_reaction_skips()
	if not config.BoonChanges.ChainReactionCooldownSkip.Enabled then return false end
	if not game.CurrentRun or not game.CurrentRun.Hero then return false end
	if not game.HeroHasTrait('DoubleMassiveAttackBoon') then return false end
	return rolls(mod.tuning.ChainReaction.SkipChance)
end


if config.BoonChanges.ChainReactionCooldownSkip.Enabled then
	boon_text({
		Traits = {
			DoubleMassiveAttackBoon = {
				Description = 'Any {$Keywords.GodBoon} effects that recharge over time may skip their recharge entirely, becoming ready at once.',
			},
		},
		StatLines = {
			BoonEditCooldownSkipStatDisplay = 'Recharge Skip Chance:',
		},
	})
end
