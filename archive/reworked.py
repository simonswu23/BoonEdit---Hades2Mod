"""Find CHANGED entries whose implementation is mostly different, not just one
field -- a proxy for "reworked" rather than "tuned". Uses difflib similarity
over the full original-vs-current source text (not the field-path diff), since
a rework can show up as a handful of touched lines that happen to restructure
everything, or a total rewrite that keeps a couple of shared lines by chance.

Prints one block per candidate: name, display name, build, similarity ratio,
then the original and current source side by side for a human (or an LLM
reading this file's stdout) to write an actual before/after description from --
that judgment call isn't something field-diffing can make.
"""
import os, io, json, difflib
from harvest import WEAPONS, GODS, CURRENT, collect, hammer_names
from changes import load_summary, original_source, OUT
from names import display_of

THRESHOLD = 0.55  # similarity ratio below this = "mostly different"


def candidates():
    summary = load_summary()
    out = []
    for w in WEAPONS:
        s = summary["hammers"][w]
        current_src = hammer_names(CURRENT, w)
        refdir = os.path.join(OUT, "hammers", w)
        out += collect_candidates(w, s, refdir, current_src)
    for g in GODS:
        s = summary["boons"][g]
        current_src = collect(CURRENT, ["TraitData_%s.lua" % g])
        refdir = os.path.join(OUT, "boons", g)
        out += collect_candidates(g, s, refdir, current_src)
    return out


def collect_candidates(title, s, refdir, current_src):
    out = []
    for name in sorted(s["changed"]):
        if name not in current_src:
            continue
        build, orig_lines = original_source(refdir, name)
        cur_lines = current_src[name][1].splitlines()
        ratio = difflib.SequenceMatcher(None, orig_lines, cur_lines).ratio()
        if ratio < THRESHOLD:
            out.append({
                "category": title, "name": name, "display": display_of(CURRENT, name),
                "build": build, "ratio": round(ratio, 2),
                "original": "\n".join(orig_lines), "current": "\n".join(cur_lines),
            })
    return out


if __name__ == "__main__":
    cands = candidates()
    print("%d candidates below ratio %.2f\n" % (len(cands), THRESHOLD))
    for c in cands:
        print("%-10s %-30s %s  ratio=%.2f  since %s" %
              (c["category"], c["name"], c["display"], c["ratio"], c["build"]))
    io.open(os.path.join(os.path.dirname(__file__), "_reworked_candidates.json"),
            'w', encoding='utf-8').write(json.dumps(cands, indent=1))
