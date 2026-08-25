---@meta _
---@diagnostic disable: lowercase-global


-- Extra Dose names every Attack weapon by hand and sets two weapon properties on them: the chance
-- of an extra projectile wave, and the delay before it lands. The Special is added to both lists,
-- so a second dose can come off a Flourish as readily as a strike.

local EXTRA_DOSE_TRAIT = 'DoubleStrikeChanceBoon'

local EXTRA_DOSE_PROPERTIES = {
	AdditionalProjectileWaveChance = true,
	ProjectileWaveInterval = true,
}


once('ExtraDoseCoversSpecial', function()
	if not config.BoonChanges.ExtraDose.Enabled then return end

	-- the entries carry ExcludeLinked, so nothing is filled in for us: a Special's own follow-ups
	-- (WeaponAxeSpecialSwing, WeaponSkullImpulse) have to be named alongside it
	local specials = game.AddLinkedWeapons(game.WeaponSets.HeroSecondaryWeapons)

	for _, change in ipairs(game.TraitData[EXTRA_DOSE_TRAIT].PropertyChanges or {}) do
		if change.WeaponNames and EXTRA_DOSE_PROPERTIES[change.WeaponProperty] then
			local named = game.ToLookup(change.WeaponNames)

			for _, weaponName in ipairs(specials) do
				if not named[weaponName] then
					table.insert(change.WeaponNames, weaponName)
				end
			end
		end
	end
end)
