---@meta _
---@diagnostic disable: lowercase-global

-- Cindered Ritual (Wrath of Olympus) becomes "Spontaneous Combustion": the Scorch you inflict lands
-- half again as hard and has no ceiling, and a foe carrying more Scorch than life bursts. Loaded
-- late, so that mod's trait is already in place.

WRATH_HESTIA = 'Wistiti-WrathOfOlympus-HestiaWrathBoon'

mod.tuning.SpontaneousCombustion = {
	ScorchMultiplier = 1.5,
}

once('SpontaneousCombustionWrath', function()
	modutil.mod.Path.Wrap("ApplyBurn", function(base, victim, functionArgs, triggerArgs)
		if not spontaneous_combustion_active() then
			return base(victim, functionArgs, triggerArgs)
		end

		local multiplier = mod.tuning.SpontaneousCombustion.ScorchMultiplier
		if multiplier ~= 1 and functionArgs and type(functionArgs.NumStacks) == 'number' then
			functionArgs = game.ShallowCopyTable(functionArgs)
			functionArgs.NumStacks = math.floor(functionArgs.NumStacks * multiplier + 0.5)
		end

		local burn = game.EffectData.BurnEffect
		local cap = burn.MaxStacks
		burn.MaxStacks = math.huge
		local ok, err = pcall(base, victim, functionArgs, triggerArgs)
		burn.MaxStacks = cap
		if not ok then error(err) end

		check_combustion(victim)
	end)

	local toggle = config.BoonChanges.SpontaneousCombustionWrath
	local wrath = game.TraitData[WRATH_HESTIA]
	if not (toggle and toggle.Enabled and wrath) then return end

	-- Kept on the existing key, so Wrath of Olympus' Chaos Trial and prophecy still find the boon.
	wrath.OnDamageEnemyFunction = nil

	wrath.OnEnemyDeathFunction = {
		Name = _PLUGIN.guid .. '.SpontaneousCombustionBlast',
	}

	wrath.SetupFunction = {
		Threaded = true,
		Name = _PLUGIN.guid .. '.SpontaneousCombustion',
		Args = {
			-- the burst's delay is measured in this; below 0.05 the room-load coroutine crashes
			Interval = 0.05,
		},
	}

	wrath.BoonEditScorchMultiplier = mod.tuning.SpontaneousCombustion.ScorchMultiplier
	wrath.StatLines = { 'BoonEditScorchDamageStatDisplay' }
	wrath.ExtractValues = {
		{
			Key = 'BoonEditScorchMultiplier',
			ExtractAs = 'TooltipScorchDamage',
			Format = 'PercentDelta',
		},
	}

	-- sjson callbacks run in registration order and this must come after GodsAPI's, so it cannot use
	-- the shared text registry.
	local traitText = rom.path.combine(rom.paths.Content, 'Game/Text/en/TraitText.en.sjson')
	sjson.hook(traitText, function(data)
		return sjson_CombustionWrathText(data)
	end)
end)


-- A foe holding more Scorch than life is already dead; this cashes that in as a blast.
local COMBUSTION_BLAST = 'BurnNova'
local COMBUSTION_BLAST_BASE_DAMAGE = 60
local COMBUSTION_BLAST_CAP = 8

-- a foe that survives its own combustion is held off this long rather than barred for good
local COMBUSTION_RETRY = 1.0

local combustionBlastDamage = nil

function spontaneous_combustion_active()
	local toggle = config.BoonChanges.SpontaneousCombustionWrath
	return toggle ~= nil and toggle.Enabled and game.HeroHasTrait(WRATH_HESTIA)
end

function check_combustion(victim)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or not spontaneous_combustion_active() then return end
	if not victim or not victim.ObjectId or victim.IsDead then return end
	if victim == hero or victim.SkipModifiers then return end
	if is_allied_summon(victim) then return end

	local scorch = victim.ActiveEffects and victim.ActiveEffects.BurnEffect
	if not scorch or scorch <= 0 then return end
	if scorch < (victim.Health or 0) then return end

	if not game.CheckCooldown('BoonEditCombustion' .. victim.ObjectId, COMBUSTION_RETRY) then return end

	victim.BoonEditCombustionScorch = scorch

	-- Damage rather than Kill, so armour and boss phase gates still resolve
	game.Damage(victim, {
		AttackerTable = hero,
		AttackerId = hero.ObjectId,
		EffectName = 'BurnEffect',
		DamageAmount = scorch,
	})

	if not victim.IsDead then
		victim.BoonEditCombustionScorch = nil
	end
end

-- Fires on a foe that combusted rather than on any death, carrying the Scorch it held.
---@diagnostic disable-next-line: unused-local
function mod.SpontaneousCombustionBlast(victim, _args, _triggerArgs)
	local scorch = victim and victim.BoonEditCombustionScorch
	if not scorch then return end
	victim.BoonEditCombustionScorch = nil

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	if not combustionBlastDamage then
		local base = game.GetBaseDataValue({ Type = 'Projectile', Name = COMBUSTION_BLAST, Property = 'Damage' })
		if type(base) ~= 'number' or base <= 0 then
			base = COMBUSTION_BLAST_BASE_DAMAGE
		end
		combustionBlastDamage = base
	end

	game.CreateProjectileFromUnit({
		Name = COMBUSTION_BLAST,
		Id = hero.ObjectId,
		DestinationId = victim.ObjectId,
		DamageMultiplier = scorch / combustionBlastDamage,
		ProjectileCap = COMBUSTION_BLAST_CAP,
	})
end

-- Room-long sweep: the threshold is as often crossed by an ordinary hit as by Scorch landing.
function mod.SpontaneousCombustion(hero, args)
	local interval = (args and args.Interval) or 0.03
	local pending = {}

	while game.CurrentRun and game.CurrentRun.CurrentRoom and game.CurrentRun.Hero
		and not game.CurrentRun.Hero.IsDead do

		-- snapshotted: a combustion that kills would mutate ActiveEnemies mid-traversal
		for i = #pending, 1, -1 do
			pending[i] = nil
		end
		for _, unit in pairs(game.ActiveEnemies or {}) do
			pending[#pending + 1] = unit
		end
		for _, unit in ipairs(pending) do
			check_combustion(unit)
		end

		game.wait(interval, game.RoomThreadName)
	end
end

-- Overwrites the entry Wrath of Olympus registered for its Hestia Wrath.
function sjson_CombustionWrathText(data)
	for _, entry in ipairs(data.Texts) do
		if entry.Id == WRATH_HESTIA then
			entry.DisplayName = 'Spontaneous Combustion'
			entry.Description = 'The {$Keywords.Burn} you inflict is stronger and has no maximum. Foes with more {$Keywords.Burn} than life remaining die at once, dealing their {$Keywords.Burn} to nearby foes.'
		end
	end
end


local combustionWrath = config.BoonChanges.SpontaneousCombustionWrath
if combustionWrath and combustionWrath.Enabled then
	boon_text({
		StatLines = {
			BoonEditScorchDamageStatDisplay = 'Scorch Damage:',
		},
	})
end
