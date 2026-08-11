---@meta _
---@diagnostic disable: lowercase-global


-- All Together (Hera legendary) grants 2 of each element on pickup instead of 1.

once('AllTogetherDoubleElements', function()
	if not config.BoonChanges.AllTogether.Enabled then return end

	local allTogether = game.TraitData.AllElementalBoon
	local doubled = {}
	for _, element in ipairs(allTogether.Elements) do
		table.insert(doubled, element)
		table.insert(doubled, element)
	end
	allTogether.Elements = doubled
end)
