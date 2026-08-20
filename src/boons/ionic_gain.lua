---@meta _
---@diagnostic disable: lowercase-global


local function ionic_gain_on()
	local toggle = config.BoonChanges.IonicGain
	return toggle ~= nil and toggle.Enabled == true
end


once('IonicGain', function()
	if not ionic_gain_on() then return end

	local zeusMana = game.TraitData.ZeusManaBoon

	zeusMana.BoonEditManaPerSecond = mod.tuning.IonicGain.ManaPerSecond
	table.insert(zeusMana.StatLines, 'BoonEditIonicGainRegenStatDisplay')
	table.insert(zeusMana.ExtractValues, {
		Key = 'BoonEditManaPerSecond',
		ExtractAs = 'TooltipManaRegen',
		DecimalPlaces = 1,
	})
end)


local function ionic_gain_rate()
	local trait = game.GetHeroTrait('ZeusManaBoon')
	if not trait then return 0 end

	local tuning = mod.tuning.IonicGain
	local scale = tuning.RarityScale[trait.Rarity or 'Common'] or 1
	return tuning.ManaPerSecond * scale
end


local function ionic_gain_nearest(heroId)
	local nearest = nil
	for _, id in ipairs(game.GetIdsByType({ Name = 'ManaDropZeus' }) or {}) do
		local distance = game.GetDistance({ Id = heroId, DestinationId = id })
		if distance and (not nearest or distance < nearest) then
			nearest = distance
		end
	end
	return nearest
end


function ionic_gain_regen()
	local tuning = mod.tuning.IonicGain
	local carried = 0

	while game.CurrentRun and game.CurrentRun.CurrentRoom and game.CurrentRun.Hero
		and not game.CurrentRun.Hero.IsDead and game.HeroHasTrait('ZeusManaBoon') do

		if ionic_gain_on() then
			local hero = game.CurrentRun.Hero
			local nearest = ionic_gain_nearest(hero.ObjectId)

			if nearest and nearest <= tuning.Range then
				local rate = ionic_gain_rate()
				if rate > 0 then

					carried = carried + rate * tuning.Interval
					local whole = math.floor(carried)
					if whole > 0 then
						carried = carried - whole
						game.ManaDelta(whole, { Silent = false, SWuManaDrip = true })
					end
				end
			end
		else
			carried = 0
		end

		game.wait(tuning.Interval, game.RoomThreadName)
	end
end


function ionic_gain_start()
	if not ionic_gain_on() then return end
	if not game.CurrentRun or not game.CurrentRun.Hero then return end
	if not game.HeroHasTrait('ZeusManaBoon') then return end

	game.thread(ionic_gain_regen)
end
