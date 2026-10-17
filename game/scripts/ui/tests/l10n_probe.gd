extends SceneTree
## fix3-ui probe: translate a few strings in Hebrew (headless).
func _init() -> void:
	L10n.setup("he")
	for s in ["• Declaration of the Establishment of the State of Israel", "Declaration of the Establishment of the State of Israel",
			"• " + UITheme.humanise("Declaration of the Establishment of the State of Israel"), "Social Welfare", "{0} completed {1}."]:
		print("[", s, "] -> [", L10n.translate(s), "] audit=", L10n.audit(s))
	quit()
