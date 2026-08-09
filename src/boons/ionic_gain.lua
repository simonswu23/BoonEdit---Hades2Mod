---@meta _
---@diagnostic disable: lowercase-global

-- Ionic Gain (Zeus): the Magick drop it spawns each encounter now feeds you while you stand near it,
-- rather than only when you pick it up. Picking it up still restores the lot, as it always did --
-- this is what the drop is worth to you for leaving it where it is.
--
-- Started from the room hook rather than a `SetupFunction`: the boon already has one
-- (`CheckZeusManaSpawn`, the thing that spawns the drop), and a trait carries only one.


-- Read through a nil-safe helper, not `config.BoonChanges.X.Enabled` directly. Chalk keeps whatever
-- the generated .cfg already holds, so a key added after that file exists is simply absent until it
-- regenerates -- and indexing `.Enabled` off nil there took the whole mod down at load.
local function ionic_gain_on()
	local toggle = config.BoonChanges.IonicGainProximity
	return toggle ~= nil and toggle.Enabled == true
end


once('IonicGain', function()
	if not ionic_gain_on() then return end

	local zeusMana = game.TraitData.ZeusManaBoon

	-- Its own field rather than the trait's `RarityLevels`: those run *downward* (Heroic is 7/10),
	-- because what they scale is the respawn interval and a shorter one is better. A regen rate
	-- wants the opposite, so the ladder is The Unseen's own -- `ManaOverTimeMetaUpgrade`, the arcana
	-- this is modelled on -- read in `ionic_gain_rate` instead.
	zeusMana.BoonEditManaPerSecond = mod.tuning.IonicGain.ManaPerSecond
	table.insert(zeusMana.StatLines, 'BoonEditIonicGainRegenStatDisplay')
	table.insert(zeusMana.ExtractValues, {
		Key = 'BoonEditManaPerSecond',
		ExtractAs = 'TooltipManaRegen',
		DecimalPlaces = 1,
	})
end)


-- The Unseen's ladder, applied to whatever rarity the boon came at.
local function ionic_gain_rate()
	local trait = game.GetHeroTrait('ZeusManaBoon')
	if not trait then return 0 end

	local tuning = mod.tuning.IonicGain
	local scale = tuning.RarityScale[trait.Rarity or 'Common'] or 1
	return tuning.ManaPerSecond * scale
end


-- Every drop the boon has put out, since more than one can be standing at a time.
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


-- Paid per tick rather than per second, so walking through the edge of the range is still worth
-- something. `ManaDelta` is what every other restore in the game goes through, so the Magick gained
-- is capped and presented the way any other is.
function ionic_gain_regen()
	local tuning = mod.tuning.IonicGain

	while game.CurrentRun and game.CurrentRun.CurrentRoom and game.CurrentRun.Hero
		and not game.CurrentRun.Hero.IsDead and game.HeroHasTrait('ZeusManaBoon') do

		if ionic_gain_on() then
			local hero = game.CurrentRun.Hero
			local nearest = ionic_gain_nearest(hero.ObjectId)

			if nearest and nearest <= tuning.Range then
				local rate = ionic_gain_rate()
				if rate > 0 then
					game.ManaDelta(rate * tuning.Interval)
				end
			end
		end

		game.wait(tuning.Interval, game.RoomThreadName)
	end
end


-- Called from `prefix_SetupMap`, so it starts fresh each room and dies with it.
function ionic_gain_start()
	if not ionic_gain_on() then return end
	if not game.CurrentRun or not game.CurrentRun.Hero then return end
	if not game.HeroHasTrait('ZeusManaBoon') then return end

	game.thread(ionic_gain_regen)
end
