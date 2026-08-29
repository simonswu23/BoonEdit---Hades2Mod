---@meta _
---@diagnostic disable: lowercase-global


local FROTH = 'AmplifyKnockbackEffect'


once('ScaldingVapor', function()
	if config.BoonChanges.ScaldingVapor.Enabled then
		local froth = game.EffectData[FROTH]
		local kept = {}
		for _, name in ipairs(froth.ProjectileNameBlacklist or {}) do
			if name ~= 'SteamBlast' then
				table.insert(kept, name)
			end
		end
		froth.ProjectileNameBlacklist = kept
		froth.ProjectileNameBlacklistLookup = game.ToLookup(kept)

		local fireballs = fireball_projectiles()
		local steam = game.TraitData.SteamBoon
		steam.OnEnemyDamagedAction.ValidProjectiles = fireballs
		steam.OnEnemyDamagedAction.ValidProjectilesLookup = game.ToLookup(fireballs)

		-- Scorch no longer makes Steam; a fireball does. These two are vanilla's way of saying the
		-- opposite. `AllEffectsTrigger` is the only gate on whether the action runs at all
		-- (`PowersLogic.lua:243`), so with it set `CheckSteam` was called on every effect landing on
		-- every foe you damaged, whatever hit them; `ValidEffect = BurnEffect` then let the Scorch
		-- ones through. Dropping both leaves `validEffects` as `args.EffectName == nil`, which is
		-- true for a damage trigger and false for an effect application -- so the projectile list
		-- above becomes the whole of what decides it.
		--
		-- The wrap below already refused those, but it was doing so after the fact and on every
		-- status tick in the room. This is the same rule written where the game reads it.
		steam.OnEnemyDamagedAction.AllEffectsTrigger = nil
		steam.OnEnemyDamagedAction.Args.ValidEffect = nil
	end

	local keepingFroth = false

	modutil.mod.Path.Wrap("CheckSteam", function(base, victim, functionArgs, triggerArgs)
		if not config.BoonChanges.ScaldingVapor.Enabled then
			return base(victim, functionArgs, triggerArgs)
		end
		if not scalding_vapor_fireball(triggerArgs) then
			scalding_vapor_log('skipped', victim, triggerArgs)
			return
		end
		scalding_vapor_log('firing', victim, triggerArgs)

		keepingFroth = true
		local ok, err = pcall(base, victim, functionArgs, triggerArgs)
		keepingFroth = false
		if not ok then error(err) end
	end)

	modutil.mod.Path.Wrap("ClearEffect", function(base, args)
		if keepingFroth and args and args.Name == FROTH then
			return
		end
		return base(args)
	end)
end)


function scalding_vapor_fireball(triggerArgs)
	if triggerArgs == nil or triggerArgs.EffectName ~= nil then return false end

	local projectile = triggerArgs.SourceProjectile
	return projectile ~= nil and game.Contains(fireball_projectiles(), projectile)
end


function scalding_vapor_log(stage, victim, triggerArgs)
	if not config.Debug.LogScaldingVapor then return end

	local effects = victim and victim.ActiveEffects or {}
	print('[' .. _PLUGIN.guid .. '] ScaldingVapor ' .. stage ..
		'  projectile=' .. tostring(triggerArgs and triggerArgs.SourceProjectile) ..
		'  effect=' .. tostring(triggerArgs and triggerArgs.EffectName) ..
		'  froth=' .. tostring(effects[FROTH] ~= nil) ..
		'  steamId=' .. tostring(victim and victim.ActiveSteamId))
end
