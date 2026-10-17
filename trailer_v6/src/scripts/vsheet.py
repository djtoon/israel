"""Frame strip of videos: python vsheet.py out.jpg n_frames v1.mp4 v2.mp4 ..."""
import sys, subprocess, json, os
from PIL import Image, ImageDraw
out, n, vids = sys.argv[1], int(sys.argv[2]), sys.argv[3:]
W = 400
rows = []
for v in vids:
    d = float(subprocess.run(["ffprobe","-v","error","-show_entries","format=duration","-of","csv=p=0",v],capture_output=True,text=True).stdout)
    fr = []
    for k in range(n):
        t = d * (k + 0.5) / n
        p = subprocess.run(["ffmpeg","-v","error","-ss",f"{t:.2f}","-i",v,"-frames:v","1","-vf",f"scale={W}:-2","-f","image2pipe","-vcodec","png","-"],capture_output=True).stdout
        import io; fr.append(Image.open(io.BytesIO(p)).convert("RGB"))
    rows.append((os.path.basename(v), fr))
h = max(f.height for _, fr in rows for f in fr) + 16
sheet = Image.new("RGB", (W * n, h * len(rows)), (8, 10, 20)); d = ImageDraw.Draw(sheet)
for r, (name, fr) in enumerate(rows):
    for k, f in enumerate(fr): sheet.paste(f, (k * W, r * h + 16))
    d.text((4, r * h + 2), name, fill=(255, 210, 120))
sheet.save(out, quality=88)
