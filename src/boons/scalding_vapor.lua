---@meta _
---@diagnostic disable: lowercase-global

-- Scalding Vapor (Hestia x Poseidon): its Steam counts as a Froth proc rather than being passed
-- over, while you hold it Poseidon's Font comes round twice as often, and the Steam no longer
-- strips the Froth that fed it.

mod.tuning.SteamProcsFroth = {
	FontCooldown = 0.3,
}

once('ScaldingVapor', function()
	-- Steam is blacklisted from Froth's proc, so it never feeds the Font. The lookup is built from
	-- the list at load, so both need rewriting.
	if config.BoonChanges.SteamProcsFroth.Enabled then
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

	-- The Font's cooldown is read live, so it only has to hold for the length of the call.
	modutil.mod.Path.Wrap("CheckPoseidonFont", function(base, victim, triggerArgs)
		if not steam_froth_active() then
			return base(victim, triggerArgs)
		end

		local froth = game.EffectData.AmplifyKnockbackEffect
		local cooldown = froth.Cooldown
		froth.Cooldown = mod.tuning.SteamProcsFroth.FontCooldown
		local ok, err = pcall(base, victim, triggerArgs)
		froth.Cooldown = cooldown
		if not ok then error(err) end
	end)

	-- CheckSteam already refreshes Steam rather than stacking it, so the only change needed is to
	-- stop it clearing the Froth that triggered it.
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


-- Froth's own keyword is left to vanilla: Scalding Vapor supplies FontChance, FontDamage and
-- KnockbackAmplifyDuration itself, so those numbers already follow your luck and your other boons.
-- Only Steam's keyword is wrong once either toggle is on, since vanilla has it removing the Froth.
local procs_froth = config.BoonChanges.SteamProcsFroth.Enabled
local keeps_froth = config.BoonChanges.ScaldingVaporKeepsFroth.Enabled

if procs_froth or keeps_froth then
	local held = ''
	if procs_froth and keeps_froth then
		held = ', which keeps the {$Keywords.KnockbackAmplify} and sets it off more often'
	elseif keeps_froth then
		held = ', which keeps the {$Keywords.KnockbackAmplify}'
	else
		held = ', which sets off the {$Keywords.KnockbackAmplify} more often'
	end

	local steam = 'A burning cloud that rapidly deals damage'
	if not keeps_froth then
		steam = 'A burning cloud that removes {$Keywords.KnockbackAmplify} from foes and rapidly deals damage'
	end
	if procs_froth then
		steam = steam .. ', and counts as a hit for {$Keywords.KnockbackAmplify}'
	end

	boon_text({
		Traits = {
			SteamBoon = {
				Description = 'If foes with {$Keywords.KnockbackAmplify} are struck by your fire effects from ' ..
					'{#BoldFormatGraft}Hestia{#Prev}, they are engulfed in {$Keywords.Steam}' .. held .. '.',
			},
		},
		Keywords = {
			Steam = {
				Description = steam .. '. Lasts {#BoldFormatGraft}{$TooltipData.ExtractData.Duration} Sec.',
			},
		},
	})
end
