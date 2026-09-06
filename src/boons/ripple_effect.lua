---@meta _
---@diagnostic disable: lowercase-global


once('RippleEffectOmegaBoons', function()
	if config.BoonChanges.RippleEffect.Enabled then
		local ripple = game.TraitData.MoneyDamageBoon

		ripple.DoubleOlympianProjectileChance = 0

		ripple.BoonEditRepeatChance = mod.tuning.RippleEffect.RepeatChance
		ripple.StatLines = { 'BoonEditRippleRepeatStatDisplay' }
		ripple.BoonEditMaxRepeats = mod.tuning.RippleEffect.MaxRepeats
		ripple.ExtractValues = {
			{
				Key = 'BoonEditRepeatChance',
				ExtractAs = 'Chance',
				Format = 'LuckModifiedPercent',
				HideSigns = true,
			},
			{ Key = 'BoonEditMaxRepeats', ExtractAs = 'TooltipMaxRepeats', SkipAutoExtract = true },
		}
	end

	modutil.mod.Path.Wrap("CheckDionysusDebuff", function(base, victim, functionArgs, triggerArgs)
		if ripple_effect_hangover then
			return ripple_effect_hangover(base, victim, functionArgs, triggerArgs)
		end
		return base(victim, functionArgs, triggerArgs)
	end)

	modutil.mod.Path.Wrap("CreateProjectileFromUnit", function(base, args)
		local result = base(args)
		if ripple_effect_repeat then
			ripple_effect_repeat(args)
		end
		return result
	end)
end)


-- The Omega boons Ripple repeats, named one at a time rather than by family. It used to take every
-- fireball through `fireball_projectiles()`, which is the Fireballs edit's own list and holds this
-- mod's and other mods' fireballs as well as Hestia's -- so a Waxing Moon Hex-Call or a Volcanic
-- Crown fed it dozens of projectiles, each repeating and bouncing on.
local RIPPLE_PROJECTILES = {
	PoseidonOmegaWave = true,   -- Ocean Swell
	ProjectileHeraOmega = true, -- Fine Line
	ArtemisCastVolley = true,   -- Easy Shot
	ProjectileFireball = true,  -- Controlled Burn
	IcarusExplosion = true,     -- Explosive Intent
	ProjectileAresSwordEx = true, -- Cut Above
}


function ripple_effect_covers(name)
	return RIPPLE_PROJECTILES[name] == true
end

-- How many extra helpings this proc earns, each roll dearer than the last.
function ripple_effect_rolls()
	local tuning = mod.tuning.RippleEffect
	local chance = game.GetTotalHeroTraitValue('BoonEditRepeatChance')
	local repeats = 0

	while repeats < tuning.MaxRepeats and rolls(chance) do
		repeats = repeats + 1
		chance = chance * tuning.Falloff
	end

	return repeats
end


-- **Drunken Stupor fires no projectile**, so it cannot be named above: it applies a lingering effect
-- through `ApplyEffect`, behind a `HitByDionysusEx` latch that lets it land once per foe
-- (`PowersLogic.lua:3721`). Re-applying would refresh that one effect rather than add to it, so a
-- ripple of it is a heavier dose instead -- the rolls that would have repeated a projectile multiply
-- what the effect carries.
function ripple_effect_hangover(base, victim, functionArgs, triggerArgs)
	if not config.BoonChanges.RippleEffect.Enabled then return base(victim, functionArgs, triggerArgs) end
	if not game.HeroHasTrait('MoneyDamageBoon') then return base(victim, functionArgs, triggerArgs) end
	if type(functionArgs and functionArgs.Damage) ~= 'number' then
		return base(victim, functionArgs, triggerArgs)
	end

	local repeats = ripple_effect_rolls()
	if repeats <= 0 then return base(victim, functionArgs, triggerArgs) end

	local dosed = game.ShallowCopyTable(functionArgs)
	dosed.Damage = functionArgs.Damage * (1 + repeats)
	return base(victim, dosed, triggerArgs)
end


function ripple_effect_repeat(args)
	if mod.RippleFiring then return end
	if not config.BoonChanges.RippleEffect.Enabled then return end
	if not args or not args.Name or not ripple_effect_covers(args.Name) then return end
	if not game.HeroHasTrait('MoneyDamageBoon') then return end


	local repeats = ripple_effect_rolls()
	if repeats <= 0 then return end

	local repeated = game.ShallowCopyTable(args)

	if repeated.ProjectileCap then
		repeated.ProjectileCap = repeated.ProjectileCap + repeats
	end

	game.thread(ripple_effect_refire, repeated, repeats)
end

function ripple_effect_refire(args, repeats)
	local interval = game.GetTotalHeroTraitValue('DoubleOlympianProjectileInterval')

	for _ = 1, repeats do
		game.waitUnmodified(interval)

		mod.RippleFiring = true
		local ok, err = pcall(game.CreateProjectileFromUnit, args)
		mod.RippleFiring = nil
		if not ok then
			print('[' .. _PLUGIN.guid .. '] ripple repeat failed: ' .. tostring(err))
			return
		end
	end
end
