"""Draw a loudness envelope + spectrogram of an audio file to a PNG, and print per-2s RMS (dBFS)."""
import sys, subprocess, numpy as np
import matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
src, out = sys.argv[1], sys.argv[2]
sr = 22050
raw = subprocess.run(["ffmpeg", "-v", "error", "-i", src, "-ac", "1", "-ar", str(sr), "-f", "f32le", "-"], capture_output=True).stdout
x = np.frombuffer(raw, np.float32)
hop = sr // 20
rms = np.array([np.sqrt(np.mean(x[i:i + hop] ** 2) + 1e-12) for i in range(0, len(x) - hop, hop)])
db = 20 * np.log10(rms)
t = np.arange(len(db)) / 20
fig, ax = plt.subplots(2, 1, figsize=(22, 8), sharex=True)
ax[0].plot(t, db); ax[0].set_ylim(-60, 0); ax[0].grid(True); ax[0].set_xticks(np.arange(0, t[-1] + 1, 2))
ax[1].specgram(x, NFFT=2048, Fs=sr, noverlap=1024, cmap="magma", vmin=-120); ax[1].set_ylim(0, 6000)
# onset strength (spectral flux)
plt.tight_layout(); plt.savefig(out, dpi=70)
print("dur", len(x) / sr)
print(" ".join(f"{i*2}:{db[i*40:(i+1)*40].mean():.0f}" for i in range(int(len(db) / 40))))
