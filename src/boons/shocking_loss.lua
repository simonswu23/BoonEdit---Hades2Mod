---@meta _
---@diagnostic disable: lowercase-global


local STRIKE = 'ZeusOnSpawn'


once('ShockingLossEveryHit', function()
	if config.BoonChanges.ShockingLoss.Enabled then
		game.ScreenData.RunClear.DamageSourceMap[STRIKE] = 'SpawnKillBoon'

		local tuning = mod.tuning.ShockingLoss
		local shockingLoss = game.TraitData.SpawnKillBoon
		shockingLoss.BoonEditHitChance = tuning.HitChance
		shockingLoss.BoonEditFirstHitChance = tuning.HitChance * tuning.FirstHitMultiplier
		shockingLoss.StatLines = { 'BoonEditShockingLossStatDisplay' }
		shockingLoss.ExtractValues = {
			{
				Key = 'BoonEditHitChance',
				ExtractAs = 'Chance',
				Format = 'LuckModifiedPercent',
				HideSigns = true,
			},
			{
				Key = 'BoonEditFirstHitChance',
				ExtractAs = 'TooltipFirstHitChance',
				Format = 'LuckModifiedPercent',
				SkipAutoExtract = true,
			},
		}
	end

	modutil.mod.Path.Wrap("CheckSpawnZeusDamage", function(base, enemy, traitArgs, triggerArgs)
		if not shocking_loss_hit(enemy, traitArgs, triggerArgs) then
			return base(enemy, traitArgs, triggerArgs)
		end
	end)
end)


function shocking_loss_hit(enemy, traitArgs, triggerArgs)
	if not config.BoonChanges.ShockingLoss.Enabled then return false end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or not enemy or not enemy.ObjectId or enemy == hero then return true end
	if enemy.IsDead or enemy.BoonEditShockingLossPending or traitArgs.VictimWillBeAlive == false then return true end

	local source = triggerArgs and triggerArgs.SourceProjectile
	if source and (source == STRIKE or source == traitArgs.ExcludeProjectileName) then return true end

	local record = game.SessionMapState and game.SessionMapState.SpawnKillRecord
	if not record then return true end

	local tuning = mod.tuning.ShockingLoss
	local chance = tuning.HitChance
	if not record[enemy.ObjectId] then
		record[enemy.ObjectId] = true
		chance = chance * tuning.FirstHitMultiplier
	end
	if not rolls(chance) then return true end

	enemy.BoonEditShockingLossPending = true
	game.thread(mod.ShockingLossStrike, enemy, traitArgs)
	return true
end

function mod.ShockingLossStrike(enemy, traitArgs)
	game.wait(0.1, game.RoomThreadName)
	enemy.BoonEditShockingLossPending = nil

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or enemy.IsDead then return end

	local guardian = enemy.IsBoss or enemy.UseBossHealthBar
	game.CreateAnimation({ Name = traitArgs.Vfx, DestinationId = enemy.ObjectId, Group = 'FX_Standing_Top' })
	if not guardian then
		game.thread(game.SpawnKillPresentation, enemy)
	end

	game.thread(game.Damage, enemy, {
		AttackerId = hero.ObjectId,
		AttackerTable = hero,
		SourceProjectile = STRIKE,
		DamageAmount = guardian and mod.tuning.ShockingLoss.GuardianDamage or traitArgs.Damage,
		Silent = false,
		PureDamage = not guardian,
		IgnoreHealthBuffer = not guardian,
	})
end
