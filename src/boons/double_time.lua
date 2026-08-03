---@meta _
---@diagnostic disable: lowercase-global

-- Paid Dues (Hermes legendary) becomes "Double Time": two Casts down at once, and a second Dash
-- before the recharge.

mod.tuning.DoubleTime = {
	ExtraCasts = 1,
	ExtraDashes = 1,
	DashRechargeMultiplier = 0.90,
}

once('DoubleTime', function()
	if config.BoonChanges.DoubleTime.Enabled then
		local doubleTime = game.TraitData.TimeStopLastStandBoon

		doubleTime.MoneyShieldData = nil

		-- All the Cast variants, since only one is live at a time. WeaponCastArm is left out: it arms
		-- a Cast already down.
		doubleTime.PropertyChanges = {}
		for _, weaponName in ipairs({
			'WeaponCast',                -- the plain Cast
			'WeaponAnywhereCast',        -- Lightning Lance
			'WeaponCastLob',             -- Tipsy Shot
			'WeaponCastProjectile',      -- Glowing Coal
			'WeaponCastProjectileHades', -- Howling Soul
		}) do
			table.insert(doubleTime.PropertyChanges, {
				WeaponName = weaponName,
				WeaponProperty = 'ActiveProjectileCap',
				ChangeValue = mod.tuning.DoubleTime.ExtraCasts,
				ChangeType = 'Add',
			})
		end

		-- ClipSize is the Dash's charge count. ExcludeLinked keeps it off WeaponSprint.
		table.insert(doubleTime.PropertyChanges, {
			WeaponName = 'WeaponBlink',
			WeaponProperty = 'ClipSize',
			ChangeValue = mod.tuning.DoubleTime.ExtraDashes,
			ChangeType = 'Add',
			ExcludeLinked = true,
		})

		table.insert(doubleTime.PropertyChanges, {
			WeaponName = 'WeaponBlink',
			WeaponProperty = 'ClipRegenInterval',
			ChangeValue = mod.tuning.DoubleTime.DashRechargeMultiplier,
			ChangeType = 'Multiply',
			ExcludeLinked = true,
		})

		doubleTime.FlavorText = 'BoonEditDoubleTimeFlavorText'
		doubleTime.StatLines = {}
		doubleTime.ExtractValues = {}

		-- Hermes is the only god with a rarity table of his own, and it puts his legendary at 1%
		game.HeroData.HermesData.RarityChances.Legendary = game.HeroData.BoonData.RarityChances.Legendary
	end

	modutil.mod.Path.Wrap("DemeterCastBlast", function(base, weaponData, traitArgs, triggerArgs)
		double_time_extend_nova(traitArgs)
		return base(weaponData, traitArgs, triggerArgs)
	end)
end)


-- Arctic Gale caps its Cast on its own MaxProjectiles rather than the weapon property.
function double_time_extend_nova(traitArgs)
	if not config.BoonChanges.DoubleTime.Enabled then return end
	if not traitArgs then return end
	if not game.CurrentRun or not game.CurrentRun.Hero then return end
	if not game.HeroHasTrait('TimeStopLastStandBoon') then return end

	traitArgs.MaxProjectiles = (traitArgs.MaxProjectiles or 1) + mod.tuning.DoubleTime.ExtraCasts
end


if config.BoonChanges.DoubleTime.Enabled then
	boon_text({
		Traits = {
			TimeStopLastStandBoon = {
				DisplayName = 'Double Time',
				Description = 'Gain an extra {$Keywords.Cast} and {$Keywords.Dash}.',
			},
		},
		-- Paid Dues' flavour was about its money shield, which Double Time no longer has.
		Flavor = {
			BoonEditDoubleTimeFlavorText = 'Not enough time? Try two!',
		},
	})
end
