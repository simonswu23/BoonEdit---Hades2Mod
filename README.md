# BoonEdits

A Hades II mod that reworks and rebalances over 30 boons. Every change is independent and can be
switched off on its own.

## Features

- Reworks across every Olympian, plus duo and legendary boons — see [CHANGELOG.md](CHANGELOG.md)
  for the full list.
- One toggle per change in `ReturnOfModding/config/SWu-BoonEdits.cfg`. Nothing is all-or-nothing.
- Tooltips and stat lines are rewritten to match, so a boon always reads as it behaves.
- Debug helpers for granting boons by name at a chosen rarity and Pom level.

## Install

Install through a mod manager (Thunderstore or r2modman) and it will pull in the dependencies.

To install by hand, drop the folder into `ReturnOfModding/plugins/` and make sure these are present:
Hell2Modding, ENVY, Chalk, ReLoad, SJSON and ModUtil.

## Configuration

Launch the game once to generate `ReturnOfModding/config/SWu-BoonEdits.cfg`, then set any change to
`false`. Edits are picked up on the next room load. Trait names for the debug grants are listed in
[TRAIT_NAMES.md](TRAIT_NAMES.md).

## Layout

`src/boons/` holds one file per boon, containing its trait edits, hooks, runtime logic and tooltip
text. `src/reload.lua` imports them and holds the shared helpers; `src/ready.lua` is plumbing only.
