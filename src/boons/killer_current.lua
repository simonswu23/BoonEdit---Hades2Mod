---@meta _
---@diagnostic disable: lowercase-global


once('KillerCurrentBolt', function()
	if not config.BoonChanges.KillerCurrent.Enabled then return end

	local killerCurrent = game.TraitData.LightningVulnerabilityBoon
	killerCurrent.AddOutgoingDamageModifiers = nil
	killerCurrent.BoonEditBoltChance = mod.tuning.KillerCurrent.BoltChance
	killerCurrent.StatLines = { 'BoonEditKillerCurrentStatDisplay' }
	killerCurrent.ExtractValues = {
		{
			Key = 'BoonEditBoltChance',
			ExtractAs = 'Chance',
			Format = 'LuckModifiedPercent',
			HideSigns = true,
		},
	}
	killerCurrent.OnEnemyDamagedAction = {
		FunctionName = _PLUGIN.guid .. '.KillerCurrentBolt',
	}
end)


---@diagnostic disable-next-line: unused-local
function mod.KillerCurrentBolt(victim, functionArgs, triggerArgs)
	if not config.BoonChanges.KillerCurrent.Enabled then return end
	if not victim or not victim.ActiveEffects or not victim.ActiveEffects.AmplifyKnockbackEffect then return end
	if not rolls(mod.tuning.KillerCurrent.BoltChance) then return end

	local baseDamage = game.GetBaseDataValue({ Type = 'Projectile', Name = 'ZeusEchoStrike', Property = 'Damage' })
	if type(baseDamage) ~= 'number' or baseDamage <= 0 then
		baseDamage = 100
	end

	game.CreateProjectileFromUnit({
		Name = 'ZeusEchoStrike',
		Id = game.CurrentRun.Hero.ObjectId,
		DestinationId = victim.ObjectId,
		FireFromTarget = true,
		DamageMultiplier = mod.tuning.KillerCurrent.BoltPower / baseDamage,
	})
end
