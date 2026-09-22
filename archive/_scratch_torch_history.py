import re, os, sys
from harvest import BUILDS, hammer_names

ARC = r"C:\Users\simon\Downloads\Hades2ScriptArchive"

DISPLAY = re.compile(r'DisplayName\s*=\s*"((?:[^"\\]|\\.)*)"')
DESC = re.compile(r'Description\s*=\s*"((?:[^"\\]|\\.)*)"')
ID = re.compile(r'Id\s*=\s*"([^"]+)"')


def text_map(build):
    path = os.path.join(ARC, build, "Content", "Game", "Text", "en", "TraitText.en.sjson")
    try:
        lines = open(path, encoding="utf-8-sig", errors="replace").read().splitlines()
    except OSError:
        return {}
    out = {}
    cur_id = None
    cur_disp = ""
    cur_desc = ""
    for line in lines:
        m = ID.search(line)
        if m:
            if cur_id:
                out[cur_id] = (cur_disp, cur_desc)
            cur_id = m.group(1)
            cur_disp = ""
            cur_desc = ""
            continue
        d = DISPLAY.search(line)
        if d:
            cur_disp = d.group(1)
        e = DESC.search(line)
        if e:
            cur_desc = e.group(1)
    if cur_id:
        out[cur_id] = (cur_disp, cur_desc)
    return out


names = set()
for b in BUILDS:
    names |= set(hammer_names(b, "Torch").keys())

for name in sorted(names):
    sys.stderr.write("=== %s ===\n" % name)
    last = None
    for b in BUILDS:
        tm = text_map(b)
        if name in tm and tm[name] != last:
            disp, desc = tm[name]
            sys.stderr.write("  %s: %r | %s\n" % (b, disp, desc))
            last = tm[name]
