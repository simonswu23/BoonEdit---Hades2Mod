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

local poseidonVfx = rom.path.combine(rom.paths.Content, 'Game/Animations/Melinoe_Poseidon_VFX.sjson')
sjson.hook(poseidonVfx, function(data)
	---@diagnostic disable-next-line: undefined-global
	return sjson_PoseidonVfx(data)
end)


modutil.mod.Path.Wrap("OpenUpgradeChoiceMenu", function(base, source, args)
	---@diagnostic disable-next-line: undefined-global
	return defer_screen_open(base, source, args)
end)

modutil.mod.Path.Wrap("OpenKeepsakeRackScreen", function(base, source)
	---@diagnostic disable-next-line: undefined-global
	return defer_screen_open(base, source)
end)


modutil.mod.Path.Wrap("SetupMap", function(base, ...)
	---@diagnostic disable-next-line: undefined-global
	prefix_SetupMap()
	return base(...)
end)
