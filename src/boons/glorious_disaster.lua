---@meta _
---@diagnostic disable: lowercase-global

-- Glorious Disaster (Apollo x Zeus) also fires from the Aspect of Charon's axe.
--
-- The second stage is decided when the Cast is *created*: holding the charge sets
-- `SuperchargeCast`, which records the projectile in `ValidSuperchargeCastIds`, and only those pay
-- out. Charon's axe detonates a Cast already on the ground, so it was laid unmarked and stayed so.
--
-- So the projectile is marked as it is detonated instead. `CheckAxeCastArm` calls every held trait's
-- `OnEarlyCastDetonation` before it detonates (`PowersLogic.lua:5157`), which is vanilla's own
-- extension point for exactly this and means nothing has to be wrapped.
once('GloriousDisasterAxe', function()
	if not config.BoonChanges.GloriousDisasterAxe.Enabled then return end

	game.TraitData.ApolloSecondStageCastBoon.OnEarlyCastDetonation = {
		FunctionName = _PLUGIN.guid .. '.GloriousDisasterEarlyDetonation',
	}
end)


-- **The second stage no longer has to be paid for.** Channelling the extra charge stopped working --
-- the same ground the Charon axe and Land Mine trip over, all three of them reaching for the
-- supercharge from outside the charge itself -- so rather than repair the condition it is stepped
-- over: every Omega Cast is a Glorious Disaster, and the boon's charge stage becomes flavour.
--
-- `CheckArmedApolloCast` is the one place a Cast is marked (`PowersLogic.lua:5545`), and the branch
-- there already asks for both traits. Setting the flag it reads is all this does -- vanilla's own
-- line still decides, and still clears the flag behind itself.
--
-- The rung itself is then taken off the weapon, since holding for something you already have is a
-- trap rather than a choice.
-- Nil-safe, for the reason spelled out in `ionic_gain.lua`: Chalk keeps the .cfg it already wrote,
-- so a key added after that file exists is absent until it regenerates -- and indexing `.Enabled`
-- off nil takes the whole mod down at load rather than just switching one boon off.
function glorious_disaster_supercharged()
	local toggle = config.BoonChanges.GloriousDisasterAlwaysSupercharged
	return toggle ~= nil and toggle.Enabled == true
end


once('GloriousDisasterAlwaysSupercharged', function()
	if not glorious_disaster_supercharged() then return end

	modutil.mod.Path.Wrap("CheckArmedApolloCast", function(base, triggerArgs, functionArgs)
		if game.HeroHasTrait('ApolloSecondStageCastBoon') and game.HeroHasTrait('ApolloExCastBoon') then
			game.SessionMapState.SuperchargeCast = true
		end
		return base(triggerArgs, functionArgs)
	end)

	-- With the condition gone the rung is not just redundant, it is a trap: 45 Magick for something
	-- you now get for nothing. It is added in two separate places and both have to go.
	local disaster = game.TraitData.ApolloSecondStageCastBoon

	-- One: the extra stage the boon writes onto the Cast arm itself. Everything past the first is
	-- dropped rather than the second by name, so the arm is left with the one rung it started with.
	local arm = disaster.WeaponDataOverride and disaster.WeaponDataOverride.WeaponCastArm
	if arm and arm.ChargeWeaponStages then
		for index = #arm.ChargeWeaponStages, 2, -1 do
			table.remove(arm.ChargeWeaponStages, index)
		end
	end

	-- Two: the rung it adds to every other Cast weapon. This is the one carrying `SuperCharge`, the
	-- flag the wrap above now sets by itself -- so removing it costs nothing.
	disaster.ChargeStageModifiers = nil
end)

-- The Cast is not made longer or wider. That was tried, as two `PropertyChanges` multiplying
-- `WeaponCast`'s `Fuse` and `BlastRadius`, and it broke the Omega Cast outright -- Magick spent,
-- nothing produced, not even vanilla's own effect. Neither is a property `WeaponCast` carries, and
-- writing unknown ones onto a weapon corrupts it. The boon is the condition-skip and the stronger
-- bolts; nothing here claims otherwise.


---@diagnostic disable-next-line: unused-local
function mod.GloriousDisasterEarlyDetonation(projectileId, _args)
	if not config.BoonChanges.GloriousDisasterAxe.Enabled then return end

	-- the duo pays out through Nova Burst, so without it there is nothing to mark the Cast for
	if not game.HeroHasTrait('ApolloExCastBoon') then return end

	local marked = game.SessionMapState and game.SessionMapState.ValidSuperchargeCastIds
	if marked and projectileId then
		marked[projectileId] = true
	end
end
