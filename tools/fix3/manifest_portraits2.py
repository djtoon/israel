import json, os, sys, tempfile
sys.path.insert(0, 'C:/civ/tools/fix3')
import portraits2

MP = 'C:/civ/game/data/art_manifest.json'
HP = 'C:/civ/game/data/i18n/he/art_manifest.json'


def save(path, obj):
    # write via temp file + replace so a reader never sees a half-written file
    fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path), suffix='.tmp')
    with os.fdopen(fd, 'w', encoding='utf-8') as f:
        json.dump(obj, f, indent=1, ensure_ascii=False)
    os.replace(tmp, path)


# manifest: re-read right before the write (another agent edits the events section)
m = json.load(open(MP, encoding='utf-8'))
ports = m['portraits']
skipped = []
for (i, name, he, role, role_he, actor, f, t, look, reuse) in portraits2.P:
    if reuse:
        src = ports[reuse]
        file, small = src['file'], src['file_small']
    else:
        file = f"res://assets/images/portraits/{i}.png"
        small = f"res://assets/images/portraits/{i}_256.png"
        if not os.path.exists(portraits2.OUT + i + '.png'):
            skipped.append(i); continue
    ports[i] = {"file": file, "file_small": small, "name": name, "role": role, "era_from": f, "era_to": t, "actor": actor}
save(MP, m)

h = json.load(open(HP, encoding='utf-8'))
for (i, name, he, role, role_he, actor, f, t, look, reuse) in portraits2.P:
    if i in skipped: continue
    h['portraits/' + i] = {"name": {"en": name, "he": he}, "role": {"en": role, "he": role_he}}
h['_meta']['entries'] = len([k for k in h if k != '_meta'])
h['_meta']['translated'] = h['_meta']['entries']
save(HP, h)
print('added', len(portraits2.P) - len(skipped), 'skipped', skipped)
