class_name CombatPreview
extends PanelContainer
## Civ VI combat preview: shown while a selected unit hovers an enemy in reach (before the attack) and, as an
## inline block, under every war-front order in the front popup. Win odds, the expected losses on both sides
## and the main modifiers (green helps the player, red hurts).

var box: VBoxContainer


func _init() -> void:
	theme = UITheme.get_theme()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override("panel", UITheme.sb(Color(0.03, 0.06, 0.13, 0.96), UIKit.GOLD, 2, 8, 12))
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	add_child(box)
	custom_minimum_size = Vector2(380, 0)
	visible = false


static func odds_text(p: float) -> String:
	if p < 0.0:
		return "n/a"
	return "%d%%" % int(round(clampf(p, 0, 1) * 100.0))


static func odds_color(p: float) -> Color:
	if p < 0.0:
		return UIKit.TEXT_DIM
	if p >= 0.66:
		return UIKit.GREEN
	if p >= 0.4:
		return Color(1.0, 0.82, 0.35)
	return Color(1.0, 0.50, 0.42)


static func verdict(p: float) -> String:
	if p < 0.0:
		return "Defensive order"
	if p >= 0.85: return "Decisive victory"
	if p >= 0.6: return "Likely victory"
	if p >= 0.4: return "Even fight"
	if p >= 0.15: return "Likely defeat"
	return "Costly defeat"


static func _n1(x: float) -> String:
	var r := snappedf(x, 0.1)
	return str(int(r)) if absf(r - roundf(r)) < 0.01 else str(r)


static func front_verdict(p: float) -> String:
	if p >= 0.66: return "Heavy blow"
	if p >= 0.4: return "Solid blow"
	if p >= 0.15: return "Light blow"
	return "Little effect"


static func _mod_line(m: Dictionary, player_side: bool) -> String:
	var a := float(m.get("amount", 0))
	if bool(m.get("base", false)):
		return "[color=#dfe3ec]%s [b]%d[/b][/color]" % [str(m.get("label", "")), int(round(a))]
	if absf(a) < 0.05:
		return "[color=#a8b0c4]%s[/color]" % str(m.get("label", ""))
	var good := (a > 0) == player_side
	return "[color=%s]%s %s[/color]" % ["#9fe07a" if good else "#ff8f7a", UITheme.fmt_signed(a, 0 if absf(a - roundf(a)) < 0.05 else 1), str(m.get("label", ""))]


func _clear() -> void:
	for c in box.get_children():
		box.remove_child(c)
		c.queue_free()


static func _bar(frac: float, col: Color) -> ProgressBar:
	var pb := ProgressBar.new()
	pb.show_percentage = false
	pb.custom_minimum_size = Vector2(0, 8)
	pb.max_value = 1.0
	pb.value = clampf(frac, 0, 1)
	var fill := StyleBoxFlat.new(); fill.bg_color = col
	var bg := StyleBoxFlat.new(); bg.bg_color = Color(0, 0.02, 0.06, 0.9)
	pb.add_theme_stylebox_override("fill", fill); pb.add_theme_stylebox_override("background", bg)
	pb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return pb


func show_unit(p: Dictionary) -> void:
	## p from SimAdapter.unit_preview()
	_clear()
	if p.is_empty():
		visible = false
		return
	var w := float(p.get("win_odds", 0.5))
	var head := HBoxContainer.new()
	var t := UITheme.title("COMBAT PREVIEW", 15, UIKit.GOLD_LIGHT)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(t)
	head.add_child(UITheme.label("%s  %s" % [verdict(w), odds_text(w)], 17, odds_color(w), "body_bold"))
	box.add_child(head)
	box.add_child(_bar(w, odds_color(w)))
	var g := GridContainer.new()
	g.columns = 3
	g.add_theme_constant_override("h_separation", 12)
	box.add_child(g)
	for x in ["", str(p.get("attacker_name", "Attacker")), str(p.get("defender_name", "Defender"))]:
		g.add_child(UITheme.label(x, 15, UIKit.GOLD_LIGHT, "body_bold"))
	g.add_child(UITheme.label("Strength", 14, UIKit.TEXT_DIM))
	g.add_child(UITheme.label(str(int(round(float(p.get("attacker", 0))))), 16))
	g.add_child(UITheme.label(str(int(round(float(p.get("defender", 0))))), 16))
	var dr: Array = p.get("dealt_range", [p.get("damage_dealt", 0), p.get("damage_dealt", 0)])
	var tr: Array = p.get("taken_range", [p.get("damage_taken", 0), p.get("damage_taken", 0)])
	g.add_child(UITheme.label("Expected HP loss", 14, UIKit.TEXT_DIM))
	g.add_child(UITheme.label(_range(tr) if not bool(p.get("ranged", false)) else "none (ranged)", 16, UIKit.BAD if float(tr[1]) > 0 else UIKit.GREEN))
	g.add_child(UITheme.label(_range(dr), 16, UIKit.GREEN))
	g.add_child(UITheme.label("HP now", 14, UIKit.TEXT_DIM))
	g.add_child(UITheme.label(str(int(float(p.get("attacker_hp", 100)))), 16))
	g.add_child(UITheme.label(str(int(float(p.get("defender_hp", 100)))), 16))
	var kc := float(p.get("kill_chance", 0))
	var dc := float(p.get("death_chance", 0))
	var bits := []
	if kc > 0.0:
		bits.append("[color=#9fe07a]chance to destroy the target %s[/color]" % odds_text(kc))
	if dc > 0.0:
		bits.append("[color=#ff8f7a]chance to lose the unit %s[/color]" % odds_text(dc))
	if str(p.get("outcome", "")) != "":
		bits.push_front("[color=#e6c76e]Expected: %s[/color]" % str(p["outcome"]))
	if bits.size() > 0:
		box.add_child(UITheme.rich(", ".join(bits), 14))
	var mods: Array = p.get("modifiers", [])
	if mods.size() > 0:
		var a := []
		var d := []
		for m in mods:
			if str(m.get("side", "attacker")) == "attacker":
				a.append(_mod_line(m, true))
			else:
				d.append(_mod_line(m, false))
		var txt := "[color=#e6c76e]Yours:[/color] " + ", ".join(a)
		if d.size() > 0:
			txt += "\n[color=#e6c76e]Theirs:[/color] " + ", ".join(d)
		box.add_child(UITheme.rich(txt, 14))
	box.add_child(UITheme.label("Click to attack. Right-click elsewhere to move instead.", 13, UIKit.TEXT_DIM))
	visible = true


static func _range(r: Array) -> String:
	var a := int(round(float(r[0]))); var b := int(round(float(r[1])))
	return str(a) if a == b else "%d–%d" % [a, b]


static func _n_people(n: int) -> String:
	if n >= 1000000:
		return "%.1fM" % (n / 1e6)
	if n >= 10000:
		return UITheme.fmt_num(roundf(n / 1000.0) * 1000.0)
	return UITheme.fmt_num(n)


static func front_stake(fp: Dictionary) -> String:
	## This front's own stake, as a one-line headline: the towns it covers, the formations it pins down and the
	## strikes on towns it is expected to avert (compared with holding with the standing forces).
	if str(fp.get("stake", "")) != "":
		return str(fp["stake"])
	var bits := []
	var prot = fp.get("protects", [])
	if typeof(prot) == TYPE_ARRAY and (prot as Array).size() > 0:
		var names := (prot as Array).slice(0, 3).map(func(x): return str(x.get("name", x)) if typeof(x) == TYPE_DICTIONARY else str(x))
		var res := int(fp.get("residents_at_risk", 0))
		if res <= 0:
			for x in prot:
				if typeof(x) == TYPE_DICTIONARY:
					res += int(x.get("residents", 0))
		bits.append("covers %s%s" % [", ".join(names), (" (%s residents)" % _n_people(res)) if res > 0 else ""])
	var n := int(fp.get("targets", 0))
	if n > 0:
		var pin := float(fp.get("pinned", 0))
		bits.append("pins down %s of %d formation%s" % [_n1(pin), n, "" if n == 1 else "s"])
	if fp.has("strikes_avoided"):
		var av := float(fp["strikes_avoided"])
		if av >= 0.05:
			bits.append("spares about %s strike%s on towns" % [_n1(av), "" if absf(av - 1.0) < 0.05 else "s"])
		elif fp.has("strikes") and float(fp["strikes"]) >= 0.05:
			bits.append("about %s strike%s on towns expected" % [_n1(float(fp["strikes"])), "" if absf(float(fp["strikes"]) - 1.0) < 0.05 else "s"])
	if bits.is_empty():
		return ""
	var s: String = ", ".join(bits)
	return s.substr(0, 1).to_upper() + s.substr(1)


static func front_block(fp: Dictionary, best := false, best_tag := "") -> Control:
	## Inline preview for one war-front option (fp from SimAdapter.front_preview()). The headline is this front's own
	## stake (towns covered, formations pinned, strikes on towns averted); the bar is the share of the formations at
	## that front pinned down this quarter.
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", UITheme.sb(Color(0.02, 0.05, 0.11, 0.85), Color(0.40, 0.34, 0.22), 1, 5, 8))
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 2)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc.add_child(v)
	var w := float(fp.get("win_odds", -1.0))
	var n := int(fp.get("targets", 0))
	var pin_share := (float(fp.get("pinned", 0)) / float(n)) if n > 0 else w
	var h := HBoxContainer.new()
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(h)
	var lt := UITheme.label("Preview%s" % (" (estimate)" if bool(fp.get("estimate", false)) else ""), 13, UIKit.GOLD, "title")
	h.add_child(lt)
	var stake := front_stake(fp)
	var hl: Control
	if stake != "":
		var col := odds_color(pin_share) if n > 0 else Color(0.62, 0.78, 1.0)
		hl = UITheme.rich("[b][color=#%s]%s[/color][/b]" % [col.to_html(false), stake], 15)
		hl.tooltip_text = "What this order is for: the towns this front threatens, how many of the formations there it is expected to pin down this quarter (a formation hit for 35 HP or more does not strike), and the strikes on towns it averts compared with holding with the standing forces."
	elif w >= 0.0:
		hl = UITheme.label("%s: %s of their strength" % [front_verdict(w), odds_text(w)], 15, odds_color(w), "body_bold")
	else:
		hl = UITheme.label(str(fp.get("verdict", verdict(w))), 15, UIKit.TEXT_DIM, "body_bold")
	hl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(hl)
	if best:
		var bt := UITheme.label("  " + (best_tag if best_tag != "" else "most towns spared"), 13, UIKit.GREEN, "body_bold")
		bt.tooltip_text = "Of this quarter's orders, this one averts the most strikes on towns."
		h.add_child(bt)
	if n > 0 or w >= 0.0:
		v.add_child(_bar(pin_share if n > 0 else w, odds_color(pin_share if n > 0 else w)))
	var lines := []
	var en: Dictionary = fp.get("enemy", {})
	if not en.is_empty() and int(en.get("formations", 0)) > 0:
		var nf := int(en["formations"])
		var dst := float(en.get("destroyed", 0))
		lines.append("[color=#9fe07a]Enemy losses: %d formation%s hit, about %s of their strength%s[/color]" % [nf, "" if nf == 1 else "s", odds_text(float(en.get("hp_share", w))),
			(", about %s destroyed" % _n1(dst)) if dst >= 0.05 else "; none expected to be destroyed outright"])
	elif fp.has("enemy_losses"):
		var el: Dictionary = fp["enemy_losses"]
		lines.append("[color=#9fe07a]Enemy losses: %s formation%s, %s HP[/color]" % [str(snappedf(float(el.get("formations", 0)), 0.1)), "" if float(el.get("formations", 0)) == 1.0 else "s", str(int(float(el.get("hp", 0))))])
	var lf: Dictionary = fp.get("left", {})
	if int(lf.get("formations", 0)) > 0:
		var left := float(lf.get("left", 0))
		var tot := int(lf["formations"])
		if tot - left >= 0.05:
			lines.append("[color=#c8ccd6]Still in the field after this quarter: about %s of the war's %d enemy formations[/color]" % [_n1(left), tot])
		else:
			lines.append("[color=#c8ccd6]The war's %d enemy formations stay in the field; pinned ones do not strike this quarter[/color]" % tot)
	if fp.has("strikes"):
		var sk := float(fp["strikes"])
		var base := float(fp.get("baseline_strikes", -1.0))
		lines.append("[color=#ffb070]Strikes on towns expected this quarter: %s%s[/color]" % [_n1(sk), (" (%s if you hold with the standing forces)" % _n1(base)) if base >= 0.0 and absf(base - sk) >= 0.05 else ""])
	var risk = fp.get("at_risk", [])
	if typeof(risk) == TYPE_ARRAY and (risk as Array).size() > 0:
		lines.append("[color=#ffb070]Towns at risk: %s[/color]" % ", ".join((risk as Array).map(func(x): return ("%s (%s)" % [str(x.get("name", "")), str(x.get("strikes", x.get("risk", "")))]) if typeof(x) == TYPE_DICTIONARY else str(x))))
	var pops = fp.get("other_populations", fp.get("populations_at_risk", fp.get("affected", [])))
	if typeof(pops) == TYPE_ARRAY and (pops as Array).size() > 0 and typeof(pops[0]) == TYPE_DICTIONARY and pops[0].has("group"):
		# fix-wars: [{group, label, text}]: the front's own civilians line, then the war's other populations
		var here := (pops as Array).filter(func(x): return str(x.get("group", "")) == "front")
		var rest := (pops as Array).filter(func(x): return str(x.get("group", "")) != "front")
		if here.size() > 0:
			lines.append("[color=#c8b8a0]Civilians in the combat area: %s[/color]" % UITheme.humanise(str(here[0].get("text", ""))))
		if rest.size() > 0:
			lines.append("[color=#c8b8a0]Also affected (whole-war figures): %s[/color]" % UITheme.humanise("; ".join(rest.slice(0, 4).map(func(x): return str(x.get("text", x.get("label", "")))))))
	elif typeof(pops) == TYPE_ARRAY and (pops as Array).size() > 0:
		lines.append("[color=#c8b8a0]Also at risk: %s[/color]" % ", ".join((pops as Array).map(func(x): return (str(x.get("name", x.get("group", ""))) + ((": " + str(x["text"])) if x.has("text") else "")) if typeof(x) == TYPE_DICTIONARY else str(x))))
	elif typeof(pops) == TYPE_STRING and str(pops) != "":
		lines.append("[color=#c8b8a0]Also at risk: %s[/color]" % str(pops))
	var ours: Array = fp.get("ours", [])
	if fp.has("our_losses") and typeof(fp["our_losses"]) == TYPE_DICTIONARY:
		var ol: Dictionary = fp["our_losses"]
		if ol.has("casualties_low"):
			ours = ours + ["about %s–%s casualties" % [UITheme.fmt_num(float(ol["casualties_low"])), UITheme.fmt_num(float(ol.get("casualties_high", ol["casualties_low"])))]]
	ours = ours.filter(func(x): return not str(x).contains("strike"))   # strikes on towns have their own line
	if ours.size() > 0:
		lines.append("[color=#ff8f7a]Our cost: %s[/color]" % ", ".join(ours))
	elif w >= 0.0:
		lines.append("[color=#9fe07a]Our cost: none beyond the order[/color]")
	if str(fp.get("note", "")) != "":
		lines.append("[i]%s[/i]" % UITheme.humanise(str(fp["note"])))
	var mods: Array = fp.get("modifiers", [])
	if mods.size() > 0:
		lines.append("[color=#a8b0c4]Modifiers:[/color] " + ", ".join(mods.map(func(m): return _mod_line(m, true))))
	var rt := UITheme.rich("\n".join(lines), 14)
	rt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(rt)
	return pc
