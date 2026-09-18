---@meta _
---@diagnostic disable: lowercase-global



once('GrapeJuice', function()
	modutil.mod.Path.Wrap("DrinkPickup", function(base, interactableObject, functionArgs, user)
		grape_juice_heal()
		return base(interactableObject, functionArgs, user)
	end)
end)


function grape_juice_heal()
	if not config.BoonChanges.GrapeJuice.Enabled then return end

	local hero = game.CurrentRun and game.CurrentRun.Hero
	if not hero then return end

	local amount = mod.tuning.GrapeJuice.Heal
	if type(amount) ~= 'number' or amount <= 0 then return end

	game.Heal(hero, {
		HealAmount = game.round(amount * game.CalculateHealingMultiplier()),
		SourceName = 'PowerDrinkDrop',
	})
end
