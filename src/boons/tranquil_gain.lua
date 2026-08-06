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

			if channelled >= hold then
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
					-- `Silent = false` is how vanilla's own regen loops mark a tick, and is what tells
					-- MoreDuos' Energy Overflow that this is a drip rather than a restore: it pays the
					-- bonus on one but will not turn one into max Magick, since a payout every 0.05s
					-- against a full meter would walk that ceiling to its cap on its own. False rather
					-- than true so the Magick-gain flourish still plays -- ManaDelta reads the field
					-- only as `not args.Silent`, so this is otherwise identical to passing nothing.
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
