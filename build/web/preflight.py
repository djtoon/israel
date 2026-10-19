"""Pre-flight check before every heavy web-build step (Godot import/export, Blender, ffmpeg, a browser run).
   python -I build/web/preflight.py [--wait MINUTES] [--label text]
Passes (exit 0) when free RAM >= 8 GB, free disk on C: >= 40 GB and the GPU is below 70 C. Otherwise it waits up to
--wait minutes (default 10), re-checking every 15 s, then fails (exit 1) with the reason: the caller stops there."""
import shutil, subprocess, sys, time

RAM_GB, DISK_GB, GPU_C = 8.0, 40.0, 70


def state():
    import psutil
    ram = psutil.virtual_memory().available / 1e9
    disk = shutil.disk_usage("C:/").free / 1e9
    try:
        gpu = int(subprocess.run(["nvidia-smi", "--query-gpu=temperature.gpu", "--format=csv,noheader,nounits"],
                                 capture_output=True, text=True, timeout=15).stdout.split()[0])
    except Exception:
        gpu = -1
    bad = []
    if ram < RAM_GB:
        bad.append("free RAM %.1f GB < %.0f" % (ram, RAM_GB))
    if disk < DISK_GB:
        bad.append("free disk %.1f GB < %.0f" % (disk, DISK_GB))
    if gpu >= GPU_C:
        bad.append("GPU %d C >= %d" % (gpu, GPU_C))
    return ram, disk, gpu, bad


def main():
    wait = 10.0
    label = ""
    a = sys.argv[1:]
    if "--wait" in a:
        wait = float(a[a.index("--wait") + 1])
    if "--label" in a:
        label = a[a.index("--label") + 1]
    t0 = time.time()
    while True:
        ram, disk, gpu, bad = state()
        if not bad:
            print("preflight ok%s: RAM %.1f GB free, disk %.1f GB free, GPU %d C" % (" (" + label + ")" if label else "", ram, disk, gpu), flush=True)
            return 0
        if time.time() - t0 > wait * 60:
            print("PREFLIGHT FAILED%s: %s" % (" (" + label + ")" if label else "", "; ".join(bad)), flush=True)
            return 1
        print("preflight waiting: " + "; ".join(bad), flush=True)
        time.sleep(15)


if __name__ == "__main__":
    sys.exit(main())
