"""Make jerusalem/coast ambience seamless: cut the faded/lull region, equal-power head/tail crossfade."""
import sys, os, shutil, subprocess
import numpy as np
sys.path.insert(0, 'C:/civ/tools/audio_build')
from loopify import load, levels, SR, FF
AMB = "C:/civ/game/assets/audio/ambience"; ORIG = "C:/civ/tools/audio_build/ambience_orig"
SPEC = {"jerusalem": (2.5, 37.0), "coast": (0.0, 31.0)}
XF = 3.0
for n, (t0, t1) in SPEC.items():
    f = f"{AMB}/{n}.ogg"; o = f"{ORIG}/{n}.ogg"
    if not os.path.exists(o): shutil.copy(f, o)
    x = load(o); body = x[int(t0*SR):int(t1*SR)]; k = int(XF*SR)

    t = np.linspace(0, np.pi/2, k)[:, None]
    head = body[:k]*np.sin(t) + body[-k:]*np.cos(t)
    out = np.concatenate([head, body[k:-k]]).astype(np.float32)
    subprocess.run([FF, "-v", "error", "-y", "-f", "f32le", "-ar", str(SR), "-ac", "2", "-i", "-", "-c:a", "libvorbis", "-q:a", "5", f], input=out.tobytes(), capture_output=True)
    print(n, len(out)/SR)
