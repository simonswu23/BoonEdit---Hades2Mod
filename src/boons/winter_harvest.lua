---@meta _
---@diagnostic disable: lowercase-global

-- Winter Harvest (Demeter legendary) executes from higher up, and against a boss measures that
-- against the whole fight rather than the current health bar, so it can end the fight in an
-- earlier phase. Prometheus loses his execute immunity.
once('WinterHarvestBosses', function()
	-- ReportedThreshold carries the number, so the tooltip follows.
	if config.BoonChanges.WinterHarvestBosses.Enabled then
		local harvest = game.TraitData.InstantRootKill.OnDamageEnemyFunction.FunctionArgs
		harvest.ExecuteImmunities = nil
		harvest.ChillDeathThreshold = mod.tuning.WinterHarvest.ExecuteThreshold
	end

	-- A multi-phase boss otherwise survives its own execute. Reporting it as already in the last
	-- phase clears both gates that would transition instead.
	modutil.mod.Path.Wrap("CheckChillKill", function(base, args, attacker, victim, triggerArgs)
		args = winter_harvest_pooled_args(args, victim)
		if winter_harvest_executes(args, attacker, victim, triggerArgs) then
			local skipping = winter_harvest_skips_phase(victim)
			if skipping then
				victim.CurrentPhase = victim.Phases
			end

			-- unconditional: the stage machine resurrects on health alone, phase declared or not
			winter_harvest_stop_phases(victim)

			if skipping then
				winter_harvest_shout(victim)
			end
		end
		return base(args, attacker, victim, triggerArgs)
	end)
end)


-- Each phase carries its own health bar. These are the bars in order, only as many as the boss
-- actually reaches.
local function boss_phase_healths(victim)
	local template = game.EnemyData[victim.Name]
	local stages = victim.AIStages or (template and template.AIStages)
	if not stages then return nil end

	-- Counted off the stages: Typhon only declares Phases under the boss Oath, yet fights two bars
	-- regardless. Phases just caps it.
	local phases = victim.Phases or math.huge

	-- MaxHealth is rewritten as each phase begins, so the opening bar is kept while it is up.
	if (victim.CurrentPhase or 1) == 1 then
		victim.BoonEditFirstPhaseHealth = victim.MaxHealth
	end

	local healths = { victim.BoonEditFirstPhaseHealth or (template and template.MaxHealth) }
	if not healths[1] then return nil end

	local extremeMeasures = game.IsBossDifficultyShrineUpgradeActive()
	for _, stage in ipairs(stages) do
		if #healths < phases then
			-- vanilla folds these in only as each stage begins, so a later bar still reads its base
			local overrides = extremeMeasures and stage.EMStageDataOverrides
			local health = (overrides and overrides.NewMaxHealth) or stage.NewMaxHealth
			if health then
				healths[#healths + 1] = health
			end
		end
	end
	return healths
end

-- The comparison lives in vanilla, so the threshold is restated against this phase instead.
function winter_harvest_pooled_args(args, victim)
	if not config.BoonChanges.WinterHarvestBosses.Enabled then return args end
	if not victim or not victim.MaxHealth or victim.MaxHealth <= 0 then return args end

	local healths = boss_phase_healths(victim)
	if not healths or #healths < 2 then return args end

	local total, later = 0, 0
	for phase, health in ipairs(healths) do
		total = total + health
		if phase > (victim.CurrentPhase or 1) then later = later + health end
	end

	local scaled = game.ShallowCopyTable(args)
	scaled.ChillDeathThreshold = (args.ChillDeathThreshold * total - later) / victim.MaxHealth
	return scaled
end

-- CheckChillKill fires the kill on a thread, so its conditions are repeated here. Its phase test
-- is omitted: Typhon leaves Phases unset.
function winter_harvest_executes(args, attacker, victim, triggerArgs)
	if not config.BoonChanges.WinterHarvestBosses.Enabled then return false end
	if not victim or not victim.ObjectId then return false end
	if not victim.MaxHealth or victim.MaxHealth <= 0 then return false end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if attacker ~= hero then return false end
	if victim.IsDead or victim.CannotDieFromDamage then return false end
	if game.SessionMapState.FiredChillKill[victim.ObjectId] then return false end
	if not triggerArgs or triggerArgs.SourceProjectile == args.ProjectileName then return false end
	if not game.HasEffectWithEffectGroup(victim, 'Root') or not victim.RootActive then return false end

	return victim.Health / victim.MaxHealth <= args.ChillDeathThreshold
end

function winter_harvest_skips_phase(victim)
	return victim.Phases ~= nil and (victim.CurrentPhase or 1) < victim.Phases
end

-- Killing a boss does not stop its AI, and the next transition would fire -- Typhon's revives him.
function winter_harvest_stop_phases(victim)
	victim.AIEndHealthThreshold = nil
	victim.ReachedAIStageEnd = nil
	if victim.AIThreadName then
		game.killTaggedThreads(victim.AIThreadName)
	end
end


-- Zagreus, taken by his grandmother's work before his second phase.
local ZAGREUS_HARVEST_LINE = {
	{
		-- without this the line is dropped outright while he is mid-quip
		Queue = 'Interrupt',
		Source = { LineHistoryName = 'NPC_Zagreus_01', SubtitleColor = game.Color.ZagreusVoice },
		{ Cue = '/VO/Zagreus_0358', Text = 'Grandmother...?' },
	},
}

function winter_harvest_shout(victim)
	if not victim or victim.Name ~= 'Zagreus' then return end
	game.thread(game.PlayVoiceLines, ZAGREUS_HARVEST_LINE, true, victim)
end
