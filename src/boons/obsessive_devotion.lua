---@meta _
---@diagnostic disable: lowercase-global

-- **Obsessive Devotion and Nervous Wreck trade behaviours, not slots.** Obsessive Devotion should be
-- Aphrodite's Legendary and Nervous Wreck the Aphrodite x Hera Duo -- but moving the traits between
-- slots means rewriting `InheritFrom`, the requirement tables, both god pools, the codex lists and
-- the pickup dialogue, and that broke the game outright.
--
-- Nothing about a slot needs to move. `RandomStatusBoon` stays the Legendary and `CharmCrowdBoon`
-- stays the Duo -- each keeps its frame, its requirements, its place in every list -- and what is
-- swapped is what they *do* and what they are called. The player sees the swap they asked for; the
-- game sees two boons behaving differently, which is all this mod ever does.
--
-- So: the Legendary carries Obsessive Devotion (Weak sometimes comes out as Charm, and you deal more
-- damage per nearby ally), and the Duo carries Nervous Wreck's random status curses, lifted whole
-- from the trait that used to hold them.
local DEVOTION_TRAIT = 'RandomStatusBoon'
local WRECK_TRAIT = 'CharmCrowdBoon'

once('ObsessiveDevotion', function()
	if not config.BoonChanges.ObsessiveDevotion.Enabled then return end

	local devotion = game.TraitData[DEVOTION_TRAIT]
	local wreck = game.TraitData[WRECK_TRAIT]
	if not devotion or not wreck then return end

	-- Read before either is written over, since each is about to be handed the other's.
	local wreckCurses = devotion.OnEffectApplyFunction
	local wreckStatLines = devotion.StatLines
	local wreckExtracts = devotion.ExtractValues
	local wreckIcon = devotion.Icon
	local devotionIcon = wreck.Icon

	-- Nervous Wreck onto the Duo. `CharmCrowd` is vanilla's own loop hunting a crowd to Charm one
	-- of, and it has nothing to do with random curses, so it goes.
	wreck.SetupFunction = nil
	wreck.OnEffectApplyFunction = wreckCurses
	wreck.StatLines = wreckStatLines
	wreck.ExtractValues = wreckExtracts
	wreck.Icon = wreckIcon

	-- Obsessive Devotion onto the Legendary. Its own curse trigger goes with the name.
	devotion.OnEffectApplyFunction = nil
	devotion.Icon = devotionIcon

	-- The loop is for counting who is fighting near you; the Charm half is not on a timer, it
	-- answers the Weak you inflict.
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

	-- **Two, and never more.** The tray builds a fixed pair of stat-line boxes and walks the trait's
	-- list against them (`TraitTrayLogic.lua:1598`), so a third entry indexes a nil box and takes the
	-- game down the moment the boon is looked at.
	devotion.StatLines = {
		'BoonEditDevotionChanceStatDisplay',
		'BoonEditDevotionDamageStatDisplay',
	}

	-- The two with lines come first: anything past the second resolved to a raw token rather than
	-- its figure, which is what printed "PercentNewTotal3" where the damage should have been.
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

	-- **Hooked on the effect, not on `ApplyAphroditeVulnerability`.** Only two things in the game
	-- name that function -- one sprint boon and one Talent -- while every other Aphrodite boon
	-- carries `EffectName = "WeakEffect"` and the engine applies it natively.
	--
	-- `OnApplyFunctionName` is dispatched by `EffectApply` (`CombatLogic.lua:4334`), so it sees every
	-- Weak however it was applied. Running under `EffectApply` also puts the roll inside CombatLogic,
	-- which is what lets Tipped Scales' Favor reach it.
	game.EffectData.WeakEffect.OnApplyFunctionName = _PLUGIN.guid .. '.ObsessiveDevotionWeak'
end)


-- Per foe, so a crowd is not one shared timer.
local function devotion_interrupt_key(unit)
	return 'BoonEditDevotionInterrupt' .. tostring(unit.ObjectId)
end


-- Vanilla's own test, from `CharmCrowd` (`PowersLogic.lua:3376`): a boss or anything carrying
-- BlockCharm is what the game means by "cannot be Charmed".
--
-- **`UseBossHealthBar` is asked as well, which vanilla's test does not.** Guardians carry it without
-- carrying `IsBoss`, so they read as charmable here, the Charm was applied and quietly did nothing,
-- and the interrupt below -- the thing they were supposed to get -- never ran. It is the same test
-- `shocking_loss_guardian` uses for the same reason.
local function devotion_charmable(unit)
	return not unit.IsBoss and not unit.UseBossHealthBar and not unit.BlockCharm
end


-- The same shape `CharmCrowd` applies, with this boon's duration in place of vanilla's half second.
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


-- What a boss gets instead. `ForcedWeaponInterrupt` is the game's own way of breaking off an attack
-- mid-pattern -- it is what a dodge does (`EnemyDodge`), and what Charm itself does on the allegiance
-- flip -- so a boss reads this as being staggered rather than as nothing happening.
--
-- Returns false when the cooldown has not come round, which lets the Weak land as normal.
--
-- The heart is played over it either way. Nothing else about this reads as Charm -- the foe does not
-- turn, and a broken-off attack looks like the foe simply choosing to do something else -- so
-- without the Vfx there is no telling the boon fired at all. `AphroditeDebuffStatus` is the
-- animation `EffectData.Charm` itself carries, so a Guardian shows exactly what a Charmed foe shows.
--
-- **And it has to be taken off by hand.** A real Charm stops its own Vfx when the effect clears;
-- there is no effect here, so the animation was simply left running and a Guardian kept the heart
-- for the rest of the fight. It is stopped after `CharmDuration`, which is how long the heart would
-- have meant something had the foe been charmable.
local function devotion_interrupt(unit)
	local cooldown = mod.tuning.ObsessiveDevotion.InterruptCooldown
	if not game.CheckCooldown(devotion_interrupt_key(unit), cooldown) then return false end

	unit.ForcedWeaponInterrupt = true

	local vfx = game.EffectData.Charm and game.EffectData.Charm.Vfx
	if not vfx then return true end

	local objectId = unit.ObjectId
	game.CreateAnimation({ Name = vfx, DestinationId = objectId })

	game.thread(function()
		-- room-scoped, so leaving the fight takes the thread with it rather than stopping an
		-- animation on an id the next room has since reused
		game.wait(mod.tuning.ObsessiveDevotion.CharmDuration, game.RoomThreadName)
		game.StopAnimation({ Name = vfx, DestinationId = objectId, PreventChain = true })
	end)

	return true
end


local DEVOTION_MODIFIER_NAME = 'BoonEditObsessiveDevotion'


-- One entry, rewritten each tick rather than appended: the SetupFunction runs again every room.
--
-- `NonPlayerMultiplier` on an *outgoing* modifier is the field for "damage this unit deals to
-- something that is not the player or one of their summons" (`CombatLogic.lua:750`), so the bonus
-- reaches foes and cannot be turned back on your own side. Keyed by `Name`, since that is what
-- `RemoveOutgoingDamageModifier` matches on.
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


-- Everything fighting on your side except Melinoe, and only what is standing near her: your summons,
-- and every foe you have turned. `is_allied_summon` is the shared test for both, and Charm is one of
-- the things it reads -- so a foe this boon Charms starts counting for the bonus the moment it turns.
--
-- **Nearby, not everywhere.** Counting the whole room paid out for a summon left behind in a corner,
-- which is a bonus for having had allies rather than for fighting alongside them.
--
-- Melinoe is left out, not by a test but by where this looks: she is not in `ActiveEnemies`, and
-- counting her would be a flat bonus for holding the boon rather than one for what is on the field.
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

	-- the modifier outlives the loop, so losing the boon mid-room would leave the bonus standing
	devotion_set_bonus(0)
end


-- Every Weak that lands on a foe, whoever applied it. Rolled once per fresh application: Weak is
-- refreshed by every hit that carries it, and `Reapplied` is how vanilla's own Weak-triggered effect
-- (`CheckRandomStatusCurse`, `PowersLogic.lua:2624`) tells a new affliction from a top-up.
--
-- The Weak is cleared only when something took its place, so a foe whose interrupt is still on
-- cooldown keeps the Weak it would otherwise have lost for nothing.
---@diagnostic disable-next-line: unused-local
function mod.ObsessiveDevotionWeak(triggerArgs, _args)
	if not config.BoonChanges.ObsessiveDevotion.Enabled then return end
	if not game.HeroHasTrait(DEVOTION_TRAIT) then return end
	if not triggerArgs or triggerArgs.Reapplied then return end

	local victim = triggerArgs.Victim
	if not victim or not victim.ObjectId or victim.IsDead then return end
	if victim == (game.CurrentRun and game.CurrentRun.Hero) then return end

	-- nothing to turn on its neighbours that is not already fighting for you
	if is_allied_summon(victim) then return end

	if not rolls(mod.tuning.ObsessiveDevotion.CharmChance) then return end

	if devotion_charmable(victim) then
		devotion_charm(victim)
	elseif not devotion_interrupt(victim) then
		return
	end

	game.ClearEffect({ Id = victim.ObjectId, Name = triggerArgs.EffectName or 'WeakEffect' })
end
