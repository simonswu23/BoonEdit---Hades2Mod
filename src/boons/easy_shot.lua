---@meta _
---@diagnostic disable: lowercase-global


-- Easy Shot's piercing arrow, doubled: the rarity ladder (50/60/70/80) rides on top of the
-- multiplier, so doubling that doubles the printed figure at every rarity.
--
-- Done on the multiplier rather than on `ArtemisCastVolley`'s own damage, because that projectile is
-- not this boon's alone: Infested Cerberus fires it too (`EnemyData_InfestedCerberus.lua:182`).
--
-- And a Pom of Power can no longer be spent on it. Vanilla leaves it stackable, and the trait carries
-- no `AbsoluteStackValues`, so a Pom added one whole `BaseValue` -- a second arrow's worth of damage
-- for one level, which the doubling above would only have made worse. `BlockStacking` is the flag
-- vanilla itself uses to keep a boon out of the Pom pool (`TraitLogic.lua:712`).
once('EasyShotDamage', function()
	if not config.BoonChanges.EasyShot.Enabled then return end

	local easyShot = game.TraitData.OmegaCastVolleyBoon
	if not easyShot or not easyShot.OnEnemyDamagedAction then return end

	easyShot.BlockStacking = true

	local args = easyShot.OnEnemyDamagedAction.Args
	if not args or type(args.DamageMultiplier) ~= 'table' then return end

	args.DamageMultiplier.BaseValue = mod.tuning.EasyShot.DamageMultiplier
end)
