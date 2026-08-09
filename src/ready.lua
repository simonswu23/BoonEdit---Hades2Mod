---@meta _
---@diagnostic disable: lowercase-global

-- Loaded once and not reloaded during play, so only plumbing that must never run twice lives here.
-- The boons are one file each under `boons/`, imported from `reload.lua`.

local traitText = rom.path.combine(rom.paths.Content, 'Game/Text/en/TraitText.en.sjson')
sjson.hook(traitText, function(data)
	---@diagnostic disable-next-line: undefined-global
	return sjson_TraitText(data)
end)

local helpText = rom.path.combine(rom.paths.Content, 'Game/Text/en/HelpText.en.sjson')
sjson.hook(helpText, function(data)
	---@diagnostic disable-next-line: undefined-global
	return sjson_HelpText(data)
end)

-- Not text. A projectile's own numbers are data rather than Lua -- `ProjectileData_Gods.lua` carries
-- little more than `InheritFrom` -- so this file is the only place they can be reached.
local playerProjectiles = rom.path.combine(rom.paths.Content, 'Game/Projectiles/PlayerProjectiles.sjson')
sjson.hook(playerProjectiles, function(data)
	---@diagnostic disable-next-line: undefined-global
	return sjson_PlayerProjectiles(data)
end)


modutil.mod.Path.Wrap("SetupMap", function(base, ...)
	---@diagnostic disable-next-line: undefined-global
	prefix_SetupMap()
	return base(...)
end)


-- Carnal Pleasure's per-Plasma healing lived here and has gone back to MoreDuos' Boiling Blood,
-- which wraps `BloodDropUse` for it now. Nothing here needs the pickup any more: the Plasma scaling
-- that replaced it is read live off the room's own count when a Heartthrob goes out.
