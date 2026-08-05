---@meta _
---@diagnostic disable: lowercase-global

-- Reloaded during play, and it imports every boon under `boons/`, so those reload too. Anything
-- that must not run twice -- trait edits, `Path.Wrap` -- goes inside `once`.
--
-- Shared plumbing lives here: config reload, debug grants, the text registry, and the helpers more
-- than one boon needs.


-- Kept on `mod` rather than in a local, which this file resets on every reload.
mod.SetupDone = mod.SetupDone or {}

function once(key, setup)
	if mod.SetupDone[key] then return end
	mod.SetupDone[key] = true
	setup()
end


-- Numbers behind the boon changes, filled in by each boon file; the config only decides what is on.
mod.tuning = {}


function prefix_SetupMap()
	reload_config()
	debug_grant_test_boons()
	cherished_heirloom_place_keepsakes()
end

-- Re-reads the .cfg so edits take effect on the next room load. Wrapped in a closure because
-- chalk.auto reads the caller's environment, and pcall's own frame has none. The result is put in a
-- local first on purpose: `return chalk.auto(...)` is a tail call, which drops this frame and leaves
-- chalk reading pcall instead, where it finds no plugin and looks for config.lua in the wrong place.
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


-- Force-grants boons for testing. Returns the names that landed, so a typo is not recorded.
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

-- What a name was granted at, so a rarity or Pom change is noticed while a room change is not.
local function debug_grant_signature()
	return tostring(config.Debug.GrantRarity) .. '/' .. tostring(config.Debug.GrantPomLevel)
end

-- Each room, grants any name not already given and takes back any name removed from the list.
-- Kept on CurrentRun, so it is per-run.
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

-- Night Bloom's summons are in MapState.SpellSummons; Sun Worshiper's are not.
function is_allied_summon(unit)
	if not unit then return false end
	if unit.AlwaysTraitor or unit.Charmed then return true end
	return game.Contains(game.MapState.SpellSummons or {}, unit)
end

-- ApplyDamageShare skips anything untargetable, which your own summons read as, so those get the
-- effect applied directly.
function apply_hitch(unit)
	if not unit or not unit.ObjectId then return end

	if not is_allied_summon(unit) then
		game.ApplyDamageShare(unit, { EffectName = 'DamageShareEffect' }, {})
		return
	end

	local effectName = 'DamageShareEffect'
	local dataProperties = game.MergeAllTables({ game.EffectData[effectName].EffectData })
	dataProperties.Duration = (dataProperties.Duration or 0) + game.GetTotalHeroTraitValue('DamageShareDurationIncrease')
	dataProperties.Amount = (dataProperties.Amount or 0) + game.GetTotalHeroTraitValue('DamageShareAmountIncrease')

	game.ApplyEffect({
		DestinationId = unit.ObjectId,
		Id = game.CurrentRun.Hero.ObjectId,
		EffectName = effectName,
		DataProperties = dataProperties,
	})
end


-- Every rewrite the boons ask for, read back when the game loads its text. Rebuilt each reload, as
-- the boon files register into it when imported.
trait_text = {}
help_text = {}
stat_lines = {}
flavor_text = {}

-- `Traits` and `Keywords` take { DisplayName, Description } keyed by text id. `StatLines` takes a
-- label, or a label plus the index of the ExtractValues entry it reads. `Flavor` takes a line.
function boon_text(spec)
	for id, entry in pairs(spec.Traits or {}) do trait_text[id] = entry end
	for id, entry in pairs(spec.Keywords or {}) do help_text[id] = entry end
	for id, entry in pairs(spec.StatLines or {}) do stat_lines[id] = entry end
	for id, entry in pairs(spec.Flavor or {}) do flavor_text[id] = entry end
end

-- Keyword tooltips. ExtractData only resolves inside the tooltip of a boon that carries it, so a
-- keyword read on its own prints the raw token.
function sjson_HelpText(data)
	for _, entry in ipairs(data.Texts) do
		local rewrite = help_text[entry.Id]
		if rewrite and rewrite.Description then
			entry.Description = rewrite.Description
		end
	end
end

-- Boon descriptions, plus the stat lines vanilla has no wording for. StatDisplayN is the Nth
-- ExtractValues entry, so the indices must match the order each boon file sets.
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

	-- InheritFrom is applied in key order and BaseStatLine carries an empty Description, so the keys
	-- are given an explicit order rather than left to re-encode arbitrarily.
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

	-- Flavour goes on an id of its own, so a renamed boon keeps whatever flavour it had.
	local flavorOrder = { 'Id', 'DisplayName' }
	for id, text in pairs(flavor_text) do
		table.insert(data.Texts, sjson.to_object({ Id = id, DisplayName = text }, flavorOrder))
	end
end


-- `import` comes from ENVY, which the language server cannot see; nothing below but imports.
---@diagnostic disable: undefined-global

import 'boons/glamour_gain.lua'
import 'boons/carnal_pleasure.lua'
import 'boons/love_handles.lua'
import 'boons/obsessive_devotion.lua'

import 'boons/stabbing_rush.lua'
import 'boons/profuse_bleeding.lua'
import 'boons/hostile_environment.lua'

import 'boons/sun_worshiper.lua'

import 'boons/local_climate.lua'
import 'boons/tranquil_gain.lua'
import 'boons/winter_harvest.lua'
import 'boons/natural_selection.lua'
import 'boons/cryo_pounder.lua'

import 'boons/unseen_ire.lua'

import 'boons/anvil_rush.lua'
import 'boons/premium_service.lua'
import 'boons/chain_reaction.lua'
import 'boons/seismic_hammer.lua'
import 'boons/brave_face.lua'

import 'boons/rousing_reception.lua'
import 'boons/all_together.lua'
import 'boons/cherished_heirloom.lua'

import 'boons/post_haste.lua'
import 'boons/double_time.lua'

import 'boons/burning_meteor.lua'
import 'boons/cardio_gain.lua'
import 'boons/scalding_vapor.lua'

import 'boons/tidal_rush.lua'
import 'boons/poseidon_froth_requirements.lua'
import 'boons/arterial_spray.lua'
import 'boons/ripple_effect.lua'

import 'boons/shocking_loss.lua'
import 'boons/killer_current.lua'
import 'boons/air_quality.lua'

import 'boons/thermal_dynamics.lua'

import 'boons/harm_for_the_afflicted.lua'
