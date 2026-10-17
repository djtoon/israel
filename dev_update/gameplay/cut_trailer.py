"""Cut a gameplay-only trailer from the recorded clips, timed to the trailer music (120 BPM, first beat 0.088 s).
   python cut_trailer.py   ->  ../IsraelBirthOfANation_GameplayTrailer.mp4"""
import os, subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
MUSIC = os.path.join(HERE, "..", "video", "assets", "trailer_music.mp3")
LOGO = os.path.join(HERE, "..", "video", "assets", "logo.png")
OUT = os.path.join(HERE, "..", "IsraelBirthOfANation_GameplayTrailer.mp4")
B = lambda k: 0.088 + 0.5 * k          # beat k
# (clip, start in clip, length in the cut, speed)  -- section ends land on the music's beats and hits
segs = [
    ("01_jaffa_orbit_1948", 0.6, 8.03, 1.0),               # quiet piano intro
    ("03_jerusalem_1948_push", 0.3, B(32) - 8.03, 1.0),     # first hit -> the drop
    ("02_coast_flight_north", 1.0, 4.0, 1.25),             # drop: one shot per bar
    ("04_ramon_flyover", 0.5, 4.0, 1.0),
    ("06_gameplay_turn1_hud", 2.0, 4.0, 1.0),
    ("07_gameplay_1967_hud", 3.0, 2.0, 1.0),
    ("09_haifa_2023", 1.0, 4.0, 1.0),
    ("05_telaviv_timelapse_1948_2023", 0.8, 12.0, 1.85),   # soaring strings: 1948 -> 2023
    ("08_telaviv_2023_orbit", 0.5, 6.0, 1.0),
    ("10_jerusalem_2023", 0.8, 4.0, 1.0),
]
for i, c in enumerate(["02_coast_flight_north", "08_telaviv_2023_orbit", "04_ramon_flyover", "01_jaffa_orbit_1948", "09_haifa_2023", "10_jerusalem_2023"]):
    segs.append((c, 5.0 + i * 0.4, 0.5, 1.4))             # half-beat strobe into the final hit
segs.append(("08_telaviv_2023_orbit", 7.0, 3.6, 0.8))       # final hit at ~59 s: slow drift + logo
total = sum(s[2] for s in segs)

inputs, parts = [], []
for i, (clip, st, ln, sp) in enumerate(segs):
    inputs += ["-ss", f"{st:.3f}", "-t", f"{ln * sp + 0.2:.3f}", "-i", os.path.join(HERE, clip + ".mp4")]
    parts.append(f"[{i}:v]setpts=(PTS-STARTPTS)/{sp},trim=duration={ln:.3f},setpts=PTS-STARTPTS,"
                 f"scale=1920:1080:flags=lanczos,fps=30,format=yuv420p[v{i}]")
n = len(segs)
fc = ";".join(parts) + ";" + "".join(f"[v{i}]" for i in range(n)) + f"concat=n={n}:v=1:a=0[cat]"
# warm grade, quick flash on the drop and final hit, fades, logo on the last shot
t_final = total - segs[-1][2]
fc += (f";[cat]eq=saturation=1.08:contrast=1.04,"
       f"fade=t=in:st=0:d=1.2,fade=t=out:st={total - 1.4:.2f}:d=1.4[g]")
fc += (f";[{n}:v]scale=1150:-1,format=rgba,fade=t=in:st=0:d=0.8:alpha=1[lg]"
       f";[g][lg]overlay=(W-w)/2:(H-h)/2-30:enable='gte(t,{t_final:.2f})':shortest=0[vout]")
inputs += ["-loop", "1", "-t", f"{segs[-1][2]:.2f}", "-i", LOGO]
inputs += ["-i", MUSIC]
fc += f";[{n + 1}:a]atrim=0:{total:.2f},afade=t=out:st={total - 2.2:.2f}:d=2.2[aout]"
# the logo stream starts at 0 in its own time: shift it to the final shot
fc = fc.replace(f"[{n}:v]scale=1150:-1", f"[{n}:v]setpts=PTS-STARTPTS+{t_final:.2f}/TB,scale=1150:-1")
cmd = ["ffmpeg", "-v", "error", "-y"] + inputs + ["-filter_complex", fc, "-map", "[vout]", "-map", "[aout]",
       "-c:v", "libx264", "-preset", "slow", "-crf", "19", "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "192k",
       "-movflags", "+faststart", "-t", f"{total:.2f}", OUT]
subprocess.run(cmd, check=True)
print("wrote", OUT, f"{total:.2f}s", n, "shots")
