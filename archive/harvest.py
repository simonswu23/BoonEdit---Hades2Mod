"""Enumerate cut and changed boons / hammer upgrades across the build archive,
and write each one's pre-existing implementation out as reference code."""
import os, re, io, json, shutil

# The builds and the extracted reference code live outside the repo: they are Supergiant's
# script files, not ours to redistribute. Override with HADES2_ARCHIVE.
ARC = os.environ.get("HADES2_ARCHIVE", r"C:\Users\simon\Downloads\Hades2ScriptArchive")
OUT = os.path.join(ARC, "reference")

BUILDS = ["2024-05-06_ea-launch", "2024-07-16_ea-patch-4", "2024-10-16_olympic-update",
          "2025-02-19_warsong-update", "2025-06-17_unseen-update", "2025-07-23_ea-patch-11",
          "2025-09-25_v1.0-launch", "2026-04-14_post-launch-patch-2", "2026-07-28_hotfix-5",
          "2026-08-04_current"]
CURRENT = BUILDS[-1]

WEAPONS = ["Staff", "Dagger", "Torch", "Axe", "Lob", "Suit"]
GODS = ["Aphrodite", "Apollo", "Ares", "Artemis", "Athena", "Chaos", "Demeter", "Dionysus",
        "Hephaestus", "Hera", "Hermes", "Hestia", "Poseidon", "Zeus", "Duo", "Aspect"]

ENTRY = re.compile(r'^\t(\w+)\s*=\s*(?:--.*)?$')


def blocks(path):
    """{entry name: source text} for one data file."""
    try:
        lines = io.open(path, encoding='utf-8-sig', errors='replace').read().splitlines()
    except OSError:
        return {}
    out, name, buf, depth = {}, None, [], 0
    for line in lines:
        m = ENTRY.match(line)
        if m and name is None:
            name, buf, depth = m.group(1), [line], 0
            continue
        if name is None:
            continue
        buf.append(line)
        depth += line.count('{') - line.count('}')
        if depth <= 0 and line.rstrip().endswith(('},', '}')) and not line.startswith('\t\t'):
            out[name] = '\n'.join(buf)
            name = None
    return out


def scripts(build):
    return os.path.join(ARC, build, "Content", "Scripts")


def collect(build, filenames):
    """{entry: (file, source)} across the given data files."""
    got = {}
    base = scripts(build)
    for fn in filenames:
        p = os.path.join(base, fn)
        if os.path.isfile(p):
            for k, v in blocks(p).items():
                got[k] = (fn, v)
    return got


def hammer_names(build, weapon):
    """Entries in this weapon's file that inherit its HammerTrait."""
    got = collect(build, ["TraitData_%s.lua" % weapon])
    marker = "%sHammerTrait" % weapon
    return {k: v for k, v in got.items()
            if marker in v[1] and k != marker}


def all_current_traits():
    """Every entry name alive anywhere in the current build's trait data."""
    base = scripts(CURRENT)
    alive = set()
    for fn in sorted(os.listdir(base)):
        if fn.startswith("TraitData") and fn.endswith(".lua"):
            alive.update(blocks(os.path.join(base, fn)))
    return alive


ALIVE = all_current_traits()


def harvest(label, per_build, outdir):
    """per_build: {build: {entry: (file, src)}}. Returns (cut, changed) name lists."""
    current = per_build[CURRENT]
    seen_order = {}
    for b in BUILDS:
        for k in per_build[b]:
            seen_order.setdefault(k, b)

    cut, changed, moved = [], [], []
    for name, first_build in seen_order.items():
        if name in current:
            first_src = per_build[first_build][name][1]
            if first_src.strip() != current[name][1].strip():
                changed.append((name, first_build))
        elif name in ALIVE:
            moved.append(name)
        else:
            last = [b for b in BUILDS if name in per_build[b]][-1]
            cut.append((name, last))

    os.makedirs(outdir, exist_ok=True)
    for name, build in cut:
        fn, src = per_build[build][name]
        head = ("-- %s -- CUT\n-- last present in %s (%s)\n-- archive: %s\n\n"
                % (name, build, fn, os.path.join(ARC, build, "Content", "Scripts", fn)))
        io.open(os.path.join(outdir, name + ".lua"), 'w', encoding='utf-8').write(head + src + "\n")
    for name, build in changed:
        fn, src = per_build[build][name]
        head = ("-- %s -- CHANGED since %s\n-- this is the ORIGINAL implementation from %s (%s)\n"
                "-- archive: %s\n\n"
                % (name, build, build, fn, os.path.join(ARC, build, "Content", "Scripts", fn)))
        io.open(os.path.join(outdir, name + ".original.lua"), 'w', encoding='utf-8').write(head + src + "\n")
    return cut, changed, moved


if os.path.isdir(OUT):
    shutil.rmtree(OUT)

summary = {"hammers": {}, "boons": {}}

for w in WEAPONS:
    per_build = {b: hammer_names(b, w) for b in BUILDS}
    cut, changed, moved = harvest(w, per_build, os.path.join(OUT, "hammers", w))
    summary["hammers"][w] = {
        "now": len(per_build[CURRENT]), "cut": sorted(n for n, _ in cut),
        "changed": sorted(n for n, _ in changed), "moved": sorted(moved),
    }

for g in GODS:
    files = ["TraitData_%s.lua" % g]
    per_build = {b: collect(b, files) for b in BUILDS}
    cut, changed, moved = harvest(g, per_build, os.path.join(OUT, "boons", g))
    summary["boons"][g] = {
        "now": len(per_build[CURRENT]), "cut": sorted(n for n, _ in cut),
        "changed": sorted(n for n, _ in changed), "moved": sorted(moved),
    }

io.open(os.path.join(OUT, "summary.json"), 'w', encoding='utf-8').write(json.dumps(summary, indent=1))

print("%-14s %6s %6s %8s" % ("weapon", "now", "cut", "changed"))
for w in WEAPONS:
    s = summary["hammers"][w]
    print("%-14s %6d %6d %8d" % (w, s["now"], len(s["cut"]), len(s["changed"])))
print()
print("%-14s %6s %6s %8s" % ("god/file", "now", "cut", "changed"))
for g in GODS:
    s = summary["boons"][g]
    print("%-14s %6d %6d %8d" % (g, s["now"], len(s["cut"]), len(s["changed"])))
