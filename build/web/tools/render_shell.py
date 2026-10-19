"""Write build/web/out/index.html from shell/index.html without a Godot export (a shell-only change): the template's
placeholders take the values of the last export's index.html (the config's file sizes stay right as long as the
pck and wasm are that export's)."""
import re, sys
W = "C:/civ/build/web"
out = open(W + "/out/index.html", encoding="utf-8").read()
cfg = re.search(r"const GODOT_CONFIG = (\{.*?\});\n", out).group(1)
thr = re.search(r"const GODOT_THREADS_ENABLED = (\w+);", out).group(1)
head = re.search(r"</style>\n(.*?)</head>", out, re.S).group(1)
tpl = open(W + "/shell/index.html", encoding="utf-8").read()
tpl_head = re.search(r"</style>\n(.*?)</head>", tpl, re.S).group(1)
assert "$GODOT_HEAD_INCLUDE" in tpl_head
html = tpl.replace("$GODOT_HEAD_INCLUDE\n", head if head.strip() else "").replace("$GODOT_URL", "index.js")
html = html.replace("$GODOT_CONFIG", cfg).replace("$GODOT_THREADS_ENABLED", thr)
assert "$GODOT" not in html
open(W + "/out/index.html", "w", encoding="utf-8", newline="\n").write(html)
open(W + "/src/game/web_shell/index.html", "w", encoding="utf-8", newline="\n").write(tpl)
print("out/index.html written from the shell (%d bytes)" % len(html))
