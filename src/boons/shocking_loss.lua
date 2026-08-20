---@meta _
---@diagnostic disable: lowercase-global


once('ShockingLossGuardians', function()
	if config.BoonChanges.ShockingLoss.Enabled then
		game.OverwriteTableKeys(game.ProjectileData, {
			BoonEditZeusGuardianStrike = {
				InheritFrom = { 'ZeusColorProjectile' },
			},
		})
		game.ProcessDataStore(game.ProjectileData)

		local shockingLoss = game.TraitData.SpawnKillBoon
		shockingLoss.OnEnemyDamagedAction.Args.BoonEditGuardianDamage = mod.tuning.ShockingLoss.GuardianDamage

		shockingLoss.BoonEditGuardianDamage = mod.tuning.ShockingLoss.GuardianDamage
	end

	modutil.mod.Path.Wrap("CheckSpawnZeusDamage", function(base, enemy, traitArgs, triggerArgs)
		if not shocking_loss_guardian(enemy, traitArgs, triggerArgs) then
			return base(enemy, traitArgs, triggerArgs)
		end
	end)
end)


function shocking_loss_guardian(enemy, traitArgs, triggerArgs)
	if not config.BoonChanges.ShockingLoss.Enabled then return false end
	if not enemy or not enemy.ObjectId then return false end
	if not (enemy.IsBoss or enemy.UseBossHealthBar) then return false end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or enemy == hero then return false end

	local record = game.SessionMapState and game.SessionMapState.SpawnKillRecord
	if not record then return false end
	if record[enemy.ObjectId] then return true end
	if triggerArgs and traitArgs.ExcludeProjectileName
		and triggerArgs.SourceProjectile == traitArgs.ExcludeProjectileName then
		return false
	end

	record[enemy.ObjectId] = true

	local chance = traitArgs.Chance * game.GetTotalHeroTraitValue('LuckMultiplier', { IsMultiplier = true })
	if not game.RandomChance(chance) then return true end

	game.thread(mod.ShockingLossGuardianStrike, enemy, traitArgs)
	return true
end

function mod.ShockingLossGuardianStrike(enemy, traitArgs)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	game.wait(0.1, game.RoomThreadName)
	game.CreateAnimation({ Name = traitArgs.Vfx, DestinationId = enemy.ObjectId, Group = 'FX_Standing_Top' })

	game.thread(game.Damage, enemy, {
		AttackerId = hero.ObjectId,
		AttackerTable = hero,
		SourceProjectile = 'BoonEditZeusGuardianStrike',
		DamageAmount = traitArgs.BoonEditGuardianDamage or mod.tuning.ShockingLoss.GuardianDamage,
		Silent = false,
	})
end
