extends SceneTree
## fix3-ui probe (headless): every How to Play line and tutorial / advisor card text, through the Hebrew catalogs.
## Writes the lines with untranslated parts to user://i18n_onboarding_missing.json ({line: ""}), ready to translate.
func _init() -> void:
	L10n.setup("he")
	var lines := []
	for p in HelpOverlay.PAGES:
		lines.append(str(p[0]))
		for ln in V3Adapter.endify(str(p[1])).split("\n"):
			lines.append(ln)
	for st in Tutorial.STEPS:
		for k in ["title", "text", "todo", "wait"]:
			if str(st.get(k, "")) != "":
				for ln in V3Adapter.endify(str(st[k])).split("\n"):
					lines.append(ln)
		lines.append("Next: %s." % str(st["title"]))
	for tk in Tutorial.TIPS:
		lines.append(str(Tutorial.TIPS[tk]["title"]))
		for ln in str(Tutorial.TIPS[tk]["text"]).split("\n"):
			lines.append(ln)
	var out := {}
	for ln in lines:
		if str(ln).strip_edges() == "":
			continue
		if not L10n.audit(ln).is_empty():
			out[ln] = ""
	var f := FileAccess.open("user://i18n_onboarding_missing.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(out, " "))
	f.close()
	print("ONBOARDING lines %d, missing %d -> %s" % [lines.size(), out.size(), ProjectSettings.globalize_path("user://i18n_onboarding_missing.json")])
	L10n.shutdown()
	quit()
