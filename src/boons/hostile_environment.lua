---@meta _
---@diagnostic disable: lowercase-global


-- Hostile Environment (Ares x Demeter): the plain Cast follows Melinoe instead of dropping.

once('HostileEnvironmentCastFollows', function()
	modutil.mod.Path.Wrap("CheckCastDetach", function(base, weaponData, args, triggerArgs)
		if hostile_environment_keeps_cast() then return end
		return base(weaponData, args, triggerArgs)
	end)

	modutil.mod.Path.Wrap("HestiaCastDefense", function(base, weaponData, traitArgs, triggerArgs)
		base(weaponData, traitArgs, triggerArgs)
		cast_defense_follows_caster()
	end)

	modutil.mod.Path.Wrap("CheckFamiliarLink", function(base, weaponData, functionArgs, triggerArgs)
		base(weaponData, functionArgs, triggerArgs)
		familiar_cast_follows_familiar()
	end)
end)


function hostile_environment_keeps_cast()
	local settings = config.BoonChanges.HostileEnvironmentCastFollows
	return settings.Enabled and game.HeroHasTrait('SelfCastBoon')
end

function cast_defense_follows_caster()
	if not hostile_environment_keeps_cast() then return end

	local defenses = game.SessionMapState.CastDefense
	local projectileId = defenses and defenses[#defenses]
	if not projectileId then return end

	game.AttachProjectiles({ Ids = { projectileId }, DestinationId = game.CurrentRun.Hero.ObjectId })
end

function familiar_cast_follows_familiar()
	if not hostile_environment_keeps_cast() then return end

	local projectileId = game.SessionMapState.FamiliarCastProjectileId
	local anchorId = game.MapState.FamiliarLocationId
	if not projectileId or not anchorId then return end

	game.AttachProjectiles({ Ids = { projectileId }, DestinationId = anchorId })
end
