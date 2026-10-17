extends SceneTree
## fix4-ui probe (headless, a few seconds): the runtime-composed Hebrew texts of UITest.he_runtime_texts() (no sim)
## plus any strings given as user args, through the catalogs and the Latin-script check.
##   tools/godot.sh --headless --path game --script res://scripts/ui/tests/fix4_he_probe.gd -- "text" ...
func _init() -> void:
	L10n.setup("he")
	var t := UITest.new()
	var texts: Array = UITest.he_runtime_texts(null)
	for a in OS.get_cmdline_user_args():
		texts.append(a)
	for s in texts:
		var tr := L10n.translate(str(s))
		var miss := L10n.audit(str(s))
		t._latin_check(str(s), "probe")
		print("PROBE [%s]\n   -> [%s]%s" % [s, tr, ("   MISSING " + str(miss)) if not miss.is_empty() else ""])
	print("PROBE latin hits: %d" % t.latin_hits.size())
	for k in t.latin_hits:
		print("PROBE LATIN '%s'  %s" % [k, t.latin_hits[k]])
	t.free()
	quit()
