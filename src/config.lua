local config = {
  version = 1;
  enabled = true;

  -- Every boon change toggles independently here; the numbers behind each live in `mod.tuning`,
  -- set by that boon's own file under `boons/`. Chalk turns this into an editable .cfg in
  -- ReturnOfModding/config/.
  BoonChanges = {

    -- Rousing Reception (Hera) also inflicts the status curse belonging to whichever Cast
    -- you are running.
    RousingReceptionCastCurse = {
      Enabled = true;
    };

    -- Anvil Ring inflicts Glow on hit, for 10 less base damage at every rarity. Smithy Rush fires
    -- the same strike at half damage on starting and stopping a Dash, also inflicting Glow, and no
    -- longer counts as a blast boon for offer requirements.
    AnvilGlowAndDash = {
      Enabled = true;
    };

    -- Local Climate buffs regular Cast damage
    LocalClimateCoversCastBoons = {
      Enabled = true;
    };

    -- Arterial Spray (Poseidon x Ares): the second splash wave always lands, at reduced power
    ArterialSprayAlwaysDouble = {
      Enabled = true;
    };

    -- Killer Current (Poseidon x Zeus): instead of amplifying lightning against Froth-afflicted
    -- foes, damaging one has a chance to call a bolt down on it.
    KillerCurrentBolt = {
      Enabled = true;
    };

    -- Sun Worshiper (Apollo x Hera): after the first foe is raised in an encounter, later slain
    -- foes have a chance to rise too.
    SunWorshiperRepeat = {
      Enabled = true;
    };

    -- Sun Worshiper's servants are Hitched for as long as they last, without needing Obsessive
    -- Devotion. They still count towards its damage bonus when you hold both.
    SunWorshiperHitch = {
      Enabled = true;
    };

    -- Fire Away (Hestia legendary) becomes "Burning Meteor": Hestia's fireballs are half again as
    -- large and as strong, and inflict Scorch equal to the damage they deal.
    BurningMeteor = {
      Enabled = true;
    };

    -- Stabbing Rush (Ares) keeps dropping blades for as long as you sprint, rather than a fixed
    -- three at the start of it.
    StabbingRushDuration = {
      Enabled = true;
    };

    -- Shocking Loss (Zeus legendary) no longer passes over Guardians. They take a large hit
    -- instead of being immune outright, and that hit scales with your damage modifiers.
    ShockingLossGuardians = {
      Enabled = true;
    };

    -- Unseen Ire (Hades) turns invisible again every 30 seconds rather than every 40.
    UnseenIreCooldown = {
      Enabled = true;
    };

    -- Chain Reaction (Hestia x Hephaestus) no longer makes blasts strike twice. Instead any
    -- boon effect that recharges over time -- the same ones Post Haste speeds up -- has a
    -- chance to skip that recharge outright and come back ready at once.
    ChainReactionCooldownSkip = {
      Enabled = true;
    };

    -- Fire Away's own effect is parked on mod.FireAwayEffect with no boon to sit on. This tunes
    -- that copy: its Scorch lands for 999 rather than 400.
    FireAwayScorch = {
      Enabled = true;
    };

    -- All Together (Hera legendary): grants 2 of each element on pickup instead of 1.
    AllTogetherDoubleElements = {
      Enabled = true;
    };

    -- Ripple Effect (Poseidon x Hera): chance to double the extra effect of any boon that charges
    -- your Omega Moves more Magick in exchange for one -- Ocean Swell, Fine Line, Controlled Burn,
    -- Cut Above, Explosive Intent -- rather than only its own two projectiles.
    RippleEffectOmegaBoons = {
      Enabled = true;
    };

    -- Hard Target (Hermes) becomes "Post Haste": instead of slowing enemy shots, it speeds up
    -- anything that recharges.
    HardTargetBecomesPostHaste = {
      Enabled = true;
    };

    -- Seismic Servo (Poseidon x Hephaestus) becomes "Seismic Hammer": Post Haste covers its old
    -- recharge effect, so instead Volcanic Strike and Flourish blasts erupt your Cast into an Omega.
    SeismicHammer = {
      Enabled = true;
    };

    -- Winter Harvest (Demeter legendary) executes from 15% rather than 10%, and against a boss
    -- measures that against the whole fight instead of the current health bar -- so an execute
    -- can land in an earlier phase, ending the fight there. Prometheus is no longer exempt.
    WinterHarvestBosses = {
      Enabled = true;
    };

    -- Carnal Pleasure (Aphrodite x Ares) stops creating Heartthrobs and instead makes yours hit
    -- harder, by more the more Plasma you hold this room.
    CarnalPleasureDamage = {
      Enabled = true;
    };

    -- Ecstatic Obsession (Hera x Aphrodite) becomes "Obsessive Devotion": Weak foes and your own
    -- summons are Hitched, and you deal more damage for each of them.
    ObsessiveDevotion = {
      Enabled = true;
    };

    -- Natural Selection (Demeter x Poseidon) drops a handful of triple Poms when you take it,
    -- then another every few encounters, instead of spreading levels over your leftmost column.
    NaturalSelectionPoms = {
      Enabled = true;
    };

    -- Cherished Heirloom (Demeter x Hera) keeps its rank bonus and gains two effects: Keepsakes
    -- stop running out for the night, and taking it lets you wear a second one.
    CherishedHeirloom = {
      Enabled = true;
    };

    -- Premium Service (Hephaestus legendary) keeps its Aspect rank bump, raises every hammer
    -- upgrade you hold to Legendary, and drops an Anvil of Fates. Also reworks the Anvil itself:
    -- give up one of 3 of your hammer upgrades, then choose new ones from 3 options, twice.
    PremiumServiceHammers = {
      Enabled = true;
    };

    -- Glamour Gain (Aphrodite) pulses once every Weak duration, inflicting Weak on everything
    -- around you and restoring Magick for each foe the pulse catches.
    GlamourGainPulse = {
      Enabled = true;
    };

    -- Tranquil Gain (Demeter) restores Magick while you hold the charge on an Omega Move, rather
    -- than for standing still.
    TranquilGainChannel = {
      Enabled = true;
    };

    -- Love Handles (Aphrodite x Hephaestus): heartthrobs come from hammer strikes landing --
    -- Anvil Ring's and Smithy Rush's -- rather than from volcanic blasts going off.
    LoveHandlesHammerStrikes = {
      Enabled = true;
    };

    -- Breaker Rush (Poseidon) gains Tidal Ring's splash when you start a Dash and again when you
    -- stop, knocking foes away and inflicting Froth.
    BreakerRushWaves = {
      Enabled = true;
    };

    -- Breaker Rush counts as a Froth boon alongside Tidal Ring and Slippery Slope, so it can earn
    -- Steam and Killer Current. King Tide also regroups: Geyser Spout shares a set with High Surf
    -- and Ocean Swell, the last set becomes the Froth boons, and Hydraulic Might and Flood Gain no
    -- longer count towards it.
    PoseidonFrothRequirements = {
      Enabled = true;
    };

    -- Cryo Pounder (Demeter x Hephaestus): the bonus damage it deals to Frozen foes now covers
    -- your hammer strikes as well, not only volcanic blasts.
    CryoPounderHammers = {
      Enabled = true;
    };

    -- Paid Dues (Hermes legendary) becomes "Double Time": two Casts down at once, and a second
    -- Dash before the recharge.
    -- Hermes' legendary chance is also raised from 1% to the 10% every other god uses.
    DoubleTime = {
      Enabled = true;
    };

    -- Hostile Environment (Ares x Demeter) makes your regular Cast follow as well
    HostileEnvironmentCastFollows = {
      Enabled = true;
    };

    -- Scalding Vapor's Steam counts as a Froth proc rather than being passed over, and while you
    -- hold it Poseidon's Font comes round twice as often.
    SteamProcsFroth = {
      Enabled = true;
    };

    -- Scalding Vapor (Hestia x Poseidon): Steam still never stacks, but no longer strips the
    -- Froth that fed it.
    ScaldingVaporKeepsFroth = {
      Enabled = true;
    };

    -- Air Quality (Elemental legendary): floors your base damage rather than the finished hit, so
    -- your multipliers, Crit and Double Damage all still apply on top of the limit.
    AirQualityAdditiveFloor = {
      Enabled = true;
    };

    -- Cardio Gain (Hestia) also restores Magick on Sprint, not just on hit.
    CardioGainSprintMana = {
      Enabled = true;
    };

    -- Profuse Bleeding (Ares): reworked. Instead of a falling blade whenever you inflict Rend or
    -- collect a Blood Drop, a Rend-afflicted foe taking damage may now spill a Blood Drop
    -- (10/15/20/25% by rarity).
    ProfuseBleedingBloodSpill = {
      Enabled = true;
    };

    -- Profuse Bleeding (Ares) is offered for holding Vicious Strike or Vicious Flourish, rather
    -- than for any one of those two plus Grisly Gain and Visceral Impact. In return it counts as a
    -- Plasma boon itself, so it can earn Sanguinary Savor, Universal Donor and Carnal Pleasure the
    -- way the other two do.
    ProfuseBleedingRequirements = {
      Enabled = true;
    };

    -- Thermal Dynamics (Hestia x Zeus): every bolt Zeus throws inflicts Scorch, not only Blitz,
    -- and the amount is 60% of the damage the bolt dealt rather than a flat count.
    ThermalDynamicsAllLightning = {
      Enabled = true;
    };

    -- Harm for the Afflicted (Medea) hits for every new curse landing on a foe, instead of once a
    -- second across the whole fight. The 0.3 second gap it keeps is counted per foe and per curse,
    -- so cursing a crowd pays out for each of them.
    HarmForTheAfflictedEveryStatus = {
      Enabled = true;
    };

    -- Brave Face (Hephaestus x Hera) resists half of every hit rather than a third, and each point
    -- resisted costs 5 Magick instead of 10.
    BraveFace = {
      Enabled = true;
    };

  };

  -- Testing aids, read on every room load: a name grants that boon once and is then left alone for
  -- the night; removing a name takes it back. Kept between sessions, so a resumed run keeps what it
  -- was granted and a new run grants the list again.
  Debug = {

    -- Trait names, separated by commas, semicolons or spaces. See TRAIT_NAMES.md.
    GrantTraits = '';

    -- Rarity for anything granted above: Common, Rare, Epic or Heroic. Changing it re-grants.
    GrantRarity = 'Common';

    -- Pom level for anything granted above. 1 is the base boon, 2 is one Pom, and so on.
    -- Changing it re-grants.
    GrantPomLevel = 1;
  };
}

return config
