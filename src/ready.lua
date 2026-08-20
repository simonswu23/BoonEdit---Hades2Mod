---@meta _
---@diagnostic disable: lowercase-global


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
