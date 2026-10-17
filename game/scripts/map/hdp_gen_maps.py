"""HD effects (hdplus.gd): generates the two procedural textures the hdplus effects use (no new art).

  assets/textures/hd/hdp_clouds.png    512x512 tileable cloud-cover mask (FFT-filtered noise, soft fbm look)
  assets/textures/hd/hdp_caustics.png  512x512 tileable caustics (photons refracted through a periodic wave
                                        heightfield and splatted with wrap-around, so the pattern tiles)

Run:  python scripts/map/hdp_gen_maps.py   (from the game/ folder)
"""
import os
import numpy as np
from PIL import Image

OUT = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "textures", "hd")
N = 512
rng = np.random.default_rng(1948)


def periodic_noise(n, beta, lo=1.0, hi=None):
    """tileable noise with a 1/f^beta spectrum (band-limited)"""
    f = np.fft.fftfreq(n) * n
    fx, fy = np.meshgrid(f, f)
    r = np.sqrt(fx * fx + fy * fy)
    amp = np.where(r >= lo, 1.0 / np.maximum(r, 1e-6) ** beta, 0.0)
    if hi:
        amp *= np.exp(-(r / hi) ** 2)
    ph = rng.uniform(0, 2 * np.pi, (n, n))
    spec = amp * np.exp(1j * ph)
    img = np.real(np.fft.ifft2(spec))
    img -= img.min()
    img /= img.max()
    return img


def clouds():
    # continuous fbm-like field (all octaves); the shaders threshold it into soft clumps (coverage, softness)
    a = periodic_noise(N, 1.8, lo=1.0, hi=110.0)
    a = (a - a.mean()) / a.std()
    c = np.clip(0.5 + a * 0.2, 0.0, 1.0)
    Image.fromarray((c * 255).astype(np.uint8), "L").save(os.path.join(OUT, "hdp_clouds.png"))


def caustics():
    h = periodic_noise(N, 2.2, lo=3.0, hi=26.0)
    gy, gx = np.gradient(h)
    # wrap-correct gradients at the borders
    gx = (np.roll(h, -1, 1) - np.roll(h, 1, 1)) * 0.5
    gy = (np.roll(h, -1, 0) - np.roll(h, 1, 0)) * 0.5
    k = 2600.0 / max(np.abs(gx).max(), np.abs(gy).max()) * 0.012
    acc = np.zeros((N, N))
    ss = 3  # photons per texel per axis
    for oy in range(ss):
        for ox in range(ss):
            ys, xs = np.mgrid[0:N, 0:N].astype(float)
            ys += (oy + 0.5) / ss
            xs += (ox + 0.5) / ss
            px = xs + gx * k
            py = ys + gy * k
            ix = np.floor(px).astype(int) % N
            iy = np.floor(py).astype(int) % N
            np.add.at(acc, (iy, ix), 1.0)
    # soften, keep the bright filaments
    f = np.fft.fftfreq(N) * N
    fx, fy = np.meshgrid(f, f)
    blur = np.exp(-(fx * fx + fy * fy) / (2 * 70.0 ** 2))
    acc = np.real(np.fft.ifft2(np.fft.fft2(acc) * blur))
    acc /= np.percentile(acc, 99.3)
    acc = np.clip(acc, 0, 1) ** 1.25
    Image.fromarray((acc * 255).astype(np.uint8), "L").save(os.path.join(OUT, "hdp_caustics.png"))


if __name__ == "__main__":
    clouds()
    caustics()
    print("wrote hdp_clouds.png, hdp_caustics.png to", os.path.abspath(OUT))
