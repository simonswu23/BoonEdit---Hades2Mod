# Credits and third-party work

This mod is MIT licensed. What follows is everything it leans on that other people wrote, and on
what terms.

## Required dependencies

Declared in `manifest.json`; the mod does not run without them. These are used as libraries — called
at runtime, not copied into this repository.

| Mod | Author | Licence |
| --- | --- | --- |
| Hell2Modding | Hell2Modding | see mod |
| ENVY | LuaENVY | see mod |
| Chalk, ReLoad, SJSON, ModUtil | SGG_Modding | see mod |

## Assets

Every animation, icon, sound and portrait this mod uses is already in Hades II and is referenced by
name. Nothing from Supergiant is extracted, repackaged or redistributed, and no assets from Hades I
are included.

## Game data

The mod reads Hades II's own shipped Lua to find the hooks it attaches to, and refers to those
functions and fields by name. No part of the game's code is reproduced in this repository.
