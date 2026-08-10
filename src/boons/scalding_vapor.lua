---@meta _
---@diagnostic disable: lowercase-global

-- Scalding Vapor (Hestia x Poseidon): while you hold it, Poseidon's Font comes round twice as often.
-- Two other changes sit here on their own switches, both off by default, which is vanilla.

once('ScaldingVapor', function()
	if config.BoonChanges.SteamCountsAsFrothProc.Enabled then
		local froth = game.EffectData.AmplifyKnockbackEffect
		local kept = {}
		for _, name in ipairs(froth.ProjectileNameBlacklist or {}) do
			if name ~= 'SteamBlast' then
				table.insert(kept, name)
			end
		end
		froth.ProjectileNameBlacklist = kept
		froth.ProjectileNameBlacklistLookup = game.ToLookup(kept)
	end

	modutil.mod.Path.Wrap("CheckPoseidonFont", function(base, victim, triggerArgs)
		if not steam_froth_active() then
			return base(victim, triggerArgs)
		end

		local froth = game.EffectData.AmplifyKnockbackEffect
		local cooldown = froth.Cooldown
		froth.Cooldown = cooldown * mod.tuning.SteamProcsFroth.FontCooldownMultiplier
		local ok, err = pcall(base, victim, triggerArgs)
		froth.Cooldown = cooldown
		if not ok then error(err) end
	end)

	local keepingFroth = false

	modutil.mod.Path.Wrap("CheckSteam", function(base, victim, functionArgs, triggerArgs)
		if not config.BoonChanges.ScaldingVaporKeepsFroth.Enabled then
			return base(victim, functionArgs, triggerArgs)
		end

		keepingFroth = true
		local ok, err = pcall(base, victim, functionArgs, triggerArgs)
		keepingFroth = false
		if not ok then error(err) end
	end)

	modutil.mod.Path.Wrap("ClearEffect", function(base, args)
		if keepingFroth and args and args.Name == 'AmplifyKnockbackEffect' then
			return
		end
		return base(args)
	end)
end)


function steam_froth_active()
	return config.BoonChanges.SteamProcsFroth.Enabled and game.HeroHasTrait('SteamBoon')
end
