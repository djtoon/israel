class_name StoryCard
extends UIWindow
## v4 story mode (V4_DESIGN 2.3): one card format for every story decision. The title and what is at stake, the
## Cabinet Secretary's recommendation, at most 3 options (the Recommended one first, history's always among the
## three) each with a two-line consequence, "More options (N)" and "Details" (the full v3 screen). After the pick the
## result opens in the same card, and the next decision follows in it ("Next (2 of 3)"); when the quarter's last
## decision is made the card ends on its result and END TURN. One click per decision, plus End Turn once a quarter.
## The card reads sim.auto.story_view(d) when the sim has it, else builds the same view from the decision itself.

const RESULT_KINDS := ["what_happened", "terms", "history_course", "consequence", "diplomacy", "fork", "cabinet", "programme", "crisis", "crisis_end", "goal"]
var deco: Dictionary = {}          # the decision on the card
var view: Dictionary = {}          # its story view
var result_text := ""              # what happened after the last pick (shown on top of the next decision)
var result_title := ""
var show_more := false
var picks_this_turn := 0
var _turn := -1
var _btn_more: Button
var _btn_details: Button
var _btn_end: Button


## v4 fix round (new-player N4): every stat word on a card explains itself on hover, and the first time a word
## appears on a card in a game, the card says in one plain line what it means. [word (case-sensitive), the short
## gloss, the hover tooltip]
const GLOSS := [
	["Cohesion", "Cohesion: how united Israeli society is; big calls spend it, and it builds up again.", "Cohesion: how united Israeli society is across its groups. Big calls spend it from a reserve that builds up again each quarter. Low cohesion brings strikes, protests and lost votes."],
	["Civic Trust", "Civic Trust: how much the towns trust the state (0 to 100).", "Civic Trust (0 to 100): how much each town trusts the state. Low trust slows growth and production."],
	["Standing", "Standing: how the world sees Israel (0 to 100).", "Standing (0 to 100): how the world sees Israel. It opens deals, aid and backing in a crisis."],
	["Readiness", "Readiness: how ready the army is (0 to 100).", "Readiness (0 to 100): how ready the army is. It makes every counter-attack hit harder and wars cost less."],
	["Gold", "Gold: the money in the Treasury.", "Gold: the money in the Treasury. It pays for buildings, programmes, the army and the newcomers."],
	["Inflation", "Inflation: how fast prices rise.", "Inflation: how fast prices rise. High inflation eats the Treasury and Civic Trust."],
	["towns hit|town hit|[Ss]trikes on towns", "Towns hit: enemy strikes that reach Israeli towns this quarter.", "Towns hit: enemy strikes that reach Israeli towns this quarter. Each costs lives, Civic Trust and production."],
	["enemy formations", "Enemy formations hit: enemy units struck before they can attack.", "Enemy formations hit: enemy units your forces strike before they can attack."],
]
static var _gloss_re := {}
var glossed_now: Array = []        # the words this card explained the first time they appeared (tests)
var _gloss_box: VBoxContainer


func _init() -> void:
	super._init("Decision")
	# long titles wrap inside the card instead of running under its close button (veteran m3)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.custom_minimum_size = Vector2(240, 0)


static func _terms_in(s: String) -> Array:
	## The GLOSS words in an English card text (the stat words as the sim writes them).
	var out := []
	for g in GLOSS:
		var w := str(g[0])
		if not _gloss_re.has(w):
			_gloss_re[w] = RegEx.create_from_string("\\b(?:" + w + ")\\b")
		if (_gloss_re[w] as RegEx).search(s) != null:
			out.append(w)
	return out


static func gloss_tip(s: String) -> String:
	## A card line's tooltip: one plain sentence for each stat word in it ("" when it has none).
	var lines := []
	for w in _terms_in(s):
		for g in GLOSS:
			if g[0] == w:
				lines.append(str(g[2]))
	return "\n".join(lines)


# v4polish (new-player: "is -28 Cohesion a lot?"): a number on a card says how big it is. [stat word in the card text,
# its name on the note, kind: "level" (a 0-100 gauge: drop / rise) or "pool" (spent or earned: cost / gain)]
const SCALE_STATS := [["Cohesion", "Cohesion", "pool"], ["Civic Trust", "Civic Trust", "level"], ["Standing", "Standing", "level"],
	["Readiness", "Readiness", "level"], ["gold", "gold", "pool"], ["Gold", "gold", "pool"]]
static var _scale_re: RegEx
static var _tag_strip: RegEx


static func scale_notes(ui, text: String) -> Array:
	## [[note, weight]] for the immediate numbers of a card line ("Now: -28 Cohesion", "Cost: 28 cohesion"): how big each
	## is against where the country stands now, e.g. "−28 Cohesion: a big cost (the reserve has 30)". The lasting
	## ("For years") terms are left alone. Heaviest first.
	var out := []
	if ui == null or ui.sim == null:
		return out
	if _scale_re == null:
		_scale_re = RegEx.create_from_string("([+\\-−]?)\\s?(\\d[\\d,]*)\\s+(Cohesion|cohesion|Civic Trust|Standing|Readiness|gold|Gold)\\b")
		_tag_strip = RegEx.create_from_string("\\[[^\\]]*\\]")
	var plain := _tag_strip.sub(text, "", true)
	var n: Dictionary = ui.sim.get_national_summary()
	for seg in plain.split("\n"):
		var s := str(seg).strip_edges()
		var is_cost := s.begins_with("Cost:")
		if not (s.begins_with("Now:") or is_cost):
			continue
		for m in _scale_re.search_all(s):
			var v := float(m.get_string(2).replace(",", ""))
			var neg := m.get_string(1) in ["-", "−"] or (is_cost and m.get_string(1) == "")
			var d := -v if neg else v
			var stat := m.get_string(3)
			if stat == "cohesion": stat = "Cohesion"
			var note := ""
			var w := 0.0
			match stat:
				"Cohesion":
					var res := float(ui.sim.state.cohesion)
					w = absf(d) / maxf(10.0, res)
					note = "%s Cohesion: %s (the reserve has %d)." % [UITheme.fmt_signed(d), size_word(w, 0.2, 0.5, "pool", d < 0), int(round(res))]
				"gold", "Gold":
					var inc := maxf(20.0, absf(float(n.get("gold", 0.0))))
					w = absf(d) / inc
					note = "%s gold: %s (the Treasury has %s)." % [UITheme.fmt_signed(d), size_word(w, 0.25, 0.75, "pool", d < 0), UITheme.fmt_num(float(n.get("gold_treasury", 0.0)))]
				_:
					var now := float(n.get({"Civic Trust": "avg_trust", "Standing": "standing", "Readiness": "readiness"}[stat], 0.0))
					w = absf(d) / 6.0
					note = "%s %s: %s (from %d to %d of 100)." % [UITheme.fmt_signed(d), stat, size_word(w, 0.4, 1.0, "level", d < 0), int(round(now)), int(round(clampf(now + d, 0.0, 100.0)))]
			out.append([note, w])
	out.sort_custom(func(a, b): return float(a[1]) > float(b[1]))
	return out


static func size_word(w: float, mid: float, big: float, kind: String, down: bool) -> String:
	var sz := "a big" if w >= big else ("a medium" if w >= mid else "a small")
	var what := ("cost" if down else "gain") if kind == "pool" else ("drop" if down else "rise")
	return "%s %s" % [sz, what]


static func reason_of(o: Dictionary) -> String:
	## Why an option cannot be taken now (sim.auto's story_view: "Needs 153 gold now"), or "".
	for k in ["reason", "unavailable_reason", "why_not"]:
		if str(o.get(k, "")) != "":
			return str(o[k])
	return ""


func open_for(d: Dictionary, keep_result := false) -> void:
	if ui == null or ui.sim == null:
		return
	if _turn != ui.sim.state.turn:
		_turn = ui.sim.state.turn
		picks_this_turn = 0
		result_text = ""
	if not keep_result:
		result_text = ""
	deco = d
	show_more = false
	view = build_view(ui, d)
	refresh()
	visible = true


func show_end(d_last_title := "") -> void:
	## Nothing left this quarter: the card keeps the last result and offers END TURN.
	deco = {"type": "end_turn"}
	view = {}
	if d_last_title != "":
		result_title = d_last_title
	refresh()
	visible = true


func refresh() -> void:
	clear_body()
	_btn_more = null
	_btn_details = null
	_btn_end = null
	if ui == null or ui.sim == null:
		return
	var sim = ui.sim
	var remaining: Array = NextStep.player_decisions(ui)
	if result_text != "":
		var rp := PanelContainer.new()
		rp.add_theme_stylebox_override("panel", UITheme.sb(Color(0.06, 0.12, 0.22, 0.95), UIKit.GOLD_DARK, 1, 6, 10))
		var rv := VBoxContainer.new()
		rp.add_child(rv)
		rv.add_child(UITheme.title("WHAT HAPPENED" + (": " + result_title.to_upper() if result_title != "" else ""), 15, UIKit.GOLD))
		var rt := UITheme.rich(result_text, 16, result_text.length() < 700)
		if result_text.length() >= 700:
			rt.custom_minimum_size = Vector2(0, 170)
			rt.scroll_active = true
		rv.add_child(rt)
		body.add_child(rp)
	if str(deco.get("type", "")) == "end_turn" or view.is_empty():
		title_label.text = "THE QUARTER IS DONE" if result_text != "" else "NOTHING NEEDS YOU"
		var nl := UITheme.rich("[color=#c8ccd6]%s[/color]" % NextStep.next_hint(sim), 16)
		body.add_child(nl)
		var fh := HBoxContainer.new()
		fh.add_theme_constant_override("separation", 10)
		fh.alignment = BoxContainer.ALIGNMENT_END
		body.add_child(fh)
		_btn_end = UITheme.button("END TURN → %s" % SimDB.date_label(sim.state.turn + 1), func(): ui.story_end_turn(), 19)
		_btn_end.name = "story_end_turn"
		_btn_end.add_theme_stylebox_override("normal", UITheme.sb(Color(0.20, 0.42, 0.92), UIKit.GOLD_LIGHT, 2, 6, 10))
		_btn_end.add_theme_stylebox_override("hover", UITheme.sb(Color(0.28, 0.52, 1.0), Color.WHITE, 2, 6, 10))
		_btn_end.custom_minimum_size = Vector2(260, 48)
		fh.add_child(_btn_end)
		return
	title_label.text = str(view.get("title", "")).to_upper()
	var total: int = picks_this_turn + remaining.size()
	if picks_this_turn > 0 and total > 1:
		body.add_child(UITheme.title("NEXT (%d OF %d)" % [picks_this_turn + 1, total], 15, Color(1.0, 0.80, 0.40)))
	elif total > 1:
		body.add_child(UITheme.title("DECISION 1 OF %d THIS QUARTER" % total, 15, Color(1.0, 0.80, 0.40)))   # (new-player m7)
	var stake := str(view.get("stake", ""))
	if stake != "":
		var stl := UITheme.rich(stake, 17)
		stl.tooltip_text = gloss_tip(stake)
		body.add_child(stl)
	var rec: Dictionary = view.get("recommended", {})
	var opts: Array = view.get("options", [])
	var hints: bool = UITheme.show_hints
	if hints and not rec.is_empty() and int(rec.get("index", -1)) >= 0:
		var rl := ""
		for o in opts:
			if int(o.get("index", -2)) == int(rec["index"]):
				rl = str(o.get("label", ""))
		if rl != "":
			var why := str(rec.get("why", ""))
			body.add_child(UITheme.rich("[color=#a8b0c4]Cabinet Secretary recommends:[/color] [b]%s[/b]%s" % [UITheme.humanise(rl), ("[color=#a8b0c4] · %s[/color]" % why) if why != "" else ""], 16))
	var shown := 0
	for o in opts:
		if not show_more and shown >= 3:
			break
		body.add_child(_option_row(o, hints and bool(o.get("recommended", false))))
		shown += 1
	if show_more:
		for i in view.get("more", []):
			for o2 in view.get("all", []):
				if int(o2.get("index", -2)) == int(i):
					body.add_child(_option_row(o2, false))
	_first_glosses(stake, opts.slice(0, 3) if not show_more else view.get("all", opts))
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", 10)
	body.add_child(foot)
	var nmore: int = (view.get("more", []) as Array).size()
	if nmore > 0:
		_btn_more = UITheme.button(("More options (%d)" % nmore) if not show_more else "Fewer options", func(): show_more = not show_more; refresh(), 16)
		_btn_more.name = "story_more"
		foot.add_child(_btn_more)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	foot.add_child(sp)
	if has_details(deco):
		_btn_details = UITheme.button("Details", func(): ui.story_details(deco), 16)
		_btn_details.name = "story_details"
		_btn_details.tooltip_text = "The full screen: every option with its advocates, sources, previews and lasting terms."
		foot.add_child(_btn_details)


func _option_row(o: Dictionary, star: bool) -> UIRow:
	var ok := bool(o.get("available", true))
	var r := UIRow.new(ok)
	r.name = "story_opt_%d" % int(o.get("index", 0))
	r.set_meta("story_index", int(o.get("index", 0)))
	var h := r.hrow()
	if star:
		h.add_child(UITheme.label("★", 19, UIKit.GOLD_LIGHT, "body_bold"))   # (its own label: the option's text stays a whole key)
	var l := UITheme.label(UITheme.humanise(str(o.get("label", ""))), 19, UIKit.GOLD_LIGHT if ok else UIKit.TEXT_DIM, "body_bold")
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(l)
	if star:
		var tag := UITheme.label("Recommended", 14, UIKit.GREEN, "body_bold")
		h.add_child(tag)
	if UITheme.show_hints and bool(o.get("historical", false)) and str(deco.get("type", "")) in ["event_choice", "immigration"]:
		var ht := UITheme.label("historical", 14, Color(0.75, 0.72, 0.62))
		ht.tooltip_text = "This is what the government actually did."
		h.add_child(ht)   # (as in v3: events and immigration plans show history's choice; forks reveal it after the pick)
	var words := str(o.get("label", ""))
	for c in (o.get("consequence", []) as Array).slice(0, 2):
		if str(c) != "":
			r.add(UITheme.rich(str(c), 15))
			words += "\n" + str(c)
	var notes := scale_notes(ui, words)
	if not notes.is_empty():
		var sl := UITheme.label(str(notes[0][0]), 14, Color(0.80, 0.82, 0.88))
		sl.name = "story_scale"
		sl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		r.add(sl)   # the biggest number's size, in words (v4polish)
	var tip := gloss_tip(words)
	for nt in notes:
		tip += ("\n" if tip != "" else "") + str(nt[0])
	r.tooltip_text = tip   # the row's hover: one plain sentence per stat word in it (Cohesion, Readiness...), then the sizes
	if not ok:
		var why := reason_of(o)
		r.add(UITheme.label(why if why != "" else "Not available now", 14, UIKit.BAD))
	var oo := o
	r.pressed.connect(func(_s): ui.story_pick(deco, oo))
	return r


func _first_glosses(stake: String, opts: Array) -> void:
	## The first time a stat word appears on a card in this game (story mode), one plain line says what it means.
	glossed_now = []
	var seen: Dictionary = ui.casual.get("glossed", {}) if ui.casual.get("glossed") is Dictionary else {}
	var texts := [stake]
	for o in opts:
		texts.append(str(o.get("label", "")))
		for c in (o.get("consequence", []) as Array).slice(0, 2):
			texts.append(str(c))
	var found := []
	for s in texts:
		for w in _terms_in(s):
			if not (w in found):
				found.append(w)
	for w in found:
		if seen.has(w) and int(seen[w]) != ui.sim.state.turn:
			continue   # (explained on an earlier quarter's card; the same quarter keeps the line while the card is redrawn)
		seen[w] = int(seen.get(w, ui.sim.state.turn))
		glossed_now.append(w)
	ui.casual["glossed"] = seen
	if glossed_now.is_empty():
		return
	_gloss_box = VBoxContainer.new()
	_gloss_box.name = "story_glossary"
	_gloss_box.add_theme_constant_override("separation", 1)
	body.add_child(_gloss_box)
	_gloss_box.add_child(UITheme.title("WORDS ON THIS CARD", 13, UIKit.GOLD))
	for w in glossed_now:
		for g in GLOSS:
			if g[0] == w:
				var gl := UITheme.label(str(g[1]), 14, Color(0.72, 0.75, 0.82))
				gl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				_gloss_box.add_child(gl)


func rows() -> Array:
	## The option rows on the card (tests).
	var out := []
	for c in body.find_children("*", "UIRow", true, false):
		if (c as Control).is_visible_in_tree():
			out.append(c)
	return out


static func has_details(d: Dictionary) -> bool:
	return not (str(d.get("type", "")) in ["brief", "end_turn", ""])


# ================================================================== the story view

static func build_view(ui, d: Dictionary) -> Dictionary:
	## {title, stake, recommended: {index, why}, options: [≤3 visible], more: [indices], all: [every option]}.
	## Each option: {index, id, label, consequence: [≤2], recommended, historical, available}.
	var sim = ui.sim
	var t := str(d.get("type", ""))
	if t != "brief" and NextStep.has_api(sim, "story_view"):
		var sv = NextStep.auto_api(sim).story_view(d)
		if sv is Dictionary and not (sv as Dictionary).is_empty() and not (sv.get("options", []) as Array).is_empty():
			var v := _from_sim(sv, _options(ui, d))
			# the card's own title and stake: translatable as whole texts (the sim's are cut English fragments)
			v["title"] = NextStep.title_of(sim, d)
			v["stake"] = NextStep.stake_of(sim, d, 1000)
			return v
	var all := _options(ui, d)
	var rec_i := _recommended(ui, d, all)
	var why := ""
	if t == "state_budget":
		why = NextStep.first_sentence(UITheme.humanise(str(d.get("recommended_why", ""))), 90)
	for o in all:
		o["recommended"] = int(o["index"]) == rec_i
	var vis := _pick_visible(all, rec_i, t)
	var more := []
	for o in all:
		if not vis.any(func(x): return int(x["index"]) == int(o["index"])):
			more.append(int(o["index"]))
	return {"title": NextStep.title_of(sim, d), "stake": NextStep.stake_of(sim, d, 1000), "recommended": {"index": rec_i, "why": why} if UITheme.show_hints else {},
		"options": vis, "more": more, "all": all}


static func _from_sim(sv: Dictionary, fb: Array) -> Dictionary:
	## sim.auto.story_view(d); the options behind "More options" come from the decision itself (fb).
	var vis: Array = []
	for o in sv.get("options", []):
		var oo: Dictionary = (o as Dictionary).duplicate()
		if not oo.has("index"):
			oo["index"] = vis.size()
		if not oo.has("historical") and bool(oo.get("historical_hidden", false)):
			oo["historical"] = false
		vis.append(oo)
	var all: Array = vis.duplicate()
	for i in sv.get("more", []):
		if not all.any(func(x): return int(x["index"]) == int(i)):
			var found := {}
			for f in fb:
				if int(f.get("index", -1)) == int(i):
					found = f
			if found.is_empty():
				found = {"index": int(i), "label": "Option %d" % (int(i) + 1), "consequence": []}
			all.append(found)
	var out: Dictionary = sv.duplicate()
	out["options"] = vis.slice(0, 3)
	out["all"] = all
	var more: Array = (sv.get("more", []) as Array).duplicate()
	for o2 in vis.slice(3):
		more.append(int(o2["index"]))
	out["more"] = more
	return out


static func _options(ui, d: Dictionary) -> Array:
	var sim = ui.sim
	var t := str(d.get("type", ""))
	var out := []
	match t:
		"event_choice":
			var ev = sim.db.event_by_id.get(str(d.get("event", "")))
			var chs: Array = d.get("choices", [])
			for ch in chs:
				var cons := []
				var et := DecisionPopup.effects_text(ch.get("effects", {}))
				if et != "":
					cons.append("Now: " + et)
				for term in ch.get("terms", []):
					if not UITheme.is_zero_term(str(term)):
						cons.append("For years: " + UITheme.clean_terms(str(term)))
						break
				if cons.is_empty() and str(ch.get("note", "")) != "":
					cons.append(NextStep.first_sentence(UITheme.humanise(str(ch["note"]))))
				out.append({"index": int(ch.get("index", out.size())), "id": str(ch.get("index", out.size())), "label": str(ch.get("label", "")),
					"consequence": cons, "historical": bool(ch.get("historical", false)), "available": true})
			if out.is_empty() and ev != null:
				for i in (ev.get("choices", []) as Array).size():
					out.append({"index": i, "id": str(i), "label": str(ev["choices"][i].get("label", "")), "consequence": [], "historical": false, "available": true})
		"crisis_response":
			var wt := bool(d.get("war_turn", false)) or bool(sim.state.crisis_decision.get("war_turn", false))
			var i := 0
			for o in d.get("options", []):
				var cons := []
				var oid := str(o.get("id", ""))
				if wt and (oid.begins_with("dfront:") or oid == "full_mobilization"):
					var fp := SimAdapter.front_preview(sim, o)
					var stk := CombatPreview.front_stake(fp)
					if stk != "":
						cons.append(stk)
				if cons.is_empty() and str(o.get("desc", "")) != "":
					cons.append(NextStep.first_sentence(UITheme.humanise(str(o["desc"])), 130))
				cons.append(_cost_text(sim, o.get("cost", {})))
				out.append({"index": i, "id": oid, "label": str(o.get("label", "")), "consequence": cons, "historical": false, "available": bool(o.get("available", true))})
				i += 1
		"dedication":
			var i2 := 0
			for o in d.get("options", []):
				out.append({"index": i2, "id": str(o.get("id", "")), "label": str(o.get("name", o.get("id", ""))),
					"consequence": [str(o.get("goal", "")), "Golden age: %s" % str(o.get("golden", ""))], "historical": false, "available": true})
				i2 += 1
		"immigration":
			var hist := str(d.get("historical", ""))
			var i3 := 0
			for o in d.get("options", []):
				var cons := []
				if str(o.get("effects", "")) != "":
					cons.append(UITheme.color_effects(str(o["effects"])))
				else:
					var el: Array = o.get("effects_list", []) if typeof(o.get("effects_list")) == TYPE_ARRAY else []
					if not el.is_empty():
						cons.append(CabinetPanel.fx_lines(el))
				if int(o.get("camp_residents", 0)) > 0:
					cons.append("[color=#ffb070]About %s into transit camps.[/color]" % UITheme.fmt_num(float(o["camp_residents"])))
				out.append({"index": i3, "id": str(o.get("id", "")), "label": str(o.get("label", o.get("id", ""))), "consequence": cons,
					"historical": str(o.get("id", "")) == hist or bool(o.get("historical", false)), "available": true})
				i3 += 1
		"brief":
			var i4 := 0
			for o in d.get("options", []):
				out.append({"index": i4, "id": str(o.get("id", "")), "label": str(o.get("label", "")), "consequence": [str(o.get("desc", ""))], "historical": false, "available": true})
				i4 += 1
		_:
			var i5 := 0
			for o in d.get("options", []):
				out.append({"index": i5, "id": str(o.get("id", "")), "label": str(o.get("label", o.get("name", ""))), "consequence": consequence(o),
					"historical": bool(o.get("historical", false)), "available": bool(o.get("available", true))})
				i5 += 1
	return out


static func consequence(o: Dictionary) -> Array:
	## At most two plain-language lines from an option's structured effects: what happens now, then what lasts.
	var out := []
	var now = o.get("now", null)
	if now is Array and not (now as Array).is_empty():
		out.append("Now: " + UITheme.color_effects(", ".join((now as Array).slice(0, 2).map(func(x): return str(x)))))
	elif now is String and str(now) != "":
		out.append("Now: " + UITheme.color_effects(str(now)))
	var lasting = o.get("lasting", null)
	if lasting is Array:
		for term in lasting:
			if not UITheme.is_zero_term(str(term)):
				out.append("For years: " + UITheme.clean_terms(str(term)))
				break
	if out.size() < 2:
		var et = o.get("effects_text", null)
		if et is Array and not (et as Array).is_empty() and out.is_empty():
			out.append(UITheme.color_effects(", ".join((et as Array).slice(0, 3).map(func(x): return str(x)))))
		elif et is String and str(et) != "" and out.is_empty():
			out.append(UITheme.color_effects(str(et)))
		elif out.is_empty() and o.get("effects") is Array and not (o["effects"] as Array).is_empty() and (o["effects"] as Array)[0] is Dictionary:
			out.append(CabinetPanel.fx_lines(o["effects"]))
		elif out.is_empty() and o.get("fx") is Dictionary and not (o["fx"] as Dictionary).is_empty():
			out.append(DecisionPopup._fx_text(o["fx"]))
	if out.size() < 2:
		var ds := str(o.get("desc", o.get("text", "")))
		if ds != "":
			out.append("[color=#c8ccd6]%s[/color]" % NextStep.first_sentence(UITheme.humanise(ds), 120))
	return out.slice(0, 2)


static func _cost_text(sim, cost: Dictionary) -> String:
	if cost.is_empty():
		return "[color=#9fe07a]No cost[/color]"
	var cs := []
	var prod := float(sim.get_national_summary().get("production", 0))
	for ck in cost:
		if ck == "production_pct":
			cs.append("−%d%% production this turn (about %d)" % [int(cost[ck]), int(round(prod * float(cost[ck]) / 100.0))])
		else:
			cs.append("%d %s" % [int(cost[ck]), UITheme.pretty(str(ck))])
	return "[color=#e6c76e]Cost: %s[/color]" % ", ".join(cs)


static func _recommended(ui, d: Dictionary, all: Array) -> int:
	## The advisor's pick: the same pickers as the Recommended badges and resolve_recommended.
	var sim = ui.sim
	if NextStep.has_api(sim, "recommend") and str(d.get("type", "")) != "brief":
		var r = NextStep.auto_api(sim).recommend(d)
		if r is Dictionary and r.has("index"):
			return int(r["index"])
	var t := str(d.get("type", ""))
	match t:
		"fork":
			var oid := str(SimAI.pick_fork(sim, d))
			for o in all:
				if str(o["id"]) == oid:
					return int(o["index"])
		"event_choice":
			var ev = sim.db.event_by_id.get(str(d.get("event", "")))
			if ev != null:
				return SimAI.pick_event_choice(sim, ev)
		"crisis_response":
			return SimAI.pick_crisis_response(sim, d.get("options", []))
		"dedication":
			var did := str(SimAI.pick_dedication(sim))
			for o in all:
				if str(o["id"]) == did:
					return int(o["index"])
		"immigration":
			var iid := str(SimAI.pick_immigration(sim))
			for o in all:
				if str(o["id"]) == iid:
					return int(o["index"])
		"programme":
			return SimAI.pick_programme(sim, d)
		"agenda", "treasury":
			if t == "agenda":
				return SimAI.pick_agenda(sim)
		"coalition":
			return SimAI.pick_option(sim, d.get("options", []), true)
		"diplomacy":
			if sim.get("diplo") != null and sim.diplo.has_method("ai_pick"):
				return int(sim.diplo.ai_pick("recommended"))
		"brief":
			return 0
	for o in d.get("options", []):
		if bool(o.get("default", false)):
			return (d.get("options", []) as Array).find(o)
	return 0


static func _words(o: Dictionary) -> Dictionary:
	var w := {}
	var re := RegEx.create_from_string("[A-Za-z]{4,}")
	for c in o.get("consequence", []):
		for m in re.search_all(str(c).to_lower()):
			w[m.get_string()] = true
	return w


static func _pick_visible(all: Array, rec_i: int, t: String) -> Array:
	## The Recommended option first, then the two that differ most from it; history's option always among the three.
	if all.size() <= 3 or t in ["event_choice"]:
		var srt := all.duplicate()
		srt.sort_custom(func(a, b): return (0 if int(a["index"]) == rec_i else 1) < (0 if int(b["index"]) == rec_i else 1))
		return srt
	var rec := {}
	for o in all:
		if int(o["index"]) == rec_i:
			rec = o
	if rec.is_empty():
		rec = all[0]
	var vis := [rec]
	var hist := {}
	for o in all:
		if bool(o.get("historical", false)) and int(o["index"]) != int(rec["index"]):
			hist = o
	var rw := _words(rec)
	var cands := all.filter(func(o): return int(o["index"]) != int(rec["index"]) and (hist.is_empty() or int(o["index"]) != int(hist["index"])) and bool(o.get("available", true)))
	if t == "crisis_response":
		# war fronts: the next front, then holding with the standing forces
		var hold := cands.filter(func(o): return str(o.get("id", "")) == "economy_first")
		var rest := cands.filter(func(o): return str(o.get("id", "")) != "economy_first")
		cands = rest + hold
		if not hold.is_empty() and rest.size() > 0:
			cands = [rest[0], hold[0]] + rest.slice(1)
	else:
		var scored := []
		for o in cands:
			var ow := _words(o)
			var diff := 0
			for k in ow:
				if not rw.has(k):
					diff += 1
			for k2 in rw:
				if not ow.has(k2):
					diff += 1
			scored.append([diff, o])
		scored.sort_custom(func(a, b): return int(a[0]) > int(b[0]))
		cands = scored.map(func(x): return x[1])
	var n_free := 2 if hist.is_empty() else 1
	for o in cands.slice(0, n_free):
		vis.append(o)
	if not hist.is_empty():
		vis.append(hist)
	return vis


# ================================================================== resolving a pick

static func resolve(ui, d: Dictionary, o: Dictionary) -> Dictionary:
	## Answers the decision with option o. Returns {ok, title, text} (text: what happened, then history's choice).
	var sim = ui.sim
	var t := str(d.get("type", ""))
	var idx := int(o.get("index", 0))
	var oid := str(o.get("id", ""))
	var before: int = sim.state.notifications.size()
	var ok := false
	var title := NextStep.title_of(sim, d)
	match t:
		"event_choice": ok = sim.choose_event(str(d["event"]), idx)
		"fork": ok = sim.choose_fork(str(d.get("fork", "")), oid if oid != "" else str(idx))
		"crisis_response": ok = sim.choose_crisis_response(idx)
		"coalition": ok = sim.choose_coalition(idx)
		"state_budget": ok = sim.choose_state_budget(idx)
		"diplomacy": ok = V3Adapter.choose_diplo(sim, d, idx)
		"programme": ok = sim.choose_programme(idx)
		"immigration": ok = sim.choose_immigration(oid)
		"dedication":
			sim.choose_dedication(oid)
			ok = not sim.state.pending_dedication
		"agenda": ok = sim.choose_agenda(idx)
		"treasury":
			if NextStep.has_api(sim, "choose_treasury"):
				ok = bool(NextStep.auto_api(sim).choose_treasury(oid))
		"brief":
			NextStep.set_brief(ui, oid)
			ok = true
		_:
			if sim.has_method("choose_" + t):
				ok = bool(sim.call("choose_" + t, idx))
	if not ok:
		return {"ok": false, "title": title, "text": ""}
	var parts: Array = []
	if t == "brief":
		parts.append("Your ministers' brief: [b]%s[/b]. You can change it in the Cabinet Room at any time." % UITheme.humanise(str(o.get("label", ""))))
	var hist_known := false
	for i in range(before, sim.state.notifications.size()):
		var n: Dictionary = sim.state.notifications[i]
		var k := str(n.get("kind", ""))
		if not (k in RESULT_KINDS):
			continue   # (the quarter's other news, a minister's routine and the stat log stay out of the decision's result)
		if k == "what_happened" and n.has("historical"):
			hist_known = true
			var hi := int(n.get("historical", -1))
			parts.append(("[color=#9fe07a]You made the historical choice.[/color]" if hi == idx else "[color=#ffb070]You chose differently from history.[/color]"))
		var tx := UITheme.humanise(str(n.get("text", "")))
		if tx != "" and parts.size() < 5 and not parts.has(tx):
			parts.append(tx if k != "terms" else "[color=#e6c76e]%s[/color]" % tx)
	if not hist_known:
		var hist := {}
		for x in d.get("options", d.get("choices", [])):
			if x is Dictionary and (bool(x.get("historical", false)) or (t == "immigration" and str(x.get("id", "")) == str(d.get("historical", "")))):
				hist = x
		if not hist.is_empty():
			var same := str(hist.get("id", "")) == oid if oid != "" and hist.has("id") else str(hist.get("label", "")) == str(o.get("label", ""))
			if same:
				parts.push_front("[color=#9fe07a]You made the historical choice.[/color]")
			else:
				parts.push_front("[color=#ffb070]History chose:[/color] [b]%s[/b]%s" % [UITheme.humanise(str(hist.get("label", ""))),
					("  [i]%s[/i]" % NextStep.first_sentence(UITheme.humanise(str(hist.get("note", ""))))) if str(hist.get("note", "")) != "" else ""])
	if t == "fork":
		var lasting: Array = o.get("lasting", [])
		for x in d.get("options", []):
			if str(x.get("id", "")) == oid:
				lasting = x.get("lasting", [])
		var lt := []
		for term in lasting:
			if not UITheme.is_zero_term(str(term)):
				lt.append("  [color=#f3d98f]•[/color] " + UITheme.clean_terms(str(term)))
		if not lt.is_empty():
			parts.append("[b]Your path:[/b]\n" + "\n".join(lt.slice(0, 3)))
	if parts.is_empty():
		parts.append("[b]%s[/b]" % UITheme.humanise(str(o.get("label", ""))))
	return {"ok": true, "title": title, "text": "\n".join(parts)}
