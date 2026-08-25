---@meta _
---@diagnostic disable: lowercase-global


-- Chain Reaction no longer doubles a Blast: a boon effect's cooldown has a chance of being skipped
-- outright instead. A Blast is taken out of that generic path and given its own roll, because
-- CheckMassiveAttack reads the cooldown multiplier on every hit that reaches it and before it has
-- checked the cooldown at all (PowersLogic.lua:3281) -- so the knives were rolling many times a
-- second against a Blast that was not going to fire anyway, and the 30% read as no cooldown.

mod.ChainReactionDisplaying = mod.ChainReactionDisplaying or 0

once('ChainReactionCooldownSkip', function()
	if config.BoonChanges.ChainReaction.Enabled then
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
		if propertyName == 'OlympianRechargeMultiplier' then
			-- the read a Blast opens with, armed just below and spent here, so every other
			-- cooldown asking alongside it still rolls
			if mod.ChainReactionBlastRead then
				mod.ChainReactionBlastRead = nil
			elseif chain_reaction_skips() then
				chain_reaction_announce()
				return 0
			end
		end
		return base(propertyName, args)
	end)

	-- The Blast that lands is the one that rolls. Whether it landed is read off its own cooldown
	-- stamp, which CheckMassiveAttack sets through CheckCooldown before it fires anything.
	modutil.mod.Path.Wrap("CheckMassiveAttack", function(base, victim, functionArgs, triggerArgs)
		local name = functionArgs and functionArgs.Name
		local before = name and chain_reaction_stamp(name)

		mod.ChainReactionBlastRead = true
		base(victim, functionArgs, triggerArgs)
		mod.ChainReactionBlastRead = nil

		if not name or chain_reaction_stamp(name) == before then return end

		local skips = chain_reaction_armed() and rolls(mod.tuning.ChainReaction.SkipChance)
		chain_reaction_log(name, skips)
		if not skips then return end

		chain_reaction_announce()
		chain_reaction_ready(functionArgs.TraitName, name)
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


-- Read fresh either side of the Blast rather than held, since a room boundary can hand
-- SessionState a new table.
function chain_reaction_stamp(name)
	local session = game.SessionState
	local cooldowns = session and session.GlobalCooldowns
	return cooldowns and cooldowns[name]
end


function chain_reaction_log(name, skipped)
	if not config.Debug.LogChainReaction then return end

	print('[' .. _PLUGIN.guid .. '] ChainReaction ' .. tostring(name) ..
		' fired  held=' .. tostring(game.HeroHasTrait('DoubleMassiveAttackBoon') == true) ..
		'  skipped=' .. tostring(skipped == true))
end


function chain_reaction_armed()
	if not config.BoonChanges.ChainReaction.Enabled then return false end
	if not game.CurrentRun or not game.CurrentRun.Hero then return false end
	if mod.ChainReactionDisplaying > 0 then return false end
	return game.HeroHasTrait('DoubleMassiveAttackBoon')
end


function chain_reaction_skips()
	if not chain_reaction_armed() then return false end
	return rolls(mod.tuning.ChainReaction.SkipChance)
end


-- What vanilla does a cooldown later (PowersLogic.lua:3293), brought forward: the stamp cleared,
-- the tray sweep ended and the Blast-ready glow back on. The delayed one it threaded is killed
-- first, or it would mark the Blast ready a second time whatever state it is in by then.
function chain_reaction_ready(traitName, cooldownName)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or not traitName then return end

	game.ResetCooldown(cooldownName)
	game.killTaggedThreads(traitName)
	game.thread(game.MassiveAttackSetup, hero, { TraitName = traitName })
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
