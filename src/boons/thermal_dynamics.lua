---@meta _
---@diagnostic disable: lowercase-global

-- Thermal Dynamics (Hestia x Zeus) reaches past Blitz to all of Zeus' lightning, and the Scorch it
-- lands is measured against the damage rather than being a flat count.

-- The same list Killer Current uses, which covers every bolt Zeus throws.
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

	-- vanilla hangs its Scorch off the Blitz effect landing; this reads the hit instead
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


-- Scorch is pending damage one for one, so the fraction is read straight off the hit.
function mod.ThermalDynamics(args, attacker, victim, triggerArgs)
	if not config.BoonChanges.ThermalDynamicsAllLightning.Enabled then return end
	if not victim or not victim.ObjectId or victim.IsDead or not victim.ActiveEffects then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or attacker ~= hero then return end

	-- Scorch ticking arrives here too, and would otherwise keep topping itself back up
	if not triggerArgs or triggerArgs.EffectName then return end

	local lightning = args and args.ValidProjectilesLookup
	if not lightning or not lightning[triggerArgs.SourceProjectile] then return end

	local damage = triggerArgs.DamageAmount
	if type(damage) ~= 'number' or damage <= 0 then return end

	local stacks = math.floor(damage * mod.tuning.ThermalDynamics.ScorchFraction + 0.5)
	if stacks <= 0 then return end

	game.ApplyBurn(victim, { EffectName = 'BurnEffect', NumStacks = stacks }, triggerArgs)
end
