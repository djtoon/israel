"""The web build's videos as WebM (VP9 + Opus) files beside index.html, streamed by an HTML <video> element
(scripts/ui/web_video.gd; Godot itself plays only Ogg Theora, decoded on the CPU in WASM).
   python -I build/web/web_video.py        -> build/web/out/video/{logo,intro,menu}.webm (cached in build/web/cache/webm)
Sources: the 720p H.264 masters in newIntro/ (the .ogv files in game/assets/intro were made from them).
One ffmpeg at a time, 4 threads, below-normal priority."""
import hashlib, os, shutil, subprocess, sys

ROOT = "C:/civ"
OUT = ROOT + "/build/web/out/video"
CACHE = ROOT + "/build/web/cache/webm"
LOW = getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
# name: (master, ffmpeg args). 1280x720 24 fps like the masters; CRF picked by eye at 1280x720 to 1080p.
VIDS = {
    "logo": ("newIntro/logo_comp.mp4", ["-c:v", "libvpx-vp9", "-b:v", "0", "-crf", "34", "-c:a", "libopus", "-b:a", "96k"]),
    # the intro: the 2026-10-18 cut, which ends on the game's new name ("Israel")
    "intro": ("newIntro/tmpexxpe_pc.mp4", ["-c:v", "libvpx-vp9", "-b:v", "0", "-crf", "34", "-c:a", "libopus", "-b:a", "96k"]),
    "menu": ("newIntro/menu.mp4", ["-c:v", "libvpx-vp9", "-b:v", "0", "-crf", "38", "-an"]),
}
COMMON = ["-row-mt", "1", "-deadline", "good", "-cpu-used", "3", "-pix_fmt", "yuv420p", "-threads", "4"]


def main():
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(CACHE, exist_ok=True)
    total = 0
    for name, (src, args) in VIDS.items():
        sp = os.path.join(ROOT, src)
        key = hashlib.md5((str(os.path.getsize(sp)) + str(os.path.getmtime(sp)) + " ".join(args + COMMON)).encode()).hexdigest()[:10]
        cached = os.path.join(CACHE, "%s_%s.webm" % (name, key))
        if not os.path.exists(cached):
            tmp = cached + ".part.webm"
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", sp] + args + COMMON + [tmp], check=True, creationflags=LOW)
            os.replace(tmp, cached)
        dst = os.path.join(OUT, name + ".webm")
        if not os.path.exists(dst) or os.path.getsize(dst) != os.path.getsize(cached):
            shutil.copyfile(cached, dst)
        total += os.path.getsize(dst)
        print("webm: %s %.1f MB (master %.1f MB)" % (name, os.path.getsize(dst) / 1e6, os.path.getsize(sp) / 1e6))
    for f in os.listdir(OUT):   # a video no longer listed leaves the page (and the zip)
        if f.endswith(".webm") and f[:-5] not in VIDS:
            os.remove(os.path.join(OUT, f))
            print("webm: removed %s" % f)
    print("webm: total %.1f MB" % (total / 1e6))


if __name__ == "__main__":
    sys.exit(main())
