"""Drive the web build in a real browser with Playwright: load, (optionally) run a UI test suite through user args,
read the console, take screenshots, sample fps and memory.

Always run it through the GPU slot wrapper (a browser rendering the game counts as a Godot instance):
   GODOT_EXE=/c/civ/build/web/browser_slot.sh GODOT_OWNER=web tools/godot.sh --headless <these args>
   --browser chrome|msedge|firefox   --args "--ui-test=/tmp/ut,--ui-test-turns=40"   --preload "/__test/x.json>/tmp/x.json"
   --until "UITEST FAILURES"   --timeout 900   --shot-every 60   --tag en40   --out <dir>   --scenario uitest|play|...
GPU safety: starts only below 70 C and stops the run (closing the browser) at 76 C. Windowed 1280x720, one browser."""
import argparse, json, os, re, subprocess, sys, threading, time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import serve  # noqa: E402

START_MAX_C, STOP_C = 70, 76


def gpu_temp():
    try:
        out = subprocess.run(["nvidia-smi", "--query-gpu=temperature.gpu", "--format=csv,noheader,nounits"],
                             capture_output=True, text=True, timeout=10).stdout.strip().splitlines()
        return int(out[0])
    except Exception:
        return -1


class Guard(threading.Thread):
    def __init__(self):
        super().__init__(daemon=True)
        self.abort = False
        self.max_t = 0
        self.temps = []

    def run(self):
        while not self.abort:
            t = gpu_temp()
            self.temps.append((time.time(), t))
            self.max_t = max(self.max_t, t)
            if t >= STOP_C:
                print("GUARD: GPU at %d C (>= %d): stopping the browser run" % (t, STOP_C), flush=True)
                self.abort = True
                return
            time.sleep(3)


def browser_mem(name_hint):
    """(tab renderer MB, all browser processes MB) for the browser Playwright launched (its temp profile)."""
    try:
        import psutil
    except Exception:
        return (-1, -1)
    tab = 0
    tot = 0
    for p in psutil.process_iter(["name", "cmdline", "memory_info"]):
        try:
            cl = " ".join(p.info["cmdline"] or [])
            if "playwright" not in cl.lower() and "ms-playwright" not in cl.lower():
                continue
            if not any(k in (p.info["name"] or "").lower() for k in ("chrome", "msedge", "firefox")):
                continue
            mi = p.info["memory_info"]
            priv = getattr(mi, "private", mi.rss)
            tot += priv
            if "--type=renderer" in cl or "-contentproc" in cl and "tab" in cl:
                tab = max(tab, priv)
        except Exception:
            pass
    return (round(tab / 1048576), round(tot / 1048576))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--browser", default="chrome")
    ap.add_argument("--args", default="")
    ap.add_argument("--preload", default="")
    ap.add_argument("--viewport", default="1280x720")
    ap.add_argument("--dsf", type=float, default=1.0, help="device scale factor (1.5 = a 150 % laptop display)")
    ap.add_argument("--eargs", default="", help="engine args, comma separated (e.g. --max-fps,20: cooler test runs)")
    ap.add_argument("--until", default="UITEST FAILURES")
    ap.add_argument("--timeout", type=float, default=600)
    ap.add_argument("--shot-every", type=float, default=0)
    ap.add_argument("--tag", default="run")
    ap.add_argument("--out", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "runs"))
    ap.add_argument("--scenario", default="uitest")
    ap.add_argument("--port", type=int, default=8060)
    ap.add_argument("--root", default="C:/civ/build/web/out")
    # this laptop has two GPUs: browsers default to the integrated AMD Radeon 610M; "high" forces the RTX 5070
    # (Chrome / Edge flag; what a player gets with Windows Settings > Graphics > High performance for the browser)
    # "low": the integrated GPU even though the page asks for high performance (?pp=low-power: the worst case, a
    # laptop with no discrete GPU); "default": no flag, the page's own powerPreference hint decides
    ap.add_argument("--gpu", default="high", choices=["high", "default", "low"])
    ap.add_argument("--no-autostart", action="store_true")
    ap.add_argument("--device", default="", help="a Playwright device (e.g. \"Pixel 7\", \"iPhone 14 landscape\"): its viewport, pixel ratio, touch and user agent")
    ap.add_argument("--headless-browser", action="store_true")
    a, rest = ap.parse_known_args()
    try:   # below-normal priority for this run and the browser it starts (children inherit it)
        import psutil
        psutil.Process().nice(psutil.BELOW_NORMAL_PRIORITY_CLASS)
    except Exception:
        pass
    os.makedirs(a.out, exist_ok=True)
    t = gpu_temp()
    waited = 0
    while t >= START_MAX_C and waited < 1800:
        if waited % 60 == 0:
            print("GUARD: GPU at %d C, waiting to cool below %d C" % (t, START_MAX_C), flush=True)
        time.sleep(5)
        waited += 5
        t = gpu_temp()
    if t >= START_MAX_C:
        print("GUARD: GPU never cooled; not starting", flush=True)
        return 3
    srv = serve.serve(a.port, a.root)
    from playwright.sync_api import sync_playwright
    guard = Guard()
    guard.start()
    log_path = os.path.join(a.out, a.tag + "_console.log")
    logf = open(log_path, "w", encoding="utf-8")
    lines = []
    summary = {"tag": a.tag, "browser": a.browser, "args": a.args, "gpu_start_c": t}
    q = {}
    if a.args:
        q["args"] = a.args
    if a.preload:
        q["preload"] = a.preload
    if a.eargs:
        q["eargs"] = a.eargs
    if not a.no_autostart:
        q["autostart"] = "1"
    if a.gpu == "low":
        q["pp"] = "low-power"
    from urllib.parse import urlencode
    url = "http://127.0.0.1:%d/index.html?%s" % (a.port, urlencode(q))
    with sync_playwright() as pw:
        common = ["--window-size=1296,840", "--window-position=60,40", "--disable-features=CalculateNativeWinOcclusion",
                  "--disable-backgrounding-occluded-windows", "--disable-renderer-backgrounding",
                  "--disable-background-timer-throttling", "--autoplay-policy=user-gesture-required",
                  "--enable-precise-memory-info"]
        if a.browser == "firefox":
            br = pw.firefox.launch(headless=a.headless_browser)
        elif a.browser == "webkit":
            br = pw.webkit.launch(headless=a.headless_browser)
        else:
            br = pw.chromium.launch(channel=a.browser, headless=a.headless_browser,
                                    args=common + (["--force_high_performance_gpu"] if a.gpu == "high" else []))
        vw, vh = [int(x) for x in a.viewport.split("x")]
        if a.device:
            dev = dict(pw.devices[a.device])
            if a.browser != "webkit":
                dev.pop("default_browser_type", None)
            else:
                dev.pop("default_browser_type", None)
            ctx = br.new_context(**dev, accept_downloads=True)
            summary["device"] = a.device
        else:
            ctx = br.new_context(viewport={"width": vw, "height": vh}, device_scale_factor=a.dsf, accept_downloads=True)
        page = ctx.new_page()
        # time Godot's main-loop callbacks (requestAnimationFrame): long callbacks = CPU (WASM) bound, short callbacks
        # with long intervals = GPU bound
        page.add_init_script("""(() => {
            const raf = window.requestAnimationFrame.bind(window);
            const S = window.ibnRaf = { cb: [], iv: [], last: 0 };
            window.requestAnimationFrame = function (f) {
                return raf(function (t) {
                    const a = performance.now();
                    if (S.last) { S.iv.push(a - S.last); if (S.iv.length > 600) S.iv.shift(); }
                    S.last = a;
                    try { f(t); } finally { S.cb.push(performance.now() - a); if (S.cb.length > 600) S.cb.shift(); }
                });
            };
            window.ibnRafStats = function () {
                const med = (x) => { const s = x.slice().sort((p, q) => p - q); return s.length ? s[Math.floor(s.length / 2)] : 0; };
                const r = { cb_ms: med(S.cb.slice(-20)), interval_ms: med(S.iv.slice(-20)) };
                return r;
            };
        })();""")
        t0 = time.time()

        def on_console(m):
            s = "[%7.1f] %s: %s" % (time.time() - t0, m.type, m.text)
            lines.append(s)
            logf.write(s + "\n")
            logf.flush()
        page.on("console", on_console)
        page.on("pageerror", lambda e: on_console(type("M", (), {"type": "pageerror", "text": str(e)})()))
        page.goto(url)
        try:
            summary["webgl"] = page.evaluate("""() => { const gl = document.createElement('canvas').getContext('webgl2');
                const e = gl.getExtension('WEBGL_debug_renderer_info'); return e ? gl.getParameter(e.UNMASKED_RENDERER_WEBGL) : gl.getParameter(gl.RENDERER); }""")
            print("WEBGL " + str(summary["webgl"]), flush=True)
        except Exception:
            pass
        ctx_state = {"page": page, "t0": t0, "lines": lines, "out": a.out, "tag": a.tag, "guard": guard, "summary": summary,
                     "browser": a.browser}
        try:
            mod = __import__("scenarios")
            fn = getattr(mod, a.scenario)
            fn(ctx_state, a)
        except Exception as e:
            import traceback
            traceback.print_exc()
            summary["error"] = repr(e)
        try:
            summary["times"] = page.evaluate("window.ibnTimes")
        except Exception:
            pass
        summary["mem_end"] = browser_mem(a.browser)
        try:
            page.screenshot(path=os.path.join(a.out, a.tag + "_final.png"))
        except Exception:
            pass
        br.close()
    guard.abort = True
    srv.shutdown()
    logf.close()
    summary["gpu_max_c"] = guard.max_t
    summary["script_errors"] = sum(1 for l in lines if "SCRIPT ERROR" in l)
    summary["errors"] = [l for l in lines if ("ERROR" in l or "pageerror" in l)][:40]
    fl = [l for l in lines if "UITEST FAILURES" in l]
    summary["uitest"] = fl[-1] if fl else None
    summary["console_lines"] = len(lines)
    json.dump(summary, open(os.path.join(a.out, a.tag + "_summary.json"), "w"), indent=1)
    print("SUMMARY " + json.dumps({k: summary[k] for k in summary if k != "errors"}), flush=True)
    for e in summary["errors"][:15]:
        print("  ERR " + e[:300], flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
