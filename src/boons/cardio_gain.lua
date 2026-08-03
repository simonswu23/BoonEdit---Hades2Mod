---@meta _
---@diagnostic disable: lowercase-global

-- Cardio Gain (Hestia) also restores Magick on Sprint, not just on hit.

mod.tuning.CardioGain = {
	-- a quarter of the old flat 3, banked as a fraction since Magick pays out in whole numbers
	SprintManaGain = 0.75,
}

once('CardioGainSprintMana', function()
	if not config.BoonChanges.CardioGainSprintMana.Enabled then return end

	local cardioGain = game.TraitData.HestiaManaBoon

	cardioGain.OnSprintAction = {
		FunctionName = _PLUGIN.guid .. '.CardioGainSprintMana',
		RunOnce = true,
		Args = {
			BoonEditManaGain = { BaseValue = mod.tuning.CardioGain.SprintManaGain },
			ReportValues = { BoonEditReportedManaGain = 'BoonEditManaGain' },
		},
	}

	table.insert(cardioGain.StatLines, 'BoonEditCardioGainSprintStatDisplay')
	table.insert(cardioGain.ExtractValues, {
		Key = 'BoonEditReportedManaGain',
		ExtractAs = 'TooltipSprintManaRecovery',
		DecimalPlaces = 1,
	})
end)


-- The per-dash gain is under 1 Magick, so fractions are banked until they cross a whole number.
local cardio_gain_sprint_carry = 0

---@diagnostic disable-next-line: unused-local
function mod.CardioGainSprintMana(args, triggerArgs)
	if not config.BoonChanges.CardioGainSprintMana.Enabled then return end

	cardio_gain_sprint_carry = cardio_gain_sprint_carry + args.BoonEditManaGain
	local whole = math.floor(cardio_gain_sprint_carry)
	if whole > 0 then
		cardio_gain_sprint_carry = cardio_gain_sprint_carry - whole
		game.ManaDelta(whole)
	end

	-- a louder copy of Melinoe's own ambient ember footsteps, so the gain reads
	local hero = game.CurrentRun and game.CurrentRun.Hero
	if hero then
		game.CreateAnimation({ Name = 'FireFootstepL', DestinationId = hero.ObjectId, OffsetX = -20 })
		game.CreateAnimation({ Name = 'FireFootstepR', DestinationId = hero.ObjectId, OffsetX = 20 })
	end
end


if config.BoonChanges.CardioGainSprintMana.Enabled then
	boon_text({
		Traits = {
			HestiaManaBoon = {
				Description = 'Whenever your {$Keywords.Attack} or {$Keywords.Special} deal damage, or you {$Keywords.Dash}, restore {!Icons.Mana}.',
			},
		},
		StatLines = {
			BoonEditCardioGainSprintStatDisplay = { Name = 'Magick on Sprint:', Index = 2 },
		},
	})
end
