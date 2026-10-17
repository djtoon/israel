"""python redraw.py gen <event_id> "<scene notes>" [style_ref_name]   -> writes progress/event_refs/new/<id>.png (and a 768 preview <id>_768.png)
   python redraw.py accept <event_id>  -> copies new/<id>.png into game/assets/images/events/ (+ _768)
Ref photo = progress/event_refs/<id>.jpg|png. Style refs: six_day_war (default, landscape/action) or oslo_i (portrait/people)."""
import sys, os, glob, subprocess, shutil
from PIL import Image
R = "C:/civ/progress/event_refs"; G = "C:/civ/game/assets/images/events"
cmd, eid = sys.argv[1], sys.argv[2]
os.makedirs(R + "/new", exist_ok=True)
if cmd == "gen":
    notes = sys.argv[3]; style = sys.argv[4] if len(sys.argv) > 4 else "six_day_war"
    ref = [p for p in glob.glob(f"{R}/{eid}.*") if p.endswith((".jpg", ".png", ".jpeg"))][0]
    prompt = ("Repaint the first reference photo as a warm painterly historical illustration in the exact style of the second reference "
        "(palette, brushwork, lighting, navy and gold warmth); keep the real composition, places, clothing, vehicles and people's arrangement from the photo; "
        "public figures recognisable and shown respectfully; dignified and neutral; no graphic violence, no text, no captions, no signs with lettering, no watermarks; 16:9 widescreen. "
        + notes)
    out = f"{R}/new/{eid}.png"
    subprocess.run(["python", "C:/civ/tools/gen.py", "image", prompt, out, "--ref", ref, "--ref", f"{R}/orig/evt_1967_{style}.png" if style == "six_day_war" else f"{R}/orig/evt_1993_{style}.png",
        "--aspect", "16:9", "--quality", "high"], check=True)
    im = Image.open(out).convert("RGB"); print(im.size)
    im.resize((768, 432), Image.LANCZOS).save(f"{R}/new/{eid}_768.png")
elif cmd == "accept":
    im = Image.open(f"{R}/new/{eid}.png").convert("RGB").resize((1536, 864), Image.LANCZOS)
    im.save(f"{G}/{eid}.png"); im.resize((768, 432), Image.LANCZOS).save(f"{G}/{eid}_768.png"); print("accepted", eid)
