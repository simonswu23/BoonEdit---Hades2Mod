---@meta _
---@diagnostic disable: lowercase-global

-- Paid Dues (Hermes legendary) becomes "Second Wind": two Casts down at once, and a second Dash
-- before the recharge.
once('SecondWind', function()
	if config.BoonChanges.SecondWind.Enabled then
		local secondWind = game.TraitData.TimeStopLastStandBoon

		secondWind.MoneyShieldData = nil

		-- All the Cast variants, since only one is live at a time. WeaponCastArm is left out: it arms
		-- a Cast already down.
		secondWind.PropertyChanges = {}
		for _, weaponName in ipairs({
			'WeaponCast',                -- the plain Cast
			'WeaponAnywhereCast',        -- Lightning Lance
			'WeaponCastLob',             -- Tipsy Shot
			'WeaponCastProjectile',      -- Glowing Coal
			'WeaponCastProjectileHades', -- Howling Soul
		}) do
			table.insert(secondWind.PropertyChanges, {
				WeaponName = weaponName,
				WeaponProperty = 'ActiveProjectileCap',
				ChangeValue = mod.tuning.SecondWind.ExtraCasts,
				ChangeType = 'Add',
			})
		end

		-- ClipSize is the Dash's charge count. ExcludeLinked keeps it off WeaponSprint.
		table.insert(secondWind.PropertyChanges, {
			WeaponName = 'WeaponBlink',
			WeaponProperty = 'ClipSize',
			ChangeValue = mod.tuning.SecondWind.ExtraDashes,
			ChangeType = 'Add',
			ExcludeLinked = true,
		})

		table.insert(secondWind.PropertyChanges, {
			WeaponName = 'WeaponBlink',
			WeaponProperty = 'ClipRegenInterval',
			ChangeValue = mod.tuning.SecondWind.DashRechargeMultiplier,
			ChangeType = 'Multiply',
			ExcludeLinked = true,
		})

		secondWind.FlavorText = 'BoonEditSecondWindFlavorText'
		secondWind.StatLines = {}
		secondWind.ExtractValues = {}

		-- Hermes is the only god with a rarity table of his own, and it puts his legendary at 1%
		game.HeroData.HermesData.RarityChances.Legendary = game.HeroData.BoonData.RarityChances.Legendary
	end

	modutil.mod.Path.Wrap("DemeterCastBlast", function(base, weaponData, traitArgs, triggerArgs)
		second_wind_extend_nova(traitArgs)
		return base(weaponData, traitArgs, triggerArgs)
	end)
end)


-- Arctic Gale caps its Cast on its own MaxProjectiles rather than the weapon property.
function second_wind_extend_nova(traitArgs)
	if not config.BoonChanges.SecondWind.Enabled then return end
	if not traitArgs then return end
	if not game.CurrentRun or not game.CurrentRun.Hero then return end
	if not game.HeroHasTrait('TimeStopLastStandBoon') then return end

	traitArgs.MaxProjectiles = (traitArgs.MaxProjectiles or 1) + mod.tuning.SecondWind.ExtraCasts
end


-- Hermes' own keepsake opens Second Wind up. `TimedBuffKeepsake` is the trait it grants.
function second_wind_keepsake()
	return config.BoonChanges.SecondWind.Enabled and game.HeroHasTrait('TimedBuffKeepsake')
end


-- **Two separate gates, so both have to be answered.**
--
-- `HasTraitRequirements` is where `TraitRequirements` is enforced, and Second Wind's is a long
-- `OneOf` of Hermes boons -- answering it met is the whole of waiving them. Cleared this way rather
-- than by deleting the entry, because `GetPriorityDependentTraits` needs the entry to exist before
-- it will read the `PriorityChance` below.
--
-- That chance is vanilla's own lever for "offer this more often" (`UpgradeChoiceLogic.lua:753`): a
-- trait carrying one is rolled for and forced into the options ahead of the ordinary draw. It is
-- written unconditionally and gated at read time, since `TraitRequirements` outlives the run while
-- the keepsake does not.
once('SecondWindKeepsake', function()
	if not config.BoonChanges.SecondWind.Enabled then return end

	local requirements = game.TraitRequirements.TimeStopLastStandBoon
	if requirements then
		requirements.PriorityChance = mod.tuning.SecondWind.KeepsakeOfferChance
	end

	modutil.mod.Path.Wrap("HasTraitRequirements", function(base, traitName)
		if traitName == 'TimeStopLastStandBoon' and second_wind_keepsake() then return true end
		return base(traitName)
	end)

	-- Without this the PriorityChance would apply whether or not the keepsake is worn.
	modutil.mod.Path.Wrap("GetPriorityDependentTraits", function(base, lootData)
		local linked = base(lootData)
		if second_wind_keepsake() then return linked end

		for index = #(linked or {}), 1, -1 do
			if linked[index].TraitName == 'TimeStopLastStandBoon' then
				table.remove(linked, index)
			end
		end
		return linked
	end)
end)
