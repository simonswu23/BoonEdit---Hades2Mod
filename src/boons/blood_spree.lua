---@meta _
---@diagnostic disable: lowercase-global


local BLOOD_SPREE = 'LowHealthLifestealBoon'

local KILLS = 'BoonEditBloodSpreeKills'
local CHANCE = 'BoonEditBloodSpreeChance'


once('BloodSpreeKillCrit', function()

	modutil.mod.Path.Wrap("KillEnemy", function(base, victim, triggerArgs)
		base(victim, triggerArgs)
		---@diagnostic disable-next-line: undefined-global
		blood_spree_orphan_kill(victim, triggerArgs)
	end)

	if not config.BoonChanges.BloodSpree.Enabled then return end

	local trait = game.TraitData[BLOOD_SPREE]
	if not trait then return end

	local scale = mod.tuning.BloodSpree.RarityScale

	trait.BoonEditKillCritChance = {
		BaseValue = mod.tuning.BloodSpree.CritChancePerKill,
		CustomRarityMultiplier = {
			Common = { Multiplier = scale.Common },
			Rare = { Multiplier = scale.Rare },
			Epic = { Multiplier = scale.Epic },
			Heroic = { Multiplier = scale.Heroic },
		},
	}

	trait.AddOutgoingDoubleDamageModifiers = { Chance = { BaseValue = 0 } }
	trait.OnEnemyDeathFunction = { Name = _PLUGIN.guid .. '.BloodSpreeKill' }
	trait.SetupFunction = { Name = _PLUGIN.guid .. '.BloodSpreeSetup' }

	trait.ShowInHUD = true
	trait.CustomLabel = {
		DisplayType = 'RoomValue',
		Key = CHANCE,
		Text = 'UI_TimedKillBuff',
	}

	table.insert(trait.StatLines, 'BoonEditBloodSpreeCritStatDisplay')
	table.insert(trait.CustomStatLinesWithShrineUpgrade.StatLines, 'BoonEditBloodSpreeCritStatDisplay')
	table.insert(trait.ExtractValues, {
		Key = 'BoonEditKillCritChance',
		ExtractAs = 'BoonEditKillCritChance',
		Format = 'LuckModifiedPercent',
		DecimalPlaces = 1,
	})
end)


local ORPHANED_KILL_EFFECTS = {
	DamageShareDeath = true,
}

function blood_spree_orphan_kill(victim, triggerArgs)
	if not config.BoonChanges.BloodSpree.Enabled then return end

	if not game.HeroHasTrait(BLOOD_SPREE) then return end
	if not victim or victim.SkipModifiers then return end
	if not triggerArgs or triggerArgs.AttackerTable ~= nil then return end
	if not ORPHANED_KILL_EFFECTS[triggerArgs.EffectName] then return end

	mod.BloodSpreeKill(victim, nil, triggerArgs)
end


---@diagnostic disable-next-line: unused-local
function mod.BloodSpreeKill(victim, _args, _triggerArgs)
	if not config.BoonChanges.BloodSpree.Enabled then return end
	---@diagnostic disable-next-line: undefined-global
	if is_allied_summon(victim) then return end

	local room = game.CurrentRun and game.CurrentRun.CurrentRoom
	if not room then return end

	room[KILLS] = (room[KILLS] or 0) + 1
	blood_spree_apply()
end


---@diagnostic disable-next-line: unused-local
function mod.BloodSpreeSetup(_hero, _args, _setupArgs, _trait)
	if not config.BoonChanges.BloodSpree.Enabled then return end

	blood_spree_apply()
end


function blood_spree_apply()
	local hero = game.CurrentRun and game.CurrentRun.Hero
	local room = game.CurrentRun and game.CurrentRun.CurrentRoom
	if not hero or not room then return end

	local trait = game.GetHeroTrait(BLOOD_SPREE)
	if not trait then return end

	local perKill = trait.BoonEditKillCritChance
	if type(perKill) ~= 'number' then return end

	local chance = math.min(perKill * (room[KILLS] or 0), mod.tuning.BloodSpree.MaxCritChance)

	for _, data in ipairs(hero.OutgoingDoubleDamageModifiers or {}) do
		if data.Name == BLOOD_SPREE then
			data.Chance = chance
		end
	end

	room[CHANCE] = game.round(chance * 1000) / 10
	game.UpdateTraitNumber(trait)
end
