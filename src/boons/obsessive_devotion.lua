---@meta _
---@diagnostic disable: lowercase-global

-- Obsessive Devotion and Nervous Wreck trade behaviours, not slots: `RandomStatusBoon` stays the
-- Legendary and `CharmCrowdBoon` stays the Duo, and only what they do and are called is swapped. Moving
-- the traits between slots means rewriting `InheritFrom`, the requirement tables, both god pools, the
-- codex lists and the pickup dialogue, and broke the game outright.

local DEVOTION_TRAIT = 'RandomStatusBoon'
local WRECK_TRAIT = 'CharmCrowdBoon'

once('ObsessiveDevotion', function()
	if not config.BoonChanges.ObsessiveDevotion.Enabled then return end

	local devotion = game.TraitData[DEVOTION_TRAIT]
	local wreck = game.TraitData[WRECK_TRAIT]
	if not devotion or not wreck then return end

	local wreckCurses = devotion.OnEffectApplyFunction
	local wreckStatLines = devotion.StatLines
	local wreckExtracts = devotion.ExtractValues
	local wreckIcon = devotion.Icon
	local devotionIcon = wreck.Icon

	wreck.SetupFunction = nil
	wreck.OnEffectApplyFunction = wreckCurses
	wreck.StatLines = wreckStatLines
	wreck.ExtractValues = wreckExtracts
	wreck.Icon = wreckIcon

	devotion.OnEffectApplyFunction = nil
	devotion.Icon = devotionIcon

	devotion.SetupFunction = {
		Threaded = true,
		Name = _PLUGIN.guid .. '.ObsessiveDevotion',
		Args = {
			Interval = 0.3,
		},
	}

	devotion.BoonEditCharmChance = mod.tuning.ObsessiveDevotion.CharmChance
	devotion.BoonEditCharmDuration = mod.tuning.ObsessiveDevotion.CharmDuration
	devotion.BoonEditDamagePerFriendly = mod.tuning.ObsessiveDevotion.DamagePerFriendly
	devotion.BoonEditMaxDamageBonus = mod.tuning.ObsessiveDevotion.MaxDamageBonus

	devotion.StatLines = {
		'BoonEditDevotionChanceStatDisplay',
	}

	devotion.ExtractValues = {
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

	game.EffectData.WeakEffect.OnApplyFunctionName = _PLUGIN.guid .. '.ObsessiveDevotionWeak'
end)


local function devotion_interrupt_key(unit)
	return 'BoonEditDevotionInterrupt' .. tostring(unit.ObjectId)
end


local function devotion_charmable(unit)
	return not unit.IsBoss and not unit.UseBossHealthBar and not unit.BlockCharm
		and not unit.SkipModifiers
end


local function devotion_charm(unit)
	game.ApplyEffect({
		Id = game.CurrentRun.Hero.ObjectId,
		DestinationId = unit.ObjectId,
		EffectName = 'Charm',
		DataProperties = {
			Type = 'CHARM',
			Duration = mod.tuning.ObsessiveDevotion.CharmDuration,
			Active = true,
			TimeModifierFraction = 0,
		},
	})
end


local function devotion_interrupt(unit)
	local weaponName = unit.WeaponName
	if not weaponName or not game.WeaponData[weaponName] then return false end

	local cooldown = mod.tuning.ObsessiveDevotion.InterruptCooldown
	if not game.CheckCooldown(devotion_interrupt_key(unit), cooldown) then return false end

	unit.ForcedWeaponInterrupt = true

	local vfx = game.EffectData.Charm and game.EffectData.Charm.Vfx
	if not vfx then return true end

	local objectId = unit.ObjectId
	game.CreateAnimation({ Name = vfx, DestinationId = objectId })

	game.thread(function()
		game.wait(mod.tuning.ObsessiveDevotion.CharmDuration, game.RoomThreadName)
		game.StopAnimation({ Name = vfx, DestinationId = objectId, PreventChain = true })
	end)

	return true
end


local DEVOTION_MODIFIER_NAME = 'BoonEditObsessiveDevotion'


local function devotion_set_bonus(friendlyCount)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end
	hero.OutgoingDamageModifiers = hero.OutgoingDamageModifiers or {}

	local entry
	for _, modifier in ipairs(hero.OutgoingDamageModifiers) do
		if modifier.Name == DEVOTION_MODIFIER_NAME then
			entry = modifier
			break
		end
	end
	if not entry then
		entry = { Name = DEVOTION_MODIFIER_NAME, NonPlayerMultiplier = 1 }
		game.AddOutgoingDamageModifier(hero, entry)
	end

	local tuning = mod.tuning.ObsessiveDevotion
	entry.NonPlayerMultiplier = 1 + math.min(friendlyCount * tuning.DamagePerFriendly, tuning.MaxDamageBonus)
end


function mod.ObsessiveDevotion(hero, args)
	local interval = (args and args.Interval) or 0.3

	while game.CurrentRun and game.CurrentRun.CurrentRoom and game.CurrentRun.Hero
		and not game.CurrentRun.Hero.IsDead and game.HeroHasTrait(DEVOTION_TRAIT) do

		local friendly = 0
		if config.BoonChanges.ObsessiveDevotion.Enabled then
			local range = mod.tuning.ObsessiveDevotion.AllyRange
			for _, unit in pairs(game.ActiveEnemies or {}) do
				if unit and unit.ObjectId and not unit.IsDead and is_allied_summon(unit) then
					local distance = game.GetDistance({ Id = hero.ObjectId, DestinationId = unit.ObjectId })
					if distance and distance <= range then
						friendly = friendly + 1
					end
				end
			end
		end

		devotion_set_bonus(friendly)
		game.wait(interval, game.RoomThreadName)
	end

	devotion_set_bonus(0)
end


---@diagnostic disable-next-line: unused-local
function mod.ObsessiveDevotionWeak(triggerArgs, _args)
	if not config.BoonChanges.ObsessiveDevotion.Enabled then return end
	if not game.HeroHasTrait(DEVOTION_TRAIT) then return end
	if not triggerArgs or triggerArgs.Reapplied then return end

	local victim = triggerArgs.Victim
	if not victim or not victim.ObjectId or victim.IsDead then return end
	if victim == (game.CurrentRun and game.CurrentRun.Hero) then return end

	if is_allied_summon(victim) then return end

	if not rolls(mod.tuning.ObsessiveDevotion.CharmChance) then return end

	if devotion_charmable(victim) then
		devotion_charm(victim)
	elseif not devotion_interrupt(victim) then
		return
	end

	game.ClearEffect({ Id = victim.ObjectId, Name = triggerArgs.EffectName or 'WeakEffect' })
end
