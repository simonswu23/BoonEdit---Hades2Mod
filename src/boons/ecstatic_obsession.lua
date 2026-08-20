---@meta _
---@diagnostic disable: lowercase-global


local OBSESSION_TRAIT = 'RandomStatusBoon'
local WRECK_TRAIT = 'CharmCrowdBoon'

once('EcstaticObsession', function()
	if not config.BoonChanges.EcstaticObsession.Enabled then return end

	local obsession = game.TraitData[OBSESSION_TRAIT]
	local wreck = game.TraitData[WRECK_TRAIT]
	if not obsession or not wreck then return end

	local wreckCurses = obsession.OnEffectApplyFunction
	local wreckStatLines = obsession.StatLines
	local wreckExtracts = obsession.ExtractValues
	local wreckIcon = obsession.Icon
	local obsessionIcon = wreck.Icon

	wreck.SetupFunction = nil
	wreck.OnEffectApplyFunction = wreckCurses
	wreck.StatLines = wreckStatLines
	wreck.ExtractValues = wreckExtracts
	wreck.Icon = wreckIcon

	obsession.OnEffectApplyFunction = nil
	obsession.Icon = obsessionIcon

	obsession.SetupFunction = {
		Threaded = true,
		Name = _PLUGIN.guid .. '.EcstaticObsession',
		Args = {
			Interval = 0.3,
		},
	}

	obsession.BoonEditCharmChance = mod.tuning.EcstaticObsession.CharmChance
	obsession.BoonEditCharmDuration = mod.tuning.EcstaticObsession.CharmDuration
	obsession.BoonEditDamagePerFriendly = mod.tuning.EcstaticObsession.DamagePerFriendly
	obsession.BoonEditMaxDamageBonus = mod.tuning.EcstaticObsession.MaxDamageBonus

	obsession.StatLines = {
		'BoonEditObsessionChanceStatDisplay',
	}

	obsession.ExtractValues = {
		{
			Key = 'BoonEditCharmChance',
			ExtractAs = 'TooltipChance',
			Format = 'LuckModifiedPercent',
			HideSigns = true,
		},
		{ Key = 'BoonEditDamagePerFriendly', ExtractAs = 'TooltipPerFriendly', Format = 'Percent' },
		{ Key = 'BoonEditCharmDuration', ExtractAs = 'TooltipDuration' },
		{ Key = 'BoonEditMaxDamageBonus', ExtractAs = 'TooltipMaxBonus', Format = 'Percent' },
	}

	game.EffectData.WeakEffect.OnApplyFunctionName = _PLUGIN.guid .. '.EcstaticObsessionWeak'
end)


local function obsession_interrupt_key(unit)
	return 'BoonEditObsessionInterrupt' .. tostring(unit.ObjectId)
end


local function obsession_charmable(unit)
	if unit.SkipModifiers or unit.BlockCharm then return false end

	if mod.tuning.EcstaticObsession.SpareBosses and (unit.IsBoss or unit.UseBossHealthBar) then
		return false
	end

	return true
end


local function obsession_charm(unit)
	game.ApplyEffect({
		Id = game.CurrentRun.Hero.ObjectId,
		DestinationId = unit.ObjectId,
		EffectName = 'Charm',
		DataProperties = {
			Type = 'CHARM',
			Duration = mod.tuning.EcstaticObsession.CharmDuration,
			Active = true,
			TimeModifierFraction = 0,
		},
	})
end


local function obsession_interrupt(unit)
	local weaponName = unit.WeaponName
	if not weaponName or not game.WeaponData[weaponName] then return false end

	local cooldown = mod.tuning.EcstaticObsession.InterruptCooldown
	if not game.CheckCooldown(obsession_interrupt_key(unit), cooldown) then return false end

	unit.ForcedWeaponInterrupt = true

	local vfx = game.EffectData.Charm and game.EffectData.Charm.Vfx
	if not vfx then return true end

	local objectId = unit.ObjectId
	game.CreateAnimation({ Name = vfx, DestinationId = objectId })

	game.thread(function()
		game.wait(mod.tuning.EcstaticObsession.CharmDuration, game.RoomThreadName)
		game.StopAnimation({ Name = vfx, DestinationId = objectId, PreventChain = true })
	end)

	return true
end


local OBSESSION_MODIFIER_NAME = 'BoonEditEcstaticObsession'


local function obsession_set_bonus(friendlyCount)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end
	hero.OutgoingDamageModifiers = hero.OutgoingDamageModifiers or {}

	local entry
	for _, modifier in ipairs(hero.OutgoingDamageModifiers) do
		if modifier.Name == OBSESSION_MODIFIER_NAME then
			entry = modifier
			break
		end
	end
	if not entry then
		entry = { Name = OBSESSION_MODIFIER_NAME, NonPlayerMultiplier = 1 }
		game.AddOutgoingDamageModifier(hero, entry)
	end

	local tuning = mod.tuning.EcstaticObsession
	entry.NonPlayerMultiplier = 1 + math.min(friendlyCount * tuning.DamagePerFriendly, tuning.MaxDamageBonus)
end


function mod.EcstaticObsession(hero, args)
	local interval = (args and args.Interval) or 0.3

	while game.CurrentRun and game.CurrentRun.CurrentRoom and game.CurrentRun.Hero
		and not game.CurrentRun.Hero.IsDead and game.HeroHasTrait(OBSESSION_TRAIT) do

		local friendly = 0
		if config.BoonChanges.EcstaticObsession.Enabled then
			local range = mod.tuning.EcstaticObsession.AllyRange
			for _, unit in pairs(game.ActiveEnemies or {}) do
				if unit and unit.ObjectId and not unit.IsDead and is_allied_summon(unit) then
					local distance = game.GetDistance({ Id = hero.ObjectId, DestinationId = unit.ObjectId })
					if distance and distance <= range then
						friendly = friendly + 1
					end
				end
			end
		end

		obsession_set_bonus(friendly)
		game.wait(interval, game.RoomThreadName)
	end

	obsession_set_bonus(0)
end


---@diagnostic disable-next-line: unused-local
function mod.EcstaticObsessionWeak(triggerArgs, _args)
	if not config.BoonChanges.EcstaticObsession.Enabled then return end
	if not game.HeroHasTrait(OBSESSION_TRAIT) then return end
	if not triggerArgs or triggerArgs.Reapplied then return end

	local victim = triggerArgs.Victim
	if not victim or not victim.ObjectId or victim.IsDead then return end
	if victim == (game.CurrentRun and game.CurrentRun.Hero) then return end

	if is_allied_summon(victim) then return end

	if not rolls(mod.tuning.EcstaticObsession.CharmChance) then return end

	game.thread(obsession_take, victim, triggerArgs.EffectName or 'WeakEffect')
end


function obsession_take(victim, effectName)

	game.waitUnmodified(0.01)

	if not victim.ObjectId or victim.IsDead then return end
	if not (game.ActiveEnemies or {})[victim.ObjectId] then return end

	if obsession_charmable(victim) then
		obsession_charm(victim)
	elseif not obsession_interrupt(victim) then
		return
	end

	game.ClearEffect({ Id = victim.ObjectId, Name = effectName })
end
