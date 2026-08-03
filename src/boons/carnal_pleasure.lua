---@meta _
---@diagnostic disable: lowercase-global

-- Carnal Pleasure (Aphrodite x Ares) stops making Heartthrobs and instead makes the ones you have
-- hit harder, by more the more Plasma you are holding.

mod.tuning.CarnalPleasure = {
	DamageBonus = 0.30,
}

once('CarnalPleasureDamage', function()
	if not config.BoonChanges.CarnalPleasureDamage.Enabled then return end

	local carnal = game.TraitData.BloodManaBurstBoon

	carnal.DropManaBurstChance = nil
	carnal.ManaBurstArgs = nil

	carnal.SetupFunction = {
		Threaded = true,
		Name = _PLUGIN.guid .. '.CarnalPleasure',
		Args = {
			Interval = 0.3,
		},
	}

	carnal.BoonEditHeartthrobDamage = mod.tuning.CarnalPleasure.DamageBonus
	carnal.StatLines = { 'BoonEditHeartthrobDamageStatDisplay' }
	carnal.ExtractValues = {
		{
			Key = 'BoonEditHeartthrobDamage',
			ExtractAs = 'Damage',
			Format = 'Percent',
			HideSigns = true,
		},
	}
end)


-- Plasma changes as you collect it, so the modifier is rewritten on a loop.
local HEARTTHROB_PROJECTILES = { 'AphroditeBurst' }

function carnal_pleasure_set_bonus(bonus)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end
	hero.OutgoingDamageModifiers = hero.OutgoingDamageModifiers or {}

	local entry
	for _, modifier in ipairs(hero.OutgoingDamageModifiers) do
		if modifier.BoonEditCarnalPleasure then
			entry = modifier
			break
		end
	end
	if not entry then
		entry = {
			BoonEditCarnalPleasure = true,
			ValidProjectiles = HEARTTHROB_PROJECTILES,
			ValidProjectilesLookup = game.ToLookup(HEARTTHROB_PROJECTILES),
			ValidWeaponMultiplier = 1,
		}
		game.AddOutgoingDamageModifier(hero, entry)
	end

	entry.ValidWeaponMultiplier = 1 + bonus
end

function mod.CarnalPleasure(hero, args)
	local interval = (args and args.Interval) or 0.3

	while game.CurrentRun and game.CurrentRun.CurrentRoom and game.CurrentRun.Hero
		and not game.CurrentRun.Hero.IsDead and game.HeroHasTrait('BloodManaBurstBoon') do

		-- BloodDropBonus is already in percentage points
		local plasma = (game.CurrentRun.CurrentRoom.BloodDropBonus or 0) / 100
		carnal_pleasure_set_bonus(mod.tuning.CarnalPleasure.DamageBonus + plasma)
		game.wait(interval, game.RoomThreadName)
	end

	carnal_pleasure_set_bonus(0)
end


if config.BoonChanges.CarnalPleasureDamage.Enabled then
	boon_text({
		Traits = {
			BloodManaBurstBoon = {
				Description = 'Your {$Keywords.HeartBurst} effects deal more damage, and more still for each {$Keywords.BloodDrop} you hold.',
			},
		},
		StatLines = {
			BoonEditHeartthrobDamageStatDisplay = 'Base Heartthrob Damage:',
		},
	})
end
