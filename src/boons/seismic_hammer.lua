---@meta _
---@diagnostic disable: lowercase-global

-- Seismic Servo (Hephaestus x Poseidon) becomes "Seismic Hammer": Post Haste covers its old
-- recharge effect, so instead Volcanic Strike and Volcanic Flourish blasts erupt your Cast into an
-- Omega Cast.

once('SeismicHammer', function()
	if not config.BoonChanges.SeismicHammer.Enabled then return end

	local hammer = game.TraitData.MassiveCastBoon

	hammer.OlympianRechargeMultiplier = nil

	hammer.BoonEditBlastCooldown = mod.tuning.SeismicHammer.BlastCooldownReduction
	hammer.StatLines = { 'BoonEditSeismicHammerStatDisplay' }
	hammer.ExtractValues = {
		{ Key = 'BoonEditBlastCooldown', ExtractAs = 'TooltipCooldown' },
	}

	-- **One function covers both blasts.** Every recharge in the game is worked out at its own call
	-- site as `Cooldown * OlympianRechargeMultiplier`, which is nine separate places in PowersLogic
	-- alone and no chokepoint to subtract a flat second at -- but Volcanic Strike and Volcanic
	-- Flourish are the only two that matter here, and both reach it through `CheckMassiveAttack`
	-- (`TraitData_Hephaestus.lua:39` and `:860`). So the second comes off there.
	--
	-- `functionArgs` is the trait's own args table and is read twice inside the call, so the figure
	-- is lowered for the length of it and put straight back rather than written down permanently.
	modutil.mod.Path.Wrap("CheckMassiveAttack", function(base, victim, functionArgs, triggerArgs)
		if not seismic_hammer_shortens(functionArgs) then
			return base(victim, functionArgs, triggerArgs)
		end

		local tuning = mod.tuning.SeismicHammer
		local full = functionArgs.Cooldown
		functionArgs.Cooldown = math.max(tuning.MinimumBlastCooldown, full - tuning.BlastCooldownReduction)

		-- safe in a pcall: nothing in `CheckMassiveAttack` waits, so no other frame sees the
		-- shortened figure
		local ok, err = pcall(base, victim, functionArgs, triggerArgs)
		functionArgs.Cooldown = full
		if not ok then error(err) end
	end)

	hammer.OnProjectileCreationFunction = {
		ValidProjectiles = { 'MassiveSlamBlast' },
		Name = 'CheckAxeCastArm',
		Args = {
			BlastMultiplier = { BaseValue = 1.15, SourceIsMultiplier = true },
		},
	}
	hammer.OnProjectileCreationFunction.ValidProjectilesLookup =
		game.ToLookup(hammer.OnProjectileCreationFunction.ValidProjectiles)
end)


-- Held, switched on, and a recharge actually there to shorten.
function seismic_hammer_shortens(functionArgs)
	if not config.BoonChanges.SeismicHammer.Enabled then return false end
	if not game.HeroHasTrait('MassiveCastBoon') then return false end
	return type(functionArgs and functionArgs.Cooldown) == 'number' and functionArgs.Cooldown > 0
end
