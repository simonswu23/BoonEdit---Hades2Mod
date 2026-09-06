# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Every change below can be switched off independently in
`ReturnOfModding/config/SWu-BoonEdits.cfg`, where each one is described in in-game terms.

### Aphrodite

- **Glamour Gain** — New Effect: Every 1 second, you inflict Weak on nearby foes. Gain mana for each one.
- **Hearty Appetite** — Additionally restores your health to full when on pickup, and increases your healing for the rest of the night by 50%.

### Dionysus

- **Festive Fog** — Standing in the fog also softens what hits you, by 40%. Hung on the fog rather than on the boon: the mark the cloud puts on you is what the damage bonus is already gated on, so the shelter reads "you are standing in a Dionysus fog" whatever put the fog there — including HexCalls' Distress Call revel, which raises the same cloud without the boon. That reduction used to live in Distress Call and be polled ten times a second; it answers the fog directly now.
- **Grape Juice** — Also restores 20 health when you pick it up. Hung on the drink itself rather than on the boon that leaves it, so anything that puts one on the floor pays it — including HexCalls' Distress Call, whose Dionysus revel drops the same item.

### Ares

- **Blood Spree** — Additionally, slaying a foe has a 20% chance to restore health. It restores the same amount the boon's Attack and Special do, so it grows with rarity the same way, and unlike the lifesteal it does not wait for you to be nearly dead.

- **Profuse Bleeding** — New(?) Effect: foes with wounds have a small chance to drop plasma after taking damage. It is no longer a sword boon: rewritten it never makes a falling blade, so it no longer unlocks Coffin Nail or Cutting Edge, the two duos that improve them.
- **Stabbing Rush** — Falling blades keep dropping for the entire duration of your sprint.

### Apollo

- **Easy Shot** — The piercing arrow deals 100 / 120 / 140 / 160 damage, doubled from 50 / 60 / 70 / 80. A Pom of Power can no longer be spent on it: the boon has no per-level figure of its own, so a Pom was adding a whole second arrow's worth for one level.
- **Dazzling Display** — Additionally inflicts Blind with your Special while you hold Nova Flourish, and Nova Flourish now makes it eligible to be offered in the first place. Blind chance raised to 15% / 20% / 25% / 30% across the rarities.
- **Extra Dose** — Additionally, your Special has the same chance to strike twice.

### Demeter

- **Local Climate** — Additionally, buff your regular cast damage as well.
- **Tranquil Gain** — New Effect: when channeling your Omega moves for 0.5 seconds, rapidly restore mana.

### Hades

- **Unseen Ire** — Cooldown reduced to 30 seconds.
- **Old Grudge** — No longer a one-time use internally, allowing it to fire multiple times.

### Hephaestus

- **Anvil Ring** — Additionally, inflicts Glow in exchange for a slight decrease in power.
- **Heavy Metal** — Additionally, foes' attacks cannot knock you back while you hold it.
- **Molten Touch** — Additionally deals bonus damage to foes afflicted with Glow.
- **Smithy Rush** — New Effect: when you start and stop dashing, a hammer strikes the area, dealing damage and inflicting Glow.

### Hera

- **Rousing Reception** — Additionally, inflicts Hitch on the foes it damages. New dependency on Engagement Ring.

### Hermes

- **Hard Target → Post Haste** — Replaced: reduces boon effect cooldowns by 20%/2%5/30%/35%.

### Hestia

- **Cardio Gain** — Additionally, restores mana when sprinting.

### Medea

- **Harm for the Afflicted** — Damage triggers on every new curse inflicted on each individual foe.

### Poseidon

- **King Tide** — Adjusted requirements.
- **Slippery Slope** — Pinned to Wave Strike and Trident Flourish. Its requirement was a bare "any splash boon", so every boon added to that group below became a fresh way to unlock it, Beach Ball included. It is the Froth those two put on the water that it works on.
- **Tidal Ring** — Its splash answers King Tide and Arterial Spray now. The game's Cast-splash
  function never consulted either of them — it drops a marker where the Cast was, fires one splash at
  it and returns — so a boon making the same splash the Attack and Special make was neither widened
  nor doubled by the boons that widen and double those. Arterial Spray's extra wave is marked with a
  red nova rather than its usual red cone here, for the same reason it is on Breaker Rush: this
  splash goes off all round, and the cone pointed one way across a circle that did not.
- **Tidal Ring**, **Breaker Rush** and **High Surf** count as splash boons. All three already make a
  splash — they fire the same splinters Poseidon's Attack and Special do, which is what King Tide's
  bonus and Slippery Slope's Froth key on — but the game's own list of "splash boons" named only
  Attack and Special, so none of them could be the boon that unlocks a splash upgrade. Beach Ball was
  already added to that list; these three join it. King Tide's own requirement is pinned to Poseidon's
  Attack and Special by name so that widening the list does not quietly drop that condition.
- **Meat Grinder** — dropped the plasma-chance stat line, which named a stat line that was never defined and so printed a raw token.
- **Controlled Burn** — fires on an Omega Attack as well as an Omega Special, and charges its Magick on both. The fireball's own Omega check lives inside the function the boon calls, so the weapon list was the only thing gating it to the Special.
- **Burning Desire** — additionally lifts the ceiling on Scorch, from vanilla's 999. Silent: nothing is added to its wording, since the boon already reads as the one that keeps Scorch from burning away, and a stack limit is not a number you track until you hit it.
- **Breaker Rush** — New Effect: when you start and stop dashing, deal damage with a watery splash that knocks back foes and inflicts Froth, and leave a trail of the same splashes behind you while you hold a sprint, one every half second. The splash deals 50 / 55 / 60 / 65 across the rarities, and now answers Arterial Spray and King Tide like any other splash — it was fired straight rather than through the game's own splash function, which is the only place either of those is read, so it never got a second wave or the extra size. King Tide's damage bonus always reached it, which is what made the gap easy to miss. Arterial Spray's second wave is marked with a red nova rather than its usual red cone here: this splash goes off all round rather than in a cone, so the cone pointed one way across a circle that did not. A Pom of Power adds 20 to that, and 10 for each one after — vanilla's own figures for this boon, which rewriting the effect had dropped, leaving each Pom adding a whole further splash's worth. The Froth is applied by the boon rather than handed to the engine to apply, because the engine's own path for that reads an impact angle the splash does not have and faults on it. It comes off the splash itself; it used to be read off the Cast's own slow, so it only landed when a Cast happened to be holding the same foe.

### Zeus

- **Ionic Gain** — Additionally, standing near the Font slowly restores Magick.
- **Air Quality** — Now floors your base damage, instead of flooring the finished hit after all multipliers.

### Duo Boons

- **Arterial Spray** (Poseidon × Ares) — The second wave's strike chance is improved to 100%, in exchange for its power reduced to 30%. It is offered off any splash boon rather than off Wave Strike and Trident Flourish alone, so it follows whatever counts as a splash — minus the duos among them, since a duo unlocking another duo is not how the pool reads and this mod's own widening is what put Beach Ball in that group. Glacial Advance in the duos mod reads the same way.
- **Beach Ball** (Apollo × Poseidon) — Is now considered a Splash Boon, and max damage increased to 400. Its blast answers King Tide and Arterial Spray as well, which nothing in the game could have done for it: the ball is not made by a splash function at all, it is a projectile that flies off and detonates, so there was nowhere the boons that shape a splash could have been read. The extra wave lands where the ball did, marked with the same red nova the other round splashes use.
- **Brave Face** (Hephaestus × Hera) — Resists up to 50% of any damage rather than 30%, and each point resisted costs 5 Magick instead of 10.
- **Chain Reaction** (Hestia × Hephaestus) — New Effect: Boon effect cooldowns have a 50% chance of being skipped. Announces itself on screen when it fires, once per cooldown it actually eats — and only for cooldowns a boon you are holding actually owns. The game runs one general-purpose timer that 136 places call, most of them throttling a voice line or a screen shake several times a second with no boon behind them, so rolling on all of those had it announcing itself constantly. It used to roll whenever anything read the recharge speed, which is not the same thing at all — the HUD reads it to draw a recharge arc, and boons like Athena's Phalanx Shot read it on a repeating timer whether or not anything is happening, so it rolled and announced itself over and over with no combat in sight. A Blast rolls on the Blast that lands rather than on every hit, so a fast weapon no longer rolls its way past the cooldown many times a second; when the roll comes up, the Blast is ready again at once. Now counts as a chance-based effect for Success Rate, which can be offered off it.
- **Carnal Pleasure** (Aphrodite × Ares) — Back to its vanilla effect, with a heal on top: collecting Plasma restores 1 health per drop as well as rolling the game's own 35% chance at a Heartthrob. That chance is a tuning value now rather than the fixed figure in the game's data, so it can be moved without touching the roll itself, which stays vanilla's — luck and all. It is also offered on vanilla's own pairing again: any Aphrodite core boon rather than Heart Breaker alone, against any Plasma source. The earlier version — larger Heartthrobs, bonus damage scaling off Plasma held, a cap of 12 following you, and Plasma counting as 10 Magick toward Heart Breaker — is gone. The heal is the one *Boiling Blood* used to pay in MoreDuosMod, moved here.
- **Cherished Heirloom** (Demeter × Hera) — Additionally, keepsake effects don't expire tonight. Equip an extra one on pickup. That extra one is a choice rather than an offer, so the rack cannot be backed out of until you take one. It also waits for the screen to be clear before it opens, rather than counting down a fixed pause — anything that offers a boon on a delay of its own, Concave Stone's random one especially, used to land on top of it.
- **Cryo Pounder** (Demeter × Hephaestus) — Additionally, frozen foes also take more damage from Hephaestus' hammer strikes.
- **Nervous Wreck** (Aphrodite x Hera) — Swapped: same effect as before (as Aphrodite's legendary), but kept Ecstatic Obession's old requirements.
- **Glorious Disaster** (Apollo × Zeus) — No longer needs the extra channeled Magick, and bolts hit for 50 rather than 20 damage. A fully charged Omega Cast releases itself again: the boon switches that off in the game because it adds a second charge stage to hold into, and removing that stage left the switch behind with nothing to protect.
- **Hostile Environment** (Demeter × Ares) — Additionally, your regular cast also follows you around. Arctic Gale's gust rides along with it, on your cast and on your familiar's under Aspect of Circe, rather than only on a cast fired with Attack held.
- **Killer Current** (Zeus × Poseidon) — New Effect: Froth-afflicted foes have a 30% chance of being struck by lightning for 30 after taking damage, at most twice a second. Froth sits on a foe for a while and every hit that lands rolls again, so a fast weapon into a Frothed crowd was rolling many times a second.
- **Love Handles → Smoldering Forge** (Aphrodite × Hephaestus) — Replaced: striking a foe with Glow with your Attack or Special has a 20% chance to create a Heartthrob. The roll is a blow you land yourself — it no longer answers every source of damage that reaches a Glowing foe, so nothing you left on one ticks it over.
- **Natural Selection** (Demeter × Poseidon) — New Effect: on pickup, gain 3 triple-poms. Every 8 encounters, gain another one. Each pom rolls its own boons when you open it rather than when it drops — the game settles a pom's options once and keeps them, so every pom out of one handful, and every look at the same pom, had been showing the same three.
- **Ripple Effect** (Hera × Poseidon) — New Effect: repeats the Omega procs of six boons — Ocean Swell, Fine Line, Easy Shot, Controlled Burn, Explosive Intent and Cut Above — with a 50% chance to occur again, up to 4 times, each with diminishing chances (50% / 25% / 12.5% / 6.25%). Those six by name and nothing else: it used to take every fireball through the Fireballs edit's own list, which holds this mod's and other mods' fireballs as well as Hestia's, so a Hex-Call throwing a dozen of them handed Ripple a dozen chances to repeat and the screen filled with bouncing fire. It no longer asks who fired the projectile either: however and whenever one of the six is created, it repeats, so a familiar's cast or a Hex-Call's swells count like your own. Dionysus' Drunken Stupor is in as well, differently: it fires no projectile but applies a lingering effect once per foe, so a ripple of it makes that one dose heavier rather than repeating it.
- **Seismic Servo → Seismic Hammer** (Hephaestus × Poseidon) — Replaced: your Cast erupts into your Omega Cast after being struck by a Hephaestus explosion. Also reduces the cooldowns of Volcanic Strike, Volcanic Flourish, and Land Mine flatly by 1 second.
- **Sun Worshiper** (Apollo × Hera) — Additional foes have a 30% chance to also be summoned in combat after being slain, up to 10 extra per encounter.
- **Scalding Vapor** (Hestia × Poseidon) — Creating Steam no longer consumes Froth and Steam can trigger Froth. Steam now comes from a fireball and from nothing else: inflicting Scorch on a Frothed foe used to make it too, which is what the boon did before the rework and not what it says now. Adjusted requirements.
- **Thermal Dynamics** (Hestia × Zeus) — Additionally triggers on every lightning effect from Zeus rather than only Blitz, but 30%.

### Legendary Boons

- **Pandemonium** (Chaos) — New Legendary: puts all gods in your pool tonight, removes all boon requirements, increases boon offering chances, and allows core boons to be stacked.
- **All Together** (Hera) — Gain an additional essence of each type upon pickup.
- **Fire Away → Burning Meteor** (Hestia) — Replaced: Fireball effects from Hestia are 50% larger and stronger, and inflict Scorch equal to the damage they deal.
- **Paid Dues → Second Wind** (Hermes) — Replaced: You can cast and dash an additional time, and dashes chain more quickly.
- **Premium Service** (Hephaestus) — Additionally, all weapon upgrades increase in rank tonight, and gain an Anvil of Fates on pickup.
- **Shocking Loss** (Zeus) — If this activates against a guardian, they take 9999 damage instead. That is set damage, dealt through vanilla's own spawn-kill projectile so nothing multiplies it, and counted as Shocking Loss on the end-of-run damage screen rather than by the projectile's name.
- **Winter Harvest** (Demeter) — Executes from 15% rather than 10%, and sums boss HP across all phases for calculation. Can now skip more boss phases (Prometheus, Zagreus, Typhon).
- **Nervous Wreck → Ecstatic Obsession** (Aphrodite × Hera) — Replaced: when you inflict Weak, you have a 30% chance to inflict Charm for 5 seconds instead. A Guardian cannot be Charmed again for 5 seconds after the last one; it shakes Charm off far faster than a lesser foe does, so without that the next Weak to land put it straight back under. Deal 10% more damage for each nearby character fighting for you, up to 50%.

### Other

- **Every boon description is written the way the game writes its own.** Checked against the game's text files rather than by eye: every `{$Keywords.…}`, `{!Icons.…}` and `{#Format}` token in the mod now resolves to something that exists. Numbers are no longer baked into the wording — Blood Spree's kill-heal chance, Natural Selection's Poms and levels, and Ripple Effect's repeat limit are read off the boon through `ExtractData`, as vanilla does, so the tooltip and the code cannot drift apart; Blood Spree's now shows the luck-scaled figure the roll actually uses. Hearty Appetite's description ended in two full stops.

- **Keyword tooltips opened from a reworked boon printed raw tokens.** A keyword resolves its numbers against the boon whose tooltip you opened it from, not against the keyword — so vanilla hangs Rend's duration, Scorch's rate, Froth's chance and Heartthrob's fuse on the boons that name them. Seven boons here replace their `ExtractValues` outright and so threw those away: Smoldering Forge (Heartthrob), Profuse Bleeding (Rend), Thermal Dynamics and Burning Meteor (Scorch), Killer Current and Breaker Rush (Froth), and Ecstatic Obsession (Weak, whose extracts were handed to Nervous Wreck in the swap and never replaced). All seven now declare what they name, through the same `with_keyword_extracts` helper MoreDuosMod uses, copied from the traits vanilla puts them on. Every entry is external and skips auto-extraction, so no stat line moved.
- **Stat lines carry their units on the value, not in the label.** Not one of the game's own 242 stat-line labels contains a unit, and not one contains an icon; four of this mod's did. Seismic Hammer's "Blast Recharge Reduction (Sec.):" is now "Blast Recharge Reduction:" against a value reading "1 Sec.", and Ionic Gain's rate is written "(every 1 Sec.)" the way vanilla writes every other per-second stat line.

- **A boon only counts as what this mod makes it, while this mod is making it.** The game answers "is this a splash boon", "does this make plasma", "does this Froth" from lists of names, and a boon rewritten into one of those roles has to join the list. Those additions used to be one-way: switching an edit off left the list still claiming a boon that no longer did the thing. Membership is now reconciled against the config every room, in both directions — so Meat Grinder counts as a plasma source only while its edit is on, Breaker Rush Froths and splashes only while its own is, and Profuse Bleeding goes back to being a falling-sword boon the moment its rewrite is switched off.

- **Nothing opens on top of an open screen.** A choice that arrives on a delay used to land over whatever was already up, so a page you were reading became a page you could no longer see. Those now wait their turn instead — the offer is deferred, never dropped.

- **Anvil of Fates** — Instead of random chance, choose from up to 3 hammer upgrades to sacrifice / gain.
- **Glow** — Now stacks: each further application makes a foe take 5% more damage, up to 35%. Each stack expires independently.
