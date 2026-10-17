class_name DecisionPopup
extends UIWindow
## Centre popup for decisions: dated events with choices, crisis responses, era dedications, the Cabinet
## Agenda, and read-only views (a single event, "This quarter in history").

var mode := ""
var data := {}


func _init() -> void:
	super._init("Event")


const EFFECT_NAMES := {"morale": "Civic Trust", "intl_standing": "Standing", "gold": "Gold", "gold_per_turn": "Gold per turn",
	"production": "Production", "science": "Science", "culture": "Culture", "unlock_civic": "Civic",
	"trust": "Civic Trust (all cities)", "standing": "Standing"}


static func effects_text(eff: Dictionary) -> String:
	var parts := []
	for k in eff:
		var v = eff[k]
		var nm: String = EFFECT_NAMES.get(k, UITheme.pretty(str(k)))
		if typeof(v) == TYPE_ARRAY:
			var names := []
			for x in v:
				names.append(str(SimDB.get_db().civics.get(str(x), {}).get("name", UITheme.pretty(str(x)))))
			parts.append("%s: %s" % [nm, ", ".join(names)])
		elif typeof(v) in [TYPE_INT, TYPE_FLOAT]:
			if absf(float(v)) < 0.05:
				continue   # no "+0" terms
			var good := UITheme.stat_good(str(k), float(v))
			parts.append("[color=%s]%s %s[/color]" % ["#9fe07a" if good else "#ff8f7a", UITheme.fmt_signed(float(v)), nm])
		elif typeof(v) == TYPE_DICTIONARY:
			parts.append(nm)
	return ",  ".join(parts)


func _sources_line(src: Array) -> String:
	if src.is_empty():
		return ""
	return "[color=#8a93a8]Sources: %s[/color]" % ", ".join(src)


func show_event(ev: Dictionary) -> void:
	## ev from sim.get_pending_events()
	mode = "event"; data = ev
	clear_body()
	title_label.text = str(ev.get("title", "")).to_upper()
	_event_head(ev)
	body.add_child(UITheme.title("YOUR DECISION", 16, UIKit.GOLD))
	for ch in ev.get("choices", []):
		var r := UIRow.new(true)
		var h := r.hrow()
		var l := UITheme.label(str(ch["label"]), 19, UIKit.GOLD_LIGHT, "body_bold")
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(l)
		if ch.get("historical", false) and UITheme.show_hints:
			var tag := UITheme.label("historical", 14, Color(0.75, 0.72, 0.62))
			tag.tooltip_text = "This is what the government actually did."
			h.add_child(tag)
		var et := effects_text(ch.get("effects", {}))
		if et != "":
			r.add(UITheme.rich(et, 16))
		var terms: Array = ch.get("terms", [])
		if terms.size() > 0:
			var tt := "[color=#e6c76e]Lasting terms:[/color]"
			for t in terms:
				if not UITheme.is_zero_term(str(t)):
					tt += "\n  [color=#f3d98f]•[/color] " + UITheme.clean_terms(str(t))
			r.add(UITheme.rich(tt, 15))
		if str(ch.get("note", "")) != "":
			r.add(UITheme.rich("[i]%s[/i]" % UITheme.humanise(str(ch["note"])), 15))
		var sl := _sources_line(ch.get("source", []))
		if sl != "":
			r.add(UITheme.rich(sl, 13))
		var idx := int(ch["index"])
		var eid := str(ev["event"])
		r.pressed.connect(func(_s): ui.choose_event(eid, idx))
		body.add_child(r)
	visible = true


func _event_head(ev: Dictionary) -> void:
	var stext0 := str(ev.get("summary", ""))
	var art := UIArt.event_art(str(ev.get("event", "")))
	if art != null:
		body.add_child(illustration(art, 210.0 if stext0.length() <= 700 else 150.0, str(UIArt.event_entry(str(ev.get("event", ""))).get("credit", ""))))
	var sub := "%s   %s" % [_date_text(str(ev.get("date", ""))), UITheme.pretty(str(ev.get("kind", "")))]
	if str(ev.get("title_he", "")) != "":
		sub += "   " + str(ev["title_he"])
	body.add_child(UITheme.label(sub, 16, UIKit.GOLD))
	var stext := str(ev.get("summary", ""))
	var long := stext.length() > 900
	var sum := UITheme.rich(stext, 17, not long)
	if long:
		sum.custom_minimum_size = Vector2(0, 250)
		sum.scroll_active = true
	body.add_child(sum)
	var sl := _sources_line(ev.get("source", []))
	if sl != "":
		body.add_child(UITheme.rich(sl, 14))


static func illustration(tex: Texture2D, h: float, credit := "") -> Control:
	## An event illustration (art-2d): a gold-framed banner, cropped to fill the popup's width.
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", UITheme.sb(Color(0.02, 0.03, 0.07), UIKit.GOLD_DARK, 1, 4, 2))
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tr := TextureRect.new()
	tr.texture = tex
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tr.custom_minimum_size = Vector2(0, h)
	tr.clip_contents = true
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tr.name = "illustration"
	if credit != "":
		tr.tooltip_text = credit
		tr.mouse_filter = Control.MOUSE_FILTER_PASS
	p.add_child(tr)
	return p


static func _date_text(d: String) -> String:
	var p := d.split("-")
	if p.size() < 1 or p[0] == "":
		return d
	const M := ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
	if p.size() >= 3:
		return "%d %s %s" % [int(p[2]), M[clampi(int(p[1]), 0, 12)], p[0]]
	if p.size() == 2:
		return "%s %s" % [M[clampi(int(p[1]), 0, 12)], p[0]]
	return p[0]


func show_result(ev_title: String, text: String, applied: Dictionary) -> void:
	mode = "result"
	clear_body()
	title_label.text = ev_title.to_upper()
	var et := effects_text(applied)
	if et != "":
		body.add_child(UITheme.rich("[b]Effect of your choice:[/b] " + et, 17))
	body.add_child(UITheme.rich(UITheme.humanise(text), 17))
	body.add_child(UITheme.button("Continue", func(): close()))
	visible = true


func show_info_event(eid: String) -> void:
	var ev = SimDB.get_db().event_by_id.get(eid)
	if ev == null:
		return
	mode = "info"
	clear_body()
	title_label.text = str(ev.get("title", "")).to_upper()
	_event_head({"event": eid, "title_he": ev.get("title_he", ""), "date": ev.get("date", ""), "kind": ev.get("kind", ""), "summary": ev.get("summary", ""), "source": ev.get("source", [])})
	var note := course_note(eid)
	if note != "":
		body.add_child(UITheme.rich("[color=#ffcf7a][i]%s[/i][/color]" % UITheme.humanise(note), 16))
	body.add_child(UITheme.button("Close", func(): close()))
	visible = true


func show_digest(turn_label: String, eids: Array) -> void:
	mode = "digest"
	clear_body()
	title_label.text = "THIS QUARTER IN HISTORY: " + turn_label.to_upper()
	var list := scroll_body(430)
	for eid in eids:
		var ev = SimDB.get_db().event_by_id.get(eid)
		if ev == null:
			continue
		var p := VBoxContainer.new()
		p.add_child(UITheme.label(str(ev.get("title", "")), 20, UIKit.GOLD_LIGHT, "body_bold"))
		p.add_child(UITheme.label("%s   %s" % [_date_text(str(ev.get("date", ""))), UITheme.pretty(str(ev.get("kind", "")))], 15, UIKit.GOLD))
		var s := UITheme.rich(str(ev.get("summary", "")), 16)
		p.add_child(s)
		var sl := _sources_line(ev.get("source", []))
		if sl != "":
			p.add_child(UITheme.rich(sl, 13))
		var note := course_note(eid)
		if note != "":
			p.add_child(UITheme.rich("[color=#ffcf7a][i]%s[/i][/color]" % UITheme.humanise(note), 16))
		if not (ev.get("choices", []) as Array).is_empty():
			p.add_child(UITheme.label("A decision is waiting for you on this event.", 15, Color(1.0, 0.75, 0.35)))
		p.add_child(UITheme.sep())
		list.add_child(p)
	var h := HBoxContainer.new()
	var cb := CheckBox.new()
	cb.text = "Show this every turn"
	cb.focus_mode = Control.FOCUS_NONE
	cb.button_pressed = ui.show_digest
	cb.toggled.connect(func(on): ui.show_digest = on)
	cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(cb)
	h.add_child(UITheme.button("Continue", func(): close()))
	body.add_child(h)
	visible = true


func course_note(eid: String) -> String:
	## fix-wars: when a fired event went against the player's earlier choice, its event_log entry carries a
	## "History took its course" / consequence note (also notified as kind "history_course").
	if ui == null or ui.sim == null:
		return ""
	var log: Array = ui.sim.state.event_log
	for i in range(log.size() - 1, maxi(-1, log.size() - 400), -1):
		var e: Dictionary = log[i]
		if str(e.get("id", "")) == eid:
			return str(e.get("history_course", e.get("consequence", "")))
	return ""


func show_fork(d: Dictionary) -> void:
	## One-time cabinet decision (sim "fork"): each option names its advocate, what happens now and its lasting terms.
	## The historical option is revealed after the pick, as with events.
	mode = "fork"; data = d
	clear_body()
	title_label.text = "CABINET DECISION"
	var fork_art := UIArt.event_art(str(d.get("fork", "")))   # v3 final (fix4-av): art_manifest events["fork_*"] -> the linked event's picture or a fork painting
	if fork_art != null:
		body.add_child(illustration(fork_art, 150.0))
	body.add_child(UITheme.label(str(d.get("title", "")), 21, UIKit.GOLD_LIGHT, "body_bold"))
	if str(d.get("date", "")) != "":
		body.add_child(UITheme.label(_date_text(str(d["date"])), 15, UIKit.GOLD))
	var tx := str(d.get("text", ""))
	var sum := UITheme.rich(UITheme.humanise(tx), 17, tx.length() <= 900)
	if tx.length() > 900:
		sum.custom_minimum_size = Vector2(0, 220)
		sum.scroll_active = true
	body.add_child(sum)
	var sl := _sources_line(d.get("source", []))
	if sl != "":
		body.add_child(UITheme.rich(sl, 13))
	body.add_child(UITheme.rich("[color=#a8b0c4]A one-time decision: its lasting terms run for years and show under Ongoing terms (G). What history chose is revealed after you decide.[/color]", 14))
	for o in d.get("options", []):
		var r := UIRow.new(true)
		r.add(UITheme.label(str(o.get("label", "")), 19, UIKit.GOLD_LIGHT, "body_bold"))
		if str(o.get("advocate", "")) != "":
			r.add(UITheme.rich("[color=#a8b0c4]Advocated by %s[/color]" % str(o["advocate"]), 14))
		var now: Array = o.get("now", [])
		if now.size() > 0:
			r.add(UITheme.rich("[color=#e6c76e]Now:[/color] " + UITheme.color_effects(", ".join(now)), 15))
		var lasting: Array = o.get("lasting", [])
		if lasting.size() > 0:
			var tt := "[color=#e6c76e]Lasting terms:[/color]"
			for t in lasting:
				if not UITheme.is_zero_term(str(t)):
					tt += "\n  [color=#f3d98f]•[/color] " + UITheme.clean_terms(str(t))
			r.add(UITheme.rich(tt, 15))
		var src := []
		for c in o.get("cite", []):
			if typeof(c) == TYPE_DICTIONARY and str(c.get("source", "")) != "":
				src.append(str(c["source"]))
		var sl2 := _sources_line(src)
		if sl2 != "":
			r.add(UITheme.rich(sl2, 13))
		var fid := str(d.get("fork", ""))
		var oid := str(o.get("id", ""))
		r.pressed.connect(func(_s): ui.choose_fork(fid, oid))
		body.add_child(r)
	visible = true


func show_fork_result(d: Dictionary, chosen: String) -> void:
	mode = "result"
	clear_body()
	title_label.text = str(d.get("title", "")).to_upper()
	var hist := {}
	var mine := {}
	for o in d.get("options", []):
		if o.get("historical", false):
			hist = o
		if str(o.get("id", "")) == chosen:
			mine = o
	if not hist.is_empty() and str(hist.get("id", "")) == chosen:
		body.add_child(UITheme.rich("[color=#9fe07a]You made the historical choice.[/color]", 17))
	elif not hist.is_empty():
		body.add_child(UITheme.rich("[color=#ffb070]You chose differently from history.[/color] What actually happened: [b]%s[/b]%s" % [hist.get("label", ""), ("  [i]%s[/i]" % UITheme.humanise(str(hist["note"]))) if str(hist.get("note", "")) != "" else ""], 17))
	var lasting: Array = mine.get("lasting", [])
	if lasting.size() > 0:
		var tt := "[b]Your path:[/b]"
		for t in lasting:
			if not UITheme.is_zero_term(str(t)):
				tt += "\n  [color=#f3d98f]•[/color] " + UITheme.clean_terms(str(t))
		body.add_child(UITheme.rich(tt, 16))
	body.add_child(UITheme.button("Continue", func(): close()))
	visible = true


func show_immigration(d: Dictionary) -> void:
	## Quarterly immigrant placement (sim: get_pending_decisions type "immigration", choose_immigration(id)).
	mode = "immigration"; data = d
	clear_body()
	title_label.text = "IMMIGRATION PLAN FOR THE COMING YEAR"
	var opts: Array = d.get("options", [])
	var arrivals := int(opts[0].get("arrivals", 0)) if opts.size() > 0 else 0
	var wave := str(d.get("wave", ""))
	if wave != "":
		body.add_child(UITheme.label("A new wave begins: " + wave, 17, Color(1.0, 0.78, 0.4), "body_bold"))
	var al := UITheme.label("About %s immigrants are expected each quarter. Where does the state settle them for the next four quarters?" % UITheme.fmt_num(arrivals), 19, UIKit.GOLD_LIGHT, "body_bold")
	al.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(al)
	body.add_child(UITheme.rich("[color=#a8b0c4]The totals follow history; where they go is your decision, and the plan holds for a year. Its costs persist: residents short of housing lower trust and growth until homes are built.[/color]", 15))
	var hist := str(d.get("historical", ""))
	for o in opts:
		var r := UIRow.new(true)
		var h := r.hrow()
		var l := UITheme.label(str(o.get("label", o.get("id", ""))), 19, UIKit.GOLD_LIGHT, "body_bold")
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		h.add_child(l)
		if (str(o.get("id", "")) == hist or bool(o.get("historical", false))) and UITheme.show_hints:
			var tag := UITheme.label("historical", 14, Color(0.75, 0.72, 0.62))
			tag.tooltip_text = "What the governments of the day did at this date."
			h.add_child(tag)
		if bool(o.get("default", false)) and UITheme.show_hints:
			h.add_child(UITheme.label("  Recommended", 14, UIKit.GREEN, "body_bold"))
		r.add(UITheme.rich(UITheme.humanise(str(o.get("text", ""))), 15))
		var el: Array = o.get("effects_list", []) if typeof(o.get("effects_list")) == TYPE_ARRAY else []
		# the sim's effects string carries the qualitative effects too ("output grows fastest"); the list is the fallback
		var eff := UITheme.color_effects(str(o.get("effects", ""))) if str(o.get("effects", "")) != "" else CabinetPanel.fx_lines(el)
		if int(o.get("camp_residents", 0)) > 0:
			eff += "   [color=#ffb070]about %s into transit camps[/color]" % UITheme.fmt_num(float(o["camp_residents"]))
		r.add(UITheme.rich(eff, 15))
		var oid := str(o.get("id", ""))
		r.pressed.connect(func(_s): ui.choose_immigration(oid))
		body.add_child(r)
	visible = true


func show_options(kind: String, d: Dictionary) -> void:
	## crisis_response | dedication | agenda (decision dicts from sim.get_pending_decisions()).
	mode = kind; data = d
	clear_body()
	match kind:
		"crisis_response":
			var war_turn := bool(d.get("war_turn", false)) or bool(ui.sim.state.crisis_decision.get("war_turn", false))
			var cd_title := str(ui.sim.state.crisis_decision.get("title", ""))
			var wkind := ""
			for cr0 in ui.sim.state.crises:
				if str(cr0.get("id", "")) == str(ui.sim.state.crisis_decision.get("crisis", "")):
					wkind = str(cr0.get("kind", "war"))
			title_label.text = ({"uprising": "THE UPRISING THIS QUARTER", "deterrence": "DEPLOYMENT THIS QUARTER"}.get(wkind, "WAR: THE FRONT THIS QUARTER") if war_turn else "CRISIS RESPONSE")
			if war_turn and bool(ui.sim.state.crisis_decision.get("first_turn", false)) and wkind not in ["uprising", "deterrence"]:
				title_label.text = "WAR: THE STATE'S RESPONSE"
			var ph := int(ui.sim.state.crisis_decision.get("phases", 1))
			if war_turn and ph > 1:
				title_label.text += "  (PHASE %d OF %d)" % [int(ui.sim.state.crisis_decision.get("phase", 1)), ph]
			body.add_child(UITheme.label(cd_title if cd_title != "" else str(d.get("label", "")).replace("CRISIS RESPONSE: ", ""), 20, UIKit.GOLD_LIGHT, "body_bold"))
			var nat: Dictionary = ui.sim.get_national_summary()
			var stat := "[color=#a8b0c4]Readiness[/color] [b]%d[/b]   [color=#a8b0c4]Gold[/color] [b]%s[/b]   [color=#a8b0c4]Production[/color] [b]%d[/b]/turn   [color=#a8b0c4]Civic Trust[/color] [b]%d[/b]   [color=#a8b0c4]Standing[/color] [b]%d[/b]" % [int(nat.get("readiness", 0)), UITheme.fmt_num(float(nat.get("gold_treasury", 0))), int(nat.get("production", 0)), int(nat.get("avg_trust", 0)), int(nat.get("standing", 0))]
			var oids: Array = (d.get("options", []) as Array).map(func(o): return str(o.get("id", "")))
			var offensive := "air_first" in oids or "limited_aims" in oids
			if offensive and not war_turn:
				body.add_child(UITheme.rich("Israel is opening this campaign. Choose how it is fought: what it costs in gold, production, trust and standing is yours; the outcome follows history.", 16))
			elif war_turn:
				var opening := bool(ui.sim.state.crisis_decision.get("first_turn", false))
				var wtxt := "The war goes on. How it ends is history; how much it costs is yours. Each quarter, decide where the reserves go. Higher Readiness makes every counter-attack hit harder."
				if opening:
					wtxt = "War has begun. How it ends is history; how much it costs is yours. Choose the state's response for this quarter: mobilise the reserves for the whole campaign, commit them to one front, or hold with the standing forces. Higher Readiness makes every counter-attack hit harder."
				if wkind == "deterrence":
					wtxt = "A deployment, not a war: where the forces stand this quarter is yours, the outcome follows history."
				elif wkind == "uprising":
					wtxt = "The uprising goes on. How it ends is history; how much it costs is yours. Each quarter, decide where the forces go."
				body.add_child(UITheme.rich(wtxt + " Each order's preview leads with that front's stake: the towns it covers, the enemy formations it pins down (they do not strike this quarter) and the strikes on towns it averts; then its cost and the main modifiers.", 16))
			else:
				body.add_child(UITheme.rich("War has begun. Choose how the state responds. Costs depend on lasting national state: mobilisation is cheaper when Civic Trust is high, and international backing needs Standing 50+.", 16))
			body.add_child(UITheme.rich(stat, 16))
		"dedication":
			title_label.text = "A NEW ERA: CHOOSE A DEDICATION"
			body.add_child(UITheme.rich("Your era score in the last era decided this era's age. Pick a dedication to earn era score (or its golden-age bonus).", 16))
		"agenda":
			var ag: Dictionary = ui.sim.state.agenda
			var aid := str(ag.get("id", ""))
			var emergency := aid.contains("emergency")
			var pressing := aid != "fiscal" and aid != ""
			title_label.text = "ECONOMIC EMERGENCY" if emergency else ("CABINET AGENDA: PRESSING" if pressing else "CABINET AGENDA")
			body.add_child(UITheme.label(str(d.get("label", "")).replace("CABINET AGENDA: ", ""), 20, Color(1.0, 0.62, 0.52) if emergency else UIKit.GOLD_LIGHT, "body_bold"))
			if str(d.get("text", "")) != "":
				body.add_child(UITheme.rich(UITheme.humanise(str(d["text"])), 17))
			if emergency or aid in ["budget", "inflation"]:
				var n2: Dictionary = ui.sim.get_national_summary()
				body.add_child(UITheme.rich(CabinetPanel.finance_line(ui.sim) + "   [color=#a8b0c4]Civic Trust[/color] [b]%d[/b]" % int(n2.get("avg_trust", 0)), 16))
			if pressing:
				body.add_child(UITheme.rich("[color=#a8b0c4]A pressing item: answer it this turn, alongside your other decisions. Effects in [/color][color=#9fe07a]green[/color][color=#a8b0c4] help, in [/color][color=#ff8f7a]red[/color][color=#a8b0c4] hurt.[/color]", 14))
		_:
			title_label.text = UITheme.humanise(str(d.get("label", UITheme.pretty(kind)))).to_upper()
			if str(d.get("text", "")) != "":
				body.add_child(UITheme.rich(UITheme.humanise(str(d["text"])), 17))
	var wt := kind == "crisis_response" and (bool(d.get("war_turn", false)) or bool(ui.sim.state.crisis_decision.get("war_turn", false)))
	var holder: VBoxContainer = body
	var previews := {}
	var best_id := ""
	if wt:
		# each front's stake against holding with the standing forces: strikes on towns averted
		var base := -1.0
		for o0 in d.get("options", []):
			var fp0 := SimAdapter.front_preview(ui.sim, o0)
			previews[str(o0.get("id", ""))] = fp0
			if str(o0.get("id", "")) == "economy_first" and fp0.has("strikes"):
				base = float(fp0["strikes"])
		if base < 0.0:
			for k in previews:
				base = maxf(base, float(previews[k].get("strikes", -1.0)))
		var best_av := 0.05
		var ties := 0
		for k in previews:
			var fp1: Dictionary = previews[k]
			if base >= 0.0 and fp1.has("strikes"):
				fp1["baseline_strikes"] = base
				if not fp1.has("strikes_avoided"):
					fp1["strikes_avoided"] = maxf(0.0, base - float(fp1["strikes"]))
			var av := float(fp1.get("strikes_avoided", 0.0))
			if str(k).begins_with("dfront:") or str(k) == "full_mobilization":
				if av > best_av + 0.05:
					best_av = av; best_id = str(k); ties = 0
				elif absf(av - best_av) <= 0.05 and best_id != "":
					ties += 1
		if ties > 0:
			best_id = ""   # mark the order that spares most towns only when it stands out
	if wt and (d.get("options", []) as Array).size() > 3:
		holder = scroll_body(minf(600.0, 150.0 * (d.get("options", []) as Array).size()))   # front orders with previews: keep the popup on screen
	var i := 0
	for o in d.get("options", []):
		var ok := true
		var r: UIRow
		match kind:
			"crisis_response":
				ok = bool(o.get("available", true))
				r = UIRow.new(ok)
				var oh := r.hrow()
				var ol := UITheme.label(str(o.get("label", "")), 19, UIKit.GOLD_LIGHT if ok else UIKit.TEXT_DIM, "body_bold")
				ol.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				ol.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				oh.add_child(ol)
				if str(o.get("id", "")).begins_with("dfront:") and str(o.get("front", "")) != "":
					oh.add_child(UITheme.label("front: " + str(o["front"]), 14, Color(0.95, 0.75, 0.55)))
				var cost: Dictionary = o.get("cost", {})
				var cs := []
				var prod := float(ui.sim.get_national_summary().get("production", 0))
				for ck in cost:
					if ck == "production_pct":
						cs.append("−%d%% production this turn (about %d)" % [int(cost[ck]), int(round(prod * float(cost[ck]) / 100.0))])
					else:
						cs.append("%d %s" % [int(cost[ck]), UITheme.pretty(ck)])
				var desc := str(o.get("desc", ""))
				if wt and (previews.get(str(o.get("id", "")), {}) as Dictionary).has("other_populations"):
					for cut in [" In the combat area:", " Also affected (whole-war figures):"]:
						var ci := desc.find(cut)
						if ci >= 0:
							desc = desc.substr(0, ci)   # the preview lists the other populations
				r.add(UITheme.rich(UITheme.humanise(desc) + ("  [color=#e6c76e]Cost: %s[/color]" % ", ".join(cs) if cs.size() > 0 else "  [color=#9fe07a]No cost[/color]"), 15))
				if not ok:
					r.add(UITheme.label("Not available now", 14, UIKit.BAD))
				elif wt:
					# combat preview before the order (Civ VI): odds, expected losses on both sides, main modifiers
					var fp: Dictionary = previews.get(str(o.get("id", "")), SimAdapter.front_preview(ui.sim, o))
					if fp.has("win_odds"):
						r.add(CombatPreview.front_block(fp, str(o.get("id", "")) == best_id))
				var idx := i
				r.pressed.connect(func(_s): ui.choose_crisis(idx))
			"dedication":
				r = UIRow.new(true)
				r.add(UITheme.label(str(o.get("name", "")), 19, UIKit.GOLD_LIGHT, "body_bold"))
				r.add(UITheme.rich("%s  [color=#e6c76e]Golden age: %s[/color]" % [o.get("goal", ""), o.get("golden", "")], 15))
				var oid := str(o.get("id", ""))
				r.pressed.connect(func(_s): ui.choose_dedication(oid))
			_:
				r = UIRow.new(bool(o.get("available", true)))
				var gh := r.hrow()
				var gl := UITheme.label(UITheme.humanise(str(o.get("label", ""))), 19, UIKit.GOLD_LIGHT, "body_bold")
				gl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				gl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				gh.add_child(gl)
				if bool(o.get("default", false)) and UITheme.show_hints and kind != "agenda":
					gh.add_child(UITheme.label("Recommended", 14, UIKit.GREEN, "body_bold"))
				if kind != "agenda" and str(o.get("desc", "")) != "":
					r.add(UITheme.rich("[color=#c8ccd6]%s[/color]" % UITheme.humanise(str(o["desc"])), 15))
				var sfx: Array = o.get("effects", []) if typeof(o.get("effects")) == TYPE_ARRAY else []
				var fx := CabinetPanel.fx_lines(sfx) if sfx.size() > 0 else _fx_text(o.get("fx", {}))
				if fx != "":
					r.add(UITheme.rich(fx, 15))
				var idx2 := i
				var kk := kind
				r.pressed.connect(func(_s): ui.choose_agenda(idx2) if kk == "agenda" else ui.choose_generic(kk, idx2))
		holder.add_child(r)
		i += 1
	visible = true


static func _good(s: String, good: bool) -> String:
	return "[color=%s]%s[/color]" % ["#9fe07a" if good else "#ff8f7a", s]


static func _fx_text(fx: Dictionary) -> String:
	var parts := []
	for k in fx:
		var v = fx[k]
		match k:
			"city", "turns", "econ_action", "target", "policy", "mode":
				continue   # (econ_action: a fiscal lever; its effects come as structured effects_extra)
			"borrow":
				parts.append(_good("%s Gold, borrowed (public debt repaid with interest over 15 years)" % UITheme.fmt_signed(float(v)), true))
			"gold":
				parts.append(_good("%s Gold" % UITheme.fmt_signed(float(v)), float(v) >= 0))
			"inflation":
				parts.append(_good("inflation %s points (lasting)" % UITheme.fmt_signed(float(v)), float(v) <= 0))
			"readiness":
				parts.append(_good("%s Readiness" % UITheme.fmt_signed(float(v)), float(v) >= 0))
			"standing":
				parts.append(_good("%s Standing" % UITheme.fmt_signed(float(v)), float(v) >= 0))
			"cohesion":
				parts.append(_good("%s Cohesion" % UITheme.fmt_signed(float(v)), float(v) >= 0))
			"adopt_policy":
				parts.append("[color=#e6c76e]adopts the %s policy card (economic slot)[/color]" % str(SimDB.get_db().policies.get(str(v), {}).get("name", UITheme.pretty(str(v)))))
			"reserve":
				parts.append(_good("%s water reserve" % UITheme.fmt_signed(float(v)), float(v) >= 0))
			"trust_all":
				parts.append(_good("%s trust in every city" % UITheme.fmt_signed(float(v)), float(v) >= 0))
			"trust_city":
				parts.append(_good("%s trust in the city" % UITheme.fmt_signed(float(v)), float(v) >= 0))
			"amenity_all":
				parts.append(_good("%s amenity everywhere (4 turns)" % UITheme.fmt_signed(float(v)), float(v) >= 0))
			"housing_city":
				parts.append("+%s housing" % str(v))
			"building":
				parts.append("builds a %s" % UITheme.pretty(str(v)))
			"budget_focus":
				parts.append("+10%% %s for 4 turns" % str(v).capitalize())
			"rural_capacity":
				parts.append("+%s rural capacity" % UITheme.fmt_num(float(v)))
			"immigrant_weight_city":
				parts.append("%s%% immigrants to the city" % UITheme.fmt_signed(float(v)))
			"temp":
				var t: Dictionary = v
				var pct := float(t.get("pct", 0))
				# "yield_pct" of science reads "Science", not "Yield science" (fix4-ui)
				var what := str(t.get("yield", "")).capitalize() if t.has("yield") else UITheme.pretty(str(t.get("type", ""))).replace(" Pct", "")
				parts.append("%s%% %s for %d turns" % [UITheme.fmt_signed(pct), what, int(fx.get("turns", 4))])
			_:
				parts.append("%s %s" % [UITheme.pretty(str(k)), str(v)])
	# each effect is translated on its own before the join (her M4: the joined Hebrew line showed only its comma)
	return ", ".join(parts.map(func(p): return L10n.t(str(p))))
