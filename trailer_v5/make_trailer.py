"""Cut the v5 game trailer from the 16 feature clips, timed to music.mp3 (quiet intro 0-10 s, build 10-29 s,
breath 29-31 s, full climax 31-70 s, tail to 75 s).
   python -I make_trailer.py   ->  C:/civ/trailer_v5/IsraelBirthOfANation_Trailer_v5.mp4"""
import os, subprocess

HERE = "C:/civ/trailer_v5"
F = "C:/civ/features"
MUSIC = HERE + "/music.mp3"
TMT = "C:/civ/newIntro/logo_comp.mp4"
TITLE = "C:/civ/game/assets/intro/title.png"
FONT = "C\\:/civ/game/assets/fonts/Cinzel.ttf"
OUT = HERE + "/IsraelBirthOfANation_Trailer_v5.mp4"
SEG = HERE + "/seg"
os.makedirs(SEG, exist_ok=True)
GOLD = "0xE8C878"


def run(cmd):
    subprocess.run(["ffmpeg", "-v", "error", "-y"] + cmd, check=True)


def caption(text, size=64):
    t = text.replace(":", "\\:").replace("'", "\u2019")
    return (f"drawtext=fontfile='{FONT}':text='{t}':fontsize={size}:fontcolor={GOLD}:"
            f"shadowcolor=black@0.85:shadowx=3:shadowy=3:x=90:y=h-150:"
            f"alpha='if(lt(t,0.25),0,if(lt(t,0.6),(t-0.25)/0.35,1))'")


def clip(name, out, start, length, text, speed=1.0, fade_in=0.0, fade_out=0.0):
    vf = [f"setpts=(PTS-STARTPTS)/{speed}", f"trim=duration={length:.3f}", "setpts=PTS-STARTPTS",
          "scale=1920:1080:flags=lanczos", "fps=30", "eq=saturation=1.06:contrast=1.03"]
    post = []
    if text:
        post.append(caption(text))
    if fade_in:
        post.append(f"fade=t=in:st=0:d={fade_in}")
    if fade_out:
        post.append(f"fade=t=out:st={length - fade_out:.3f}:d={fade_out}")
    post.append("format=yuv420p")
    # a soft dark band under the caption keeps it readable over the game's own panels
    fc = f"[0:v]{','.join(vf)}[c];[1:v]format=rgba[gr];[c][gr]overlay=0:H-h:shortest=1,{','.join(post)}[v]"
    run(["-ss", f"{start:.3f}", "-t", f"{length * speed + 0.3:.3f}", "-i", f"{F}/{name}.mp4",
         "-loop", "1", "-i", HERE + "/grad.png", "-filter_complex", fc, "-map", "[v]", "-t", f"{length:.3f}",
         "-an", "-c:v", "libx264", "-preset", "medium", "-crf", "16", "-r", "30", out])


segs = []
# 1. the creator's logo (starfield -> TMT reveal), 9.5 s
run(["-ss", "5.0", "-t", "9.5", "-i", TMT, "-vf",
     "scale=1920:1080:flags=lanczos,fps=30,fade=t=in:st=0:d=0.8,fade=t=out:st=8.7:d=0.8,format=yuv420p",
     "-an", "-c:v", "libx264", "-preset", "medium", "-crf", "16", "-r", "30", f"{SEG}/00.mp4"])
segs.append(f"{SEG}/00.mp4")
# 2. the build: calm shots with soft fades (9.5 -> 29 s)
build = [("01_lead_israel", 1.5, 3.0, "14 May 1948. Lead a new state.", 1.0),
         ("08_hdplus_graphics", 0.5, 4.0, "A living land", 1.0),
         ("07_day_night", 0.0, 4.0, "From dawn to night", 1.25),
         ("02_story_mode", 1.5, 3.0, "One decision at a time", 1.0),
         ("03_dilemmas", 2.0, 3.0, "Real dilemmas. Real history.", 1.0),
         ("05_era_goals", 2.0, 2.5, "Goals for every era", 1.0)]
for i, (n, st, ln, tx, sp) in enumerate(build):
    p = f"{SEG}/1{i}.mp4"
    clip(n, p, st, ln, tx, sp, fade_in=0.35, fade_out=0.35 if i < len(build) - 1 else 0.6)
    segs.append(p)
# 3. the breath (29 -> 31 s): a centred title card on black
run(["-f", "lavfi", "-t", "2.0", "-i", "color=c=black:s=1920x1080:r=30", "-vf",
     f"drawtext=fontfile='{FONT}':text='75 years. Your choices.':fontsize=72:fontcolor={GOLD}:"
     f"x=(w-text_w)/2:y=(h-text_h)/2:alpha='if(lt(t,0.3),t/0.3,if(gt(t,1.7),(2-t)/0.3,1))',format=yuv420p",
     "-c:v", "libx264", "-preset", "medium", "-crf", "16", f"{SEG}/20.mp4"])
segs.append(f"{SEG}/20.mp4")
# 4. the climax (31 -> 58 s): hard cuts, 3 s each
climax = [("09_wars_fronts", 1.5, "Wars on every front"),
          ("10_diplomacy", 1.5, "Diplomacy with 26 nations"),
          ("04_cabinet_room", 1.5, "Your ministers, your cabinet"),
          ("11_treasury_fail_states", 1.5, "Every shekel counts"),
          ("12_national_programmes", 1.5, "Build the nation's future"),
          ("16_civilopedia", 1.5, "Sourced, factual history"),
          ("15_hebrew_rtl", 1.5, "In English and Hebrew"),
          ("14_scenarios_difficulty", 1.5, "Start in 1948, 1967, 1977 or 1992"),
          ("13_endings_epilogue", 1.5, "Write your own ending")]
for i, (n, st, tx) in enumerate(climax):
    p = f"{SEG}/3{i}.mp4"
    clip(n, p, st, 3.0, tx, 1.0, fade_in=0.08 if i == 0 else 0.0)
    segs.append(p)
# 5. the time-lapse, slowed (58 -> 64.67 s)
clip("06_living_map_timelapse", f"{SEG}/40.mp4", 0.0, 6.67, "1948 \u2013 2023", 0.75, fade_out=0.5)
segs.append(f"{SEG}/40.mp4")
# 6. the end card (64.67 -> 75 s): the game logo over the blurred, darkened night city
END = 75.0 - (9.5 + 19.5 + 2.0 + 27.0 + 6.67)
run(["-ss", "3.0", "-t", "2.0", "-i", f"{F}/07_day_night.mp4", "-loop", "1", "-t", f"{END:.2f}", "-i", TITLE,
     "-filter_complex",
     f"[0:v]setpts=PTS*{END / 2.0:.3f},fps=30,scale=1920:1080,boxblur=12:2,eq=brightness=-0.18:saturation=0.8,"
     f"trim=duration={END:.2f},setpts=PTS-STARTPTS[bg];"
     f"[1:v]scale=1300:-1,format=rgba,fade=t=in:st=0.4:d=1.2:alpha=1[lg];"
     f"[bg][lg]overlay=(W-w)/2:(H-h)/2-60:shortest=1,"
     f"drawtext=fontfile='{FONT}':text='Windows  \u00b7  macOS':fontsize=46:fontcolor={GOLD}:x=(w-text_w)/2:y=h/2+170:"
     f"alpha='if(lt(t,1.6),0,if(lt(t,2.4),(t-1.6)/0.8,1))',"
     f"fade=t=in:st=0:d=0.6,fade=t=out:st={END - 1.6:.2f}:d=1.6,format=yuv420p",
     "-t", f"{END:.2f}", "-c:v", "libx264", "-preset", "medium", "-crf", "16", "-r", "30", f"{SEG}/50.mp4"])
segs.append(f"{SEG}/50.mp4")

with open(f"{SEG}/list.txt", "w") as fh:
    for s in segs:
        fh.write(f"file '{s}'\n")
total = 75.0
run(["-f", "concat", "-safe", "0", "-i", f"{SEG}/list.txt", "-i", MUSIC,
     "-filter_complex", f"[1:a]atrim=0:{total},afade=t=in:st=0:d=0.5,afade=t=out:st={total - 2.5}:d=2.5,"
     "loudnorm=I=-14:TP=-1.0:LRA=11[a]",
     "-map", "0:v", "-map", "[a]", "-c:v", "libx264", "-preset", "slow", "-crf", "18", "-pix_fmt", "yuv420p",
     "-c:a", "aac", "-b:a", "256k", "-movflags", "+faststart", "-t", f"{total}", OUT])
print("wrote", OUT)
