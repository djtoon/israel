"""Size of the web export per category, read from the .pck directory (what the player downloads).
   python -I build/web/size_report.py [out dir]   -> prints the table and writes progress/web_size.txt"""
import os, struct, sys, collections, time

OUT = sys.argv[1] if len(sys.argv) > 1 else "C:/civ/build/web/out"
PCK = os.path.join(OUT, "index.pck")


def pck_files(path):
    f = open(path, "rb")
    magic = f.read(4)
    assert magic == b"GDPC", magic
    fmt, vmaj, vmin, vpat = struct.unpack("<IIII", f.read(16))
    flags, base = struct.unpack("<IQ", f.read(12))
    if fmt >= 3:
        diroff = struct.unpack("<Q", f.read(8))[0]
        f.seek(diroff)
    else:
        f.read(16 * 4)
    n = struct.unpack("<I", f.read(4))[0]
    out = []
    for _ in range(n):
        ln = struct.unpack("<I", f.read(4))[0]
        p = f.read(ln).rstrip(b"\0").decode("utf-8")
        off, size = struct.unpack("<QQ", f.read(16))
        f.read(16)
        f.read(4)
        out.append((p, size))
    return out


def category(p, imported_from):
    src = imported_from.get(p.replace("res://", ""), p)
    s = src.replace("res://", "")
    if s.startswith("assets/models/"):
        sub = s.split("/")[2]
        kind = "textures" if s.endswith(".png") or ".png-" in p else "meshes"
        return "models/%s (%s)" % (sub, kind)
    if s.startswith("assets/images/"):
        return "images/" + s.split("/")[2]
    if s.startswith("assets/audio/"):
        return "audio"
    if s.startswith("assets/intro/") and s.endswith(".ogv"):
        return "videos"
    if s.startswith("assets/"):
        return "assets/" + s.split("/")[1]
    if s.startswith("data/") or s.startswith("i18n/"):
        return "data + i18n (json)"
    if s.startswith("scripts/") or s.endswith(".gd") or s.endswith(".gdc"):
        return "scripts and shaders"
    return "other (engine, project, scenes)"


files = pck_files(PCK)
# map .godot/imported/<name>-<hash>.<ext> back to its source via the .import remaps inside the pack
names = {p for p, _ in files}
imported_from = {}
src_dir = "C:/civ/build/web/src/game"
for dp, dn, fn in os.walk(src_dir):
    if ".godot" in dp:
        continue
    for f in fn:
        if f.endswith(".import"):
            s = open(os.path.join(dp, f), encoding="utf-8", errors="ignore").read()
            src = "res://" + os.path.relpath(os.path.join(dp, f[:-7]), src_dir).replace(os.sep, "/")
            for line in s.splitlines():
                if line.startswith("path") and "res://.godot/imported/" in line:
                    imp = line.split('"')[1]
                    imported_from[imp.replace("res://", "")] = src
cat = collections.Counter()
cnt = collections.Counter()
for p, sz in files:
    c = category(p, imported_from)
    cat[c] += sz
    cnt[c] += 1
total = sum(cat.values())
lines = ["Web build size per category (%s), from %s" % (time.strftime("%Y-%m-%d %H:%M"), PCK.replace("\\", "/")), ""]
lines.append("%-40s %9s %6s" % ("category", "MB", "files"))
for c, v in sorted(cat.items(), key=lambda kv: -kv[1]):
    lines.append("%-40s %9.1f %6d" % (c, v / 1e6, cnt[c]))
lines.append("%-40s %9.1f %6d" % ("TOTAL inside index.pck", total / 1e6, len(files)))
lines.append("")
tot_out = 0
nfiles = 0
for dp, dn, fn in os.walk(OUT):
    for f in sorted(fn):
        p = os.path.join(dp, f)
        if f == "index.apple-touch-icon.png":
            continue   # (not packaged)
        tot_out += os.path.getsize(p)
        nfiles += 1
        lines.append("%-40s %9.1f MB" % ("out/" + os.path.relpath(p, OUT).replace(os.sep, "/"), os.path.getsize(p) / 1e6))
lines.append("%-40s %9.1f MB, %d files" % ("download (all files)", tot_out / 1e6, nfiles))
lines.append("first load at 50 Mbit/s (6.25 MB/s), download only: %.0f s" % (tot_out / 6.25e6))
txt = "\n".join(lines)
print(txt)
os.makedirs("C:/civ/progress", exist_ok=True)
with open("C:/civ/progress/web_size.txt", "a", encoding="utf-8") as fo:
    fo.write(txt + "\n\n")
