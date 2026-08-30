---@meta _
---@diagnostic disable: lowercase-global


mod.SetupDone = mod.SetupDone or {}

function once(key, setup)
	if mod.SetupDone[key] then return end
	mod.SetupDone[key] = true
	setup()
end


---@diagnostic disable-next-line: undefined-global
import 'tuning.lua'


SCREEN_WAIT_TRIES = 40
SCREEN_WAIT_STEP = 0.1

function prefix_SetupMap()
	reload_config()
	debug_grant_test_boons()
	cherished_heirloom_place_keepsakes()
	---@diagnostic disable-next-line: undefined-global
	pandemonium_sync_slots()
	---@diagnostic disable-next-line: undefined-global
	ionic_gain_start()
	---@diagnostic disable-next-line: undefined-global
	breaker_rush_sync()
end

function reload_config()

	local ok, reloaded = pcall(function()
		local loaded = chalk.auto('config.lua')
		return loaded
	end)
	if ok and reloaded then
		config = reloaded
		---@diagnostic disable-next-line: undefined-global
		public.config = config
	else
		print('[' .. _PLUGIN.guid .. '] config reload failed: ' .. tostring(reloaded))
	end
end


function debug_grant_traits(...)
	local landed = {}
	if not game.CurrentRun or not game.CurrentRun.Hero then return landed end

	for _, traitName in ipairs({...}) do
		if not game.TraitData[traitName] then
			print('[' .. _PLUGIN.guid .. '] debug_grant_traits: no such trait "' .. tostring(traitName) .. '"')
		else
			if game.HeroHasTrait(traitName) then
				game.RemoveTrait(game.CurrentRun.Hero, traitName)
			end
			game.AddTraitToHero({
				FromLoot = true,
				SkipNewTraitHighlight = true,
				TraitData = game.GetProcessedTraitData({
					Unit = game.CurrentRun.Hero,
					TraitName = traitName,
					Rarity = config.Debug.GrantRarity,
					StackNum = math.max(1, math.floor(config.Debug.GrantPomLevel or 1)),
				}),
			})
			landed[traitName] = true
		end
	end
	return landed
end

local function debug_grant_signature()
	return tostring(config.Debug.GrantRarity) .. '/' .. tostring(config.Debug.GrantPomLevel)
end

function debug_grant_test_boons()
	if not game.CurrentRun or not game.CurrentRun.Hero then return end

	local wanted = {}
	for name in string.gmatch(config.Debug.GrantTraits or '', '[^,;%s]+') do
		wanted[name] = true
	end

	local granted = game.CurrentRun.BoonEditDebugGranted or {}
	game.CurrentRun.BoonEditDebugGranted = granted

	for name in pairs(granted) do
		if not wanted[name] then
			if game.HeroHasTrait(name) then
				game.RemoveTrait(game.CurrentRun.Hero, name)
			end
			granted[name] = nil
		end
	end

	local signature = debug_grant_signature()
	for name in pairs(wanted) do
		if granted[name] ~= signature then
			for landed in pairs(debug_grant_traits(name)) do
				granted[landed] = signature
			end
		end
	end
end


function rolls(chance)
	return game.RandomChance(chance * game.GetTotalHeroTraitValue('LuckMultiplier', { IsMultiplier = true }))
end

function is_allied_summon(unit)
	if not unit then return false end
	if unit.AlwaysTraitor or unit.Charmed then return true end
	if unit.ObjectId and game.IsCharmed({ Id = unit.ObjectId }) then return true end
	return game.Contains(game.MapState.SpellSummons or {}, unit)
end

function apply_hitch(unit)
	if not unit or not unit.ObjectId then return end
	if is_allied_summon(unit) then return end

	game.ApplyDamageShare(unit, { EffectName = 'DamageShareEffect' }, {})
end


HEARTTHROB_PROJECTILE = 'AphroditeBurst'

once('Heartthrobs', function()
	modutil.mod.Path.Wrap("CreateProjectileFromUnit", function(base, args)
		if args and args.Name == HEARTTHROB_PROJECTILE then
			---@diagnostic disable-next-line: undefined-global
			local capacity = carnal_pleasure_heartthrob_cap()
			if capacity then
				args.FizzleOldestProjectileCount = capacity
			end

			---@diagnostic disable-next-line: undefined-global
			local bonus = carnal_pleasure_bonus_damage()
			if bonus > 0 then
				local baseDamage = game.GetBaseDataValue({
					Type = 'Projectile',
					Name = HEARTTHROB_PROJECTILE,
					Property = 'Damage',
				})
				if type(baseDamage) == 'number' then
					args.DataProperties = args.DataProperties or {}
					args.DataProperties.Damage = baseDamage + bonus
				end
			end

			---@diagnostic disable-next-line: undefined-global
			local size = carnal_pleasure_size_boost()
			if size > 1 then
				args.ScaleMultiplier = (args.ScaleMultiplier or 1) * size
				args.BlastRadiusModifier = (args.BlastRadiusModifier or 1) * size
			end
		end
		return base(args)
	end)
end)

function create_heartthrob(burstArgs)
	if not burstArgs then return end
	game.thread(game.CreateManaBurst, burstArgs, 1 + game.GetTotalHeroTraitValue('BurstCount'))
end


trait_text = {}
help_text = {}
stat_lines = {}
flavor_text = {}
combat_text = {}

function boon_text(spec)
	for id, entry in pairs(spec.Traits or {}) do trait_text[id] = entry end
	for id, entry in pairs(spec.Keywords or {}) do help_text[id] = entry end
	for id, entry in pairs(spec.StatLines or {}) do stat_lines[id] = entry end
	for id, entry in pairs(spec.Flavor or {}) do flavor_text[id] = entry end
	for id, entry in pairs(spec.CombatText or {}) do combat_text[id] = entry end
end

function sjson_PlayerProjectiles(data)
	local damages = {}

	---@diagnostic disable-next-line: undefined-global
	if glorious_disaster_supercharged() then
		damages.ZeusApolloSynergyStrike = mod.tuning.GloriousDisaster.BoltDamage
	end

	---@diagnostic disable-next-line: undefined-global
	if beach_ball_rebalanced() then
		damages.ProjectileSprintBall = mod.tuning.BeachBall.BlastDamage
	end

	for _, projectile in ipairs(data.Projectiles) do
		local damage = damages[projectile.Name]
		if damage then projectile.Damage = damage end
	end
end

-- Arterial Spray marks its second wave with `PoseidonRedConeFxEmitterLarge`, which is a cone --
-- vanilla's splash is a cone, so that matches. Breaker Rush's is not: `PoseidonCastSplashSplinter`
-- is `Type = INSTANT` with `UseRadialImpact` and a 290 damage radius, so it already hits all round
-- and the red cone pointed one way across a circle that did not.
--
-- This is the same trick vanilla used to make the red cone in the first place: inherit the shape and
-- recolour it, with the red taken verbatim off `PoseidonRedConeFxLarge`. `ClearCreateAnimations`
-- drops the parent's child animations, which are all tinted Poseidon blue and would otherwise show
-- through the red.
function sjson_PoseidonVfx(data)
	if not data or not data.Animations then return end

	for _, animation in ipairs(data.Animations) do
		if animation.Name == mod.tuning.PoseidonSplash.RedNova then return end
	end

	table.insert(data.Animations, sjson.to_object({
		Name = mod.tuning.PoseidonSplash.RedNova,
		InheritFrom = 'RadialNovaPentagram_Poseidon',
		ClearCreateAnimations = true,
		StartRed = 1,
		StartGreen = 0.01,
		StartBlue = 0.01,
		EndRed = 0.7,
		EndGreen = 0,
		EndBlue = 0,
	}, {
		'Name', 'InheritFrom', 'ClearCreateAnimations',
		'StartRed', 'StartGreen', 'StartBlue', 'EndRed', 'EndGreen', 'EndBlue',
	}))
end


function sjson_HelpText(data)
	for _, entry in ipairs(data.Texts) do
		local rewrite = help_text[entry.Id]
		if rewrite and rewrite.Description then
			entry.Description = rewrite.Description
		end
	end
end

function sjson_TraitText(data)
	for _, entry in ipairs(data.Texts) do
		local rewrite = trait_text[entry.Id]
		if rewrite then
			if rewrite.DisplayName then
				entry.DisplayName = rewrite.DisplayName
			end
			if rewrite.Description then
				entry.Description = rewrite.Description
			end
		end
	end

	local statLineOrder = { 'Id', 'InheritFrom', 'DisplayName', 'Description' }

	for id, entry in pairs(stat_lines) do
		local name = type(entry) == 'table' and entry.Name or entry
		local index = (type(entry) == 'table' and entry.Index) or 1
		table.insert(data.Texts, sjson.to_object({
			Id = id,
			InheritFrom = 'BaseStatLine',
			DisplayName = '{!Icons.Bullet}{#PropertyFormat}' .. name,
			Description = '{#UpgradeFormat}{$TooltipData.StatDisplay' .. index .. '}',
		}, statLineOrder))
	end

	local flavorOrder = { 'Id', 'DisplayName' }
	for id, text in pairs(flavor_text) do
		table.insert(data.Texts, sjson.to_object({ Id = id, DisplayName = text }, flavorOrder))
	end

	for id, text in pairs(combat_text) do
		table.insert(data.Texts, sjson.to_object({ Id = id, DisplayName = text }, flavorOrder))
	end
end


---@diagnostic disable: undefined-global

import 'boons/fireballs.lua'
import 'boons/glamour_gain.lua'
import 'boons/carnal_pleasure.lua'
import 'boons/smoldering_forge.lua'
import 'boons/ecstatic_obsession.lua'
import 'boons/hearty_appetite.lua'

import 'boons/stabbing_rush.lua'
import 'boons/profuse_bleeding.lua'
import 'boons/meat_grinder.lua'
import 'boons/hostile_environment.lua'
import 'boons/blood_spree.lua'

import 'boons/sun_worshiper.lua'
import 'boons/dazzling_display.lua'
import 'boons/extra_dose.lua'

import 'boons/local_climate.lua'
import 'boons/tranquil_gain.lua'
import 'boons/winter_harvest.lua'
import 'boons/natural_selection.lua'
import 'boons/cryo_pounder.lua'
import 'boons/arctic_gale.lua'

import 'boons/unseen_ire.lua'
import 'boons/old_grudge.lua'

import 'boons/anvil_rush.lua'
import 'boons/heavy_armor.lua'
import 'boons/molten_touch.lua'
import 'boons/premium_service.lua'
import 'boons/chain_reaction.lua'
import 'boons/seismic_hammer.lua'
import 'boons/brave_face.lua'

import 'boons/rousing_reception.lua'
import 'boons/all_together.lua'
import 'boons/cherished_heirloom.lua'

import 'boons/post_haste.lua'
import 'boons/second_wind.lua'

import 'boons/burning_meteor.lua'
import 'boons/cardio_gain.lua'
import 'boons/scalding_vapor.lua'

import 'boons/tidal_rush.lua'
import 'boons/tidal_ring.lua'
import 'boons/easy_shot.lua'
import 'boons/beach_ball.lua'
import 'boons/arterial_spray.lua'
import 'boons/ripple_effect.lua'

import 'boons/shocking_loss.lua'
import 'boons/killer_current.lua'
import 'boons/air_quality.lua'
import 'boons/power_surge.lua'

import 'boons/thermal_dynamics.lua'

import 'boons/harm_for_the_afflicted.lua'

import 'boons/ionic_gain.lua'
import 'boons/glorious_disaster.lua'
import 'boons/pandemonium.lua'


import 'requirements.lua'
import 'text.lua'

-- Wait for whatever is already on screen to close before opening one of our own.
--
-- Both of the prompts that use this used to be a fixed pause, which raced anything else that opens a
-- window on a delay of its own -- Concave Stone's random boon is the one that showed it: whichever
-- screen opened second landed on top of the first. Time is frozen while a screen is up, so the pause
-- also has to be unmodified or it does not run down at all.
--
-- Bounded, so a screen that never closes cannot strand the prompt for good. `settle` is the old
-- fixed pause, kept as the beat after the field is clear.
--
-- The field is re-checked on the far side of that pause, not only before it. The window this exists
-- to avoid is a *delayed* one, so it can open during the settle just as easily as before it, and
-- leaving on the first clear reading would walk straight back into the collision.
-- `ConeModifier` is what Arterial Spray, King Tide and Backwash all work through, and the only
-- things that ever read it are vanilla's own splash functions -- `CheckPoseidonSplash`
-- (`PowersLogic.lua:3799`) and High Surf's `PoseidonAttackPunish` (`:6123`). Notably *not*
-- `CheckPoseidonCastSplash` (`:1857`), which fires Tidal Ring's and consults nothing at all.
--
-- So any splash this mod fires itself goes past all of them unless it does the reading, and three
-- now do. The loop is vanilla's, in vanilla's order; each trait carrying the field rolls separately
-- and each success is another wave, so the boons stack here exactly as they do elsewhere.
--
-- The graphic is deliberately not `data.DoubleWaveGraphic`. Every caller of this fires a radial
-- splash, and Arterial Spray's own marker is a cone.
function poseidon_splash_cone()
	local scale = 1
	local count = 1
	local graphic = nil

	for _, data in pairs(game.GetHeroTraitValues('ConeModifier')) do
		if data.ScaleIncrease then
			scale = scale * data.ScaleIncrease
		end
		if data.MaxScale and scale > data.MaxScale then
			scale = data.MaxScale
		end
		if data.DoubleWaveChance and game.RandomChance(data.DoubleWaveChance
			* game.GetTotalHeroTraitValue('LuckMultiplier', { IsMultiplier = true })) then
			count = count + 1
			graphic = mod.tuning.PoseidonSplash.RedNova
		end
	end

	return scale, count, graphic
end


function cast_area_multiplier()
	local multiplier = 1

	for _, data in pairs(game.GetHeroTraitValues('CastProjectileModifiers')) do
		if data.AreaIncrease then
			multiplier = multiplier * data.AreaIncrease
		end
	end

	return multiplier
end


function wait_for_screens(settle)
	settle = settle or 0

	for _ = 1, SCREEN_WAIT_TRIES do
		if not game.IsEmpty(game.ActiveScreenOrder or {}) then
			game.waitUnmodified(SCREEN_WAIT_STEP)
		else
			if settle > 0 then game.waitUnmodified(settle) end
			if game.IsEmpty(game.ActiveScreenOrder or {}) then return end
		end
	end
end

function defer_screen_open(open, ...)
	if game.IsEmpty(game.ActiveScreenOrder or {}) then
		return open(...)
	end

	local args = table.pack(...)
	game.thread(function()
		wait_for_screens(0)
		open(table.unpack(args, 1, args.n))
	end)
end
