class_name ChooserPanel
extends UIWindow
## Civ VI "Choose Research" / "Choose Civic" list: cost, turns, unlocks, boost hint, historical blurb.

var kind := "tech"   # tech | civic


func _init(k: String) -> void:
	super._init("Choose Research" if k == "tech" else "Choose Civic")
	kind = k


func refresh() -> void:
	clear_body()
	var sim: Sim = ui.sim
	var nat := sim.get_national_summary()
	var rate := maxf(1.0, float(nat.get("science" if kind == "tech" else "culture", 1.0)))
	var items: Array = sim.get_techs() if kind == "tech" else sim.get_civics()
	var cur := str(nat.get("current_tech" if kind == "tech" else "current_civic", ""))
	var rec := ""
	if kind == "tech":
		rec = str(SimAI.pick_research(sim))
	else:
		rec = str(SimAI.pick_civic(sim))
	var col := UIKit.BLUE if kind == "tech" else UIKit.PURPLE
	var rate_s := "%s %s per turn" % [UITheme.fmt_num(rate), "Science" if kind == "tech" else "Culture"]
	var head := HBoxContainer.new()
	head.add_child(UITheme.icon("science" if kind == "tech" else "culture", 24))
	head.add_child(UITheme.label(rate_s, 18, UIKit.TEXT_DIM))
	var done_n := items.filter(func(t): return t["done"]).size()
	var sp := Control.new(); sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL; head.add_child(sp)
	head.add_child(UITheme.label("%d / %d %s" % [done_n, items.size(), "researched" if kind == "tech" else "adopted"], 16, UIKit.TEXT_DIM))
	body.add_child(head)
	var tb := UITheme.button("Open the %s tree" % ("technology" if kind == "tech" else "civics"), func(): ui.open_tree(kind), 16)
	body.add_child(tb)
	var list := scroll_body(560)
	var avail := items.filter(func(t): return t["available"])
	avail.sort_custom(func(a, b): return float(a["cost"]) - float(a["progress"]) < float(b["cost"]) - float(b["progress"]))
	if avail.is_empty():
		list.add_child(UITheme.label("Nothing available right now.", 18, UIKit.TEXT_DIM))
	for t in avail:
		list.add_child(_row(t, rate, t["id"] == cur, t["id"] == rec, col, true))
	# what comes next: locked items whose prerequisites are mostly met
	var locked := items.filter(func(t): return not t["done"] and not t["available"])
	locked.sort_custom(func(a, b): return int(a.get("year", 9999) if a.get("year") != null else 9999) < int(b.get("year", 9999) if b.get("year") != null else 9999))
	if locked.size() > 0:
		list.add_child(UITheme.section("Later"))
		for t in locked.slice(0, 10):
			list.add_child(_row(t, rate, false, false, col, false))


func _row(t: Dictionary, rate: float, is_cur: bool, is_rec: bool, col: Color, enabled: bool) -> UIRow:
	var r := UIRow.new(enabled, is_cur)
	var h := r.hrow()
	var nm := UITheme.label(str(t["name"]), 20, UIKit.GOLD_LIGHT if enabled else UIKit.TEXT_DIM, "body_bold")
	nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	h.add_child(nm)
	if is_rec and enabled and UITheme.show_hints:
		h.add_child(UITheme.label("Recommended", 15, UIKit.GREEN, "body_bold"))
	var remaining := maxf(0.0, float(t["cost"]) - float(t["progress"]))
	var turns := int(ceil(remaining / rate))
	var tl := UITheme.label(UITheme.turns(turns) if enabled else "", 18, UIKit.TEXT)
	tl.tooltip_text = "%s of %s left at %s per turn = %.1f turns" % [UITheme.fmt_num(remaining), UITheme.fmt_num(float(t["cost"])), UITheme.fmt_num(rate), remaining / rate]
	h.add_child(tl)
	h.add_child(ui.pedia_button(kind, str(t["id"])))
	var meta :="Cost %s (%.1f turns)" % [UITheme.fmt_num(float(t["cost"])), remaining / rate] if enabled else "Cost %s" % UITheme.fmt_num(float(t["cost"]))
	if enabled and not t.get("boosted", false) and str(t.get("boost_text", "")) not in ["", "Arrives with history."]:
		var boosted := maxf(0.0, remaining - 0.4 * float(t["cost"]))
		meta += ", %d with the boost" % int(ceil(boosted / rate))
	if float(t["progress"]) > 0:
		meta += "  (%d%% done)" % int(100.0 * float(t["progress"]) / maxf(1.0, float(t["cost"])))
	if t.get("year") != null:
		meta += "   History: %d" % int(t["year"])
	if t.get("rail", false):
		meta += "   Arrives with history"
	r.add(UITheme.label(meta, 15, UIKit.TEXT_DIM))
	if float(t["progress"]) > 0 or is_cur:
		var pb := ProgressBar.new()
		pb.show_percentage = false
		pb.custom_minimum_size = Vector2(0, 6)
		pb.max_value = 1.0
		pb.value = float(t["progress"]) / maxf(1.0, float(t["cost"]))
		var fill := StyleBoxFlat.new(); fill.bg_color = col
		var bg := StyleBoxFlat.new(); bg.bg_color = Color(0, 0.02, 0.06, 0.9)
		pb.add_theme_stylebox_override("fill", fill); pb.add_theme_stylebox_override("background", bg)
		r.add(pb)
	var un: String = ui.unlock_text(t.get("unlocks", {}))
	if un != "":
		var l := UITheme.label("Unlocks: " + un, 16, UIKit.TEXT)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r.add(l)
	if not enabled:
		r.add(UITheme.label(str(t.get("reason", "")), 15, UIKit.BAD))
	elif t.get("boosted", false):
		r.add(UITheme.label("Boosted (%s)" % ("Eureka" if kind == "tech" else "Inspiration"), 15, UIKit.GREEN))
	elif str(t.get("boost_text", "")) != "" and str(t.get("boost_text", "")) != "Arrives with history.":
		var bl := UITheme.label("To boost: " + str(t["boost_text"]), 15, Color(0.70, 0.82, 1.0))
		bl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r.add(bl)
	var desc := str(t.get("description", ""))
	if desc == "":
		desc = str(ui.db().techs.get(t["id"], {}).get("description", "") if kind == "tech" else ui.db().civics.get(t["id"], {}).get("description", ""))
	if desc != "":
		var src: Array = t.get("source", [])
		var d := UITheme.rich("[i]%s[/i]%s" % [desc, ("  [color=#8a93a8][%s][/color]" % ", ".join(src)) if src.size() > 0 else ""], 15)
		r.add(d)
	if enabled:
		r.pressed.connect(func(_s): ui.choose_research(kind, str(t["id"])))
	var tid := str(t["id"])
	r.right_pressed.connect(func(): ui.open_pedia(kind, tid))   # right-click: Civilopedia (Civ VI)
	return r
