---@meta _
---@diagnostic disable: lowercase-global


local PASSION_RUSH_WEAPONS = { 'WeaponBlink', 'WeaponSprint' }


once('PassionRushTrail', function()
	if not config.BoonChanges.PassionRush.Enabled then return end

	local passion = game.TraitData.AphroditeSprintBoon

	passion.OnWeaponFiredFunctions.ValidWeapons = game.DeepCopyTable(PASSION_RUSH_WEAPONS)
	passion.OnWeaponFiredFunctions.ValidWeaponsLookup = game.ToLookup(PASSION_RUSH_WEAPONS)
	passion.OnWeaponFiredFunctions.ExcludeLinked = true
	passion.OnWeaponFiredFunctions.FunctionName = _PLUGIN.guid .. '.PassionRushStart'

	passion.OnSprintEndAction = { FunctionName = _PLUGIN.guid .. '.PassionRushEnd' }
	passion.OnBlinkEndAction = {
		FunctionName = _PLUGIN.guid .. '.PassionRushEnd',
		FunctionArgs = { CheckSprint = true },
	}
end)


function passion_rush_splash()
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local trait = game.GetHeroTrait('AphroditeSprintBoon')
	local traitArgs = trait and trait.OnWeaponFiredFunctions and trait.OnWeaponFiredFunctions.FunctionArgs
	if not traitArgs then return end

	game.CreateProjectileFromUnit({
		Name = traitArgs.ProjectileName,
		Id = hero.ObjectId,
		DestinationId = hero.ObjectId,
		FireFromTarget = true,
		DamageMultiplier = traitArgs.DamageMultiplier,
	})
end


function fire_passion_rush_wave(args, triggerArgs)
	if args and args.CheckSprint and game.ConfigOptionCache.SprintAutoHold and game.SessionMapState.SprintActive then
		return
	end
	if not game.ConfigOptionCache.SprintAutoHold
		and ((triggerArgs and triggerArgs.Canceled) or (args and args.CheckSprint and game.SessionMapState.SprintActive)) then
		return
	end

	passion_rush_splash()
	game.SessionMapState.BoonEditPassionRushStarted = nil
end


---@diagnostic disable-next-line: unused-local
function mod.PassionRushStart(weaponData, _args, _triggerArgs)
	if weaponData and weaponData.Name == 'WeaponSprint' then
		if game.CheckCooldown('BoonEditPassionRushTrail', mod.tuning.PassionRush.TrailInterval) then
			passion_rush_splash()
		end
		return
	end

	passion_rush_splash()
	game.SessionMapState.BoonEditPassionRushStarted = true
end

function mod.PassionRushEnd(args, triggerArgs)
	if not game.SessionMapState.BoonEditPassionRushStarted then return end
	fire_passion_rush_wave(args, triggerArgs)
end
