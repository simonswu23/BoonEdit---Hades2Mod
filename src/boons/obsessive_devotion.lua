---@meta _
---@diagnostic disable: lowercase-global

-- Ecstatic Obsession (Aphrodite x Hera) becomes "Obsessive Devotion": Weak foes and your summons
-- are Hitched, and you deal more damage for each Hitched foe.

mod.tuning.ObsessiveDevotion = {
	DamagePerFoe = 0.10,
	MaxBonus = 1.00,
}

once('ObsessiveDevotion', function()
	if not config.BoonChanges.ObsessiveDevotion.Enabled then return end

	local devotion = game.TraitData.CharmCrowdBoon

	devotion.SetupFunction = {
		Threaded = true,
		Name = _PLUGIN.guid .. '.ObsessiveDevotion',
		Args = {
			Interval = 0.3,
		},
	}

	devotion.BoonEditDamagePerFoe = mod.tuning.ObsessiveDevotion.DamagePerFoe
	devotion.BoonEditMaxBonus = mod.tuning.ObsessiveDevotion.MaxBonus
	devotion.StatLines = { 'BoonEditDevotionDamageStatDisplay', 'BoonEditDevotionMaxStatDisplay' }
	devotion.ExtractValues = {
		{ Key = 'BoonEditDamagePerFoe', ExtractAs = 'TooltipPerFoe', Format = 'Percent' },
		{ Key = 'BoonEditMaxBonus', ExtractAs = 'TooltipMaxBonus', Format = 'Percent' },
	}
end)


-- One entry, rewritten each tick rather than appended: the SetupFunction runs again every room.
function devotion_set_bonus(hitchedCount)
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end
	hero.OutgoingDamageModifiers = hero.OutgoingDamageModifiers or {}

	local entry
	for _, modifier in ipairs(hero.OutgoingDamageModifiers) do
		if modifier.BoonEditObsessiveDevotion then
			entry = modifier
			break
		end
	end
	if not entry then
		entry = { BoonEditObsessiveDevotion = true, ValidWeaponMultiplier = 1 }
		game.AddOutgoingDamageModifier(hero, entry)
	end

	entry.ValidWeaponMultiplier = 1 + math.min(hitchedCount * mod.tuning.ObsessiveDevotion.DamagePerFoe, mod.tuning.ObsessiveDevotion.MaxBonus)
end

function mod.ObsessiveDevotion(hero, args)
	local interval = (args and args.Interval) or 0.3

	while game.CurrentRun and game.CurrentRun.CurrentRoom and game.CurrentRun.Hero
		and not game.CurrentRun.Hero.IsDead and game.HeroHasTrait('CharmCrowdBoon') do

		local hitched = 0
		for _, unit in pairs(game.ActiveEnemies or {}) do
			-- SkipModifiers is waived for summons, so they still count towards the bonus
			if unit and unit.ObjectId and not unit.IsDead and unit.ActiveEffects
				and (not unit.SkipModifiers or is_allied_summon(unit)) then

				if unit.ActiveEffects.WeakEffect then
					apply_hitch(unit)
				end
				if unit.ActiveEffects.DamageShareEffect then
					hitched = hitched + 1
				end
			end
		end

		devotion_set_bonus(hitched)
		game.wait(interval, game.RoomThreadName)
	end

	-- the modifier outlives the loop, so losing the boon mid-room would leave the bonus standing
	devotion_set_bonus(0)
end


if config.BoonChanges.ObsessiveDevotion.Enabled then
	boon_text({
		Traits = {
			CharmCrowdBoon = {
				DisplayName = 'Obsessive Devotion',
				Description = '{$Keywords.Weak} foes are also afflicted with {$Keywords.Link}, and you deal more damage for each.',
			},
		},
		StatLines = {
			BoonEditDevotionDamageStatDisplay = 'Damage per {$Keywords.Link}ed Foe:',
			BoonEditDevotionMaxStatDisplay = { Name = 'Maximum Bonus:', Index = 2 },
		},
	})
end
