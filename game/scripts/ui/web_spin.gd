class_name WebSpin
extends RefCounted
## web: the page's spinners (build/web/shell/index.html). They are HTML with CSS transform animations, which the
## browser's compositor runs, so they keep turning while a long frame blocks the game (a shader compile, the sim).
## loading(): the loading screen's text and percentage while it is up. busy(): the busy indicator, which the page shows
## only once it has been on for 0.3 s; the caller lets a frame pass after turning it on (so the page draws it) before
## the long work, and turns it off ("") afterwards. The desktop game never calls the page.

static var _on := false


static func loading(text: String, pct := -1.0) -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.ibnLoading && window.ibnLoading(%s, %.1f)" % [JSON.stringify(L10n.plain(text)), pct], true)


static func busy(text: String) -> void:
	if not OS.has_feature("web"):
		return
	if text == "" and not _on:
		return
	_on = text != ""
	JavaScriptBridge.eval("window.ibnBusy && window.ibnBusy(%s)" % JSON.stringify(L10n.plain(text)), true)
