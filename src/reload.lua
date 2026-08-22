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


function prefix_SetupMap()
	reload_config()
	debug_grant_test_boons()
	cherished_heirloom_place_keepsakes()
	---@diagnostic disable-next-line: undefined-global
	pandemonium_sync_slots()
	---@diagnostic disable-next-line: undefined-global
	ionic_gain_start()
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

import 'boons/local_climate.lua'
import 'boons/tranquil_gain.lua'
import 'boons/winter_harvest.lua'
import 'boons/natural_selection.lua'
import 'boons/cryo_pounder.lua'

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
