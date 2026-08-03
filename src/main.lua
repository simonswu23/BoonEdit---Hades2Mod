---@meta _
-- Dependencies. The ---@ comments are for the language server only.

---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

---@module 'LuaENVY-ENVY-auto'
mods['LuaENVY-ENVY'].auto()
-- gives us `public` and `import`, and makes our globals private to this plugin
---@diagnostic disable: lowercase-global
-- `public`, `import` and `import_as_fallback` all come from ENVY, which the language server cannot see
---@diagnostic disable: undefined-global

---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = _PLUGIN

-- get definitions for the game's globals
---@module 'game'
game = rom.game
---@module 'game-import'
import_as_fallback(game)

---@module 'SGG_Modding-SJSON'
sjson = mods['SGG_Modding-SJSON']
---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-Chalk'
chalk = mods["SGG_Modding-Chalk"]
---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']

---@module 'config'
config = chalk.auto 'config.lua'
-- writes the .cfg in the config folder
public.config = config -- so other mods can access our config

local function on_ready()
	if config.enabled == false then return end
	mod = modutil.mod.Mod.Register(_PLUGIN.guid)

	import 'ready.lua'
end

local function on_reload()
	if config.enabled == false then return end

	import 'reload.lua'
end

local function on_ready_late()
	if config.enabled == false then return end

	import 'ready_late.lua'
end

local function on_reload_late()
	if config.enabled == false then return end

	import 'reload_late.lua'
end

-- lets the ready halves run once and the reload halves run again on every reload
local loader = reload.auto_multiple()

-- runs only once modutil and the game's lua are ready
modutil.once_loaded.game(function()
	loader.load("early", on_ready, on_reload)
end)

-- again but loaded later than other mods
mods.on_all_mods_loaded(function()
	modutil.once_loaded.game(function()
		loader.load("late", on_ready_late, on_reload_late)
	end)
end)