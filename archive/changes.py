"""Document what changed in every entry harvest.py flagged as CHANGED: a field-level
diff between the original implementation (reference/*.original.lua) and the current
TraitData block, one subsection per entry.

Field paths are qualified by nesting, same as inventory.py's parse_entries, so a
Value at one depth never collides with a same-named Value elsewhere. Numeric,
string and boolean scalar fields are compared; Icon/IconLayers/Sounds/screenshake
subtrees are skipped as presentation noise, not gameplay change. An entry with no
scalar-field diff (formatting only, or a change shaped as something other than a
scalar -- a reordered list, a swapped function name) falls back to a unified text
diff of its source so nothing is left undocumented.
"""
import os, re, io, json, difflib
from harvest import ARC, OUT, WEAPONS, GODS, CURRENT, collect, hammer_names
from names import display_of

FIELD = re.compile(r'^(\t*)\s*(\w+)\s*=\s*(-?[\d.]+)\s*,?\s*$')
STRFIELD = re.compile(r'^(\t*)\s*(\w+)\s*=\s*"([^"]*)"\s*,?\s*$')
BOOLFIELD = re.compile(r'^(\t*)\s*(\w+)\s*=\s*(true|false)\s*,?\s*$')
NAMED = re.compile(r'^(\t+)(\w+)\s*=\s*\{?\s*$')
FROM_BUILD = re.compile(r'from (\S+) \(')

SKIP_CONTAINERS = {"Icon", "IconLayers", "Sounds", "HitScreenshake", "HitSimSlowParameters"}


def parse_block_fields(lines):
    """{field_path: value} for one entry's body lines (declaration line included but inert)."""
    out, path_at = {}, {}
    for line in lines:
        n = NAMED.match(line)
        if n:
            indent = len(n.group(1))
            path_at = {i: v for i, v in path_at.items() if i < indent}
            path_at[indent] = n.group(2)
            continue
        for pat, cast in ((FIELD, float), (STRFIELD, str), (BOOLFIELD, lambda s: s == "true")):
            m = pat.match(line)
            if not m:
                continue
            indent = len(m.group(1))
            prefix = [path_at[i] for i in sorted(path_at) if i < indent]
            if SKIP_CONTAINERS & set(prefix) or m.group(2) in SKIP_CONTAINERS:
                break
            key = '/'.join(prefix + [m.group(2)])
            try:
                out[key] = cast(m.group(3))
            except ValueError:
                pass
            break
    return out


def diff_entry(name, original_lines, current_lines):
    """(diffs, unified): diffs is a list of (key, kind, old, new) with kind in
    changed/removed/added, or None if nothing scalar differs -- unified is then a
    fallback text diff. old/new are None for the sides that don't apply."""
    a, b = parse_block_fields(original_lines), parse_block_fields(current_lines)
    removed = sorted(k for k in a if k not in b)
    added = sorted(k for k in b if k not in a)
    changed = sorted(k for k in a if k in b and a[k] != b[k])
    if not (removed or added or changed):
        return None, difflib.unified_diff(
            [l.rstrip() for l in original_lines], [l.rstrip() for l in current_lines],
            fromfile="original", tofile="current", lineterm="", n=0)
    diffs = [(k, "changed", a[k], b[k]) for k in changed]
    diffs += [(k, "removed", a[k], None) for k in removed]
    diffs += [(k, "added", None, b[k]) for k in added]
    return diffs, None


def format_diff(key, kind, old, new):
    if kind == "changed":
        if isinstance(old, float) and isinstance(new, float):
            arrow = "up" if new > old else "down"
            return "`%s`: %g -> %g (%s)" % (key, old, new, arrow)
        return "`%s`: %r -> %r" % (key, old, new)
    if kind == "removed":
        return "`%s`: %r removed" % (key, old)
    return "`%s`: %r added" % (key, new)


def load_summary():
    with io.open(os.path.join(OUT, "summary.json"), encoding='utf-8') as f:
        return json.load(f)


def original_source(refdir, name):
    path = os.path.join(refdir, name + ".original.lua")
    text = io.open(path, encoding='utf-8').read()
    m = FROM_BUILD.search(text)
    build = m.group(1) if m else "?"
    body = text.split("\n\n", 1)[1] if "\n\n" in text else text
    return build, body.splitlines()


def write_section(out, title, names, refdir, current_src):
    if not names:
        return
    out.write("### %s\n\n" % title)
    for name in sorted(names):
        if name not in current_src:
            continue
        build, orig_lines = original_source(refdir, name)
        cur_lines = current_src[name][1].splitlines()
        diffs, unified = diff_entry(name, orig_lines, cur_lines)
        disp = display_of(CURRENT, name)
        header = "%s (`%s`)" % (disp, name) if disp else "`%s`" % name
        out.write("**%s** (since %s)\n\n" % (header, build))
        if diffs:
            for d in diffs:
                out.write("- %s\n" % format_diff(*d))
        else:
            out.write("No scalar field changed; raw diff:\n\n```diff\n")
            for l in unified:
                out.write(l + "\n")
            out.write("```\n")
        out.write("\n")


def main():
    summary = load_summary()
    out_path = os.path.join(os.path.dirname(__file__), "CHANGES.md")
    out = io.open(out_path, 'w', encoding='utf-8')
    out.write("# What changed, every CHANGED entry\n\n")
    out.write("Generated by `changes.py`. Field paths are nesting-qualified, so a `Value` inside\n")
    out.write("`IdenticalMultiplier` never collides with one elsewhere in the same block. Icon,\n")
    out.write("sound and screenshake fields are excluded as presentation, not gameplay. Entries\n")
    out.write("with no scalar-field diff fall back to a raw text diff. Headers show the\n")
    out.write("in-game display name with the internal name in backticks alongside it.\n\n")

    out.write("## Hammer upgrades\n\n")
    for w in WEAPONS:
        s = summary["hammers"][w]
        current_src = {k: v for k, v in hammer_names(CURRENT, w).items()}
        write_section(out, w, s["changed"], os.path.join(OUT, "hammers", w), current_src)

    out.write("## Boons\n\n")
    for g in GODS:
        s = summary["boons"][g]
        current_src = collect(CURRENT, ["TraitData_%s.lua" % g])
        write_section(out, g, s["changed"], os.path.join(OUT, "boons", g), current_src)

    out.close()
    print("wrote", out_path)


if __name__ == "__main__":
    main()
