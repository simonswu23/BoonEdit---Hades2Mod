---@meta _
---@diagnostic disable: lowercase-global


-- Blood Spree's lifesteal only pays out while you are already nearly dead. This adds a second way to
-- get it: slaying a foe restores the same amount the boon's Attack and Special do, one kill in five.
-- The amount is read off the boon's own lifesteal figure, so it grows with rarity exactly as the
-- lifesteal does and there is no second number to keep in step.

local BLOOD_SPREE = 'LowHealthLifestealBoon'


-- The key is a guard, not a name: `once` remembers the string, so changing it would let a hot reload
-- in a live session apply a second `KillEnemy` wrap and roll the chance twice per orphaned kill.
once('BloodSpreeKillCrit', function()

	modutil.mod.Path.Wrap("KillEnemy", function(base, victim, triggerArgs)
		base(victim, triggerArgs)
		---@diagnostic disable-next-line: undefined-global
		blood_spree_orphan_kill(victim, triggerArgs)
	end)

	if not config.BoonChanges.BloodSpree.Enabled then return end

	local trait = game.TraitData[BLOOD_SPREE]
	if not trait then return end

	trait.OnEnemyDeathFunction = { Name = _PLUGIN.guid .. '.BloodSpreeKill' }
end)


-- A foe killed by a lingering effect rather than by a hit has no attacker, so `OnEnemyDeathFunction`
-- never runs for it. These are the ones worth catching anyway.
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

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	---@diagnostic disable-next-line: undefined-global
	if not rolls(mod.tuning.BloodSpree.KillHealChance) then return end

	local amount = blood_spree_heal_amount()
	if amount <= 0 then return end

	-- vanilla puts every point of lifesteal through the healing multiplier before it lands
	-- (`CombatLogic.lua:1107`), and this boon carries the shrine-upgrade stat line that says so
	game.Heal(hero, {
		HealAmount = game.round(amount * game.CalculateHealingMultiplier()),
		SourceName = BLOOD_SPREE,
	})
end


-- `MaxLifesteal` is nested inside `AddOutgoingLifestealModifiers`, and `GetProcessedValue` recurses
-- (`TraitLogic.lua:337`), so the hero's copy of the trait already carries it as a plain number with
-- the rarity multiplier applied. Read off the trait rather than off tuning for that reason.
function blood_spree_heal_amount()
	local trait = game.GetHeroTrait(BLOOD_SPREE)
	local modifiers = trait and trait.AddOutgoingLifestealModifiers
	local amount = modifiers and modifiers.MaxLifesteal

	if type(amount) ~= 'number' then return 0 end
	return amount
end
