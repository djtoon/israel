import sys, os, subprocess, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from jobs import J
FF = "ffmpeg"
RAW = "C:/civ/progress/audio_raw"
DST = "C:/civ/game/assets/audio"
for d in ("music", "stingers", "ambience", "sfx"):
    os.makedirs(f"{DST}/{d}", exist_ok=True)


def dur(p):
    return float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", p]).decode())


def run(args):
    r = subprocess.run([FF, "-y", "-v", "error"] + args, capture_output=True, text=True)
    if r.returncode:
        print(r.stderr)


def loopify(src, dst_wav, x):
    L = dur(src)
    fc = (f"[0:a]atrim={x}:{L-x},asetpts=PTS-STARTPTS[body];"
          f"[0:a]atrim={L-x}:{L},asetpts=PTS-STARTPTS[tail];[0:a]atrim=0:{x},asetpts=PTS-STARTPTS[head];"
          f"[tail][head]acrossfade=d={x}:c1=tri:c2=tri[x];[body][x]concat=n=2:v=0:a=1[o]")
    run(["-i", src, "-filter_complex", fc, "-map", "[o]", dst_wav])


manifest = []
tmp = "C:/civ/progress/audio_raw/tmp"
os.makedirs(tmp, exist_ok=True)
for n, (cat, prompt, secs, loop, use) in J.items():
    src = f"{RAW}/{n}.mp3"
    out = f"{DST}/{cat}/{n}.ogg"
    if cat == "music":
        loopify(src, f"{tmp}/{n}.wav", 4.0)
        run(["-i", f"{tmp}/{n}.wav", "-af", "loudnorm=I=-16:TP=-1.5:LRA=11", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "5", out])
    elif cat == "ambience":
        loopify(src, f"{tmp}/{n}.wav", 3.0)
        run(["-i", f"{tmp}/{n}.wav", "-af", "loudnorm=I=-24:TP=-3:LRA=11", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "5", out])
    else:
        L = min(dur(src), 8.0)
        run(["-i", src, "-t", str(L), "-af", f"afade=t=out:st={max(0,L-0.8)}:d=0.8,loudnorm=I=-18:TP=-3:LRA=7", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "5", out])
    manifest.append({"file": f"{cat}/{n}.ogg", "prompt": prompt, "duration": round(dur(out), 2), "loop": loop, "use": use, "source": "elevenlabs/music via tools/gen.py"})
# sfx
for f in sorted(os.listdir(f"{tmp}/sfx")):
    n = f[:-4]
    out = f"{DST}/sfx/{n}.ogg"
    run(["-i", f"{tmp}/sfx/{f}", "-ar", "44100", "-c:a", "libvorbis", "-q:a", "5", out])
    manifest.append({"file": f"sfx/{n}.ogg", "prompt": "synthesised in Python (tools/audio_build/synth_sfx.py)", "duration": round(dur(out), 3), "loop": False, "use": "UI/city SFX: " + n, "source": "numpy synthesis"})
json.dump({"loudness": "music -16 LUFS, ambience -24 LUFS, stingers -18 LUFS (TP<=-3), sfx peak <=-3 dBFS", "files": manifest}, open(f"{DST}/AUDIO_MANIFEST.json", "w", encoding="utf8"), indent=1)
print(len(manifest), "files")
