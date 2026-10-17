"""2.5D camera moves on the game's painted illustrations that show real people (camera, parallax and light only:
no generated motion on any face). A soft depth split gives the lower rows a little more push than the back wall,
then god rays and drifting dust are added in light.
   python -I paint25d.py  ->  C:/civ/trailer_v6/src/stills/hall_25d.mp4, treaty_25d.mp4"""
import numpy as np, cv2, subprocess

EV = "C:/civ/game/assets/images/events/"
OUT = "C:/civ/trailer_v6/src/stills/"
W, H, FPS = 1920, 1080, 24
rng = np.random.default_rng(14)


def ease(u):
    return u * u * (3 - 2 * u)


def warp(img, s, cx, cy, ox=0.0, oy=0.0):
    """scale img (already W x H) by s about (cx,cy) in output pixels, plus offset"""
    M = np.float32([[s, 0, cx - s * cx + ox], [0, s, cy - s * cy + oy]])
    return cv2.warpAffine(img, M, (W, H), flags=cv2.INTER_LANCZOS4, borderMode=cv2.BORDER_REFLECT)


def render(name, src, dur, s0, s1, cx, cy, split_y, fg_extra, rays_from=None, ray_tint=(1.0, 0.85, 0.6), dust=220,
           pan=(0, 0)):
    im = cv2.imread(EV + src, cv2.IMREAD_COLOR)
    base = cv2.resize(im, (W, H), interpolation=cv2.INTER_LANCZOS4)
    blur = cv2.GaussianBlur(base, (0, 0), 1.0)
    base = cv2.addWeighted(base, 1.45, blur, -0.45, 0)  # gentle sharpen after the upscale
    yy = np.arange(H)[:, None].astype(np.float32)
    mask = np.clip((yy - split_y) / 160.0 + 0.5, 0, 1)  # 0 back wall .. 1 foreground rows
    mask = np.repeat(mask, W, 1)[..., None]
    n = int(dur * FPS)
    # dust motes
    P = dust
    px, py = rng.uniform(0, W, P), rng.uniform(0, H, P)
    pv = rng.uniform(-6, 6, (P, 2)) + np.array([4, -3])
    pr = rng.uniform(1.0, 3.2, P)
    pa = rng.uniform(0.15, 0.6, P)
    ff = subprocess.Popen(["ffmpeg", "-v", "error", "-y", "-f", "rawvideo", "-pix_fmt", "bgr24", "-s", f"{W}x{H}",
                           "-r", str(FPS), "-i", "-", "-c:v", "libx264", "-preset", "slow", "-crf", "12",
                           "-pix_fmt", "yuv420p", OUT + name + ".mp4"], stdin=subprocess.PIPE)
    for i in range(n):
        u = ease(i / (n - 1)) * 0.85 + 0.15 * (i / (n - 1))
        s = s0 + (s1 - s0) * u
        ox, oy = pan[0] * u, pan[1] * u
        back = warp(base, s, cx, cy, ox, oy).astype(np.float32)
        fore = warp(base, s * (1 + fg_extra * u), cx, cy, ox * 1.3, oy * 1.3).astype(np.float32)
        fr = back * (1 - mask) + fore * mask
        light = np.zeros((H, W), np.float32)
        if rays_from is not None:
            rx, ry = rays_from
            Y, X = np.mgrid[0:H:4, 0:W:4].astype(np.float32)
            ang = np.arctan2(Y - ry, X - rx)
            dist = np.hypot(X - rx, Y - ry)
            t = i / FPS
            rays = (0.55 + 0.45 * np.sin(ang * 23 + t * 0.35)) * (0.6 + 0.4 * np.sin(ang * 9 - t * 0.22 + 1.3))
            rays = rays ** 3 * np.exp(-dist / 1300.0)
            rays = cv2.resize(cv2.GaussianBlur(rays, (0, 0), 3), (W, H))
            light += rays * 0.32
        # dust
        dl = np.zeros((H, W), np.float32)
        pxx = (px + pv[:, 0] * i / FPS) % W
        pyy = (py + pv[:, 1] * i / FPS + 4 * np.sin(i / FPS * 0.8 + px)) % H
        for k in range(P):
            cv2.circle(dl, (int(pxx[k]), int(pyy[k])), int(pr[k]), float(pa[k]), -1, cv2.LINE_AA)
        dl = cv2.GaussianBlur(dl, (0, 0), 1.6)
        light += dl * (0.35 + 1.2 * light)
        tint = np.array(ray_tint, np.float32)[::-1]  # BGR
        fr = fr + (light[..., None] * 255 * tint)
        ff.stdin.write(np.clip(fr, 0, 255).astype(np.uint8).tobytes())
    ff.stdin.close(); ff.wait()
    print("wrote", name)


if __name__ == "__main__":
    import os; os.makedirs(OUT, exist_ok=True)
    render("hall_25d", "evt_1948_independence.png", 8.0, 1.02, 1.16, 980, 470, 640, 0.035, rays_from=(1500, -150))
    render("treaty_25d", "evt_1979_egypt_peace_treaty.png", 3.0, 1.03, 1.10, 960, 500, 760, 0.03,
           rays_from=(200, -200), dust=120)
