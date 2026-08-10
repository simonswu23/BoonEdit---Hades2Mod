---@meta _
---@diagnostic disable: lowercase-global


-- Thermal Dynamics (Hestia x Zeus) reaches past Blitz to all of Zeus' lightning, and measures the Scorch
-- it lands against the damage rather than a flat count.

local LIGHTNING = {
	'ZeusEchoStrike',
	'ZeusCastStrike',
	'ZeusRootStrike',
	'ZeusSprintStrike',
	'ProjectileZeusSpark',
	'ZeusZeroManaStrike',
	'ZeusRetaliateStrike',
}

once('ThermalDynamicsAllLightning', function()
	if not config.BoonChanges.ThermalDynamicsAllLightning.Enabled then return end

	local thermal = game.TraitData.EchoBurnBoon

	thermal.OnEffectApplyFunction = nil

	thermal.OnDamageEnemyFunction = {
		FunctionName = _PLUGIN.guid .. '.ThermalDynamics',
		FunctionArgs = {
			ValidProjectilesLookup = game.ToLookup(LIGHTNING),
		},
	}

	thermal.BoonEditScorchFraction = mod.tuning.ThermalDynamics.ScorchFraction
	thermal.StatLines = { 'BoonEditThermalScorchStatDisplay' }
	thermal.ExtractValues = {
		{
			Key = 'BoonEditScorchFraction',
			ExtractAs = 'TooltipScorchFraction',
			Format = 'Percent',
			HideSigns = true,
		},
	}
end)


function mod.ThermalDynamics(args, attacker, victim, triggerArgs)
	if not config.BoonChanges.ThermalDynamicsAllLightning.Enabled then return end
	if not victim or not victim.ObjectId or victim.IsDead or not victim.ActiveEffects then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or attacker ~= hero then return end

	if not triggerArgs or triggerArgs.EffectName then return end

	local lightning = args and args.ValidProjectilesLookup
	if not lightning or not lightning[triggerArgs.SourceProjectile] then return end

	local damage = triggerArgs.DamageAmount
	if type(damage) ~= 'number' or damage <= 0 then return end

	local stacks = math.floor(damage * mod.tuning.ThermalDynamics.ScorchFraction + 0.5)
	if stacks <= 0 then return end

	game.ApplyBurn(victim, { EffectName = 'BurnEffect', NumStacks = stacks }, triggerArgs)
end
