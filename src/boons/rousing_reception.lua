---@meta _
---@diagnostic disable: lowercase-global

-- Rousing Reception (Hera) additionally curses the foes it damages. With HitchOnly it is always
-- Hitch; otherwise it is the status curse belonging to whichever Cast you are running, and Casts
-- that deliver a strike of their own take that path instead.
once('RousingReceptionCastCurse', function()
	local summonProjectile = game.ProjectileData.HeraCastSummonProjectile
	summonProjectile.OnHitFunctionNames = summonProjectile.OnHitFunctionNames or {}
	table.insert(summonProjectile.OnHitFunctionNames, _PLUGIN.guid .. '.RousingReceptionCurse')
end)


-- **Your Cast lasts half again as long.** `WeaponCast` is the one Cast every weapon and aspect uses
-- sits in `WeaponPackages` alongside `WeaponBlink`, no aspect trait touches it, and Winner's Circle
-- is a plain Hermes boon that shortens it by writing to exactly these two properties
-- (`TraitData_Hermes.lua:329`). So this is Winner's Circle inverted, and it reaches the ring
-- whatever you are holding.
--
-- Winner's Circle also carries `CastDurationMultiplier` and a `ChargeTime` change, deliberately not
-- copied: that field is a time *scale* pacing the tick rate, so mirroring the multiplier onto it
-- would stretch the ring out, thin its ticks and slow the channel. Only the ring's own fuse is
-- lengthened.
--
-- A flat multiplier rather than `SourceIsMultiplier`: this trait's rarity Multiplier already scales
-- its summon damage, and folding duration into it would reach 4x at Heroic.
once('RousingReceptionCastDuration', function()
	if not config.BoonChanges.RousingReceptionCastDuration.Enabled then return end

	local reception = game.TraitData.SpawnCastDamageBoon
	local multiplier = mod.tuning.RousingReception.CastDurationMultiplier

	reception.PropertyChanges = reception.PropertyChanges or {}
	for _, property in ipairs({ 'FuseStart', 'Fuse' }) do
		table.insert(reception.PropertyChanges, {
			WeaponName = 'WeaponCast',
			ProjectileProperty = property,
			BaseValue = multiplier,
			ChangeType = 'Multiply',
		})
	end
end)


-- Map of Gods to Status Curses
cast_curses = {
	-- no Apply: DamageShareEffect is routed through apply_hitch in apply_cast_curse
	HeraCastBoon       = { EffectName = 'DamageShareEffect' };
	AphroditeCastBoon  = { EffectName = 'WeakEffect' };
	ApolloCastBoon     = { EffectName = 'BlindEffect' };
	DemeterCastBoon    = { EffectName = 'ChillEffect', Apply = 'ApplyRoot' };
	PoseidonCastBoon   = { EffectName = 'AmplifyKnockbackEffect' };
	-- stacks of Scorch equal to the entry damage
	HestiaCastBoon     = { EffectName = 'BurnEffect', Apply = 'ApplyBurn', StacksFromDamage = true };

	-- Blitz at its default damage value
	ZeusCastBoon       = { EffectName = 'DamageEchoEffect', Overrides = { Modifier = 1 } };
	HephaestusCastBoon = { EffectName = 'DelayedKnockbackEffect' };
	-- adds 50 damage to the entry damage and applies Wounds
	AresCastBoon       = {
		EffectName = 'AresStatus'; BonusDamageOnInflict = true;
		DamageTextStartColor = 'AresDamageLight';
		DamageTextColor = 'AresDamage';
		HitFx = 'AresMissingDamageFx';
		HitSfx = '/SFX/AresRendApply';
	};
}

-- Casts that deliver a strike rather than a status curse.
cast_strikes = {
	ZeusCastBoon       = { ArgsField = 'OnWeaponFiredFunctions',    Style = 'bolt' };
	HephaestusCastBoon = { ArgsField = 'OnWeaponFiredFunctions',    Style = 'projectile' };
	AresCastBoon       = { ArgsField = 'OnEffectApplyFunction',     Style = 'projectile' };
	HestiaCastBoon     = { ArgsField = 'OnCastEffectApplyFunction', Style = 'burn' };
}

function fire_cast_strike(victim, traitName, strike, triggerArgs)
	local trait = game.GetHeroTrait(traitName)
	local entry = trait and trait[strike.ArgsField]
	local args = entry and entry.FunctionArgs
	if not args then return end

	if strike.Style == 'bolt' then
		game.thread(game.CreateZeusBolt, {
			SourceId = victim.ObjectId,
			TargetId = victim.ObjectId,
			Range = args.Range,
			WeaponName = 'WeaponCast',
			ProjectileName = args.ProjectileName,
			DamageMultiplier = args.DamageMultiplier,
			InitialDelay = 0,
			Delay = 0.1,
			Count = 1,
		})

	elseif strike.Style == 'projectile' then
		game.CreateProjectileFromUnit({
			Name = args.ProjectileName,
			Id = game.CurrentRun.Hero.ObjectId,
			DestinationId = victim.ObjectId,
			DamageMultiplier = args.DamageMultiplier,
			FireFromTarget = true,
		})

	elseif strike.Style == 'burn' then
		-- same stack count the Cast itself applies, Cast damage multipliers included
		local multiplier = game.CalculateDamageMultipliers(
			game.CurrentRun.Hero, victim, game.WeaponData.WeaponCast,
			{ SourceWeapon = 'WeaponCast', ExplicitMultipliersOnly = true })
		game.ApplyBurn(victim, {
			EffectName = args.EffectName,
			NumStacks = game.round(args.NumStacks * multiplier),
		}, triggerArgs)
	end
end

function cast_curse_stacks(triggerArgs)
	local damage = (triggerArgs and triggerArgs.DamageAmount) or 0
	return math.max(1, math.floor(damage * mod.tuning.RousingReception.DamageScaledCurseMultiplier))
end

function apply_cast_curse(victim, curse, triggerArgs)
	-- Wounds has no per-hit damage, so fold its inflict damage into this hit.
	if curse.BonusDamageOnInflict and triggerArgs then
		local bonus = game.EffectData[curse.EffectName].BonusBaseDamageOnInflict or 0
		triggerArgs.DamageAmount = (triggerArgs.DamageAmount or 0) + bonus
	end

	if triggerArgs then
		if curse.DamageTextStartColor then
			triggerArgs.OverrideDamageTextStartColor = game.Color[curse.DamageTextStartColor]
		end
		if curse.DamageTextColor then
			triggerArgs.OverrideDamageTextColor = game.Color[curse.DamageTextColor]
		end
	end

	-- what Wounds' own presentation plays, minus its hit-stop
	if curse.HitFx then
		if curse.HitSfx then
			game.PlaySound({ Name = curse.HitSfx, Id = victim.ObjectId, ManagerCap = 46 })
		end
		game.CreateAnimation({
			Name = curse.HitFx,
			DestinationId = victim.ObjectId,
			Angle = triggerArgs and triggerArgs.ImpactAngle,
		})
	end

	-- all Hitch goes through one path, so a summon is never skipped
	if curse.EffectName == 'DamageShareEffect' then
		apply_hitch(victim)
		return
	end

	if curse.Apply then
		local args = { EffectName = curse.EffectName }
		if curse.StacksFromDamage then
			args.NumStacks = cast_curse_stacks(triggerArgs)
		end
		game[curse.Apply](victim, args, triggerArgs)
		return
	end

	-- merged into a fresh table, so the shared EffectData entry is left alone
	local dataProperties = game.EffectData[curse.EffectName].EffectData
	if curse.Overrides then
		dataProperties = game.MergeAllTables({ dataProperties, curse.Overrides })
	end

	game.ApplyEffect({
		DestinationId = victim.ObjectId,
		Id = game.CurrentRun.Hero.ObjectId,
		EffectName = curse.EffectName,
		DataProperties = dataProperties,
	})
end

-- Only one Cast boon can be held, so this matches at most once.
---@diagnostic disable-next-line: unused-local
function mod.RousingReceptionCurse(victim, _victimId, triggerArgs)
	if not config.BoonChanges.RousingReceptionCastCurse.Enabled then return end

	if mod.tuning.RousingReception.HitchOnly then
		apply_hitch(victim)
		return
	end

	if mod.tuning.RousingReception.UseCastStrikes then
		for traitName, strike in pairs(cast_strikes) do
			if game.HeroHasTrait(traitName) then
				fire_cast_strike(victim, traitName, strike, triggerArgs)
				return
			end
		end
	end

	for traitName, curse in pairs(cast_curses) do
		if game.HeroHasTrait(traitName) then
			apply_cast_curse(victim, curse, triggerArgs)
		end
	end
end
