---@meta _
---@diagnostic disable: lowercase-global

-- Cherished Heirloom (Demeter x Hera) keeps its rank bonus and gains two effects: Keepsakes stop
-- running out for the night, and taking it lets you wear a second one.
once('CherishedHeirloom', function()
	if config.BoonChanges.CherishedHeirloom.Enabled then
		game.TraitData.KeepsakeLevelBoon.AcquireFunctionName = _PLUGIN.guid .. '.CherishedHeirloomAcquire'
	end

	-- The close swaps by unequipping then equipping, so skipping the unequip keeps both on.
	modutil.mod.Path.Wrap("KeepsakeScreenClose", function(base, screen, button)
		local extra = cherished_heirloom_extra_pending()
		local incoming = nil
		if extra then
			mod.HeirloomSkipUnequip = true
			mod.HeirloomExtraPending = nil

			-- kept out of the HUD from the moment it is equipped, or it draws over the old one
			incoming = game.GameState.LastAwardTrait
			if incoming ~= screen.LastTrait then
				mod.HeirloomIncoming = incoming
			end
		end

		-- the close bars whichever Keepsake it thinks was swapped away, but ours is still worn. It is
		-- the extra that must not be picked again.
		local blocked = extra and game.CurrentRun and game.CurrentRun.BlockedKeepsakes
		local blockedCount = blocked and #blocked or 0

		base(screen, button)

		if extra then
			mod.HeirloomSkipUnequip = nil
			mod.HeirloomIncoming = nil

			if blocked and incoming and #blocked > blockedCount and blocked[#blocked] == screen.LastTrait then
				blocked[#blocked] = incoming
			end

			-- the worn slot goes back to the one already on, so it keeps its chamber progress
			if game.CurrentRun and screen.LastTrait and game.HeroHasTrait(screen.LastTrait) then
				game.GameState.LastAwardTrait = screen.LastTrait
			end

			cherished_heirloom_place_keepsakes()
		end
	end)

	modutil.mod.Path.Wrap("IsShownInHUD", function(base, trait)
		if heirloom_hides_from_hud(trait) then return false end
		return base(trait)
	end)

	modutil.mod.Path.Wrap("UnequipKeepsake", function(base, heroUnit, traitName, args)
		if mod.HeirloomSkipUnequip then
			mod.HeirloomSkipUnequip = nil
			return
		end
		return base(heroUnit, traitName, args)
	end)
end)


-- A large HoldRemainingRooms freezes the expiry countdown without touching RemainingUses.
local HEIRLOOM_HOLD_ENCOUNTERS = 9999

-- long enough for the boon's pickup presentation to finish before a full-screen menu opens
local HEIRLOOM_MENU_DELAY = 1.2

function cherished_heirloom_active()
	if not config.BoonChanges.CherishedHeirloom.Enabled then return false end
	if not game.CurrentRun or not game.CurrentRun.Hero then return false end
	return game.HeroHasTrait('KeepsakeLevelBoon')
end

function cherished_heirloom_extra_pending()
	return mod.HeirloomExtraPending and mod.tuning.CherishedHeirloom.ExtraKeepsake
end

-- Demotes a Keepsake out of its slot. Two left alone would draw on the same spot.
function heirloom_demote_keepsake(trait)
	if not trait or not trait.Name then return end

	game.TraitUIRemove(trait)
	trait.Slot = nil
	trait.ActiveSlotOffsetIndex = nil
	trait.HideInRunHistory = nil
	trait.Ordered = nil
	game.SessionMapState.HUDTraitsShown[trait.Name] = nil

	if mod.tuning.CherishedHeirloom.ExtraKeepsakeInMenuOnly then
		-- the boon menu lists what is neither Hidden nor in the HUD. RemainingUses is left alone,
		-- since the game reads it unguarded all over, so the flag does the work.
		trait.ShowInHUD = nil
		trait.BoonEditHeirloomExtra = true
		return
	end

	trait.BoonEditHeirloomExtra = nil
	game.TraitUIAdd(trait)
end

-- IsShownInHUD says yes to anything with uses left, which every Keepsake has.
function heirloom_hides_from_hud(trait)
	if not trait then return false end
	if trait.BoonEditHeirloomExtra then return true end
	return mod.HeirloomIncoming ~= nil and trait.Name == mod.HeirloomIncoming
end

function heirloom_hold_keepsake(trait)
	if trait.UsesAsEncounters and trait.RemainingUses then
		trait.HoldRemainingRooms = HEIRLOOM_HOLD_ENCOUNTERS
	end
end

-- Runs every room, so a later swap is covered. The worn one keeps its spot, the rest are demoted.
function cherished_heirloom_place_keepsakes()
	if not cherished_heirloom_active() then return end

	local equipped = game.GameState.LastAwardTrait
	for _, trait in ipairs(game.CurrentRun.Hero.Traits or {}) do
		if game.GetKeepsakeData(trait.Name) then
			heirloom_hold_keepsake(trait)
			if trait.Name ~= equipped and trait.ActiveSlotOffsetIndex ~= nil then
				heirloom_demote_keepsake(trait)
			end
		end
	end
end

function mod.CherishedHeirloomAcquire(args, traitData)
	game.AttemptAdvanceKeepsake(args, traitData)

	cherished_heirloom_place_keepsakes()

	if not mod.tuning.CherishedHeirloom.ExtraKeepsake then return end
	mod.HeirloomExtraPending = true
	game.thread(cherished_heirloom_open_rack)
end

-- No source on purpose: the close animates screen.Source into a closed rack.
function cherished_heirloom_open_rack()
	game.wait(HEIRLOOM_MENU_DELAY)
	if not cherished_heirloom_extra_pending() then return end
	game.OpenKeepsakeRackScreen(nil)
end
