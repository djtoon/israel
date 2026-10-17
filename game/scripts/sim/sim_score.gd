class_name SimScore
extends RefCounted
## Six-track scoring against the Historical Israel ghost (game/data/ghost.json), World-Rankings style.
## The ghost is a recorded run of the scripted historical autoplayer, in the game's own units.
## Real-world figures (S119, S500, S501, S502) are attached only as calibrated labels.

const TRACKS := [
	{"id": "population", "name": "Population", "unit": "residents", "real": "population"},
	{"id": "economy", "name": "Economy (output per capita)", "unit": "index", "real": "gdp_per_capita"},
	{"id": "science", "name": "Science", "unit": "techs", "real": "rnd_share_gdp"},
	{"id": "water", "name": "Water security", "unit": "index", "real": "water_withdrawal_per_capita"},
	{"id": "standing", "name": "Culture and international standing", "unit": "index", "real": ""},
	{"id": "cohesion", "name": "Social cohesion (civic trust)", "unit": "index", "real": ""},
]
const MILESTONE_TRACK := {"tech": "science", "civic": "standing", "project": "economy", "town": "population", "district": "economy",
	"building": "economy", "boost": "science"}
const WATER_ITEMS := ["project:national_water_carrier", "project:shafdan", "project:ashkelon_desalination", "project:sorek_desalination",
	"tech:desalination", "tech:wastewater_reuse", "tech:drip_irrigation", "tech:national_water_carrier", "tech:groundwater_drilling",
	"district:desalination_plant", "district:water_connection"]

var sim


func _init(s) -> void:
	sim = s


func S() -> GameState:
	return sim.state


func avg_trust() -> float:
	var t := 0.0; var w := 0.0
	for c in sim.active_cities():
		t += c.trust * c.residents; w += c.residents
	return t / w if w > 0 else 75.0


func values() -> Dictionary:
	var n: Dictionary = sim.national()
	var res: float = sim.total_residents()
	var output := float(n.get("production", 0)) + float(n.get("gold", 0)) + float(n.get("science", 0)) + float(n.get("culture", 0)) + 0.5 * float(n.get("food", 0))
	for tr in S().trade_routes:
		output += sim.trade_route_gold(tr)
	var productivity := pow(1.03, S().techs.size()) * pow(1.015, S().civics.size())
	# inflation above history's path and a heavy public debt lower output per capita (fix-cabinet, debt blocker B3)
	var econ: float = output / maxf(1.0, res / 10000.0) * productivity * float(sim.econ.economy_health())
	var sci := float(S().techs.size())
	if S().current_tech != "":
		sci += clampf(float(S().tech_progress.get(S().current_tech, 0.0)) / maxf(1.0, sim.tech_cost(S().current_tech)), 0.0, 0.99)
	for k in S().repeat_count:
		sci += 0.2 * float(S().repeat_count[k])   # repeatable programmes are filler, not new capabilities
	var w: Dictionary = S().water
	# smooth saturation (no hard cap): surplus keeps counting with diminishing returns, so the track stays contested
	var wr := float(w.get("ratio", 1.0))
	var water := 100.0 * (1.0 + 0.6 * tanh((wr - 1.0) / 0.5)) * (0.7 + 0.3 * float(w.get("reserve", 70.0)) / 100.0)
	# v3 (sim-endgame): completed national programmes add lasting track gains (data/projects.json "legacy", % of the track)
	var lg: Dictionary = sim.endgame.legacy() if sim.endgame != null else {}
	var pop_track := res * (1.0 + float(lg.get("population", 0.0)) / 100.0)
	econ *= 1.0 + float(lg.get("economy", 0.0)) / 100.0
	sci *= 1.0 + float(lg.get("science", 0.0)) / 100.0
	water *= 1.0 + float(lg.get("water", 0.0)) / 100.0
	var stand_track: float = S().standing * (1.0 + float(lg.get("standing", 0.0)) / 100.0)
	var coh_track: float = avg_trust() * (1.0 + float(lg.get("cohesion", 0.0)) / 100.0)
	# v3 fix3-econ (A7): the lasting mark of the cabinet's choices against history's (SimEndgame.choice_legacy_vs_history)
	var cd: Dictionary = sim.endgame.choice_legacy_vs_history() if sim.endgame != null else {}
	if not cd.is_empty():
		econ *= maxf(0.5, 1.0 + float(cd.get("economy", 0.0)) / 100.0)
		sci *= maxf(0.5, 1.0 + float(cd.get("science", 0.0)) / 100.0)
		water *= maxf(0.5, 1.0 + float(cd.get("water", 0.0)) / 100.0)
		stand_track *= maxf(0.5, 1.0 + float(cd.get("standing", 0.0)) / 100.0)
		coh_track *= maxf(0.5, 1.0 + float(cd.get("cohesion", 0.0)) / 100.0)
	return {"population": pop_track, "economy": econ, "science": sci, "water": water, "standing": stand_track, "cohesion": coh_track, "residents": res,
		"gold": S().gold, "science_rate": float(n.get("science", 0)), "culture_rate": float(n.get("culture", 0)),
		"cities": sim.active_cities().size(), "water_per_capita": float(w.get("per_capita", 0.0)), "readiness": S().readiness}


func ghost_turns() -> int:
	return (sim.db.ghost.get("turns", []) as Array).size()


func ghost_at(turn: int) -> Dictionary:
	var g: Dictionary = sim.db.ghost
	var arr: Array = g.get("turns", [])
	if arr.is_empty():
		return {}
	var i := clampi(turn - 1, 0, arr.size() - 1)
	var row: Dictionary = arr[i]
	if sim.endgame == null or S().mode == "historical" or is_equal_approx(sim.endgame.ghost_strength("economy"), 1.0):
		return row
	# v3 difficulty: history's record counts higher (Hard) or lower (Easy); population by the square root
	var out := row.duplicate()
	for t in TRACKS:
		out[t["id"]] = float(row.get(t["id"], 0.0)) * sim.endgame.ghost_strength(t["id"])
	return out


func current_ratios() -> Dictionary:
	## {track: player / ghost} now (1.0 where there is no ghost). Cheap: no reasons (v3 endings and programme picks).
	var v := values()
	var g := ghost_at(S().turn)
	var out := {}
	for t in TRACKS:
		var gv := float(g.get(t["id"], 0.0)) if not g.is_empty() else 0.0
		out[t["id"]] = float(v.get(t["id"], 0.0)) / gv if gv > 0.0 else 1.0
	return out


func real_label(track: String, value: float, ghost_value: float) -> Dictionary:
	## The real figure for this date, and the player's value expressed on the same scale.
	var tr := {}
	for t in TRACKS:
		if t["id"] == track: tr = t
	var series := str(tr.get("real", ""))
	if series == "":
		return {}
	var rv: float = sim.db.real_value(series, SimDB.year_f(S().turn))
	var latest := ""
	if rv < 0:
		# beyond the last datum (series end 2022-2023): show the latest real figure, labelled as such
		var lv: Dictionary = sim.db.real_latest(series)
		if not lv.is_empty() and SimDB.year_f(S().turn) > float(lv["year"]):
			rv = float(lv["value"])
			latest = "latest: %d" % int(lv["year"])
	if rv < 0 or ghost_value <= 0:
		return {}
	var unit := str(sim.db.real.get(series, {}).get("unit", ""))
	var player_equiv := rv * value / ghost_value
	if track == "population":
		player_equiv = value
	var out := {"history": rv, "player": player_equiv, "unit": unit, "source": sim.db.real.get(series, {}).get("source", [])}
	if latest != "":
		out["latest"] = latest
	return out


func sample() -> void:
	var v := values()
	var g := ghost_at(S().turn)
	var entry := {"t": S().turn, "v": v, "infl": snappedf(S().inflation, 0.1)}
	var lb: Dictionary = S().counters.get("last_budget", {})
	entry["net"] = snappedf(float(lb.get("net", 0.0)), 0.1)   # v3 fix3-econ: history's budget record for the inflation gap (A8)
	entry["inc"] = snappedf(float(lb.get("income", 0.0)), 0.1)
	entry["infs"] = snappedf(sim.stream_sum("inflation"), 0.01)   # v3 fix3-econ (A8): history's lasting inflation terms
	entry["infm"] = snappedf(sim.econ.mod_sum("inflation"), 0.01)   # history's price policies in force
	entry["sr"] = snappedf(float(S().counters.get("structural", {}).get("ratio", 0.0)), 0.001)   # v3 final round (fix4-econ): history's outflows against revenue
	if sim.endgame != null:   # v3 fix3-econ (A7): the lasting mark of the choices so far (the ghost's is what players are measured against)
		var clg := {}
		var cl: Dictionary = sim.endgame.choice_legacy()
		for k in cl: clg[k] = snappedf(float(cl[k]), 0.01)
		entry["clg"] = clg
	entry["infsh"] = snappedf(float(S().counters.get("infl_shift_sum", 0.0)), 0.0001)   # history's emergency price measures (log points)
	if not g.is_empty():
		entry["g"] = g
	entry["real_pop"] = sim.db.real_value("population", SimDB.year_f(S().turn))
	S().history.append(entry)


func current() -> Dictionary:
	var v := values()
	var g := ghost_at(S().turn)
	var tracks := []
	var ahead := 0
	var even := 0
	var total := 0.0
	for t in TRACKS:
		var id: String = t["id"]
		var pv := float(v.get(id, 0.0))
		var gv := float(g.get(id, 0.0)) if not g.is_empty() else 0.0
		var ratio := pv / gv if gv > 0 else 1.0
		var status := "even" if absf(ratio - 1.0) < 0.01 else ("ahead" if ratio > 1.0 else "behind")
		var item := {"id": id, "name": t["name"], "player": pv, "ghost": gv, "ratio": ratio, "ahead": status == "ahead", "status": status,
			"points": clampf(100.0 * ratio, 0.0, 200.0), "label": real_label(id, pv, gv)}
		if status == "ahead": ahead += 1
		if status == "even": even += 1
		total += item["points"]
		tracks.append(item)
	var behind := TRACKS.size() - ahead - even
	var summary := "Level with history" if behind == 0 and ahead == 0 else "Ahead in %d, level in %d, behind in %d" % [ahead, even, behind]
	var rmap := {}
	for it in tracks: rmap[it["id"]] = float(it["ratio"])
	var hl := health(rmap)
	return {"turn": S().turn, "date": SimDB.date_label(S().turn), "tracks": tracks, "ahead": ahead, "even": even, "behind": behind, "summary": summary,
		"overall": total / TRACKS.size() * float(hl["factor"]), "overall_raw": total / TRACKS.size(), "health": float(hl["factor"]),
		"health_parts": hl["parts"], "health_text": hl["text"],
		"has_ghost": not g.is_empty(), "reasons": reasons(8)}


const LAG_FROM := 0.9        # v3 fix3-econ (A7): a track below 90% of history's weighs the state's health
const LAG_PER_POINT := 0.25   # percent of the overall per point below it
const LAG_MAX := 20.0


func health(ratios := {}) -> Dictionary:
	## v3 fix3-econ: the state's health weighs the headline overall score (the tracks stay as they are): a collapse of the
	## state in the countdown (up to -25% at its limit), a collapse that ended the game (-30%), inflation above history's
	## (up to -8%), a treasury below zero (up to -6%) and (A7) a track left far behind history's: a quarter percent for each
	## point below 90% of history (up to -20% in all), so ground lost on one track is not hidden by gains on the others.
	## `ratios` ({track: player / ghost}) may be passed by a caller that has them. {factor (1.0 = healthy), parts: [{label, pct}], text}.
	var parts := []
	if S().mode != "historical" and not ghost_at(S().turn).is_empty():
		var rs: Dictionary = ratios if not ratios.is_empty() else current_ratios()
		var lag := 0.0
		var lagging := []
		for t in TRACKS:
			var r := float(rs.get(t["id"], 1.0))
			if r < LAG_FROM:
				lag += (LAG_FROM - r) * 100.0 * LAG_PER_POINT
				lagging.append("%s %d%%" % [str(TRACK_SHORT.get(t["id"], t["name"])), int(round(r * 100.0))])
		if lag > 0.05:
			parts.append({"label": "far behind history's record (%s)" % ", ".join(lagging), "pct": snappedf(minf(LAG_MAX, lag), 0.1)})
	if sim.collapse != null and S().mode != "historical":
		for c in sim.collapse.status():
			var st := int(c["strain"])
			var lim := maxi(1, int(c["limit"]))
			if bool(c.get("ended", false)):
				parts.append({"label": "%s: the state collapsed" % str(c["name"]), "pct": 30.0})
			elif st > 0:
				parts.append({"label": "%s: %d of %d quarters of strain" % [str(c["name"]), st, lim], "pct": snappedf(25.0 * float(st) / float(lim), 0.1)})
	var gap := maxf(0.0, sim.inflation_gap()) if S().mode != "historical" else 0.0
	if gap > 0.1:
		parts.append({"label": "inflation above history's (%.0f%% against %.0f%%)" % [S().inflation, sim.inflation_baseline(SimDB.year_f(S().turn))], "pct": snappedf(minf(8.0, 7.0 * (gap - 0.1)), 0.1)})
	if S().gold < 0.0 and S().mode != "historical":
		var inc := maxf(30.0, float(S().counters.get("income_avg", 45.0)))
		parts.append({"label": "treasury below zero (%s gold)" % sim.econ._fmt_n(S().gold), "pct": snappedf(minf(6.0, 6.0 * -S().gold / (8.0 * inc)), 0.1)})
	var f := 1.0
	for x in parts:
		f *= 1.0 - float(x["pct"]) / 100.0
	var txt := "" if parts.is_empty() else "State's health %d%%: %s." % [int(round(f * 100.0)), "; ".join(parts.map(func(x): return "%s -%.0f%%" % [str(x["label"]), float(x["pct"])]))]
	return {"factor": f, "parts": parts, "text": txt}


func overall_now() -> Dictionary:
	## The headline overall without the reasons (cheap): {raw, health, overall}.
	var v := values()
	var g := ghost_at(S().turn)
	var total := 0.0
	var rmap := {}
	for t in TRACKS:
		var gv := float(g.get(t["id"], 0.0)) if not g.is_empty() else 0.0
		rmap[t["id"]] = float(v.get(t["id"], 0.0)) / gv if gv > 0 else 1.0
		total += clampf(100.0 * float(rmap[t["id"]]), 0.0, 200.0)
	var h := float(health(rmap)["factor"])
	return {"raw": total / TRACKS.size(), "health": h, "overall": total / TRACKS.size() * h}


const TERM_TRACK6 := {"gold": "economy", "output_pct": "economy", "inflation": "economy", "standing": "standing", "standing_target": "standing",
	"trust": "cohesion", "trust_base": "cohesion", "cohesion": "cohesion", "amenity": "cohesion", "readiness": "standing",
	"science_pct": "science", "growth_pct": "population", "retention": "population", "water": "water", "immigrant_weight": "population"}
const TRACK_CAP := 2.0   # the score counts each track up to 200% of history's (points = clampf(100 x ratio, 0, 200))


static func ratio_text(ratio: float) -> String:
	## A track's ratio to history as shown everywhere (VS. HISTORY, the end screen, the Ending outlook, the epilogue):
	## the score counts a track up to 200%, so a larger ratio reads ">200%" rather than a figure the score ignores.
	if ratio * 100.0 >= TRACK_CAP * 100.0 + 0.5: return ">%d%%" % int(TRACK_CAP * 100.0)
	return "%d%%" % int(round(ratio * 100.0))


static func ratio_delta_text(ratio: float) -> String:
	## The same as a difference from history ("+12%", ">+100%" past the cap).
	if ratio * 100.0 >= TRACK_CAP * 100.0 + 0.5: return ">%+d%%" % int((TRACK_CAP - 1.0) * 100.0)
	return "%+.0f%%" % ((ratio - 1.0) * 100.0)


const TRACK_SHORT := {"population": "Population", "economy": "Economy", "science": "Science", "water": "Water", "standing": "Standing", "cohesion": "Cohesion"}
const ENVELOPE_TRACK := {"defence": "standing", "absorption": "population", "development": "water", "education": "science"}
const ENVELOPE_NAME := {"defence": "defence first", "absorption": "absorption and housing first", "development": "development and water first",
	"education": "education and science first", "balanced": "balanced", "war": "war budgets"}
const PLACEMENT_EFFECT := {"cities": {"economy": 1.0, "population": 0.5}, "dev_towns": {"cohesion": -0.6, "population": -0.4, "standing": 0.2},
	"villages": {"water": -1.0, "economy": -0.4, "cohesion": 0.3}, "camps": {"cohesion": -1.0, "population": -0.6}}


func _fork_drivers(fade_turns := 40.0) -> Array:
	## Forks and event choices answered differently from history, with the signed weight of each lasting term on its
	## track, discounted for terms that ended long before now (fix-cabinet, V2_FIXES C1: credit what is still in force).
	var st := S()
	var out := []
	var now := st.turn
	for e in sim.forks.get_path_ledger():
		if e.get("matched_history", true):
			continue
		var per := {}
		var live := {}
		for s2 in st.streams:
			if str(s2.get("src", "")) != str(e["id"]):
				continue
			var t := str(s2.get("type", ""))
			var yrs := float(int(s2.get("until", 0)) - int(s2.get("from", 0)) + 1) / 4.0
			var mag := float(s2.get("amount", 0)) / float(SimDB.TERM_TYPICAL.get(t, 1.0)) * clampf(yrs / 8.0, 0.25, 3.0)
			if t == "gold": mag /= maxf(1.0, sim.events.gold_scale())
			if t == "inflation": mag = -mag
			if t == "immigrant_weight": mag *= 0.3
			var until := int(s2.get("until", 0))
			var active := 1.0 if until >= now - 1 else exp(-float(now - until) / fade_turns)
			var tr := str(TERM_TRACK6.get(t, "economy"))
			per[tr] = float(per.get(tr, 0.0)) + mag * (0.25 + 0.75 * active)
			if active >= 1.0: live[tr] = str(s2.get("label", ""))
		for tr in per:
			if absf(float(per[tr])) < 0.05: continue
			var still := live.has(tr)
			out.append({"track": tr, "weight": float(per[tr]), "kind": "choice", "id": str(e["id"]),
				"text": "your choice \"%s\" at \"%s\" (history: \"%s\")%s" % [e.get("chosen_label", ""), e.get("title", ""), e.get("historical_label", ""),
					(", still in force: " + str(live[tr])) if still else ""]})
	for evid in st.choices_made:
		var ev = sim.db.event_by_id.get(evid)
		if ev == null: continue
		var idx := int(st.choices_made[evid])
		var hist: int = sim.events.historical_choice(ev)
		if idx == hist or idx < 0 or idx >= ev["choices"].size(): continue
		var per2 := {}
		for s3 in st.streams:
			if str(s3.get("src", "")) != str(evid): continue
			var t3 := str(s3.get("type", ""))
			var until3 := int(s3.get("until", 0))
			var act3 := 1.0 if until3 >= now - 1 else exp(-float(now - until3) / fade_turns)
			var m3 := float(s3.get("amount", 0)) / float(SimDB.TERM_TYPICAL.get(t3, 1.0)) * (0.25 + 0.75 * act3)
			if t3 == "gold": m3 /= maxf(1.0, sim.events.gold_scale())
			if t3 == "inflation": m3 = -m3
			var tr3 := str(TERM_TRACK6.get(t3, "cohesion"))
			per2[tr3] = float(per2.get(tr3, 0.0)) + m3
		for tr3 in per2:
			if absf(float(per2[tr3])) < 0.05: continue
			out.append({"track": tr3, "weight": float(per2[tr3]) * 0.8, "kind": "choice", "id": str(evid),
				"text": "your choice \"%s\" at \"%s\" (%s; history: \"%s\")" % [ev["choices"][idx].get("label", ""), ev.get("title", evid), str(ev.get("date", "")).substr(0, 4), ev["choices"][hist].get("label", "")]})
	return out


func _count_by(arr: Array, key: String) -> Dictionary:
	var c := {}
	for b in arr:
		var k := str(b.get(key, ""))
		c[k] = int(c.get(k, 0)) + 1
	return c


func _budget_drivers() -> Array:
	## The State Budget splits against the ghost's: an envelope led more often than history helps its track and
	## costs the other three.
	var st := S()
	var bh: Array = st.counters.get("budget_history", [])
	if bh.size() < 3:
		return []
	var pc := _count_by(bh, "preset")
	var gc: Dictionary = sim.db.ghost.get("budget_counts", {})
	var gn := 0
	for k in gc: gn += int(gc[k])
	var out := []
	var scale := float(bh.size()) / maxf(1.0, float(gn)) if gn > 0 else 1.0
	for env in ENVELOPE_TRACK:
		var mine := int(pc.get(env, 0)) + (int(pc.get("war", 0)) if env == "defence" else 0)
		var theirs := (float(gc.get(env, 0)) + (float(gc.get("war", 0)) if env == "defence" else 0.0)) * scale
		var d := float(mine) - theirs
		if absf(d) < 2.0: continue
		var txt := "State Budgets: %s in %d of %d years (history's ghost: %d)" % [ENVELOPE_NAME[env], mine, bh.size(), int(round(theirs))]
		out.append({"track": ENVELOPE_TRACK[env], "weight": d * 0.25, "kind": "budget", "text": txt})
		for other in ENVELOPE_TRACK:
			if d > 0.0 and other != env and ENVELOPE_TRACK[other] != ENVELOPE_TRACK[env]:
				out.append({"track": ENVELOPE_TRACK[other], "weight": -d * 0.08, "kind": "budget", "text": txt})
	return out


func _immigration_drivers() -> Array:
	var st := S()
	var mine := {}
	var n := 0
	for b in ["cities", "dev_towns", "villages", "camps"]:
		mine[b] = int(st.counters.get("imm_plan_" + b, 0))
		n += int(mine[b])
	if n < 4:
		return []
	var gc: Dictionary = sim.db.ghost.get("imm_counts", {})
	var gn := 0
	for k in gc: gn += int(gc[k])
	var out := []
	for b in mine:
		var share := float(mine[b]) / float(n)
		var gshare := float(gc.get(b, 0)) / maxf(1.0, float(gn)) if gn > 0 else 0.25
		var d := share - gshare
		if absf(d) < 0.12: continue
		var name: String = {"cities": "the large cities", "dev_towns": "development and periphery towns", "villages": "villages and moshavim", "camps": "transit camps and caravan sites"}[b]
		var txt := "Immigration plans: %d of %d quarters to %s (history's ghost: %.0f%%)" % [int(mine[b]), n, name, gshare * 100.0]
		for tr in PLACEMENT_EFFECT[b]:
			out.append({"track": tr, "weight": d * 4.0 * float(PLACEMENT_EFFECT[b][tr]), "kind": "immigration", "text": txt})
	return out


func _fiscal_drivers() -> Array:
	## Deficits, borrowing, inflation above history and open deficit rails (economy track).
	var st := S()
	var out := []
	var g: Dictionary = sim.db.ghost
	var dt := int(st.counters.get("deficit_turns", 0))
	var gdt := int(g.get("deficit_turns", dt))
	var bor := float(st.counters.get("borrowed_total", 0.0))
	var health: float = sim.econ.economy_health()
	var peak := 0.0; var py := 0
	for h in st.history:
		var infl := float(h.get("infl", 0.0))
		if infl > peak: peak = infl; py = SimDB.year_of(int(h["t"]))
	var txt := "Deficits: net gold negative in %d of %d quarters (history's ghost: %d)" % [dt, st.turn, gdt]
	if bor > 0.0: txt += ", %s gold borrowed" % sim.econ._fmt_n(bor)
	if peak > 0.0 and py > 0:
		txt += "; inflation peaked at %s%% in %d (history %.0f%%)" % [sim.econ._fmt_n(peak), py, sim.inflation_baseline(float(py) + 0.5)]
	var w := -(float(dt - gdt) / maxf(20.0, float(st.turn))) * 3.0 - (1.0 - health) * 6.0
	if absf(w) > 0.1:
		out.append({"track": "economy", "weight": w, "kind": "deficit", "text": txt})
	if float(st.counters.get("repaid_early", 0.0)) > 0.0 or (dt < gdt - 10):
		out.append({"track": "economy", "weight": 0.4 + float(gdt - dt) / maxf(20.0, float(st.turn)) * 2.0, "kind": "deficit",
			"text": "Fiscal record: %d deficit quarters against history's %d%s" % [dt, gdt, (", %s of debt repaid early" % sim.econ._fmt_n(float(st.counters.get("repaid_early", 0.0)))) if float(st.counters.get("repaid_early", 0.0)) > 0.0 else ""]})
	for r in sim.econ.open_deficit_rails():
		var since := 0
		for s in st.streams:
			if str(s.get("label", "")) == str(r["label"]): since = int(s.get("from", 0))
		var q := st.turn - since
		if q > 8:
			out.append({"track": "economy", "weight": float(r["amount"]) / maxf(1.0, sim.events.gold_scale()) * q / 120.0, "kind": "rail",
				"text": "%s: still open after %d years (%d a quarter; it %s)" % [str(r["label"]), q / 4, int(r["amount"]), str(r["ends"])]})
	return out


func _milestone_drivers() -> Array:
	## Milestones only where they still matter: within the last 20 years, or a national project or water item still
	## missing (no "first recreation complex" trivia at the final payoff).
	var st := S()
	var gm: Dictionary = sim.db.ghost.get("milestones", {})
	var pm: Dictionary = st.milestones
	var out := []
	for k in gm:
		var kind := str(k).split(":")[0]
		if not MILESTONE_TRACK.has(kind) or kind in ["building", "boost", "district"]:
			continue
		var gt := int(gm[k])
		if gt > st.turn: continue
		var track := "water" if k in WATER_ITEMS else str(MILESTONE_TRACK[kind])
		var recent := st.turn - gt <= 80
		if not pm.has(k):
			if recent or k in WATER_ITEMS or kind == "project":
				out.append({"track": track, "weight": -0.6, "kind": "milestone", "text": "%s: history had it in %s, you do not" % [_milestone_name(k), SimDB.date_label(gt)]})
		else:
			var d := gt - int(pm[k])
			if absi(d) >= 8 and (recent or st.turn - int(pm[k]) <= 80 or k in WATER_ITEMS):
				out.append({"track": track, "weight": 0.04 * float(d), "kind": "milestone", "text": "%s %d years %s than history" % [_milestone_name(k), absi(d) / 4, "earlier" if d > 0 else "later"]})
	return out


func driver_reasons(limit := 8) -> Array:
	## "What made the difference": each track's gap with history now (player / ghost - 1), attributed to its largest
	## drivers that push the same way: forks and choices still in force, the State Budget splits, immigration
	## placement, deficits and debt, open rails, and only recent or still-missing milestones. Tracks with the
	## largest gaps first, up to two drivers each. Entries {track, gap, kind, weight, turns, text, line}.
	var g := ghost_at(S().turn)
	if g.is_empty():
		return []
	var v := values()
	var cands := _fork_drivers() + _budget_drivers() + _immigration_drivers() + _fiscal_drivers() + _milestone_drivers() + _programme_drivers() + _legacy_drivers()
	var gaps := []
	for t in TRACKS:
		var gv := float(g.get(t["id"], 0.0))
		if gv <= 0.0: continue
		var gap := float(v.get(t["id"], 0.0)) / gv - 1.0
		if absf(gap) >= 0.02: gaps.append([t["id"], gap])
	gaps.sort_custom(func(a, b): return absf(float(a[1])) > absf(float(b[1])))
	var out := []
	var used := {}
	for gp in gaps:
		var tr := str(gp[0]); var gap := float(gp[1])
		var mine := cands.filter(func(c): return str(c["track"]) == tr and signf(float(c["weight"])) == signf(gap))
		mine.sort_custom(func(a, b): return absf(float(a["weight"])) > absf(float(b["weight"])))
		var n := 0
		for c in mine:
			if n >= 2: break
			var key := str(c["text"])
			if used.has(key): continue
			used[key] = true
			n += 1
			var txt := "%+.0f%% vs history: %s" % [gap * 100.0, str(c["text"])]
			out.append({"track": tr, "gap": snappedf(gap, 0.001), "kind": str(c["kind"]), "weight": snappedf(float(c["weight"]), 0.01), "turns": 0, "good": gap > 0.0,
				"text": txt, "headline": txt, "line": "%s %s" % [TRACK_SHORT.get(tr, tr), txt]})
		if n == 0:
			var txt2 := "%+.0f%% vs history: no single decision; the pace of building and growth over the decades" % (gap * 100.0)
			out.append({"track": tr, "gap": snappedf(gap, 0.001), "kind": "pace", "weight": 0.0, "turns": 0, "good": gap > 0.0, "text": txt2, "headline": txt2, "line": "%s %s" % [TRACK_SHORT.get(tr, tr), txt2]})
	return out.slice(0, limit)


func choice_reasons() -> Array:
	## (kept for callers) The player's own decisions that moved a track, strongest first.
	var c := _fork_drivers() + _budget_drivers() + _immigration_drivers() + _fiscal_drivers()
	c.sort_custom(func(a, b): return absf(float(a["weight"])) > absf(float(b["weight"])))
	return c.map(func(x): return {"track": x["track"], "turns": 0, "weight": x["weight"], "kind": "choice", "text": x["text"]})


func reasons(limit := 8) -> Array:
	## Itemised reasons for the score screen and the end screen's "What made the difference" (driver_reasons).
	return driver_reasons(limit)


func _milestone_name(k: String) -> String:
	var parts := k.split(":")
	var kind := parts[0]; var id := parts[1] if parts.size() > 1 else ""
	match kind:
		"tech": return str(sim.db.techs.get(id, {}).get("name", id))
		"civic": return str(sim.db.civics.get(id, {}).get("name", id))
		"project": return str(sim.db.projects.get(id, {}).get("name", id))
		"district": return "First " + str(sim.db.districts.get(id, {}).get("name", id))
		"town": return "Town of " + str(sim.db.city_by_id.get(id, {}).get("name", id))
	return k


func final_summary() -> Dictionary:
	var cur := current()
	cur["timeline"] = S().timeline.size()
	cur["crises"] = S().crisis_log.size()
	# v3 final round (fix4-econ): the count of decisions answered differently comes from the path ledger (one source)
	cur["counterfactual_choices"] = int(sim.endgame.choice_counts()["differed"]) if sim.endgame != null else int(S().counters.get("counterfactual_choices", 0))
	cur["counterfactual_choices_all"] = int(S().counters.get("counterfactual_choices", 0))
	cur["verdict"] = "Outperformed history in %d of 6 tracks" % int(cur["ahead"])
	if float(cur.get("health", 1.0)) < 0.995:
		cur["verdict"] += " (%s)" % str(cur.get("health_text", ""))
	return cur


func export_ghost(path: String) -> Error:
	## Writes this run (normally mode == "historical") as the ghost of history.
	var turns := []
	for h in S().history:
		var v: Dictionary = h["v"]
		var row := {"t": h["t"]}
		for k in ["population", "economy", "science", "water", "standing", "cohesion", "gold", "science_rate", "culture_rate", "cities", "water_per_capita", "readiness"]:
			row[k] = snappedf(float(v.get(k, 0.0)), 0.001)
		row["net"] = float(h.get("net", 0.0))
		row["inc"] = float(h.get("inc", 0.0))
		row["infs"] = float(h.get("infs", 0.0))
		for k2 in ["infm", "infsh", "sr"]:
			if h.has(k2): row[k2] = float(h[k2])
		if h.has("clg"): row["clg"] = h["clg"]
		turns.append(row)
	var data := {"generated_by": "scripts/sim/sim_test.gd (Historical Israel autoplayer, mode=historical)", "seed": S().rng_seed,
		"note": "The ghost of history: a scripted run that follows the real dates (techs, civics, foundings, national projects, event choices). Values are in game units; real-world figures are labels only.",
		"tracks": TRACKS, "turns": turns, "milestones": S().milestones.duplicate(), "budget_top": _budget_top(),
		"budget_counts": _count_by(S().counters.get("budget_history", []), "preset"),
		"imm_counts": {"cities": int(S().counters.get("imm_plan_cities", 0)), "dev_towns": int(S().counters.get("imm_plan_dev_towns", 0)),
			"villages": int(S().counters.get("imm_plan_villages", 0)), "camps": int(S().counters.get("imm_plan_camps", 0))},
		"deficit_turns": int(S().counters.get("deficit_turns", 0)), "borrowed_total": snappedf(float(S().counters.get("borrowed_total", 0.0)), 1.0),
		"endgame": _endgame_record()}
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify(data, " "))
	return OK


func _endgame_record() -> Dictionary:
	## v3 (sim-endgame): what the endings compare with history: strikes on towns (whole game and by date), treaties
	## in force, programme levels by group.
	var by := {}
	for cr in S().crisis_log:
		var t := int(cr.get("end", 0))
		by[t] = int(by.get(t, 0)) + int(cr.get("city_hits", 0))
	var keys := by.keys()
	keys.sort()
	var cum := 0
	var cum_by := {}
	for k in keys:
		cum += int(by[k])
		cum_by[str(k)] = cum
	var groups := {}
	for g in SimEndgame.GROUP_NAMES:
		groups[g] = sim.endgame.group_levels(g)
	return {"town_strikes": cum, "town_strikes_by_turn": cum_by, "treaties": sim.endgame.treaties(), "programme_levels": groups,
		"programmes_spent": snappedf(float(sim.endgame.eg().get("spent", 0.0)), 1.0)}


func _programme_drivers() -> Array:
	## v3: national programmes against history's: levels and expansions done (or done earlier / not done), per track.
	var out := []
	var gm: Dictionary = sim.db.ghost.get("milestones", {})
	for p in SimEndgame.programme_defs():
		var pid := str(p["id"])
		var ps: Dictionary = sim.endgame.pstate(pid)
		var mine: int = ps["done"].size() + int(ps["expand"])
		var hist := 0
		for k in gm:
			if str(k).begins_with("programme:%s:" % pid) and int(gm[k]) <= S().turn: hist += 1
		if mine == hist:
			continue
		var per := {}
		for l in p.get("levels", []):
			for t in l.get("legacy", {}): per[t] = float(per.get(t, 0.0)) + float(l["legacy"][t])
		for t in per:
			var w := float(mine - hist) * float(per[t]) / maxf(1.0, p.get("levels", []).size()) * 0.15
			out.append({"track": t, "weight": w, "kind": "programme", "text": "National programmes: %s, %d level%s done (history's ghost: %d)" % [p.get("name", pid), mine, "" if mine == 1 else "s", hist]})
	return out


func _legacy_drivers() -> Array:
	## v3 fix3-econ (A7): the lasting mark the cabinet's choices left on each track, against the one history's choices left.
	var out := []
	if sim.endgame == null: return out
	var cd: Dictionary = sim.endgame.choice_legacy_vs_history()
	var gl: Dictionary = ghost_at(S().turn).get("clg", {})
	var cl: Dictionary = sim.endgame.choice_legacy()
	for t in cd:
		var d := float(cd[t])
		if absf(d) < 1.0: continue
		out.append({"track": t, "weight": d / SimEndgame.CHOICE_LEGACY_K, "kind": "legacy",
			"text": "the lasting mark of your cabinet's choices, %+.0f%% on this track against history's choices (%+.0f%% against %+.0f%%)" % [d, float(cl.get(t, 0.0)), float(gl.get(t, 0.0))]})
	return out


func _budget_top() -> String:
	var cnt := {}
	for b in S().counters.get("budget_history", []):
		cnt[str(b.get("preset", ""))] = int(cnt.get(str(b.get("preset", "")), 0)) + 1
	var top := ""
	var tn := 0
	for k in cnt:
		if int(cnt[k]) > tn:
			tn = int(cnt[k]); top = k
	return top
