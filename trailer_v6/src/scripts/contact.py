"""Deliverable contact sheet: one frame every 3 s with timecodes.  python -I contact.py master.mp4 out.jpg"""
import subprocess, sys, io
from PIL import Image, ImageDraw, ImageFont
src, out = sys.argv[1], sys.argv[2]
d = float(subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", src],
                         capture_output=True, text=True).stdout)
ts = [t + 1.5 for t in range(0, int(d - 1), 3)]
w, h, cols = 480, 270, 6
font = ImageFont.truetype("C:/civ/game/assets/fonts/Cinzel.ttf", 16)
rows = (len(ts) + cols - 1) // cols
S = Image.new("RGB", (cols * w, rows * (h + 24) + 50), (8, 14, 30))
dr = ImageDraw.Draw(S)
dr.text((10, 12), "ISRAEL: THE BIRTH OF A NATION  -  cinematic trailer v6  -  one frame every 3 s", fill=(232, 200, 120), font=font)
for k, t in enumerate(ts):
    png = subprocess.run(["ffmpeg", "-v", "error", "-ss", f"{t:.2f}", "-i", src, "-frames:v", "1", "-vf", f"scale={w}:{h}",
                          "-f", "image2pipe", "-vcodec", "png", "-"], capture_output=True).stdout
    im = Image.open(io.BytesIO(png)).convert("RGB")
    x, y = (k % cols) * w, 50 + (k // cols) * (h + 24)
    S.paste(im, (x, y + 24))
    dr.text((x + 6, y + 4), f"{int(t // 60):02d}:{t % 60:04.1f}", fill=(239, 227, 198), font=font)
S.save(out, quality=88)
print("wrote", out, len(ts), "frames")
