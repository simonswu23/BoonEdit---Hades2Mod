local config = {
  version = 1;
  enabled = true;

  -- Every boon change toggles independently here; the numbers behind each live in `mod.tuning`.
  -- Chalk turns this into an editable .cfg in ReturnOfModding/config/.
  BoonChanges = {

    -- Rousing Reception (Hera) also inflicts Hitch on the foes it damages.
    RousingReceptionCastCurse = {
      Enabled = true;
    };

    -- Rousing Reception also makes your Cast ring last half again as long.
    RousingReceptionCastDuration = {
      Enabled = true;
    };

    -- Rousing Reception is only offered if you have Engagement Ring, rather than any Cast boon.
    RousingReceptionRequirements = {
      Enabled = true;
    };

    -- Anvil Ring inflicts Glow on hit, for 10 less base damage. Smithy Rush fires the same strike at
    -- half damage on starting and stopping a Dash, and no longer counts as a blast boon.
    AnvilGlowAndDash = {
      Enabled = true;
    };

    -- Molten Touch (Hephaestus) deals its bonus damage to foes with Glow as well as Armor, at half.
    MoltenTouchGlow = {
      Enabled = true;
    };

    -- Local Climate buffs regular Cast damage.
    LocalClimateCoversCastBoons = {
      Enabled = true;
    };

    -- Arterial Spray (Poseidon x Ares): the second splash wave always lands, at reduced power.
    ArterialSprayAlwaysDouble = {
      Enabled = true;
    };

    -- Killer Current (Poseidon x Zeus): damaging a Froth-afflicted foe may call a bolt down on it,
    -- instead of amplifying lightning against it.
    KillerCurrentBolt = {
      Enabled = true;
    };

    -- Sun Worshiper (Apollo x Hera): after the first foe is raised, later slain foes may rise too.
    SunWorshiperRepeat = {
      Enabled = true;
    };

    -- Ionic Gain (Zeus) also restores Magick while you stand near the drop it spawns. The rate rises
    -- with rarity, on the same ladder The Unseen uses.
    IonicGainProximity = {
      Enabled = true;
    };

    -- Removed: it put your summons on the enemy team, so anything aimed there cursed your own side.
    -- The key is kept so nothing reading it breaks; there is no code behind it.
    SunWorshiperHitch = {
      Enabled = false;
    };

    -- Fire Away (Hestia legendary) becomes "Burning Meteor": fireballs are half again as large and
    -- as strong, and inflict Scorch equal to the damage they deal.
    BurningMeteor = {
      Enabled = true;
    };

    -- Stabbing Rush (Ares) keeps dropping blades for as long as you sprint.
    StabbingRushDuration = {
      Enabled = true;
    };

    -- Shocking Loss (Zeus legendary) hits Guardians for a large amount instead of passing over them.
    ShockingLossGuardians = {
      Enabled = true;
    };

    -- Unseen Ire (Hades) turns invisible again every 30 seconds rather than every 40.
    UnseenIreCooldown = {
      Enabled = true;
    };

    -- Chain Reaction (Hestia x Hephaestus): instead of blasts striking twice, anything that
    -- recharges over time may skip its recharge outright.
    ChainReactionCooldownSkip = {
      Enabled = true;
    };

    -- Fire Away's parked effect lands its Scorch for 999 rather than 400.
    FireAwayScorch = {
      Enabled = true;
    };

    -- All Together (Hera legendary): grants 2 of each element on pickup instead of 1.
    AllTogetherDoubleElements = {
      Enabled = true;
    };

    -- Ripple Effect (Poseidon x Hera) may double the extra effect of any boon that surcharges your
    -- Omega Moves, rather than only its own two projectiles.
    RippleEffectOmegaBoons = {
      Enabled = true;
    };

    -- Hard Target (Hermes) becomes "Post Haste": speeds up anything that recharges, instead of
    -- slowing enemy shots.
    HardTargetBecomesPostHaste = {
      Enabled = true;
    };

    -- Seismic Servo (Poseidon x Hephaestus) becomes "Seismic Hammer": Volcanic Strike and Flourish
    -- blasts erupt your Cast into an Omega.
    SeismicHammer = {
      Enabled = true;
    };

    -- Winter Harvest (Demeter legendary) executes from 15% rather than 10%, and against a boss
    -- measures that against the whole fight. Prometheus is no longer exempt.
    WinterHarvestBosses = {
      Enabled = true;
    };

    -- Off: this healing moved back to MoreDuos' Boiling Blood. On alongside it, you heal twice.
    CarnalPleasureHealing = {
      Enabled = false;
    };

    -- Carnal Pleasure no longer throws a Heartthrob on Plasma pickup. Instead every Heartthrob has
    -- twice the blast radius and +50% damage, rising to +80% with a full stack of Plasma.
    CarnalPleasurePlasmaBursts = {
      Enabled = true;
    };

    -- Hearty Appetite (Aphrodite x Demeter) also restores your Life to full when you take it, and
    -- makes everything that heals you tonight heal for half again as much.
    HeartyAppetite = {
      Enabled = true;
    };

    -- Ecstatic Obsession (Hera x Aphrodite) becomes "Obsessive Devotion": the Weak you inflict may
    -- come out as Charm, foes that cannot be Charmed are interrupted, and you deal more damage for
    -- every character fighting for you.
    ObsessiveDevotion = {
      Enabled = true;
    };

    -- Natural Selection (Demeter x Poseidon) drops triple Poms on pickup and every few encounters,
    -- instead of spreading levels over your leftmost column.
    NaturalSelectionPoms = {
      Enabled = true;
    };

    -- Cherished Heirloom (Demeter x Hera) keeps its rank bonus, stops Keepsakes running out for the
    -- night, and lets you wear a second one.
    CherishedHeirloom = {
      Enabled = true;
    };

    -- Premium Service (Hephaestus legendary) keeps its Aspect rank bump, raises every hammer upgrade
    -- to Legendary, and drops a reworked Anvil of Fates: give up 1 of 3, then pick from 3, twice.
    PremiumServiceHammers = {
      Enabled = true;
    };

    -- Glamour Gain (Aphrodite) pulses once every Weak duration, inflicting Weak on everything around
    -- you and restoring Magick per foe caught.
    GlamourGainPulse = {
      Enabled = true;
    };

    -- Tranquil Gain (Demeter) restores Magick while you hold an Omega Move, not for standing still.
    TranquilGainChannel = {
      Enabled = true;
    };

    -- Love Handles (Aphrodite x Hephaestus) becomes "Smoldering Forge": a 20% chance to throw a
    -- Heartthrob whenever you damage a Glowing foe. Also raises the shared Heartthrob cap from 6 to 12.
    SmolderingForge = {
      Enabled = true;
    };

    -- Breaker Rush (Poseidon) gains Tidal Ring's splash on starting and stopping a Dash, knocking
    -- foes away and inflicting Froth.
    BreakerRushWaves = {
      Enabled = true;
    };

    -- Breaker Rush counts as a Froth boon, so it can earn Steam and Killer Current. King Tide also
    -- regroups, and Hydraulic Might and Flood Gain no longer count towards it.
    PoseidonFrothRequirements = {
      Enabled = true;
    };

    -- Beach Ball (Apollo x Poseidon) hits for 400 when the globe goes off, rather than 300.
    BeachBallDamage = {
      Enabled = true;
    };

    -- Beach Ball counts as one of your Splash boons, so it can satisfy Slippery Slope and King Tide.
    BeachBallCountsAsSplash = {
      Enabled = true;
    };

    -- Cryo Pounder (Demeter x Hephaestus): its bonus damage against Frozen foes covers hammer
    -- strikes as well, not only volcanic blasts.
    CryoPounderHammers = {
      Enabled = true;
    };

    -- Paid Dues (Hermes legendary) becomes "Second Wind": two Casts down at once, and a second Dash
    -- before the recharge. Hermes' legendary chance rises from 1% to 10%, and his keepsake waives
    -- its requirements and adds a further 10% chance of being offered.
    SecondWind = {
      Enabled = true;
    };

    -- Hostile Environment (Ares x Demeter) makes your regular Cast follow as well.
    HostileEnvironmentCastFollows = {
      Enabled = true;
    };

    -- Off: Steam counting as a hit for Froth never happened in play, and only put the claim in
    -- Steam's tooltip. The Font cooldown halving is separate and unaffected.
    SteamProcsFroth = {
      Enabled = false;
    };

    -- Off: Scalding Vapor's Steam counts as a Froth proc, so it can feed Poseidon's Font.
    SteamCountsAsFrothProc = {
      Enabled = false;
    };

    -- Off: Steam consumes the Froth that fed it again, and stacks, both the way the game means them to.
    ScaldingVaporKeepsFroth = {
      Enabled = false;
    };

    -- Air Quality (Elemental legendary) floors your base damage rather than the finished hit, so
    -- multipliers, Crit and Double Damage all still apply on top of the limit.
    AirQualityAdditiveFloor = {
      Enabled = true;
    };

    -- Cardio Gain (Hestia) also restores Magick on Sprint, not just on hit.
    CardioGainSprintMana = {
      Enabled = true;
    };

    -- Profuse Bleeding (Ares): a Rend-afflicted foe taking damage may spill a Blood Drop
    -- (10/15/20/25% by rarity), instead of a falling blade.
    ProfuseBleedingBloodSpill = {
      Enabled = true;
    };

    -- Profuse Bleeding is offered for Vicious Strike or Vicious Flourish alone, and in return counts
    -- as a Plasma boon itself.
    ProfuseBleedingRequirements = {
      Enabled = true;
    };

    -- Thermal Dynamics (Hestia x Zeus): every bolt Zeus throws inflicts Scorch, not only Blitz, for
    -- 60% of the damage dealt rather than a flat count.
    ThermalDynamicsAllLightning = {
      Enabled = true;
    };

    -- Harm for the Afflicted (Medea) hits for every new curse landing on a foe. Its 0.3 second gap
    -- is counted per foe and per curse, so cursing a crowd pays out for each.
    HarmForTheAfflictedEveryStatus = {
      Enabled = true;
    };

    -- Brave Face (Hephaestus x Hera) resists half of every hit rather than a third, at 5 Magick a
    -- point instead of 10.
    BraveFace = {
      Enabled = true;
    };

    -- Glorious Disaster (Apollo x Zeus) can also be earned from Lucid Gain or Super Nova.
    GloriousDisasterRequirements = {
      Enabled = true;
    };

    -- Glorious Disaster also fires when the Aspect of Charon's axe detonates your Cast, which
    -- normally skips it entirely.
    GloriousDisasterAxe = {
      Enabled = true;
    };

    -- Glorious Disaster no longer needs the extra Magick channelled: every Omega Cast is one.
    GloriousDisasterAlwaysSupercharged = {
      Enabled = true;
    };

    -- Adds "Pandemonium", a new Legendary blessing from Chaos: every god may turn up, no boon
    -- requires another first, core boons stop taking each other's slots, and doors offer blessings
    -- more often. Offered only once Chaos has blessed you; his keepsake adds a further 10% chance.
    Pandemonium = {
      Enabled = true;
    };

  };

  -- Testing aids, read on every room load: a name grants that boon once and is then left alone for
  -- the night; removing a name takes it back. Kept between sessions.
  Debug = {

    -- Trait names, separated by commas, semicolons or spaces. See TRAIT_NAMES.md.
    GrantTraits = '';

    -- Rarity for anything granted above: Common, Rare, Epic or Heroic. Changing it re-grants.
    GrantRarity = 'Common';

    -- Pom level for anything granted above: 1 is the base boon, 2 is one Pom, and so on. Changing
    -- it re-grants.
    GrantPomLevel = 1;
  };
}

return config
