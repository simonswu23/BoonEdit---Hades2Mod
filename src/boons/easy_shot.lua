---@meta _
---@diagnostic disable: lowercase-global


once('EasyShotDamage', function()
	if not config.BoonChanges.EasyShot.Enabled then return end

	local easyShot = game.TraitData.OmegaCastVolleyBoon
	if not easyShot or not easyShot.OnEnemyDamagedAction then return end

	easyShot.BlockStacking = true

	local args = easyShot.OnEnemyDamagedAction.Args
	if not args or type(args.DamageMultiplier) ~= 'table' then return end

	args.DamageMultiplier.BaseValue = mod.tuning.EasyShot.DamageMultiplier
end)


once('EasyShotCrit', function()
	if not config.BoonChanges.EasyShot.Enabled then return end

	local easyShot = game.TraitData.OmegaCastVolleyBoon
	if not easyShot then return end

	easyShot.AddOutgoingCritModifiers = easyShot.AddOutgoingCritModifiers or {
		ValidProjectiles = { 'ArtemisCastVolley' },
		Chance = { BaseValue = mod.tuning.EasyShot.CritChance },
	}
end)
