---@meta _
---@diagnostic disable: lowercase-global


-- Tidal Ring's splash answers none of the boons that shape a splash, and for a plainer reason than
-- Breaker Rush's did. `CheckPoseidonCastSplash` (`PowersLogic.lua:1857`) does not read
-- `ConeModifier` at all -- it spawns a blank obstacle where the Cast was, fires one splinter at it
-- and returns. So King Tide never widened it and Arterial Spray never doubled it, on a boon that
-- makes the same `PoseidonCastSplashSplinter` the Attack and Special splash does.
--
-- Wrapped rather than replaced: the radius it reads off the Cast's own `ModifiedDamageRadius`, the
-- obstacle it anchors to and the cleanup after are all vanilla's, and worth keeping.


-- Set only for the length of vanilla's call, and read by the wrap below. King Tide's size has to
-- reach the splash vanilla itself fires, which is the one projectile we do not create.
local pending = nil


once('TidalRingCone', function()

	modutil.mod.Path.Wrap("CheckPoseidonCastSplash", function(base, weaponData, functionArgs, triggerArgs)
		if not config.BoonChanges.TidalRing.Enabled then
			return base(weaponData, functionArgs, triggerArgs)
		end

		---@diagnostic disable-next-line: undefined-global
		local scale, count, graphic = poseidon_splash_cone()

		pending = { Projectile = functionArgs and functionArgs.ProjectileName, Scale = scale }

		local ok, err = pcall(base, weaponData, functionArgs, triggerArgs)

		pending = nil
		if not ok then error(err) end

		tidal_ring_extra_waves(functionArgs, triggerArgs, scale, count, graphic)
	end)

	modutil.mod.Path.Wrap("CreateProjectileFromUnit", function(base, args)
		if pending and args and args.Name == pending.Projectile and pending.Scale ~= 1 then
			args.ScaleMultiplier = (args.ScaleMultiplier or 1) * pending.Scale
		end
		return base(args)
	end)
end)


-- The waves past the first, fired the way vanilla fired the first: anchored to a blank obstacle at
-- the Cast's own location, at the radius the Cast was carrying. The anchor outlives the last wave
-- rather than vanilla's flat 0.1, since a delayed wave with nothing to spawn on is no wave at all.
function tidal_ring_extra_waves(functionArgs, triggerArgs, scale, count, graphic)
	if count < 2 then return end
	if not functionArgs or not functionArgs.ProjectileName then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or not triggerArgs then return end

	local x, y = triggerArgs.ProjectileX, triggerArgs.ProjectileY
	if not x or not y then return end

	local anchor = game.SpawnObstacle({ Name = 'BlankObstacle', LocationX = x, LocationY = y })
	if not anchor then return end

	local radius = tidal_ring_radius(triggerArgs)
	local last = 0

	-- Arterial Spray's power reduction is a separate wrap that arms itself only inside vanilla's
	-- splash functions, and reads the delay to tell one wave from another. Opening the same window
	-- by hand is what keeps these at the reduced power rather than full strength.
	---@diagnostic disable-next-line: undefined-global
	arterial_spray_begin(functionArgs)

	local ok, err = pcall(function()
		for index = 2, count do
			last = (index - 1) * mod.tuning.PoseidonSplash.WaveDelay

			game.CreateProjectileFromUnit({
				Name = functionArgs.ProjectileName,
				Id = hero.ObjectId,
				DestinationId = anchor,
				DamageMultiplier = functionArgs.DamageMultiplier,
				FireFromTarget = true,
				ScaleMultiplier = scale,
				DataProperties = {
					DamageRadius = radius,
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


function tidal_ring_radius(triggerArgs)
	if not triggerArgs.ProjectileId then return mod.tuning.TidalRing.Radius end

	local modified = game.GetProjectileProperty({
		ProjectileId = triggerArgs.ProjectileId,
		Property = 'ModifiedDamageRadius',
	})
	if type(modified) ~= 'number' or modified <= 0 then return mod.tuning.TidalRing.Radius end

	return modified
end
