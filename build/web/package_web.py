"""Package the web export (build/web/out) into build/web/release/IsraelBirthOfANation_Web.zip for itch.io
("HTML5, run game in browser": index.html at the zip's root) and check it against itch's HTML5 limits:
at most 1,000 files, each extracted file at most 200 MB, at most 500 MB extracted, path names at most 240 characters
(itch.io/docs/creators/html5, read 2026-10-18).
   python -I build/web/package_web.py"""
import os, sys, zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")
REL = os.path.join(HERE, "release")
ZIP = os.path.join(REL, "IsraelBirthOfANation_Web.zip")
MAX_FILES, MAX_FILE, MAX_TOTAL, MAX_PATH = 1000, 200 * 1000 * 1000, 500 * 1000 * 1000, 240
# what the page needs (the export's own files, the loading screen's logo, the WebM videos); nothing else
KEEP_EXT = {".html", ".js", ".wasm", ".pck", ".png", ".webp", ".webm"}
SKIP = {"index.apple-touch-icon.png"}   # (an iOS home-screen icon: not used on itch)


def main():
    files = []
    for dp, dn, fn in os.walk(OUT):
        for f in fn:
            p = os.path.join(dp, f)
            rel = os.path.relpath(p, OUT).replace(os.sep, "/")
            if os.path.splitext(f)[1].lower() in KEEP_EXT and f not in SKIP:
                files.append((p, rel))
    files.sort(key=lambda x: x[1])
    need = {"index.html", "index.js", "index.wasm", "index.pck", "index.audio.worklet.js", "logo.webp"}
    have = {r for _, r in files}
    missing = sorted(need - have)
    if missing:
        sys.exit("missing in out/: %s (run build/web/export.sh)" % ", ".join(missing))
    problems = []
    total = 0
    for p, rel in files:
        sz = os.path.getsize(p)
        total += sz
        if sz > MAX_FILE:
            problems.append("%s is %.1f MB (itch: at most 200 MB per file)" % (rel, sz / 1e6))
        if len(rel) > MAX_PATH:
            problems.append("%s: path longer than %d characters" % (rel, MAX_PATH))
    if len(files) > MAX_FILES:
        problems.append("%d files (itch: at most %d)" % (len(files), MAX_FILES))
    if total > MAX_TOTAL:
        problems.append("%.1f MB extracted (itch: at most 500 MB)" % (total / 1e6))
    if problems:
        sys.exit("itch limits:\n  " + "\n  ".join(problems))
    os.makedirs(REL, exist_ok=True)
    with zipfile.ZipFile(ZIP, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        for p, rel in files:
            # the big binaries barely compress (pck: compressed textures and audio, webm): store them, faster to unzip
            ct = zipfile.ZIP_STORED if rel.endswith((".pck", ".webm", ".webp", ".png")) else zipfile.ZIP_DEFLATED
            z.write(p, rel, compress_type=ct)
    with zipfile.ZipFile(ZIP) as z:
        names = z.namelist()
        assert "index.html" in names, "index.html must be at the zip's root"
        assert not any(n.endswith(".md") or "sources/" in n for n in names)
        biggest = max(z.infolist(), key=lambda i: i.file_size)
    print("%s: %.1f MB zip, %d files, %.1f MB extracted (largest %s %.1f MB)" % (
        os.path.relpath(ZIP, HERE), os.path.getsize(ZIP) / 1e6, len(names), total / 1e6, biggest.filename, biggest.file_size / 1e6))
    print("itch limits: OK (<= %d files, each <= 200 MB, <= 500 MB extracted, paths <= %d chars)" % (MAX_FILES, MAX_PATH))
    for n in names:
        print("  %-36s %8.1f MB" % (n, z.getinfo(n).file_size / 1e6) if False else "  " + n)


if __name__ == "__main__":
    main()
