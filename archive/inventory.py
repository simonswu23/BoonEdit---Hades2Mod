"""Compare two archived Hades II script trees.

  python inventory.py <old_build_dir> <new_build_dir> [--section traits|enemies|weapons|encounters|files]

Reports entries added/removed between builds and, for entries present in both,
every numeric field that changed (the "nerf" view).
"""
import sys, os, re, hashlib, json
from collections import OrderedDict

SECTIONS = {
    'traits':     ('TraitData',     re.compile(r'^TraitData.*\.lua$')),
    'enemies':    ('EnemyData',     re.compile(r'^EnemyData.*\.lua$')),
    'weapons':    ('WeaponData',    re.compile(r'^WeaponData.*\.lua$')),
    'encounters': ('EncounterData', re.compile(r'^EncounterData.*\.lua$')),
}
ENTRY = re.compile(r'^	(\w+)\s*=\s*(?:--.*)?$')
NAMED = re.compile(r'^(	+)(\w+)\s*=\s*\{?\s*$')
FIELD = re.compile(r'^(	*)\s*(\w+)\s*=\s*(-?[\d.]+)\s*,?\s*$')


def scripts_dir(root):
    return os.path.join(root, 'Content', 'Scripts')


def parse_entries(path):
    """Return {entry_name: {field_path: value}} for one data file.

    Field keys are qualified by their nesting path, so same-named keys at
    different depths (Threshold in a damage window vs. in a colour block)
    stay distinct.
    """
    entries = OrderedDict()
    cur = None
    path_at = {}
    try:
        lines = open(path, encoding='utf-8-sig', errors='replace').read().splitlines()
    except OSError:
        return entries
    for line in lines:
        m = ENTRY.match(line)
        if m:
            cur = m.group(1)
            entries.setdefault(cur, OrderedDict())
            path_at = {}
            continue
        if cur is None:
            continue
        stripped = line.strip()
        if stripped and not line.startswith('	'):
            cur = None
            continue
        f = FIELD.match(line)
        if f:
            indent = len(f.group(1))
            prefix = [path_at[i] for i in sorted(path_at) if i < indent]
            key = '/'.join(prefix + [f.group(2)])
            try:
                entries[cur][key] = float(f.group(3))
            except ValueError:
                pass
            continue
        n = NAMED.match(line)
        if n:
            indent = len(n.group(1))
            path_at = {i: v for i, v in path_at.items() if i < indent}
            path_at[indent] = n.group(2)
    return entries


def collect(root, pattern):
    out = OrderedDict()
    d = scripts_dir(root)
    if not os.path.isdir(d):
        sys.exit('missing Scripts dir: ' + d)
    for name in sorted(os.listdir(d)):
        if pattern.match(name):
            for entry, fields in parse_entries(os.path.join(d, name)).items():
                out[entry] = (name, fields)
    return out


def digest(path):
    h = hashlib.sha1()
    with open(path, 'rb') as fh:
        for chunk in iter(lambda: fh.read(65536), b''):
            h.update(chunk)
    return h.hexdigest()


def file_diff(old, new):
    def tree(root):
        base = scripts_dir(root)
        return {f: digest(os.path.join(base, f))
                for f in sorted(os.listdir(base)) if f.endswith('.lua')}
    a, b = tree(old), tree(new)
    added = [f for f in b if f not in a]
    removed = [f for f in a if f not in b]
    changed = [f for f in a if f in b and a[f] != b[f]]
    return added, removed, changed


def report(name, old, new):
    a = collect(old, SECTIONS[name][1])
    b = collect(new, SECTIONS[name][1])
    added = [k for k in b if k not in a]
    removed = [k for k in a if k not in b]
    print(f'\n### {name}  ({len(a)} old / {len(b)} new)')
    if removed:
        print(f'\n-- removed ({len(removed)}) --')
        for k in removed:
            print(f'  - {k}  [{a[k][0]}]')
    if added:
        print(f'\n-- added ({len(added)}) --')
        for k in added:
            print(f'  + {k}  [{b[k][0]}]')
    deltas = []
    for k in a:
        if k not in b:
            continue
        fa, fb = a[k][1], b[k][1]
        diff = {f: (fa[f], fb[f]) for f in fa if f in fb and fa[f] != fb[f]}
        if diff:
            deltas.append((k, a[k][0], diff))
    if deltas:
        print(f'\n-- numeric changes ({len(deltas)} entries) --')
        for k, src, diff in deltas:
            print(f'  {k}  [{src}]')
            for f, (x, y) in sorted(diff.items()):
                arrow = 'up' if y > x else 'down'
                print(f'      {f}: {x:g} -> {y:g}  ({arrow})')


if __name__ == '__main__':
    args = [x for x in sys.argv[1:] if not x.startswith('--')]
    flags = [x for x in sys.argv[1:] if x.startswith('--')]
    if len(args) != 2:
        sys.exit(__doc__)
    old, new = args
    want = None
    for fl in flags:
        if fl.startswith('--section'):
            want = fl.split('=', 1)[1] if '=' in fl else None
    print(f'OLD: {old}\nNEW: {new}')
    if want in (None, 'files'):
        ad, rm, ch = file_diff(old, new)
        print(f'\n### files  (+{len(ad)} / -{len(rm)} / ~{len(ch)})')
        for f in ad: print('  + ' + f)
        for f in rm: print('  - ' + f)
        for f in ch: print('  ~ ' + f)
    for s in SECTIONS:
        if want in (None, s):
            report(s, old, new)
