---@meta _
---@diagnostic disable: lowercase-global


-- Burning Desire additionally lifts the ceiling on Scorch, silently -- nothing is added to its
-- wording. The ceiling is `BurnEffect.MaxStacks`, read live by `ApplyBurn`, and nothing else in the
-- game overrides it, so it is set and put back rather than added to.
--
-- Reconciled at every room load so it follows the boon being gained, lost or traded without a hook
-- for each. The baseline lives on `mod`, so a reload landing while it is raised cannot make it stick.


local BURNING_DESIRE = 'BurnRefreshBoon'


function burning_desire_sync()
	local burn = game.EffectData and game.EffectData.BurnEffect
	if not burn then return end

	local wanted = config.BoonChanges.BurningDesire.Enabled
		and game.HeroHasTrait(BURNING_DESIRE) == true

	if wanted then
		if mod.BurningDesireBaseCap == nil then
			mod.BurningDesireBaseCap = burn.MaxStacks
		end
		burn.MaxStacks = mod.tuning.BurningDesire.ScorchCap
	elseif mod.BurningDesireBaseCap ~= nil then
		burn.MaxStacks = mod.BurningDesireBaseCap
		mod.BurningDesireBaseCap = nil
	end
end
