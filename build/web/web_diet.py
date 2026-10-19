"""The web build's asset diet, applied to the web source copy (never to game/). Idempotent and incremental: it decides
from the live game's files (game/), caches every derived file in build/web/cache, and writes a file in the copy only
when it differs, so a refresh re-imports only what changed (build/web/sync_src.py copies the changed sources first).
   python -I build/web/web_diet.py
1. Models: every generated GLB above its category's triangle budget is welded and decimated in Blender
   (build/web/blender_decimate.py, one process, below-normal priority), cached by source md5 + budget.
2. Texture imports: model textures VRAM-compressed (S3TC/BPTC) at 512 px (1024 for landmarks and whole cities),
   painted 2D art (events, portraits) as lossy WebP at a lower size, thumbnails and icons smaller.
   Texture arrays for the WEB_LOOK shaders (WebGL 2's 16 texture units): ground and kit textures.
3. Audio: music and ambience as Ogg Vorbis at web bitrates; the menu MP3 at 112 kbit/s.
4. Videos: the in-game Theora fallbacks re-encoded small (the web build plays WebM in an HTML <video>, see
   build/web/web_video.py and scripts/ui/web_video.gd)."""
import sys, os, re, json, hashlib, shutil, subprocess, struct

SRC = "C:/civ/game/assets"
A = "C:/civ/build/web/src/game/assets"
CACHE = "C:/civ/build/web/cache"
BLENDER = r"C:\Program Files\Blender Foundation\Blender 5.2\blender.exe"
HERE = os.path.dirname(os.path.abspath(__file__))
LOW = getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
MD5_CACHE = os.path.join(CACHE, "src_md5.json")
_md5 = json.load(open(MD5_CACHE, encoding="utf-8")) if os.path.exists(MD5_CACHE) else {}


def src_md5(p):
    """md5 of a source file, cached by its mtime and size (no re-hashing of unchanged sources)"""
    st = os.stat(p)
    k = p.replace("\\", "/")
    e = _md5.get(k)
    if e and e[0] == st.st_mtime_ns and e[1] == st.st_size:
        return e[2]
    h = hashlib.md5(open(p, "rb").read()).hexdigest()[:12]
    _md5[k] = [st.st_mtime_ns, st.st_size, h]
    return h


def place(cached, dst):
    """copy a cached derived file into the copy unless it is already there (same size and bytes)"""
    if os.path.exists(dst) and os.path.getsize(dst) == os.path.getsize(cached):
        with open(dst, "rb") as a, open(cached, "rb") as b:
            if a.read() == b.read():
                return False
    shutil.copyfile(cached, dst)
    return True


def ffmpeg(args):
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-threads", "4"] + args, check=True, creationflags=LOW)


# ---------------------------------------------------------------- 1. models
# kit models (building / harbour / shore, drawn as MultiMesh instances, up to ~1200 in a chunk) carry most of the
# vertex work in WebGL: 2500 (picked by eye at map zoom; 1500 broke up); hero buildings (v3_*) and whole scenes more
TRIS = {"building": 2500, "landmark": 14000, "city": 14000, "harbour": 3000, "improvement": 7000, "unit": 6000,
        "shore": 2500, "nature": 6000, "kit": 6000}
TRIS_PREFIX = {"v3_": 8000, "lm_": 14000}


def glb_json(p):
    b = open(p, "rb").read()
    jl = struct.unpack("<I", b[12:16])[0]
    return json.loads(b[20:20 + jl])


def glb_tris(p):
    j = glb_json(p)
    n = 0
    for m in j.get("meshes", []):
        for pr in m["primitives"]:
            acc = pr["indices"] if "indices" in pr else pr["attributes"]["POSITION"]
            n += j["accessors"][acc]["count"] // 3
    return n


def strip_image_names(p):
    """Blender names the exported image ("Image_0"); Godot names an extracted texture <model>_<image name>.png, so a
    named image would extract a second, full-size texture beside the existing <model>_0.png. Unnamed, Godot keeps using
    <model>_0.png (the same picture, with the web import limits below)."""
    b = bytearray(open(p, "rb").read())
    jl = struct.unpack("<I", b[12:16])[0]
    j = json.loads(bytes(b[20:20 + jl]))
    changed = False
    for im in j.get("images", []):
        if "name" in im:
            del im["name"]
            changed = True
    if not changed:
        return
    js = json.dumps(j, separators=(",", ":")).encode("utf-8")
    js += b" " * ((4 - len(js) % 4) % 4)
    out = b[:12] + struct.pack("<I", len(js)) + b"JSON" + js + bytes(b[20 + jl:])
    out[8:12] = struct.pack("<I", len(out))
    open(p, "wb").write(bytes(out))


jobs, places = [], []
before = after = 0
tri_cache_p = os.path.join(CACHE, "glb_tris.json")
tri_cache = json.load(open(tri_cache_p, encoding="utf-8")) if os.path.exists(tri_cache_p) else {}
for dp, dn, fn in os.walk(SRC):
    if "_cand" in dp or "_pipeline" in dp or "model_src" in dp:
        continue
    for f in fn:
        if not f.endswith(".glb"):
            continue
        sp = os.path.join(dp, f)
        rel = os.path.relpath(sp, SRC).replace(os.sep, "/")
        dst = os.path.join(A, rel)
        if not os.path.exists(dst):
            continue   # (left out of the web build by sync_src.py)
        cat = rel.split("/")[1] if rel.startswith("models/") else rel.split("/")[0]
        budget = TRIS.get(cat)
        if budget is None:
            continue
        for pre, b in TRIS_PREFIX.items():
            if f.startswith(pre):
                budget = b
        md5 = src_md5(sp)
        t = tri_cache.get(md5) or glb_tris(sp)
        tri_cache[md5] = t
        before += t
        if t <= budget * 1.2:
            after += t
            continue
        out = os.path.join(CACHE, "glb", rel.replace("/", "__")[:-4] + "_%s_%d.glb" % (md5, budget))
        if not os.path.exists(out):
            jobs.append({"in": sp, "out": out, "tris": budget})
        places.append((out, dst))
if jobs:
    os.makedirs(os.path.join(CACHE, "glb"), exist_ok=True)
    jf = os.path.join(CACHE, "glb_jobs.json")
    json.dump(jobs, open(jf, "w", encoding="utf-8"))
    print("web diet: decimating %d models in Blender (one process, below-normal priority)" % len(jobs), flush=True)
    r = subprocess.run([BLENDER, "-b", "--factory-startup", "-t", "4", "-P", os.path.join(HERE, "blender_decimate.py"), "--", jf],
                       capture_output=True, text=True, encoding="utf-8", errors="replace", creationflags=LOW)
    for line in r.stdout.splitlines():
        if line.startswith("WEBDEC") or "Error" in line or "Traceback" in line:
            print("  " + line)
    for j in jobs:
        if os.path.exists(j["out"]):
            strip_image_names(j["out"])   # (once, on the cached file)
# far LODs of the kit models (MultiMesh instances): geometry only, about FAR_TRIS triangles, in models/web_far/;
# ArtKit uses them as the mid / far LOD on the web (it builds its own LODs on a worker thread on the desktop)
FAR_TRIS = 500
MID_TRIS = 1000   # the mid LOD (models/web_mid/): silhouette, roofs and colours kept (the user's request, 2026-10-18)
far_jobs, far_places = [], []
for dp, dn, fn in os.walk(os.path.join(SRC, "models")):
    if "_cand" in dp:
        continue
    for f in fn:
        cat = os.path.basename(dp)
        if not f.endswith(".glb") or cat not in ("building", "harbour", "shore") or f.startswith(("v3_", "lm_")):
            continue
        sp = os.path.join(dp, f)
        if not os.path.exists(os.path.join(A, "models", cat, f)):
            continue
        for tris, sub in ((FAR_TRIS, "web_far"), (MID_TRIS, "web_mid")):
            out = os.path.join(CACHE, "glb_far", "%s_%s_%d.glb" % (f[:-4], src_md5(sp), tris))
            if not os.path.exists(out):
                far_jobs.append({"in": sp, "out": out, "tris": tris, "mesh_only": True})
            far_places.append((out, os.path.join(A, "models", sub, f)))
if far_jobs:
    os.makedirs(os.path.join(CACHE, "glb_far"), exist_ok=True)
    jf = os.path.join(CACHE, "glb_far_jobs.json")
    json.dump(far_jobs, open(jf, "w", encoding="utf-8"))
    print("web diet: %d far LODs in Blender" % len(far_jobs), flush=True)
    subprocess.run([BLENDER, "-b", "--factory-startup", "-t", "4", "-P", os.path.join(HERE, "blender_decimate.py"), "--", jf],
                   capture_output=True, text=True, encoding="utf-8", errors="replace", creationflags=LOW)
os.makedirs(os.path.join(A, "models", "web_far"), exist_ok=True)
os.makedirs(os.path.join(A, "models", "web_mid"), exist_ok=True)
n_far = 0
for out, dst in far_places:
    if os.path.exists(out):
        n_far += place(out, dst)
print("web diet: %d far LODs (%d written now)" % (len(far_places), n_far))

n_new = 0
for out, dst in places:
    if os.path.exists(out):
        strip_image_names(out)   # (no-op once stripped)
        n_new += place(out, dst)
        after += tri_cache.get("dec:" + out) or glb_tris(out)
        tri_cache["dec:" + out] = tri_cache.get("dec:" + out) or glb_tris(out)
    else:
        print("web diet: MISSING decimated model for", dst)
json.dump(tri_cache, open(tri_cache_p, "w", encoding="utf-8"))
print("web diet: models %d -> %d triangles (%d decimated, %d written now)" % (before, after, len(places), n_new))

# ---------------------------------------------------------------- 2. texture imports


def set_params(path, params):
    s = open(path, encoding="utf-8").read()
    t = s
    for k, v in params.items():
        if re.search(r"^%s=.*$" % re.escape(k), t, flags=re.M):
            t = re.sub(r"^%s=.*$" % re.escape(k), "%s=%s" % (k, v), t, flags=re.M)
        else:
            t = t.rstrip("\n") + "\n%s=%s\n" % (k, v)
    if t != s:
        open(path, "w", encoding="utf-8", newline="\n").write(t)
        return 1
    return 0


VRAM = {"compress/mode": "2", "mipmaps/generate": "true", "detect_3d/compress_to": "0"}
n = {}
for dp, dn, fn in os.walk(A):
    for f in fn:
        if not f.endswith(".png.import") and not f.endswith(".jpg.import"):
            continue
        p = os.path.join(dp, f)
        rel = os.path.relpath(p, A).replace(os.sep, "/")
        prm = None
        if re.search(r"_\d+\.png\.import$", f) and (rel.startswith("models/") or rel.startswith("kit/models/")):
            big = rel.startswith("models/landmark/") or rel.startswith("models/city/")
            prm = dict(VRAM, **{"process/size_limit": "1024" if big else "512"})
            key = "model textures"
        elif rel.startswith("images/events/"):
            prm = {"compress/mode": "1", "compress/lossy_quality": "0.68", "process/size_limit": "1024", "mipmaps/generate": "false"}
            key = "event art"
        elif rel.startswith("images/portraits/"):
            prm = {"compress/mode": "1", "compress/lossy_quality": "0.75", "process/size_limit": "512", "mipmaps/generate": "false"}
            key = "portraits"
        elif rel.startswith("images/ending/"):
            prm = {"compress/mode": "1", "compress/lossy_quality": "0.85"}
            key = "ending art"
        elif rel.startswith("ui/thumb_"):
            prm = {"process/size_limit": "512"}
            key = "thumbnails"
        elif rel.startswith("brand/icon"):
            prm = {"process/size_limit": "256"}
            key = "icons"
        elif rel.startswith("kit/models/") and f.endswith("_src.png.import"):
            prm = {"compress/mode": "1", "process/size_limit": "256"}
            key = "sources"
        if prm:
            n[key] = n.get(key, 0) + set_params(p, prm)
print("web diet: texture import settings changed now:", n)

# texture arrays for the WEB_LOOK shaders (layer order = their S_* / K_* / KN_* defines); vertical strips imported as
# Texture2DArray. Built from the live game's textures (the single ones are not in the web copy).
ARRAYS = [
    ("textures/terrain/web_terrain_array.png", 1024, ["textures/terrain/terrain_grassland", "textures/terrain/terrain_plains",
        "textures/terrain/terrain_hills_limestone", "textures/terrain/terrain_desert_rock", "textures/terrain/terrain_desert_sand",
        "textures/terrain/terrain_marsh", "textures/terrain/terrain_beach_sand", "textures/terrain/terrain_pine_forest_floor",
        "textures/terrain/terrain_basalt", "kit/kit_paving"]),
    ("kit/web_kit_array.png", 1024, ["kit/kit_stone_facade", "kit/kit_bauhaus_facade", "kit/kit_shikun_facade",
        "kit/kit_glass_facade", "kit/kit_roof_flat", "kit/kit_roof_tiles", "kit/kit_paving"]),
    ("kit/web_kit_n_array.png", 512, ["kit/kit_stone_facade_n", "kit/kit_bauhaus_facade_n", "kit/kit_shikun_facade_n",
        "kit/kit_glass_facade_n", "kit/kit_roof_tiles_n"]),
]
ARRAY_IMPORT = """[remap]

importer="2d_array_texture"
type="CompressedTexture2DArray"

[deps]

source_file="res://assets/%s"

[params]

compress/mode=2
compress/high_quality=false
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/channel_pack=0
mipmaps/generate=true
mipmaps/limit=-1
slices/horizontal=1
slices/vertical=%d
"""
wrote = []
for rel, size, layers in ARRAYS:
    out = os.path.join(A, rel)
    srcs = [os.path.join(SRC, l + ".png") for l in layers]
    key = hashlib.md5(("".join(src_md5(s) for s in srcs) + str(size)).encode()).hexdigest()[:12]
    cached = os.path.join(CACHE, "arrays", os.path.basename(rel)[:-4] + "_" + key + ".png")
    if not os.path.exists(cached):
        from PIL import Image
        os.makedirs(os.path.dirname(cached), exist_ok=True)
        strip = Image.new("RGB", (size, size * len(srcs)))
        for i, s in enumerate(srcs):
            strip.paste(Image.open(s).convert("RGB").resize((size, size), Image.LANCZOS), (0, i * size))
        strip.save(cached, compress_level=3)
    if place(cached, out):
        wrote.append(rel)
    if not os.path.exists(out + ".import"):
        open(out + ".import", "w", encoding="utf-8", newline="\n").write(ARRAY_IMPORT % (rel, len(srcs)))
print("web diet: texture arrays (written now: %s)" % (", ".join(wrote) or "none"))

# ---------------------------------------------------------------- 3. audio: music and ambience at web bitrates
au = {"music": ["-c:a", "libvorbis", "-q:a", "1"], "ambience": ["-c:a", "libvorbis", "-q:a", "0"]}
os.makedirs(os.path.join(CACHE, "audio"), exist_ok=True)
a_before = a_after = a_new = 0
for sub, args in au.items():
    d = os.path.join(SRC, "audio", sub)
    for fn in sorted(os.listdir(d)) if os.path.isdir(d) else []:
        if not fn.endswith(".ogg"):
            continue
        sp = os.path.join(d, fn)
        out = os.path.join(CACHE, "audio", "%s_%s_%s_%s.ogg" % (sub, fn[:-4], src_md5(sp), args[-1]))
        if not os.path.exists(out):
            ffmpeg(["-i", sp, "-map_metadata", "-1"] + args + [out])
        a_before += os.path.getsize(sp)
        a_after += os.path.getsize(out)
        a_new += place(out, os.path.join(A, "audio", sub, fn))
mp = os.path.join(SRC, "audio", "menu_music.mp3")
if os.path.exists(mp):
    out = os.path.join(CACHE, "audio", "menu_music_%s_112k.mp3" % src_md5(mp))
    if not os.path.exists(out):
        ffmpeg(["-i", mp, "-map_metadata", "-1", "-c:a", "libmp3lame", "-b:a", "112k", out])
    a_before += os.path.getsize(mp)
    a_after += os.path.getsize(out)
    a_new += place(out, os.path.join(A, "audio", "menu_music.mp3"))
print("web diet: music and ambience %.1f -> %.1f MB (%d written now)" % (a_before / 1e6, a_after / 1e6, a_new))

# ---------------------------------------------------------------- 4. videos (the Theora fallbacks)
VID = {  # name: ffmpeg args (Theora video, Vorbis audio)
    "intro.ogv": ["-c:v", "libtheora", "-b:v", "2000k", "-c:a", "libvorbis", "-q:a", "2"],
    "logo.ogv": ["-c:v", "libtheora", "-b:v", "1800k", "-c:a", "libvorbis", "-q:a", "2"],
    "menu_loop.ogv": ["-c:v", "libtheora", "-b:v", "1500k", "-an"],
}
os.makedirs(os.path.join(CACHE, "video"), exist_ok=True)
for name, args in VID.items():
    sp = os.path.join(SRC, "intro", name)
    dst = os.path.join(A, "intro", name)
    if not os.path.exists(sp) or not os.path.exists(dst):
        continue
    out = os.path.join(CACHE, "video", name[:-4] + "_" + src_md5(sp) + "_" + hashlib.md5(" ".join(args).encode()).hexdigest()[:6] + ".ogv")
    if not os.path.exists(out):
        ffmpeg(["-i", sp] + args + [out])
    w = place(out, dst)
    print("web diet: video %s %.1f -> %.1f MB%s" % (name, os.path.getsize(sp) / 1e6, os.path.getsize(out) / 1e6, " (written now)" if w else ""))
# the menu loop's still (shown if its WebM cannot play): a frame of the master
ms = "C:/civ/newIntro/menu.mp4"
if os.path.exists(ms):
    out = os.path.join(CACHE, "video", "menu_still_%s.jpg" % src_md5(ms))
    if not os.path.exists(out):
        ffmpeg(["-ss", "2", "-i", ms, "-frames:v", "1", "-q:v", "3", out])
    w = place(out, os.path.join(A, "intro", "menu_still.jpg"))
    print("web diet: menu still%s" % (" (written now)" if w else ""))
json.dump(_md5, open(MD5_CACHE, "w", encoding="utf-8"))
