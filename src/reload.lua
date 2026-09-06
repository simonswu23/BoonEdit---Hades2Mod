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
	---@diagnostic disable-next-line: undefined-global
	boon_edit_sync_groups()
	---@diagnostic disable-next-line: undefined-global
	burning_desire_sync()
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


KEYWORD_EXTRACTS = {
	Rend = {
		{ ExtractAs = 'AresCurseDuration', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'AresStatus', BaseProperty = 'Duration' },
		{ ExtractAs = 'AresCursePowerBonus', SkipAutoExtract = true, External = true,
			BaseType = 'EffectLuaData', BaseName = 'AresStatus', BaseProperty = 'BonusBaseDamageOnInflict' },
	},
	Weak = {
		{ ExtractAs = 'TooltipWeakModifier', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'WeakEffect', BaseProperty = 'Modifier',
			Format = 'NegativePercentDelta' },
		{ ExtractAs = 'TooltipWeakDuration', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'WeakEffect', BaseProperty = 'Duration' },
	},
	Burn = {
		{ ExtractAs = 'BurnRate', SkipAutoExtract = true, External = true,
			BaseType = 'EffectLuaData', BaseName = 'BurnEffect', BaseProperty = 'DamagePerSecond',
			DecimalPlaces = 1 },
	},
	KnockbackAmplify = {
		{ ExtractAs = 'KnockbackAmplifyDuration', SkipAutoExtract = true, External = true,
			BaseType = 'EffectData', BaseName = 'AmplifyKnockbackEffect', BaseProperty = 'Duration',
			DecimalPlaces = 1 },
		{ ExtractAs = 'FontChance', SkipAutoExtract = true, External = true,
			BaseType = 'EffectLuaData', BaseName = 'AmplifyKnockbackEffect', BaseProperty = 'Chance',
			Format = 'LuckModifiedPercent' },
		{ ExtractAs = 'FontDamage', SkipAutoExtract = true, External = true,
			BaseType = 'ProjectileBase', BaseName = 'PoseidonEffectFont', BaseProperty = 'Damage' },
	},
	HeartBurst = {
		{ ExtractAs = 'Duration', SkipAutoExtract = true, External = true,
			BaseType = 'ProjectileBase', BaseName = 'AphroditeBurst', BaseProperty = 'Fuse' },
	},
}


function with_keyword_extracts(own, ...)
	local combined = {}
	for _, entry in ipairs(own or {}) do table.insert(combined, entry) end

	for _, keyword in ipairs({ ... }) do
		for _, entry in ipairs(KEYWORD_EXTRACTS[keyword] or {}) do
			table.insert(combined, entry)
		end
	end
	return combined
end


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
		local prefix = (type(entry) == 'table' and entry.Prefix) or ''
		local suffix = (type(entry) == 'table' and entry.Suffix) or ''
		table.insert(data.Texts, sjson.to_object({
			Id = id,
			InheritFrom = 'BaseStatLine',
			DisplayName = '{!Icons.Bullet}{#PropertyFormat}' .. name,
			Description = '{#UpgradeFormat}' .. prefix .. '{$TooltipData.StatDisplay' .. index .. '}' .. suffix,
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
import 'boons/passion_rush.lua'
import 'boons/carnal_pleasure.lua'
import 'boons/smoldering_forge.lua'
import 'boons/ecstatic_obsession.lua'
import 'boons/hearty_appetite.lua'

import 'boons/stabbing_rush.lua'
import 'boons/profuse_bleeding.lua'
import 'boons/meat_grinder.lua'
import 'boons/hostile_environment.lua'
import 'boons/blood_spree.lua'
import 'boons/grape_juice.lua'
import 'boons/festive_fog.lua'

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
import 'boons/burning_desire.lua'
import 'boons/controlled_burn.lua'
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
