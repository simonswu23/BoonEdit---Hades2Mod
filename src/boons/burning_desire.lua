---@meta _
---@diagnostic disable: lowercase-global


-- Burning Desire additionally lifts the ceiling on Scorch


local BURNING_DESIRE = 'BurnRefreshBoon'


function burning_desire_sync()
	local burn = game.EffectData and game.EffectData.BurnEffect
	if not burn then return end

	local wanted = config.BoonChanges.BurningDesire.Enabled
		and in_run() and game.HeroHasTrait(BURNING_DESIRE) == true

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
