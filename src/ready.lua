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


modutil.mod.Path.Wrap("SetupMap", function(base, ...)
	---@diagnostic disable-next-line: undefined-global
	prefix_SetupMap()
	return base(...)
end)
