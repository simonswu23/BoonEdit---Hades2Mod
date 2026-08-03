---@meta _
---@diagnostic disable: lowercase-global

-- Seismic Servo (Hephaestus x Poseidon) becomes "Seismic Hammer": Divine Haste covers its old
-- recharge effect, so instead Volcanic Strike and Volcanic Flourish blasts erupt your Cast into an
-- Omega Cast.

once('SeismicHammer', function()
	if not config.BoonChanges.SeismicHammer.Enabled then return end

	local hammer = game.TraitData.MassiveCastBoon

	hammer.OlympianRechargeMultiplier = nil
	hammer.StatLines = {}
	hammer.ExtractValues = {}

	hammer.OnProjectileCreationFunction = {
		ValidProjectiles = { 'MassiveSlamBlast' },
		Name = 'CheckAxeCastArm',
		Args = {
			BlastMultiplier = { BaseValue = 1.15, SourceIsMultiplier = true },
		},
	}
	hammer.OnProjectileCreationFunction.ValidProjectilesLookup =
		game.ToLookup(hammer.OnProjectileCreationFunction.ValidProjectiles)

	game.TraitRequirements.MassiveCastBoon = {
		OneFromEachSet = {
			{ 'HephaestusWeaponBoon', 'HephaestusSpecialBoon' },
			{ 'PoseidonExCastBoon' },
		},
	}
end)


if config.BoonChanges.SeismicHammer.Enabled then
	boon_text({
		Traits = {
			MassiveCastBoon = {
				DisplayName = 'Seismic Hammer',
				Description = 'Your blast effects from {#BoldFormatGraft}Hephaestus {#Prev}make your {$Keywords.Cast} erupt like your {$Keywords.CastEX}.',
			},
		},
	})
end
