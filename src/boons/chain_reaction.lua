---@meta _
---@diagnostic disable: lowercase-global


-- Chain Reaction no longer doubles a Blast: a boon effect's cooldown has a chance of being skipped

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

	modutil.mod.Path.Wrap("CheckCooldown", function(base, name, time, unmodified)
		local ready = base(name, time, unmodified)
		if ready then chain_reaction_eat(name, time) end
		return ready
	end)

	modutil.mod.Path.Wrap("AddTraitToHero", function(base, ...)
		mod.ChainReactionCooldowns = nil
		return base(...)
	end)

	modutil.mod.Path.Wrap("RemoveTrait", function(base, ...)
		mod.ChainReactionCooldowns = nil
		return base(...)
	end)

	modutil.mod.Path.Wrap("CheckMassiveAttack", function(base, victim, functionArgs, triggerArgs)
		local name = functionArgs and functionArgs.Name
		mod.ChainReactionSkipped = nil

		base(victim, functionArgs, triggerArgs)

		if not name or mod.ChainReactionSkipped ~= name then return end
		mod.ChainReactionSkipped = nil

		chain_reaction_log(name, true)
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


function chain_reaction_eat(name, time)
	if name == nil or type(time) ~= 'number' or time <= 0 then return false end
	if not chain_reaction_armed() then return false end
	if not chain_reaction_owns(name) then return false end
	if not rolls(mod.tuning.ChainReaction.SkipChance) then return false end

	game.ResetCooldown(name)
	mod.ChainReactionSkipped = name
	chain_reaction_announce()

	return true
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


-- Whether this cooldown belongs to a boon Melinoe is holding.
--
-- `CheckCooldown` is the game's one general-purpose timer and 136 places call it -- most of them
-- presentation, throttling a voice line or a screen shake or a text pop, several times a second and
-- with no boon behind them. Rolling on all of those is what made the boon announce itself
-- constantly. A cooldown only counts here if a held trait actually names it.
--
-- A boon writes its cooldown into its action's arguments as a `Name`/`Cooldown` pair -- that is the
-- shape the HUD reads to draw a recharge ring (`HUDLogic.lua:1481`, `:1502`, `:1509`), at no fixed
-- depth, so the sweep is recursive.
--
-- The prefix match is for the handful whose key is built at the call site rather than written down:
-- Athena's invulnerability is `"AthenaInvulnerability" .. ObjectId` against a trait that says only
-- `AthenaInvulnerability`.
local function chain_reaction_collect(node, names, depth)
	if type(node) ~= 'table' or depth > 5 then return end

	local name = rawget(node, 'Name')
	if type(name) == 'string' and type(rawget(node, 'Cooldown')) == 'number' then
		names[name] = true
	end

	for _, value in pairs(node) do
		if type(value) == 'table' then
			chain_reaction_collect(value, names, depth + 1)
		end
	end
end


function chain_reaction_cooldowns()
	if mod.ChainReactionCooldowns then return mod.ChainReactionCooldowns end

	local names = {}
	local hero = game.CurrentRun and game.CurrentRun.Hero

	for _, trait in ipairs((hero and hero.Traits) or {}) do
		chain_reaction_collect(trait, names, 0)
	end

	for _, extra in ipairs(mod.tuning.ChainReaction.ExtraCooldowns) do
		names[extra] = true
	end

	mod.ChainReactionCooldowns = names
	return names
end


function chain_reaction_owns(name)
	local names = chain_reaction_cooldowns()
	if names[name] then return true end

	for owned in pairs(names) do
		if #name > #owned and name:sub(1, #owned) == owned then return true end
	end

	return false
end
