---@meta _
---@diagnostic disable: lowercase-global


once('ProfuseBleedingBloodSpill', function()
	if not config.BoonChanges.ProfuseBleeding.Enabled then return end

	local rend = game.TraitData.RendBloodDropBoon

	rend.RarityLevels = {
		Common = { Multiplier = 1.0 },
		Rare = { Multiplier = 1.5 },
		Epic = { Multiplier = 2.0 },
		Heroic = { Multiplier = 2.5 },
	}

	rend.AcquireFunctionName = 'SetupBloodDropDisplay'

	rend.BloodDropOrRendFallingBladeArgs = nil
	rend.OnEnemyDamagedAction = {
		FunctionName = 'CheckAresBloodDrop',
		Args = {
			Chance = { BaseValue = mod.tuning.ProfuseBleeding.SpillChance },
			RequiredEffect = 'AresStatus',
			Name = 'BloodDrop',
			ReportValues = { ReportedDropChance = 'Chance' },
		},
	}

	rend.StatLines = { 'BoonEditBloodSpillChanceStatDisplay' }
	rend.ExtractValues = with_keyword_extracts({
		{
			Key = 'ReportedDropChance',
			ExtractAs = 'TooltipDropChance',
			Format = 'LuckModifiedPercent',
			HideSigns = true,
		},
	}, 'Rend')
end)


function profuse_bleeding_fresh_rend(victim)
	if not config.BoonChanges.ProfuseBleeding.Enabled or not game.CurrentRun then return end
	if not victim or victim.IsDead or victim == game.CurrentRun.Hero then return end

	local trait = game.GetHeroTrait('RendBloodDropBoon')
	local args = trait and trait.OnEnemyDamagedAction and trait.OnEnemyDamagedAction.Args
	if not args or not args.Chance then return end

	if rolls(args.Chance * mod.tuning.ProfuseBleeding.FreshRendMultiplier) then
		game.thread(game.CreateBloodDrop, victim, args)
	end
end


once('ProfuseBleedingFreshRend', function()
	modutil.mod.Path.Wrap('EffectApply', function(base, victim, triggerArgs)
		local fresh = victim and triggerArgs and triggerArgs.EffectName == 'AresStatus'
			and not (victim.ActiveEffects and victim.ActiveEffects.AresStatus)

		local result = base(victim, triggerArgs)
		if fresh then profuse_bleeding_fresh_rend(triggerArgs.Victim or victim) end
		return result
	end)
end)
