---@meta _
---@diagnostic disable: lowercase-global

-- Ripple Effect (Hera x Poseidon) covers every boon that surcharges your Omega Moves rather than
-- doubling its own two projectiles; each repeat rolls again at half the chance, up to four deep.

once('RippleEffectOmegaBoons', function()
	if config.BoonChanges.RippleEffect.Enabled then
		local ripple = game.TraitData.MoneyDamageBoon

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


local OMEGA_BOON_PROJECTILES = {
	PoseidonOmegaWave     = true, -- Ocean Swell (Poseidon)
	ProjectileHeraOmega   = true, -- Fine Line (Hera)
	ProjectileFireball    = true, -- Controlled Burn (Hestia)
	ProjectileAresSwordEx = true, -- Cut Above (Ares)
	IcarusExplosion       = true, -- Explosive Intent (Icarus)
}

function ripple_effect_repeat(args)
	if mod.RippleFiring then return end
	if not config.BoonChanges.RippleEffect.Enabled then return end
	if not args or not args.Name or not OMEGA_BOON_PROJECTILES[args.Name] then return end
	if not game.HeroHasTrait('MoneyDamageBoon') then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero or args.Id ~= hero.ObjectId then return end

	local tuning = mod.tuning.RippleEffect
	local chance = game.GetTotalHeroTraitValue('BoonEditRepeatChance')
	local repeats = 0

	while repeats < tuning.MaxRepeats and rolls(chance) do
		repeats = repeats + 1
		chance = chance * tuning.Falloff
	end
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
