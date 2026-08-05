---@meta _
---@diagnostic disable: lowercase-global

-- Carnal Pleasure (Aphrodite x Ares) keeps its vanilla Heartthrob roll and picks up the healing
-- that used to sit on MoreDuos' Boiling Blood: each Plasma collected restores a little health.
once('CarnalPleasureHealing', function()
	if not config.BoonChanges.CarnalPleasureHealing.Enabled then return end

	local carnal = game.TraitData.BloodManaBurstBoon

	carnal.BoonEditHealPerDrop = mod.tuning.CarnalPleasure.HealPerDrop

	-- Second stat line, not fourth: StatDisplayN counts only the ExtractValues entries that are
	-- auto-extracted, and vanilla's last two both carry SkipAutoExtract.
	table.insert(carnal.StatLines, 'BoonEditCarnalPleasureHealStatDisplay')
	table.insert(carnal.ExtractValues, {
		Key = 'BoonEditHealPerDrop',
		ExtractAs = 'Healing',
	})
end)


-- Rides the pickup itself, alongside vanilla's own per-drop Magick restore. The count is how many
-- drops the pickup was worth, which is what BloodDropUse itself counts.
function carnal_pleasure_heal(count)
	if not config.BoonChanges.CarnalPleasureHealing.Enabled then return end
	if not game.CurrentRun or not game.CurrentRun.Hero then return end
	if not game.HeroHasTrait('BloodManaBurstBoon') then return end

	local trait = game.GetHeroTrait('BloodManaBurstBoon')
	local amount = (count or 1) * ((trait and trait.BoonEditHealPerDrop) or mod.tuning.CarnalPleasure.HealPerDrop)
	if amount > 0 then
		game.Heal(game.CurrentRun.Hero, { HealAmount = amount, SourceName = 'BoonEditCarnalPleasure' })
	end
end
