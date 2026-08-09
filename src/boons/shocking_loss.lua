---@meta _
---@diagnostic disable: lowercase-global

-- Shocking Loss (Zeus legendary) no longer passes over Guardians. They take a large hit instead of
-- being immune outright, and that hit scales with your damage modifiers.
once('ShockingLossGuardians', function()
	if config.BoonChanges.ShockingLossGuardians.Enabled then
		-- ZeusOnSpawn is the same projectile with IgnoreAllModifiers, which would strip that scaling
		game.OverwriteTableKeys(game.ProjectileData, {
			BoonEditZeusGuardianStrike = {
				InheritFrom = { 'ZeusColorProjectile' },
			},
		})
		game.ProcessDataStore(game.ProjectileData)

		local shockingLoss = game.TraitData.SpawnKillBoon
		shockingLoss.OnEnemyDamagedAction.Args.BoonEditGuardianDamage = mod.tuning.ShockingLoss.GuardianDamage

		-- No stat line for the Guardian figure. It rendered as a raw token rather than the number,
		-- and it is not a value worth a line of its own anyway -- the description carries it.
		shockingLoss.BoonEditGuardianDamage = mod.tuning.ShockingLoss.GuardianDamage
	end

	-- Wrapped rather than repointed, so both of the trait's dispatch paths keep working.
	modutil.mod.Path.Wrap("CheckSpawnZeusDamage", function(base, enemy, traitArgs, triggerArgs)
		if not shocking_loss_guardian(enemy, traitArgs, triggerArgs) then
			return base(enemy, traitArgs, triggerArgs)
		end
	end)
end)


-- Returns whether it handled the foe, so the wrap knows whether to fall through.
function shocking_loss_guardian(enemy, traitArgs, triggerArgs)
	if not config.BoonChanges.ShockingLossGuardians.Enabled then return false end
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

	-- one attempt per Guardian per room, taken whether or not the roll lands
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

	-- no PureDamage, so this runs the whole pipeline and your modifiers apply
	game.thread(game.Damage, enemy, {
		AttackerId = hero.ObjectId,
		AttackerTable = hero,
		SourceProjectile = 'BoonEditZeusGuardianStrike',
		DamageAmount = traitArgs.BoonEditGuardianDamage or mod.tuning.ShockingLoss.GuardianDamage,
		Silent = false,
	})
end
