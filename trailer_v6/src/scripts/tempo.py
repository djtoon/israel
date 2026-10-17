import sys, subprocess, numpy as np
src = sys.argv[1]; a, b = float(sys.argv[2]), float(sys.argv[3])
sr = 11025
x = np.frombuffer(subprocess.run(["ffmpeg","-v","error","-i",src,"-ac","1","-ar",str(sr),"-f","f32le","-"],capture_output=True).stdout, np.float32)
hop = 128; n = 1024
frames = np.lib.stride_tricks.sliding_window_view(x, n)[::hop] * np.hanning(n)
S = np.abs(np.fft.rfft(frames, axis=1))
lo = np.log1p(S[:, 1:40]).sum(1)     # < ~430 Hz
fl = np.maximum(np.diff(np.log1p(S), axis=0), 0).sum(1)
fps = sr / hop
def seg(v):
    return v[int(a*fps):int(b*fps)]
o = seg(fl); o = o - o.mean()
ac = np.correlate(o, o, "full")[len(o)-1:]
lags = np.arange(len(ac)) / fps
m = (lags > 0.3) & (lags < 2.1)
best = lags[m][np.argsort(ac[m])[::-1][:8]]
print("top lags s:", np.round(best, 3), "-> bpm", np.round(60 / best, 1))
# strongest onsets
ol = np.diff(lo); ol[ol < 0] = 0
idx = np.argsort(seg(ol))[::-1][:30]
print("strong low onsets:", sorted(np.round(a + idx / fps, 2)))
