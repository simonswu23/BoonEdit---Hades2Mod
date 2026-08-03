---@meta _
---@diagnostic disable: lowercase-global

-- Ripple Effect (Hera x Poseidon) stops doubling its own two projectiles only, and instead covers
-- every boon that surcharges your Omega Moves in exchange for an extra effect. Each repeat rolls
-- again at half the chance, so a run of them can carry on up to four deep.

mod.tuning.RippleEffect = {
	RepeatChance = 0.50,
	-- each repeat is this much as likely as the one before it
	Falloff = 0.5,
	MaxRepeats = 4,
}

once('RippleEffectOmegaBoons', function()
	if config.BoonChanges.RippleEffectOmegaBoons.Enabled then
		local ripple = game.TraitData.MoneyDamageBoon

		-- Fine Line and Ocean Swell roll this themselves, for one extra only. Silenced so they use
		-- the same chain as everything else.
		ripple.DoubleOlympianProjectileChance = 0

		ripple.BoonEditRepeatChance = mod.tuning.RippleEffect.RepeatChance
		ripple.StatLines = { 'BoonEditRippleRepeatStatDisplay' }
		ripple.ExtractValues = {
			{
				Key = 'BoonEditRepeatChance',
				ExtractAs = 'Chance',
				Format = 'LuckModifiedPercent',
				HideSigns = true,
			},
		}
	end

	modutil.mod.Path.Wrap("CreateProjectileFromUnit", function(base, args)
		local result = base(args)
		if ripple_effect_repeat then
			ripple_effect_repeat(args)
		end
		return result
	end)
end)


-- what each of the five Omega-surcharge boons puts on the field
local OMEGA_BOON_PROJECTILES = {
	PoseidonOmegaWave     = true, -- Ocean Swell (Poseidon)
	ProjectileHeraOmega   = true, -- Fine Line (Hera)
	ProjectileFireball    = true, -- Controlled Burn (Hestia)
	ProjectileAresSwordEx = true, -- Cut Above (Ares)
	IcarusExplosion       = true, -- Explosive Intent (Icarus)
}

function ripple_effect_repeat(args)
	-- the repeats pass back through this wrap; without the guard they would compound
	if mod.RippleFiring then return end
	if not config.BoonChanges.RippleEffectOmegaBoons.Enabled then return end
	if not args or not args.Name or not OMEGA_BOON_PROJECTILES[args.Name] then return end
	if not game.HeroHasTrait('MoneyDamageBoon') then return end

	-- Icarus fires his own IcarusExplosion, so the shot has to be ours
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or args.Id ~= hero.ObjectId then return end

	local chance = game.GetTotalHeroTraitValue('BoonEditRepeatChance')
	if not rolls(chance) then return end

	local repeated = game.ShallowCopyTable(args)

	-- Ocean Swell allows 2 waves, Cut Above 3 swords, so the cap gains room for the repeats.
	if repeated.ProjectileCap then
		repeated.ProjectileCap = repeated.ProjectileCap + mod.tuning.RippleEffect.MaxRepeats
	end

	game.thread(ripple_effect_refire, repeated, chance)
end

function ripple_effect_refire(args, chance)
	local interval = game.GetTotalHeroTraitValue('DoubleOlympianProjectileInterval')

	for count = 1, mod.tuning.RippleEffect.MaxRepeats do
		game.waitUnmodified(interval)

		mod.RippleFiring = true
		local ok, err = pcall(game.CreateProjectileFromUnit, args)
		mod.RippleFiring = nil
		if not ok then
			print('[' .. _PLUGIN.guid .. '] ripple repeat failed: ' .. tostring(err))
			return
		end

		if count == mod.tuning.RippleEffect.MaxRepeats then return end

		chance = chance * mod.tuning.RippleEffect.Falloff
		if not rolls(chance) then return end
	end
end


if config.BoonChanges.RippleEffectOmegaBoons.Enabled then
	boon_text({
		Traits = {
			MoneyDamageBoon = {
				Description = 'The bonus effects your {$Keywords.Omega} trigger may occur again, up to '
					.. '{#AltUpgradeFormat}' .. mod.tuning.RippleEffect.MaxRepeats .. ' {#Prev}more times '
					.. '{#ItalicLightFormat}(each half as likely as the last).',
			},
		},
		StatLines = {
			BoonEditRippleRepeatStatDisplay = 'Repeat Chance:',
		},
	})
end
