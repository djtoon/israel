class_name UnitPanel
extends UIWindow
## Selected unit: stats and actions (Civ VI unit panel, bottom right next to the end-turn button).

func _init() -> void:
	super._init("Unit")
	title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS   # a long unit name never widens the panel out of its slot
	grow_horizontal = Control.GROW_DIRECTION_BEGIN   # (should the content still be wider: leftwards, away from the minimap)


func show_unit(u: Dictionary) -> void:
	clear_body()
	title_label.text = str(u.get("name", "")).to_upper()
	var stats := "Moves %s / %s" % [str(snappedf(float(u["moves"]), 0.1)), str(u["max_moves"])]
	if float(u.get("cs", 0)) > 0:
		stats += "   Strength %d" % int(u["cs"])
	if float(u.get("rs", 0)) > 0:
		stats += "   Ranged %d (range %d)" % [int(u["rs"]), int(u["range"])]
	if int(u.get("charges", 0)) > 0:
		stats += "   Charges %d" % int(u["charges"])
	var sl := UITheme.label(stats, 16)
	sl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART   # (the panel fills its slot beside the minimap: a long line wraps)
	body.add_child(sl)
	var hp := ProgressBar.new()
	hp.max_value = 100; hp.value = float(u["hp"]); hp.show_percentage = false
	hp.custom_minimum_size = Vector2(0, 6)
	var f := StyleBoxFlat.new(); f.bg_color = UIKit.GREEN if float(u["hp"]) > 50 else UIKit.BAD
	var bg := StyleBoxFlat.new(); bg.bg_color = Color(0, 0.02, 0.06)
	hp.add_theme_stylebox_override("fill", f); hp.add_theme_stylebox_override("background", bg)
	body.add_child(hp)
	var hint: String = ui.unit_hint(u)
	if hint != "":
		var hl := UITheme.rich(hint, 15)
		body.add_child(hl)
	var flow := HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 4)
	flow.add_theme_constant_override("v_separation", 4)
	body.add_child(flow)
	for a in ui.unit_actions(u):
		var b := UITheme.button(str(a["label"]), a["cb"], 15)
		b.disabled = not a.get("enabled", true)
		b.tooltip_text = str(a.get("tip", ""))
		flow.add_child(b)
	visible = true
