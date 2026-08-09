---@meta _
---@diagnostic disable: lowercase-global

-- Carnal Pleasure (Aphrodite x Ares) no longer throws a Heartthrob when you collect Plasma. What it
-- does instead is make every Heartthrob you get from anywhere else twice the size and harder
-- hitting, harder still for the Plasma you are carrying.
--
-- **The pickup roll is gone deliberately.** Vanilla's `DropManaBurstChance` is a 35% roll on each
-- Plasma collected, and with Heart Breaker and Smoldering Forge both making Hearts of their own, a
-- third source made this boon a duplicate rather than a multiplier. Zeroing the chance leaves it as
-- the thing that makes Hearts worth having.
--
-- The healing that used to live here has gone back to MoreDuos' Boiling Blood, so only one boon
-- answers for what a Plasma pickup is worth.
once('CarnalPleasurePlasmaBursts', function()
	if not config.BoonChanges.CarnalPleasurePlasmaBursts.Enabled then return end

	local carnal = game.TraitData.BloodManaBurstBoon

	-- The line shows the floor -- what a Heartthrob gains before any Plasma is counted. The Plasma
	-- scaling on top of it is what the description means by "plus extra for any Plasma you hold".
	carnal.BoonEditPlasmaBonus = mod.tuning.CarnalPleasure.BaseBonus

	-- Zero rather than nil: vanilla rolls this figure directly, so a nil would be an arithmetic error
	-- rather than a chance that never comes up.
	carnal.DropManaBurstChance = 0

	-- Plasma feeds Heart Breaker's counter. Wrapped after the pickup rather than replacing it, so
	-- everything else a Plasma does still happens first.
	modutil.mod.Path.Wrap("BloodDropUse", function(base, args, consumable)
		local result = base(args, consumable)
		carnal_pleasure_count_plasma()
		return result
	end)

	-- Vanilla's own line is that pickup chance, which is now always zero, so it goes. The
	-- ExtractValues are left alone -- the chance is still the first auto-extracted entry, and that is
	-- what keeps ours reading StatDisplay2.
	carnal.StatLines = {}
	table.insert(carnal.StatLines, 'BoonEditCarnalPleasurePlasmaStatDisplay')
	table.insert(carnal.ExtractValues, {
		Key = 'BoonEditPlasmaBonus',
		ExtractAs = 'TooltipPlasmaBonus',
		Format = 'Percent',
	})
end)


-- How much bigger and harder a Heartthrob lands right now. Applied by the shared wrap in
-- `reload.lua`, so it reaches Smoldering Forge's Hearts too -- deliberate, since the boon says
-- Heartthrobs grow with your Plasma, not that its own do.
--
-- **The bonus starts at BaseBonus with no Plasma at all** and climbs linearly from there, so holding
-- the boon is worth something in the room you picked it up in. Carrying Plasma is what takes it
-- higher, not what switches it on.
--
-- Plasma is counted only as far as the game itself counts it, for the reason MoreDuos' Boiling Blood
-- caps at the same place: `UpdateBloodDropSpeed` stops paying out past that, so scaling off the raw
-- count would let this keep climbing where every other Plasma effect had stopped.
function carnal_pleasure_plasma_boost()
	if not config.BoonChanges.CarnalPleasurePlasmaBursts.Enabled then return 1 end
	if not game.HeroHasTrait('BloodManaBurstBoon') then return 1 end

	local tuning = mod.tuning.CarnalPleasure
	local room = game.CurrentRun and game.CurrentRun.CurrentRoom

	-- no room to count Plasma in is the same as no Plasma, which still pays the base
	local plasma = 0
	if room and tuning.PlasmaCeiling > 0 then
		plasma = math.min(room.BloodDropCount or 0, tuning.PlasmaCeiling)
	end

	local scaled = 0
	if tuning.PlasmaCeiling > 0 then
		scaled = tuning.PlasmaBonus * (plasma / tuning.PlasmaCeiling)
	end

	return 1 + tuning.BaseBonus + scaled
end


-- Flat, and not scaled by Plasma. Twice the blast whatever you are carrying, which is the "larger"
-- half of the boon -- kept out of the trait text on purpose, since a figure that never moves invites
-- the reader to work out when it does.
function carnal_pleasure_size_boost()
	if not config.BoonChanges.CarnalPleasurePlasmaBursts.Enabled then return 1 end
	if not game.HeroHasTrait('BloodManaBurstBoon') then return 1 end

	return mod.tuning.CarnalPleasure.HeartSizeMultiplier
end


-- Each Plasma collected counts towards Heart Breaker as though it were Magick spent.
--
-- `CheckManaBurst` is the counter itself (`PowersLogic.lua:5725`) -- it adds to
-- `SessionMapState.BurstCounter` and throws the Heart once the total reaches the boon's own
-- `ManaCost`. Calling it is what keeps this in step: the threshold, the Heart it makes and the
-- extra Hearts from `BurstCount` are all vanilla's, and none of them are copied here.
--
-- Both boons are asked for. Heart Breaker is the counter being fed, and Carnal Pleasure is the
-- reason Plasma has anything to do with it.
function carnal_pleasure_count_plasma()
	if not config.BoonChanges.CarnalPleasurePlasmaBursts.Enabled then return end
	if not game.HeroHasTrait('BloodManaBurstBoon') then return end

	local heartBreaker = game.GetHeroTrait('ManaBurstBoon')
	local args = heartBreaker and heartBreaker.OnManaSpendAction and heartBreaker.OnManaSpendAction.FunctionArgs
	if not args then return end

	game.CheckManaBurst(args, mod.tuning.CarnalPleasure.PlasmaManaValue)
end
