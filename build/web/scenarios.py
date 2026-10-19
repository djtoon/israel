"""Scenarios for browser_run.py. Each takes (st, a): st = {page, t0, lines, out, tag, guard, summary, browser}."""
import os, re, time

import browser_run


def _wait(st, a, until=None, timeout=None, shot_every=None, mem_every=10.0):
    page, lines, guard, summ = st["page"], st["lines"], st["guard"], st["summary"]
    until = until if until is not None else a.until
    timeout = timeout if timeout is not None else a.timeout
    shot_every = shot_every if shot_every is not None else a.shot_every
    rx = re.compile(until) if until else None
    t_start = time.time()
    next_shot = t_start + shot_every if shot_every else 1e18
    next_mem = t_start + 5
    seen = len(lines)
    n = 0
    hit = None
    rx_bench = re.compile(r"WEBBENCH (\S+) fps")
    while time.time() - t_start < timeout and not guard.abort:
        page.wait_for_timeout(500)
        # after each bench line: the rAF timing of that configuration (CPU vs GPU)
        for l in lines[seen:]:
            m = rx_bench.search(l)
            if m:
                try:
                    r = page.evaluate("window.ibnRafStats()")
                    summ.setdefault("raf", {})[m.group(1)] = r
                    print("RAF %s %s" % (m.group(1), r), flush=True)
                except Exception:
                    pass
        if rx:
            for l in lines[seen:]:
                if rx.search(l):
                    hit = l
            seen = len(lines)
            if hit:
                break
        if time.time() >= next_shot:
            n += 1
            try:
                page.screenshot(path=os.path.join(st["out"], "%s_%02d.png" % (st["tag"], n)))
            except Exception:
                pass
            next_shot += shot_every
        if time.time() >= next_mem:
            m = browser_run.browser_mem(st["browser"])
            summ["mem_max_tab_mb"] = max(summ.get("mem_max_tab_mb", 0), m[0])
            summ["mem_max_all_mb"] = max(summ.get("mem_max_all_mb", 0), m[1])
            next_mem += mem_every
    summ["waited_s"] = round(time.time() - t_start, 1)
    summ["hit"] = hit
    if guard.abort:
        summ["aborted"] = "gpu guard"
    return hit


def uitest(st, a):
    """load with autostart + user args; wait for the suite's last line (or the timeout)"""
    _wait(st, a)
    perf = [l for l in st["lines"] if "WEBPERF" in l]
    st["summary"]["webperf"] = perf[-20:]


def idle(st, a):
    """just load and run for --timeout seconds (screenshots every --shot-every)"""
    _wait(st, a, until="")
    perf = [l for l in st["lines"] if "WEBPERF" in l]
    st["summary"]["webperf"] = perf[-30:]


def profile(st, a):
    """wait until the map runs (--until line, then 25 s for shaders), then a 6 s CPU profile of the page (CDP):
    self time by function, to tell WASM CPU work from WebGL calls"""
    _wait(st, a)
    page = st["page"]
    page.wait_for_timeout(25000)
    cdp = page.context.new_cdp_session(page)
    cdp.send("Profiler.enable")
    cdp.send("Profiler.setSamplingInterval", {"interval": 500})
    cdp.send("Profiler.start")
    page.wait_for_timeout(6000)
    prof = cdp.send("Profiler.stop")["profile"]
    nodes = {n["id"]: n for n in prof["nodes"]}
    counts = {}
    total = 0
    for sid in prof.get("samples", []):
        n = nodes[sid]
        cf = n["callFrame"]
        key = "%s %s" % (cf.get("functionName") or "(anon)", (cf.get("url") or "").rsplit("/", 1)[-1])
        counts[key] = counts.get(key, 0) + 1
        total += 1
    top = sorted(counts.items(), key=lambda kv: -kv[1])[:30]
    st["summary"]["profile_top"] = [(k, round(100.0 * v / max(total, 1), 1)) for k, v in top]
    for k, v in top:
        print("PROF %5.1f%% %s" % (100.0 * v / max(total, 1), k), flush=True)
    import json, os
    json.dump(prof, open(os.path.join(st["out"], st["tag"] + ".cpuprofile"), "w"))
    st["summary"]["raf"] = page.evaluate("window.ibnRafStats()")


def _shot(st, name):
    p = os.path.join(st["out"], "%s_%s.png" % (st["tag"], name))
    try:
        st["page"].screenshot(path=p)
    except Exception as e:
        print("shot failed", e)
    return p


def _vid(st):
    try:
        return st["page"].evaluate("({state: window.ibnVideo.state(), t: window.ibnVideo.time(), src: document.getElementById('ibnv').src.split('/').pop(), z: document.getElementById('ibnv').style.zIndex, shown: document.getElementById('ibnv').style.display, muted: document.getElementById('ibnv').muted, vol: document.getElementById('ibnv').volume})")
    except Exception as e:
        return {"err": str(e)}


def play1(st, a):
    """the real start: the gate, Click to play, the language prompt, logo -> intro (skip) -> menu, browser keys"""
    page, summ = st["page"], st["summary"]
    log = summ.setdefault("steps", [])

    def note(s):
        print("STEP " + s, flush=True)
        log.append(s)
    page.wait_for_timeout(1500)
    _shot(st, "01_loading")
    page.wait_for_selector("#play", state="visible", timeout=120000)
    _shot(st, "02_gate")
    note("gate shown after %.1f s" % (time.time() - st["t0"]))
    t_click = time.time()
    page.click("#play")
    page.wait_for_function("window.ibnTimes.running", timeout=180000)
    note("engine running %.1f s after the click" % (time.time() - t_click))
    page.wait_for_timeout(4000)
    _shot(st, "03_language")
    page.mouse.click(548, 389)   # English
    note("clicked English")
    page.wait_for_timeout(2500)
    v = _vid(st)
    note("after the language: video %s" % v)
    _shot(st, "04_logo")
    page.wait_for_timeout(5000)
    v2 = _vid(st)
    note("5 s later: video %s" % v2)
    # wait for the intro (the logo ends by itself after ~15 s)
    t0 = time.time()
    while time.time() - t0 < 40:
        page.wait_for_timeout(1000)
        v = _vid(st)
        if v.get("src") == "intro.webm" and v.get("state") == "playing":
            break
    note("intro: %s after %.0f s" % (v, time.time() - t0))
    page.wait_for_timeout(4000)
    _shot(st, "05_intro")
    page.keyboard.press("Space")   # skip the intro
    note("pressed Space (skip)")
    page.wait_for_timeout(5000)
    v = _vid(st)
    note("menu: video %s" % v)
    _shot(st, "06_menu")
    # the keys the browser would take
    url0 = page.url
    nav0 = page.evaluate("performance.getEntriesByType('navigation').length")
    for k in ["F5", "Control+s", "Control+l", "F11"]:
        page.keyboard.press(k)
        page.wait_for_timeout(1200)
        note("key %s: url same=%s, engine alive=%s" % (k, page.url == url0, page.evaluate("!!window.ibnTimes.running && document.getElementById('canvas') != null")))
    _shot(st, "07_after_keys")
    note("page reloads: %s" % (page.evaluate("performance.getEntriesByType('navigation')[0].type")))
    _wait(st, a, until="", timeout=3, shot_every=0)


def _boot_to_menu(st, a, lang_xy=(548, 389)):
    page = st["page"]
    page.wait_for_selector("#play", state="visible", timeout=120000)
    page.click("#play")
    page.wait_for_function("window.ibnTimes.running", timeout=180000)
    page.wait_for_timeout(3000)
    if lang_xy:
        page.mouse.click(*lang_xy)
    page.wait_for_timeout(2500)
    for i in range(2):   # skip the logo and the intro
        page.keyboard.press("Space")
        page.wait_for_timeout(2500)
    page.wait_for_timeout(2500)


def newgame_map(st, a):
    """map the New Game panel: menu -> New Game -> screenshot"""
    page = st["page"]
    _boot_to_menu(st, a)
    _shot(st, "01_menu")
    page.mouse.click(282, 364)
    page.wait_for_timeout(2500)
    _shot(st, "02_newgame")


def play2(st, a):
    """a real game: New Game -> Full game, the map, End Turns (WEBTURN timing, the "Ending turn..." indicator), the
    Save window (Ctrl+S) with a named save"""
    page, summ = st["page"], st["summary"]
    _boot_to_menu(st, a)
    page.mouse.click(282, 364)
    page.wait_for_timeout(2000)
    t0 = time.time()
    page.mouse.click(795, 671)   # Full game (no tutorial)
    # the map is ready when WEBPERF says the renderer is idle for a few seconds
    page.wait_for_timeout(15000)
    _shot(st, "01_game")
    print("STEP game shown %.0f s after Full game" % (time.time() - t0), flush=True)
    turns = []
    for i in range(6):
        page.mouse.move(640, 400)
        n0 = len(st["lines"])
        tp = time.time()
        page.keyboard.press("Shift+Enter")
        page.wait_for_timeout(120)
        if i == 1:
            _shot(st, "02_ending_turn")
        hit = None
        while time.time() - tp < 30:
            page.wait_for_timeout(100)
            for l in st["lines"][n0:]:
                if "WEBTURN" in l:
                    hit = l
            if hit:
                break
        turns.append([round(time.time() - tp, 2), hit[-90:] if hit else None])
        print("STEP turn %d: %.2f s wall  %s" % (i + 1, time.time() - tp, hit[-80:] if hit else "-"), flush=True)
        page.wait_for_timeout(4000)
        for k in ["Escape", "Escape"]:
            page.keyboard.press(k)
            page.wait_for_timeout(300)
    summ["turns"] = turns
    _shot(st, "03_after_turns")
    page.keyboard.press("Control+s")
    page.wait_for_timeout(1500)
    _shot(st, "04_save_window")


def shots(st, a):
    """--web-shots: a page screenshot at each "WEBSHOT <name>" line, until "WEBSHOT done" (or the timeout)"""
    page, lines, guard = st["page"], st["lines"], st["guard"]
    rx = re.compile(r"WEBSHOT (\S+)")
    seen = 0
    t0 = time.time()
    taken = []
    while time.time() - t0 < a.timeout and not guard.abort:
        page.wait_for_timeout(250)
        new = lines[seen:]
        seen = len(lines)
        done = False
        for l in new:
            m = rx.search(l)
            if m:
                if m.group(1) == "done":
                    done = True
                else:
                    taken.append(_shot(st, m.group(1)))
                    print("SHOT " + m.group(1), flush=True)
        if done:
            break
    st["summary"]["shots"] = taken


IDB_JS = """() => new Promise((res) => {
  const r = indexedDB.open('/userfs');
  r.onerror = () => res(['(no /userfs)']);
  r.onsuccess = () => { try { const db = r.result; const tx = db.transaction(db.objectStoreNames[0], 'readonly');
    const st = tx.objectStore(db.objectStoreNames[0]); const q = st.getAllKeys();
    q.onsuccess = () => res(q.result.map(String).filter((k) => k.indexOf('save') >= 0 || k.indexOf('.cfg') >= 0));
    q.onerror = () => res(['(keys failed)']); } catch (e) { res(['(err ' + e + ')']); } };
})"""


def play3(st, a):
    """saves in the browser: F5 quick-save, a named save (Ctrl+S), Export (download), reload (IndexedDB), Load list,
    Import (upload), citation links (new tab)"""
    page, summ = st["page"], st["summary"]
    res = summ.setdefault("checks", {})

    def note(k, v):
        res[k] = v
        print("CHECK %s: %s" % (k, v), flush=True)
    _boot_to_menu(st, a)
    page.mouse.click(282, 364)
    page.wait_for_timeout(2000)
    page.mouse.click(795, 671)   # Full game
    page.wait_for_timeout(16000)
    page.mouse.move(640, 400)
    page.keyboard.press("Escape")
    page.wait_for_timeout(500)
    page.keyboard.press("F5")    # quick-save (the shell keeps the browser from reloading)
    page.wait_for_timeout(2500)
    _shot(st, "01_quicksave")
    keys = page.evaluate(IDB_JS)
    note("idb_after_f5", keys)
    note("f5_quicksave_in_idb", any("quicksave.json" in k for k in keys))
    page.keyboard.press("Control+s")
    page.wait_for_timeout(1500)
    page.mouse.click(592, 200)   # the name field
    page.keyboard.press("Control+a")
    page.keyboard.type("WebTest")
    page.keyboard.press("Enter")
    page.wait_for_timeout(2500)
    _shot(st, "02_saved")
    dl_path = os.path.join(st["out"], st["tag"] + "_export.ibnsave.json")
    try:
        with page.expect_download(timeout=10000) as dli:
            page.mouse.click(872, 299)   # Export on the first row
        dli.value.save_as(dl_path)
        note("export_download", "%s (%d bytes)" % (dli.value.suggested_filename, os.path.getsize(dl_path)))
    except Exception as e:
        note("export_download", "FAILED %s" % e)
        _shot(st, "02b_export_failed")
    page.keyboard.press("Escape")
    page.wait_for_timeout(1500)
    keys = page.evaluate(IDB_JS)
    note("idb_before_reload", keys)
    # reload: the saves and settings must still be there (IndexedDB)
    page.reload()
    page.wait_for_selector("#play", state="visible", timeout=120000)
    page.click("#play")
    page.wait_for_function("window.ibnTimes.running", timeout=180000)
    page.wait_for_timeout(5000)
    _shot(st, "03_after_reload")   # no language prompt now: the choice was kept
    for i in range(2):
        page.keyboard.press("Space")
        page.wait_for_timeout(2500)
    page.wait_for_timeout(2000)
    page.mouse.click(282, 410)   # Load Game
    page.wait_for_timeout(2500)
    _shot(st, "04_load_list")
    keys = page.evaluate(IDB_JS)
    note("idb_after_reload", keys)
    note("saves_kept_after_reload", any("WebTest" in k for k in keys) and any("quicksave" in k for k in keys))
    # import the exported file back (it becomes a second slot)
    if os.path.exists(dl_path):
        try:
            with page.expect_file_chooser(timeout=10000) as fci:
                page.mouse.click(368, 258)   # Import a save file...
            fci.value.set_files(dl_path)
            page.wait_for_timeout(3000)
            _shot(st, "05_imported")
            keys = page.evaluate(IDB_JS)
            note("import_new_slot", [k for k in keys if "WebTest" in k])
        except Exception as e:
            note("import", "FAILED %s" % e)
            _shot(st, "05b_import_failed")
    page.keyboard.press("Escape")
    page.wait_for_timeout(1000)
    _wait(st, a, until="", timeout=2, shot_every=0)


def citation(st, a):
    """--web-open-test=<url>: a click opens the URL the way citation links do; a new tab must open"""
    page = st["page"]
    _boot_to_menu(st, a)
    urls = [pg.url for pg in page.context.pages]
    st["summary"]["tabs_after_click"] = urls
    print("CHECK tabs after the first click (it opens the link): %s" % urls, flush=True)
    if len(urls) > 1:
        return
    try:
        with page.context.expect_page(timeout=15000) as npi:
            page.mouse.click(1100, 650)
        np = npi.value
        st["summary"]["citation_new_tab"] = np.url
        print("CHECK citation_new_tab: %s" % np.url, flush=True)
        np.close()
    except Exception as e:
        st["summary"]["citation_new_tab"] = "FAILED %s" % e
        print("CHECK citation_new_tab: FAILED %s" % e, flush=True)


def saveio(st, a):
    """--web-save-test: (after a quick-save) click 1 = Export (a download), click 2 = Import (the file picker)"""
    page = st["page"]
    _boot_to_menu(st, a)
    page.mouse.click(282, 364)
    page.wait_for_timeout(2000)
    page.mouse.click(795, 671)
    page.wait_for_timeout(16000)
    page.mouse.move(640, 400)
    page.keyboard.press("F5")
    page.wait_for_timeout(2500)
    dl = os.path.join(st["out"], st["tag"] + "_export.json")
    try:
        with page.expect_download(timeout=15000) as d:
            page.mouse.click(1200, 300)
        d.value.save_as(dl)
        print("CHECK export: %s %d bytes" % (d.value.suggested_filename, os.path.getsize(dl)), flush=True)
    except Exception as e:
        print("CHECK export: FAILED %s" % e, flush=True)
    page.wait_for_timeout(1500)
    try:
        with page.expect_file_chooser(timeout=15000) as fc:
            page.mouse.click(1200, 300)
        fc.value.set_files(dl)
        page.wait_for_timeout(3000)
        print("CHECK import: chooser ok", flush=True)
    except Exception as e:
        print("CHECK import: FAILED %s" % e, flush=True)
    page.keyboard.press("Control+l")
    page.wait_for_timeout(2000)
    _shot(st, "load_window")
    _wait(st, a, until="WEBSAVE import", timeout=8, shot_every=0)


def ship(st, a):
    """the ship check: new game, 10 End Turns (timing, the "Ending turn..." indicator), F5 quick-save, reload,
    Continue (the save loads after the reload)"""
    page, summ = st["page"], st["summary"]
    chk = summ.setdefault("checks", {})

    def note(k, v):
        chk[k] = v
        print("CHECK %s: %s" % (k, v), flush=True)
    _boot_to_menu(st, a)
    page.mouse.click(282, 364)
    page.wait_for_timeout(2000)
    t0 = time.time()
    page.mouse.click(795, 671)   # Full game
    page.wait_for_timeout(16000)
    _shot(st, "01_turn1")
    turns = []
    for i in range(10):
        page.mouse.move(640, 420)
        n0 = len(st["lines"])
        tp = time.time()
        page.keyboard.press("Shift+Enter")
        if i == 3:
            page.wait_for_timeout(60)
            _shot(st, "02_ending_turn")
        hit = None
        while time.time() - tp < 30:
            page.wait_for_timeout(50)
            for l in st["lines"][n0:]:
                if "WEBTURN" in l:
                    hit = l
            if hit:
                break
        turns.append([round(time.time() - tp, 2), hit.split("WEBTURN ")[-1] if hit else None])
        page.wait_for_timeout(2500)
        page.keyboard.press("Escape")
        page.wait_for_timeout(300)
        page.keyboard.press("Escape")
        page.wait_for_timeout(300)
    note("turns", turns)
    _shot(st, "03_turn11")
    page.keyboard.press("F5")
    page.wait_for_timeout(2500)
    keys = page.evaluate(IDB_JS)
    note("quicksave_in_idb", any("quicksave.json" in k for k in keys))
    m = browser_run.browser_mem(st["browser"])
    note("memory_mb_tab_all", m)
    page.reload()
    page.wait_for_selector("#play", state="visible", timeout=120000)
    page.click("#play")
    page.wait_for_function("window.ibnTimes.running", timeout=180000)
    page.wait_for_timeout(4000)
    for i in range(2):
        page.keyboard.press("Space")
        page.wait_for_timeout(2500)
    page.wait_for_timeout(2000)
    _shot(st, "04_menu_after_reload")
    page.mouse.click(282, 392)   # Continue (the newest save)
    page.wait_for_timeout(15000)
    _shot(st, "05_continued")
    _wait(st, a, until="", timeout=2, shot_every=0)


def smoke(st, a):
    """Edge / Firefox smoke: Click to play, language, skip the videos, a new game, 3 End Turns, screenshots"""
    page, summ = st["page"], st["summary"]
    _boot_to_menu(st, a)
    _shot(st, "01_menu")
    print("CHECK video: %s" % _vid(st), flush=True)
    page.mouse.click(282, 364)
    page.wait_for_timeout(2000)
    page.mouse.click(795, 671)
    page.wait_for_timeout(18000)
    turns = []
    for i in range(3):
        page.mouse.move(640, 420)
        n0 = len(st["lines"])
        tp = time.time()
        page.keyboard.press("Shift+Enter")
        hit = None
        while time.time() - tp < 40:
            page.wait_for_timeout(100)
            hit = next((l for l in st["lines"][n0:] if "WEBTURN" in l), None)
            if hit:
                break
        turns.append([round(time.time() - tp, 2), hit.split("WEBTURN ")[-1] if hit else None])
        page.wait_for_timeout(2500)
        page.keyboard.press("Escape")
        page.wait_for_timeout(400)
    summ["turns"] = turns
    print("CHECK turns: %s" % turns, flush=True)
    _shot(st, "02_turn4")
    _wait(st, a, until="", timeout=2, shot_every=0)


def memorial(st, a):
    """--ui-load=<end save> --ui-memorial (capture flags): the 7 October memorial screen, then a screenshot"""
    _wait(st, a, until="", timeout=a.timeout, shot_every=0)
    _shot(st, "memorial")


def pan(st, a):
    """--web-pan=...: the WEBPAN lines (fps panning and static)"""
    _wait(st, a, until="WEBPAN done", timeout=a.timeout, shot_every=0)
    st["summary"]["webpan"] = [l for l in st["lines"] if "WEBPAN" in l]
    _shot(st, "pan_end")


def ab(st, a):
    """--web-ab=...: the WEBAB lines (uncapped fps per lever configuration, build/web/tools/web_bench.gd)"""
    _wait(st, a, until="WEBAB done", timeout=a.timeout, shot_every=0)
    st["summary"]["webab"] = [l for l in st["lines"] if "WEBAB" in l]
    _shot(st, "ab_end")


def spin(st, a):
    """the loading indicators (2026-10-18): a throttled download (spinner and percentage), the corner spinner over the
    logo and intro, "Starting..." and the game's "Preparing graphics...", the busy indicator on End Turn and F5"""
    page, summ = st["page"], st["summary"]
    chk = summ.setdefault("checks", {})

    def note(k, v):
        chk[k] = v
        print("CHECK %s: %s" % (k, v), flush=True)
    cdp = page.context.new_cdp_session(page)
    cdp.send("Network.enable")
    cdp.send("Network.setCacheDisabled", {"cacheDisabled": True})
    cdp.send("Network.emulateNetworkConditions", {"offline": False, "latency": 20,
             "downloadThroughput": 10 * 1024 * 1024, "uploadThroughput": 1024 * 1024})
    page.reload()
    page.wait_for_timeout(2500)
    js_gate = """() => { const q = (i) => document.getElementById(i); return { gate: !!q('gate'),
        status: q('status') ? q('status').textContent : '', gspin: q('gspin') ? getComputedStyle(q('gspin')).display : '',
        corner: getComputedStyle(q('corner')).display, ctext: q('cornertext').textContent,
        vbuf: q('vbuf').style.display, busy: q('busy').classList.contains('on'),
        busy_op: getComputedStyle(q('busy')).opacity, ready: !!window.ibnTimes.ready,
        anim: q('gspin') ? getComputedStyle(q('gspin')).animationName : '' }; }"""
    note("gate_before_click", page.evaluate(js_gate))
    _shot(st, "01_downloading")
    page.click("#play")
    page.wait_for_timeout(3000)
    note("over_video", page.evaluate(js_gate))
    _shot(st, "02_video_corner")
    seen = []
    shots = set()
    t0 = time.time()
    skipped = 0
    while time.time() - t0 < 300:
        s = page.evaluate(js_gate)
        key = [s["status"] if s["gate"] else "GATE GONE", s["corner"], s["ctext"] if s["corner"] != "none" else "", s["vbuf"]]
        if not seen or seen[-1][1] != key:
            seen.append([round(time.time() - t0, 1), key])
            print("STATE %s" % seen[-1], flush=True)
        for word, nm in (("Starting", "03_starting"), ("Preparing", "04_preparing"), ("Downloading", "03a_gate_downloading")):
            if s["gate"] and word in s["status"] and nm not in shots and (nm != "03a_gate_downloading" or skipped >= 2):
                shots.add(nm)
                _shot(st, nm)
        if s["vbuf"] == "block" and "02b_video_buffering" not in shots:
            shots.add("02b_video_buffering")
            _shot(st, "02b_video_buffering")
        if skipped < 2 and time.time() - t0 > 6 + 4 * skipped:
            page.keyboard.press("Space")   # skip the logo, then the intro
            skipped += 1
        if s["ready"]:
            break
        page.wait_for_timeout(200)
    note("states", seen)
    cdp.send("Network.emulateNetworkConditions", {"offline": False, "latency": 0, "downloadThroughput": -1, "uploadThroughput": -1})
    page.wait_for_timeout(3000)
    page.mouse.click(548, 389)   # English
    page.wait_for_timeout(4000)
    for i in range(2):
        page.keyboard.press("Space")
        page.wait_for_timeout(2000)
    _shot(st, "05_menu")
    page.mouse.click(282, 364)   # New Game
    page.wait_for_timeout(2000)
    page.mouse.click(795, 671)   # Full game
    page.wait_for_timeout(16000)
    turns = []
    for i in range(3):
        page.mouse.move(640, 420)
        tp = time.time()
        page.keyboard.press("Shift+Enter")
        mx = 0.0
        on_seen = False
        while time.time() - tp < 8:
            r = page.evaluate(js_gate)
            on_seen = on_seen or r["busy"]
            op = float(r["busy_op"])
            if op > mx:
                mx = op
                if op > 0.5 and "06_busy_end_turn" not in shots:
                    shots.add("06_busy_end_turn")
                    _shot(st, "06_busy_end_turn")
            if on_seen and not r["busy"]:
                break
            page.wait_for_timeout(50)
        turns.append({"s": round(time.time() - tp, 2), "busy_on": on_seen, "max_opacity": mx})
        page.wait_for_timeout(2500)
        page.keyboard.press("Escape")
        page.wait_for_timeout(300)
        page.keyboard.press("Escape")
        page.wait_for_timeout(300)
    note("end_turns", turns)
    page.keyboard.press("F5")
    page.wait_for_timeout(1500)
    note("after_f5", page.evaluate(js_gate))
    _shot(st, "07_after_f5")
    _wait(st, a, until="", timeout=2, shot_every=0)


def brand(st, a):
    """the page's loading screen with the game's name: before the click, over the logo, after it (the spinners)"""
    page = st["page"]
    page.wait_for_timeout(1500)
    _shot(st, "01_loading")
    page.click("#play")
    page.wait_for_timeout(4000)
    _shot(st, "02_logo")
    t0 = time.time()
    shot = False
    while time.time() - t0 < 200:
        s = page.evaluate("() => ({gate: !!document.getElementById('gate'), status: (document.getElementById('status') || {}).textContent || '', ready: !!window.ibnTimes.ready})")
        if s["gate"] and not shot and ("Starting" in s["status"] or "Preparing" in s["status"] or "Downloading" in s["status"]) and time.time() - t0 > 12:
            _shot(st, "03_loading_after_logo")
            print("STATE %s" % s, flush=True)
            shot = True
        if s["ready"]:
            break
        page.wait_for_timeout(300)
    page.wait_for_timeout(4000)
    _shot(st, "04_after_ready")


def introend(st, a):
    """Click to play, the logo, the intro to its last frame (the game's name), then the loading screen"""
    page = st["page"]
    page.wait_for_selector("#play", state="visible", timeout=120000)
    page.click("#play")
    t0 = time.time()
    done = False
    while time.time() - t0 < 90:
        v = page.evaluate("() => { const v = document.getElementById('ibnv'); return {src: (v.currentSrc || '').split('/').pop(), t: v.currentTime, d: v.duration || 0}; }")
        if v["src"] == "intro.webm" and v["d"] > 0 and v["t"] > v["d"] - 0.6:
            _shot(st, "01_intro_last_frame")
            print("STATE intro at %.2f / %.2f" % (v["t"], v["d"]), flush=True)
            done = True
            break
        page.wait_for_timeout(100)
    page.wait_for_timeout(2000)
    _shot(st, "02_loading_after_intro")
    page.wait_for_function("window.ibnTimes.ready", timeout=240000)
    page.wait_for_timeout(3000)
    _shot(st, "03_ready")


def mobile(st, a):
    """a phone (--device): tap Click to play, the logo and the intro, then what the page shows until the game is
    interactive or gives up: screenshots after the intro and every 10 s, the gate's state"""
    page = st["page"]
    mbps = float(os.environ.get("IBN_THROTTLE_MBPS", "0"))   # a phone's network: the download still runs after a skip
    if mbps > 0 and st["browser"] != "webkit":
        cdp = page.context.new_cdp_session(page)
        cdp.send("Network.enable")
        cdp.send("Network.setCacheDisabled", {"cacheDisabled": True})
        cdp.send("Network.emulateNetworkConditions", {"offline": False, "latency": 40,
                 "downloadThroughput": mbps * 125000, "uploadThroughput": 125000})
        page.reload()
    page.wait_for_selector("#play", state="visible", timeout=120000)
    _shot(st, "00_gate")
    try:
        page.tap("#play")
    except Exception:
        page.click("#play")
    js = """() => { const q = (i) => document.getElementById(i); const r = (e) => { if (!e) return null; const b = e.getBoundingClientRect();
        const cs = getComputedStyle(e); return [Math.round(b.left), Math.round(b.top), Math.round(b.width), Math.round(b.height), cs.display, cs.visibility, cs.opacity, cs.zIndex]; };
        return { gate: !!q('gate'), status: q('status') ? q('status').textContent : '', statusBox: r(q('statusrow')), spin: r(q('gspin')),
        vw: innerWidth, vh: innerHeight, vid: q('ibnv').style.display, vsrc: (q('ibnv').currentSrc || '').split('/').pop(),
        times: window.ibnTimes, err: q('err') ? q('err').textContent : '', msg: q('mobilemsg') ? r(q('mobilemsg')) : null }; }"""
    t0 = time.time()
    skip_at = float(os.environ.get("IBN_SKIP_AT", "-1"))   # seconds into the intro to tap (skip); -1: watch it all
    while time.time() - t0 < 90 and not page.evaluate("!!window.ibnTimes.intro_end"):
        if skip_at >= 0:
            v = page.evaluate("() => { const v = document.getElementById('ibnv'); return {src: (v.currentSrc || '').split('/').pop(), t: v.currentTime}; }")
            if v["src"] == "intro.webm" and v["t"] >= skip_at:
                vp = page.viewport_size
                try:
                    page.touchscreen.tap(vp["width"] // 2, vp["height"] // 3)
                except Exception:
                    page.mouse.click(vp["width"] // 2, vp["height"] // 3)
                page.wait_for_timeout(300)
                print("STATE skipped at %.1f s: %s" % (v["t"], page.evaluate(js)), flush=True)
                _shot(st, "01_after_skip")
                break
        page.wait_for_timeout(100)
    if skip_at < 0:
        print("STATE intro_end %s" % page.evaluate(js), flush=True)
        page.wait_for_timeout(300)
        _shot(st, "01_after_intro")
    n = 2
    t1 = time.time()
    while time.time() - t1 < a.timeout - 30:
        page.wait_for_timeout(10000)
        s = page.evaluate(js)
        print("STATE %.0f %s" % (time.time() - t1, s), flush=True)
        _shot(st, "%02d_t%d" % (n, int(time.time() - t1)))
        n += 1
        if not s["gate"]:
            break
    _wait(st, a, until="", timeout=1, shot_every=0)


def hebrew(st, a):
    """the language prompt: Hebrew; the menu and the New Game panel in Hebrew (right to left)"""
    page = st["page"]
    _boot_to_menu(st, a, lang_xy=(731, 389))
    _shot(st, "01_menu_he")
    page.mouse.click(998, 364)   # New Game (the column mirrors to the right in Hebrew? try both sides)
    page.wait_for_timeout(2000)
    _shot(st, "02_newgame_he")


VQ_JS = """() => { const v = document.getElementById('ibnv'); if (!v || !v.getVideoPlaybackQuality) return null;
  const q = v.getVideoPlaybackQuality(); return {src: (v.currentSrc || '').split('/').pop(), t: v.currentTime,
  total: q.totalVideoFrames, dropped: q.droppedVideoFrames, times: window.ibnTimes}; }"""


def vidq(st, a):
    """dropped video frames during the logo and the intro (getVideoPlaybackQuality), from the click on; the language
    prompt (old flow) is answered if it shows"""
    page, summ = st["page"], st["summary"]
    page.wait_for_selector("#play", state="visible", timeout=120000)
    page.click("#play")
    t0 = time.time()
    last = {}
    answered = False
    while time.time() - t0 < 110:
        page.wait_for_timeout(500)
        q = page.evaluate(VQ_JS)
        if q and q.get("src"):
            last[q["src"]] = q
        if not answered and time.time() - t0 > 12 and not any(k.endswith(".webm") for k in last):
            page.mouse.click(548, 389)   # (the old flow's language prompt)
            answered = True
        tm = page.evaluate("window.ibnTimes")
        if tm.get("ready") or (last.get("menu.webm")):
            break
    summ["video_quality"] = {k: {kk: v[kk] for kk in ("t", "total", "dropped")} for k, v in last.items()}
    summ["times_after"] = page.evaluate("window.ibnTimes")
    print("CHECK video quality: %s" % summ["video_quality"], flush=True)
    print("CHECK times: %s" % summ["times_after"], flush=True)
    _shot(st, "after_intro")


def canvas_size(st, a):
    """the canvas's backing size against its CSS size, and the pixel ratio the page reports"""
    page = st["page"]
    page.wait_for_timeout(int(a.timeout * 1000))
    r = page.evaluate("({w: document.getElementById('canvas').width, h: document.getElementById('canvas').height, cw: document.getElementById('canvas').clientWidth, ch: document.getElementById('canvas').clientHeight, dpr: window.devicePixelRatio})")
    st["summary"]["canvas"] = r
    print("CHECK canvas: %s" % r, flush=True)
