"""Package the full-game exports in out/ into release/ zips (game only: no sources, no dev files)."""
import zipfile, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
OUT, REL = os.path.join(HERE, "out"), os.path.join(HERE, "release")
HEAD = """Israel (1948-2023)
===============================================

Lead the State of Israel from 14 May 1948 to 2023, one quarter per turn. English and Hebrew.
Full control (the default) or Story mode, where your ministers run the routine and the gold NOW button shows the one thing that needs you.
A real-time day and night cycle (Settings > Display: time of day, day length, pause the clock).
Start with New Game -> Tutorial for your first game. F1 = help, F5 = quick-save, F9 = quick-load.
The game starts full screen; F11 or Alt+Enter switches between full screen and a window.

History in the game is factual and sourced; every event shows its citation ids.

"""
WIN = """WINDOWS
- Unzip the whole folder, then double-click IsraelBirthOfANation.exe.
  Keep IsraelBirthOfANation.pck next to the .exe.
- The game is not code-signed, so Windows SmartScreen may warn "Windows protected your PC":
  click "More info" -> "Run anyway".
"""
MAC = """macOS (Intel and Apple Silicon)
- Unzip, then drag "Israel.app" to Applications.
- The game is not notarized by Apple, so the first launch is blocked. Right-click the app ->
  Open -> Open. If macOS still says the app is damaged, run in Terminal:
      xattr -cr "/Applications/Israel.app"
  and open it again.
"""
TAIL = "\nSystem: 64-bit, a GPU with Vulkan (Windows) or Metal (macOS) support, about 2 GB free disk space.\n"
os.makedirs(REL, exist_ok=True)
D = zipfile.ZIP_DEFLATED

w = os.path.join(REL, "IsraelBirthOfANation_Windows.zip")
with zipfile.ZipFile(w, "w", D, compresslevel=6) as z:
    for f in ("IsraelBirthOfANation.exe", "IsraelBirthOfANation.pck"):
        z.write(os.path.join(OUT, "windows", f), "IsraelBirthOfANation/" + f)
    z.writestr("IsraelBirthOfANation/README.txt", (HEAD + WIN + TAIL).replace("\n", "\r\n"))

m = os.path.join(REL, "IsraelBirthOfANation_macOS.zip")
with zipfile.ZipFile(os.path.join(OUT, "macos", "IsraelBirthOfANation.zip")) as src, zipfile.ZipFile(m, "w", D, compresslevel=6) as z:
    for info in src.infolist():          # copy entries with their ZipInfo so the unix exec bits survive
        z.writestr(info, src.read(info.filename), compress_type=D)
    z.writestr("README.txt", HEAD + MAC + TAIL)

for p in (w, m):
    with zipfile.ZipFile(p) as z:
        names = z.namelist()
        assert not any("sources" in n.split("/")[:-1] or n.endswith(".md") for n in names), p
        print(os.path.basename(p), round(os.path.getsize(p) / 1e6, 1), "MB,", len(names), "files")
