---@meta _
---@diagnostic disable: lowercase-global

-- Tranquil Gain (Demeter) pays out for holding an Omega Move; MovePenaltyDuration is reused as the
-- hold.
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


-- The hold scales with how fast you actually channel: a flat half-second was worth less the more
-- channel speed you bought.
--
-- Channel speed comes from three places, none aware of the others, so all three are read here --
-- catching only the first misses Racing Thoughts' larger half.
--
-- 1. The weapon's `ChargeTime` -- the Arcana, the hammers, Winner's Circle, and Racing Thoughts via
--    `SpeedPropertyChanges`, whose default expands to exactly that property.
-- 2. `WeaponSpeedMultiplier`, summed by `GetLuaWeaponSpeedMultiplier` and never written into
--    ChargeTime. A duration multiplier, so it multiplies in.
-- 3. The engine's `WeaponChargeMultiplier`, where Plasma speed and time slow go instead. A rate, so
--    it divides out.
--
-- The fastest weapon held wins, since holding two is holding the shorter of the two.
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

	-- nothing measurable being held, so the threshold stands as written
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

-- Paid out directly, since the game zeroes the regen rate while anything is channelling.
function mod.TranquilGainChannel(hero, args)
	local hold = (args and args.MovePenaltyDuration) or 0
	local channelled = 0
	local carried = 0
	local flowing = false

	while game.CurrentRun and game.CurrentRun.CurrentRoom and game.CurrentRun.Hero
		and not game.CurrentRun.Hero.IsDead and game.HeroHasTrait('DemeterManaBoon') do

		if tranquil_gain_channelling() then
			channelled = channelled + TRANQUIL_POLL_INTERVAL

			-- read each tick rather than once: which weapon is being held can change mid-hold, and
			-- so can the speed on it
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

				-- Magick is whole numbers, so each tick's share is banked until it reaches one
				carried = carried + game.CurrentRun.Hero.MaxMana * args.PercentManaRegenPerSecond * TRANQUIL_POLL_INTERVAL
				local whole = math.floor(carried)
				if whole > 0 then
					carried = carried - whole
					-- `Silent = false` marks this as a drip, the way vanilla's regen loops do -- which is
					-- what stops MoreDuos' Energy Overflow turning it into max Magick. False rather than
					-- true so the gain flourish still plays; ManaDelta only reads `not args.Silent`.
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
