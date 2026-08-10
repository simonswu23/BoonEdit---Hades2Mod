---@meta _
---@diagnostic disable: lowercase-global

-- Tranquil Gain (Demeter) pays out for holding an Omega Move; `MovePenaltyDuration` is reused as the hold.

once('TranquilGainChannel', function()
	if not config.BoonChanges.TranquilGainChannel.Enabled then return end

	local tranquil = game.TraitData.DemeterManaBoon

	tranquil.SetupFunction.Args.MovePenaltyDuration = mod.tuning.TranquilGain.HoldSeconds
	tranquil.SetupFunction.Name = _PLUGIN.guid .. '.TranquilGainChannel'

	tranquil.SetupFunction.Threaded = true
	tranquil.SetupFunction.RunOnce = nil
end)


local TRANQUIL_POLL_INTERVAL = (game.HeroData and game.HeroData.ManaData and game.HeroData.ManaData.MinManaTickRate) or 0.05

function tranquil_gain_channelling()
	return not game.IsEmpty(game.MapState.ChargedManaWeapons or {})
end


local function tranquil_gain_hold(base)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or base <= 0 then return base end

	local fastest = nil
	for weaponName in pairs(game.MapState.ChargedManaWeapons or {}) do
		local current = game.GetWeaponDataValue({ Id = hero.ObjectId, WeaponName = weaponName, Property = 'ChargeTime' })
		local baseCharge = game.GetBaseDataValue({ Type = 'Weapon', Name = weaponName, Property = 'ChargeTime' })

		if current and baseCharge and baseCharge > 0 then
			local ratio = (current / baseCharge) * (game.GetLuaWeaponSpeedMultiplier(weaponName) or 1)
			if not fastest or ratio < fastest then fastest = ratio end
		end
	end

	if not fastest then return base end

	local global = 1
	for _, value in pairs((game.SessionMapState or {}).GlobalAttackSpecialSpeed or {}) do
		global = global * value
	end
	if global > 0 then
		fastest = fastest / global
	end

	return base * fastest
end

function tranquil_gain_stop(args)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end
	if args and args.ManaRegenStartFx then
		game.StopAnimation({ Name = args.ManaRegenStartFx, DestinationId = hero.ObjectId })
	end
end

function mod.TranquilGainChannel(hero, args)
	local hold = (args and args.MovePenaltyDuration) or 0
	local channelled = 0
	local carried = 0
	local flowing = false

	while game.CurrentRun and game.CurrentRun.CurrentRoom and game.CurrentRun.Hero
		and not game.CurrentRun.Hero.IsDead and game.HeroHasTrait('DemeterManaBoon') do

		if tranquil_gain_channelling() then
			channelled = channelled + TRANQUIL_POLL_INTERVAL

			if channelled >= tranquil_gain_hold(hold) then
				if not flowing then
					flowing = true
					if args.ManaRegenStartSound then
						game.PlaySound({ Name = args.ManaRegenStartSound, Id = game.CurrentRun.Hero.ObjectId })
					end
					if args.ManaRegenStartFx then
						game.CreateAnimation({ Name = args.ManaRegenStartFx, DestinationId = game.CurrentRun.Hero.ObjectId, OffsetX = 0 })
					end
				end

				carried = carried + game.CurrentRun.Hero.MaxMana * args.PercentManaRegenPerSecond * TRANQUIL_POLL_INTERVAL
				local whole = math.floor(carried)
				if whole > 0 then
					carried = carried - whole
					game.ManaDelta(whole, { Silent = false })
				end
			end
		else
			channelled = 0
			carried = 0
			if flowing then
				flowing = false
				tranquil_gain_stop(args)
			end
		end

		game.wait(TRANQUIL_POLL_INTERVAL, game.RoomThreadName)
	end

	tranquil_gain_stop(args)
end
