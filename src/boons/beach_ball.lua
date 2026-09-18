---@meta _
---@diagnostic disable: lowercase-global


function beach_ball_rebalanced()
	local toggle = config.BoonChanges.BeachBall
	return toggle ~= nil and toggle.Enabled == true
end


once('BeachBallCone', function()
	if not beach_ball_rebalanced() then return end

	local ball = game.TraitData.PoseidonSplashSprintBoon
	if not ball then return end

	ball.OnProjectileDeathFunction = {
		Name = _PLUGIN.guid .. '.BeachBallWaves',
		ValidProjectiles = { 'ProjectileSprintBall' },
		ValidProjectilesLookup = game.ToLookup({ 'ProjectileSprintBall' }),
		Args = {},
	}
end)


---@diagnostic disable-next-line: unused-local
function mod.BeachBallWaves(triggerArgs, _args)
	if not beach_ball_rebalanced() then return end
	if not triggerArgs or not triggerArgs.LocationX or not triggerArgs.LocationY then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	---@diagnostic disable-next-line: undefined-global
	local scale, count, graphic = poseidon_splash_cone()
	if count < 2 then return end

	local tuning = mod.tuning.BeachBall

	local anchor = game.SpawnObstacle({
		Name = 'BlankObstacle',
		LocationX = triggerArgs.LocationX,
		LocationY = triggerArgs.LocationY,
	})
	if not anchor then return end

	local base = game.GetBaseDataValue({
		Type = 'Projectile',
		Name = tuning.WaveProjectile,
		Property = 'Damage',
	})
	if type(base) ~= 'number' or base <= 0 then base = 60 end

	local last = 0

	---@diagnostic disable-next-line: undefined-global
	arterial_spray_begin({ ProjectileName = tuning.WaveProjectile })

	local ok, err = pcall(function()
		for index = 2, count do
			last = (index - 1) * mod.tuning.PoseidonSplash.WaveDelay

			game.CreateProjectileFromUnit({
				Name = tuning.WaveProjectile,
				Id = hero.ObjectId,
				DestinationId = anchor,
				FireFromTarget = true,
				DamageMultiplier = tuning.BlastDamage / base,
				ScaleMultiplier = scale,
				DataProperties = {
					DamageRadius = tuning.BlastRadius * scale,
					StartFx = graphic,
					StartDelay = last,
				},
			})
		end
	end)

	---@diagnostic disable-next-line: undefined-global
	arterial_spray_end()

	game.thread(game.DestroyOnDelay, { anchor }, last + mod.tuning.PoseidonSplash.WaveDelay)
	if not ok then error(err) end
end
