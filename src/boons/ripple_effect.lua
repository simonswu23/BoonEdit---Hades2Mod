---@meta _
---@diagnostic disable: lowercase-global


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


-- Four families and no more. Ares' swords and Icarus' explosion used to be here and are not the
-- kind of thing this is for -- one is a falling blade with its own count, the other a one-off blast.
--
-- Hestia's is the whole fireball list rather than the one name, because this mod widens what counts
-- as a fireball elsewhere (`fireball_projectiles`) and a boon that repeats "your fireballs" should
-- mean the same set everywhere.
local RIPPLE_PROJECTILES = {
	-- Ocean Swells
	PoseidonOmegaWave = true,

	-- Hera Rifts
	ProjectileHeraOmega = true,

	-- Artemis' piercing arrows, off Easy Shot
	ArtemisCastVolley = true,
}


function ripple_effect_covers(name)
	if RIPPLE_PROJECTILES[name] then return true end

	---@diagnostic disable-next-line: undefined-global
	return game.Contains(fireball_projectiles(), name)
end

function ripple_effect_repeat(args)
	if mod.RippleFiring then return end
	if not config.BoonChanges.RippleEffect.Enabled then return end
	if not args or not args.Name or not ripple_effect_covers(args.Name) then return end
	if not game.HeroHasTrait('MoneyDamageBoon') then return end

	-- No check on who fired it. These four are yours by definition -- nothing else in the game makes
	-- an Ocean Swell or a Hera Rift -- and tying it to Melinoe's own ObjectId quietly dropped every
	-- one of them that something else spawned on your behalf: a familiar's cast, a Hex-Call's swells,
	-- anything re-fired through a wrap. However and whenever one is created, it repeats.

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
