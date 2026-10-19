"""Run a command at below-normal priority with a silence watchdog (used as tools/godot.sh's GODOT_EXE through
build/web/godot_low.sh, so the GPU slots and the temperature watchdog stay godot.sh's).
   python -I lowprio.py <exe> [args...]
Env: LOWPRIO_SILENCE=<s> (default 180): no output for that long = a hang: this one process tree is killed (by PID,
only the child this script started) and the exit code is 124. LOWPRIO_LOG=<path> also appends the output there."""
import os, subprocess, sys, threading, time

sys.stdout.reconfigure(encoding="utf-8", errors="replace")   # (Godot prints Hebrew; the cp1252 console crashed the pump)
exe, args = sys.argv[1], sys.argv[2:]
silence = float(os.environ.get("LOWPRIO_SILENCE", "180"))
log = os.environ.get("LOWPRIO_LOG", "")
flags = getattr(subprocess, "BELOW_NORMAL_PRIORITY_CLASS", 0)
p = subprocess.Popen([exe] + args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, creationflags=flags)
last = [time.time()]
lf = open(log, "a", encoding="utf-8", errors="replace") if log else None


def pump():
    for raw in iter(p.stdout.readline, b""):
        last[0] = time.time()
        s = raw.decode("utf-8", "replace")
        sys.stdout.write(s)
        sys.stdout.flush()
        if lf:
            lf.write(s)
            lf.flush()


t = threading.Thread(target=pump, daemon=True)
t.start()
hung = False
while p.poll() is None:
    time.sleep(2)
    if time.time() - last[0] > silence:
        hung = True
        msg = "LOWPRIO: no output for %d s: killing the hung process tree (pid %d)\n" % (silence, p.pid)
        sys.stdout.write(msg)
        if lf:
            lf.write(msg)
        subprocess.run(["taskkill", "/F", "/T", "/PID", str(p.pid)], capture_output=True)
        break
t.join(timeout=5)
sys.exit(124 if hung else (p.returncode or 0))
