# Build archive tooling

Scripts for pulling historical Hades II builds off Steam and diffing them, plus `INVENTORY.md`,
the enumeration of cut and changed boons, duos and hammer upgrades.

**The builds themselves are not in this repo, and the extracted reference code is not either.**
Both are Supergiant's script files. They live at `C:\Users\simon\Downloads\Hades2ScriptArchive`
(override with the `HADES2_ARCHIVE` environment variable), which holds one folder per build plus
`reference/`, the implementation of every cut or changed trait.

## Pulling a build

Append `<label>,<manifest id>` to `manifests.txt`, then:

    powershell -ExecutionPolicy Bypass -File pull-all.ps1 -User <steam-account>

Builds already on disk are skipped. Manifest IDs come from SteamDB's depot 1145352 page — Steam
keeps only the current manifest per branch, and Hades II has one public branch, so there is no
version history to read from the client. Each build is ~31 MB: `Content/Scripts/*.lua` and
`Content/Game/Text/en/*.sjson`, per `filelist.txt`. Needs DepotDownloader at
`C:\Users\simon\Downloads\DepotDownloader`.

## Comparing builds

    python inventory.py <old_build_dir> <new_build_dir> [--section traits|enemies|weapons|encounters|files]

Entries added and removed, and every changed numeric field for entries in both. Field names are
path-qualified, so the same key at different nesting depths stays distinct. It compares only paths
present in both builds — a value that moves to a new nesting path reads as unchanged, which is worth
remembering when a diff looks too quiet.

## Rebuilding the reference code

    python harvest.py

Rewrites `reference/` in the archive and reprints the tables in `INVENTORY.md`. A trait that merely
moved between data files is not reported as cut: presence is checked against every `TraitData*.lua`
in the current build.
