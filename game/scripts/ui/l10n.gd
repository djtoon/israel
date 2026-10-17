class_name L10n
extends RefCounted
## Localisation (v3 item 11). English is the source language; Hebrew ("he") is the first translation.
## Format and rules for translators: game/i18n/I18N.md.
##
## How text gets translated
## - UI strings: catalogs game/i18n/<lang>/*.json, flat {English: translation}. Keys may hold placeholders: {0}, {name}
##   (any text, itself translated) or {#0} (a number, kept as is). BBCode tags are never part of a key: a string
##   with tags is translated run by run between the tags.
## - Data text (events, forks, techs, ..., place names): game/data/i18n/<lang>/<source>.json,
##   {record: {field: {en, he}}}, made by tools/i18n/make_skeletons.py. Looked up by the English text (and by
##   source / record / field through data()).
## - Everything reaches the screen through Godot's own translation hook: L10nTranslation (a Translation whose
##   _get_message calls translate()) is registered with the TranslationServer, so Labels, Buttons, tooltips,
##   RichTextLabels, OptionButton items and Label3Ds translate themselves; UIKit.text() (custom drawn HUD, map
##   banners) calls t(). Code that formats a string first ("Turn %d" % n) needs nothing: the catalog key
##   "Turn {#0}" matches the finished text.
## - Missing translations fall back to English. In Hebrew, the memorial (ending_oct7.json) stays in the user's own
##   English unless that file has paragraphs_he.
##
## Right to left: the screen layout (window docks, the HUD) keeps its English positions so the Civ-style top bar and
## side panels still fit together; the content of every container (window bodies, rows, cards) is laid out right to
## left: rows mirror, text aligns right, scroll bars move left. A node with meta "i18n_ltr" keeps left-to-right.

const UI_DIR := "res://i18n/"
const DATA_DIR := "res://data/i18n/"
const RTL_LANGS := ["he", "ar", "fa", "ur", "yi"]
const LANG_NAMES := {"en": "English", "he": "עברית"}
const MEMO_MAX := 30000

static var lang := "en"
static var rtl := false
static var ready := false
static var catalog := {}        # English -> translation (UI catalogs + data text)
static var lower := {}          # lower-case English -> translation
static var data_en := {}        # every English data string (translated or not), lower-case -> true
static var data_rec := {}       # "source/record/field" -> translation
static var patterns: Array = []          # [{re, names, he, lit}], most literal text first
static var _ui_loading := false
static var _pattern_en := {}            # English pattern -> its entry: a later catalog file overrides an earlier one
static var buckets := {}                 # first two lower-case letters of the literal prefix -> [pattern]
static var wild: Array = []              # patterns that start with a placeholder
static var memo := {}           # source -> [translation, ui_misses(Array)]
static var misses := {}         # untranslated UI text seen this run -> count (for the tests and tools)
static var verbatim := {}       # text shown as published in every language (source citations), lower-case -> true
static var miss_parts := {}     # the untranslated pieces of those texts -> count
static var pending := {}        # data text shown in English because its translation is not in yet -> count
static var stats := {}          # {ui: n, data: n, data_translated: n, patterns: n}
static var _translation: Translation
static var _tag_re: RegEx
static var _latin_re: RegEx
static var _ph_re: RegEx
static var _edge_re: RegEx
static var _allow_re: RegEx
static var _hooked := false


# ================================================================== setup

static func setup(code: String) -> void:
	## Loads the catalogs for `code` and switches the TranslationServer to it ("en" = no translation).
	_compile()
	install_fonts()
	if _translation != null:
		TranslationServer.remove_translation(_translation)
		_translation = null
	catalog.clear(); lower.clear(); data_en.clear(); data_rec.clear(); patterns.clear(); _pattern_en.clear(); buckets.clear(); wild.clear()
	memo.clear(); misses.clear(); miss_parts.clear(); pending.clear(); verbatim.clear(); pending_res.clear(); stats.clear()
	lang = code if code != "" else "en"
	rtl = lang in RTL_LANGS
	if lang != "en":
		_ui_loading = true
		_load_ui(lang)
		_ui_loading = false
		_load_data(lang)
		_index_patterns()
		_translation = L10nTranslation.new()
		# Registered under the engine locale "en": the TranslationServer keeps "en", so text with no letters of its own
		# (numbers, "+3", "4 / 5.0") stays left to right instead of taking the locale's right-to-left default, while
		# Hebrew text still reads right to left by its letters (Unicode bidi). The language itself is L10n.lang.
		_translation.locale = "en"
		TranslationServer.add_translation(_translation)
	TranslationServer.set_locale("en")
	ready = true
	var ml := Engine.get_main_loop()
	if ml is SceneTree:
		_hook_tree(ml as SceneTree)
		# every Label, Button and tooltip on screen re-translates itself (a live switch: the locale itself stays "en")
		(ml as SceneTree).root.propagate_notification(Node.NOTIFICATION_TRANSLATION_CHANGED)


static func shutdown() -> void:
	## Unregisters the translation (a script Translation left in the server at exit can crash the engine).
	if _translation != null:
		TranslationServer.remove_translation(_translation)
		_translation = null


static func available(code: String) -> bool:
	if code == "en":
		return true
	return DirAccess.dir_exists_absolute(UI_DIR + code) and not DirAccess.get_files_at(UI_DIR + code).is_empty()


static func is_he() -> bool:
	return lang == "he"


static func _compile() -> void:
	if _tag_re != null:
		return
	_tag_re = RegEx.create_from_string("\\[img[^\\]]*\\][^\\[]*\\[/img\\]|\\[/?(?:b|i|u|s|code|center|left|right|fill|indent|ul|ol|table|cell|p|br|lb|rb|hint|url|color|bgcolor|fgcolor|font|font_size|outline_size|outline_color|wave|shake|tornado|rainbow|pulse|fade|dropcap|lang|opentype_features|char|hr)(?:[= ][^\\]]*)?\\]")
	_latin_re = RegEx.create_from_string("[A-Za-z]")
	_ph_re = RegEx.create_from_string("\\{(#?[A-Za-z0-9_]+)\\}")
	_edge_re = RegEx.create_from_string("^([\\s•·▸►*\\-–—:,]*)(.*?)([\\s.:;,!?…]*)$")
	# Latin text that is fine in a Hebrew UI: key names, units, licences, acronyms kept by Hebrew usage
	_allow_re = RegEx.create_from_string("(?i)\\b(English|Ctrl|Alt|Shift|Esc|Enter|Space|Tab|Backspace|F\\d{1,2}|Page ?Up|Page ?Down|Home|End|WASD|[A-Z]|OFL|SIL|CC|BY|SA|CC0|PD|SD|HD|km|MW|AI|Godot|Engine|Cinzel|Crimson Pro|Cormorant Garamond|Frank Ruhl Libre|Noto Sans Hebrew|S\\d{2,5}|UI test \\w+|v\\d+|https?://\\S+|www\\.\\S+|\\S+\\.(?:png|jpg|webp|json|ttf|org|com|gov|il|net|edu))\\b")


static func _hook_tree(tree: SceneTree) -> void:
	if _hooked:
		return
	_hooked = true
	tree.node_added.connect(_on_node_added)
	# the screen layout stays left-to-right (the HUD and the window docks are drawn for it); content mirrors
	tree.root.call("set_layout_direction", 2)   # Window.LAYOUT_DIRECTION_LTR


static func _on_node_added(n: Node) -> void:
	if not rtl or not (n is Control):
		return
	var c := n as Control
	if c.has_meta("i18n_ltr"):
		return
	if c.layout_direction == Control.LAYOUT_DIRECTION_INHERITED:
		var p := c.get_parent()
		if p is Container and not (p as Control).is_layout_rtl() and not p.has_meta("i18n_ltr") and not _ltr_marked(p):
			c.layout_direction = Control.LAYOUT_DIRECTION_RTL
			c.set_meta("i18n_rtl", true)
	# rich text in right-to-left content: every paragraph right to left and right-aligned (with AUTO, Godot keeps
	# the paragraphs left-aligned in an RTL layout)
	if c is RichTextLabel and (c as RichTextLabel).text_direction == Control.TEXT_DIRECTION_AUTO and c.is_layout_rtl() and not _ltr_marked(c):
		(c as RichTextLabel).text_direction = Control.TEXT_DIRECTION_INHERITED
		c.set_meta("i18n_rtl_text", true)


static func relayout(n: Node) -> void:
	## After a live language switch: applies (or removes) the right-to-left content layout on everything already
	## on screen, top down. New nodes get it from the node_added hook.
	for c in n.get_children():
		if c is Control:
			if rtl:
				_on_node_added(c)
			else:
				if c.has_meta("i18n_rtl"):
					(c as Control).layout_direction = Control.LAYOUT_DIRECTION_INHERITED
					c.remove_meta("i18n_rtl")
				if c.has_meta("i18n_rtl_text"):
					(c as RichTextLabel).text_direction = Control.TEXT_DIRECTION_AUTO
					c.remove_meta("i18n_rtl_text")
		relayout(c)


static func _ltr_marked(n: Node) -> bool:
	var p := n
	for i in 12:
		if p == null:
			return false
		if p.has_meta("i18n_ltr"):
			return true
		p = p.get_parent()
	return false


static func keep_ltr(c: Control) -> void:
	## Content that must read left to right in every language (the memorial in English, URLs, credits lines).
	c.set_meta("i18n_ltr", true)
	c.layout_direction = Control.LAYOUT_DIRECTION_LTR


static func ltr(text: String) -> String:
	## Left-to-right text inside a right-to-left line (an English citation, a formula, a licence name): wrapped in a
	## left-to-right isolate (U+2066 ... U+2069) in a right-to-left language, so its punctuation keeps its place.
	if not rtl or text.strip_edges() == "":
		return text
	return char(0x2066) + text + char(0x2069)


static func mark_verbatim(text: String) -> String:
	## Text that stays as published inside translated text (a source citation, a title of a work): returns it.
	if lang != "en" and text.strip_edges() != "":
		verbatim[text.strip_edges().to_lower()] = true
	return text


static func raw_label(l: Control, text: String) -> Control:
	## Text shown exactly as written in every language (names, licences, links): no translation, not audited.
	l.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	l.set_meta("i18n_skip", true)
	l.set("text", text)
	return l


static func skip(c: Control) -> void:
	## Text intentionally left untranslated (licences, photographers' names, the user's memorial): the Hebrew UI test
	## does not report it.
	c.set_meta("i18n_skip", true)


# ================================================================== fonts

static var _fonts_done := false
static var _he_serif: FontFile
static var _he_sans: FontFile


static func hebrew_font(weight := 500, sans := false) -> Font:
	install_fonts()
	if (_he_sans if sans else _he_serif) == null:
		return null
	var f := FontVariation.new()
	f.base_font = _he_sans if sans else _he_serif
	f.variation_opentype = {"wght": weight}
	return f


static func install_fonts() -> void:
	## Hebrew fallbacks for every Latin font the game uses (Cinzel and Crimson Pro have no Hebrew): Frank Ruhl Libre
	## (serif, OFL) for the serif faces, Noto Sans Hebrew (OFL) for the engine's sans default. Harmless in English.
	if _fonts_done:
		return
	_fonts_done = true
	if ResourceLoader.exists("res://assets/fonts/FrankRuhlLibre.ttf"):
		_he_serif = load("res://assets/fonts/FrankRuhlLibre.ttf")
	if ResourceLoader.exists("res://assets/fonts/NotoSansHebrew.ttf"):
		_he_sans = load("res://assets/fonts/NotoSansHebrew.ttf")
	if _he_serif == null:
		return
	for p in ["res://assets/fonts/Cinzel.ttf", "res://assets/fonts/CrimsonPro.ttf", "res://assets/fonts/CormorantGaramond.ttf"]:
		if ResourceLoader.exists(p):
			var ff: Font = load(p)
			if ff != null and not ff.fallbacks.has(_he_serif):
				var fb := ff.fallbacks.duplicate()
				fb.append(_he_serif)
				ff.fallbacks = fb
	var df := ThemeDB.fallback_font
	if df != null and _he_sans != null and not df.fallbacks.has(_he_sans):
		var fb2 := df.fallbacks.duplicate()
		fb2.append(_he_sans)
		df.fallbacks = fb2


# ================================================================== loading

static func _read(path: String):
	if not FileAccess.file_exists(path):
		return null
	return JSON.parse_string(FileAccess.get_file_as_string(path))


static func _load_ui(code: String) -> void:
	var dir := UI_DIR + code + "/"
	var n := 0
	if not DirAccess.dir_exists_absolute(dir):
		return
	var files := Array(DirAccess.get_files_at(dir))
	files.sort()
	for fn in files:
		if not str(fn).ends_with(".json"):
			continue
		var d = _read(dir + fn)
		if typeof(d) != TYPE_DICTIONARY:
			push_warning("L10n: %s is not a JSON object" % fn)
			continue
		for k in d:
			var en := str(k)
			if en.begins_with("_"):
				continue
			var v = d[k]
			if typeof(v) != TYPE_STRING or str(v) == "":
				continue
			_add(en, str(v))
			n += 1
	stats["ui"] = n


static func _load_data(code: String) -> void:
	var dir := DATA_DIR + code + "/"
	var n := 0
	var nt := 0
	if not DirAccess.dir_exists_absolute(dir):
		return
	for fn in DirAccess.get_files_at(dir):
		if not str(fn).ends_with(".json"):
			continue
		var src := str(fn).get_basename()
		var d = _read(dir + fn)
		if typeof(d) != TYPE_DICTIONARY:
			push_warning("L10n: %s is not a JSON object" % fn)
			continue
		for rk in d:
			if str(rk).begins_with("_") or typeof(d[rk]) != TYPE_DICTIONARY:
				continue
			var rec: Dictionary = d[rk]
			for fk in rec:
				var e = rec[fk]
				if typeof(e) != TYPE_DICTIONARY:
					continue
				var en := str(e.get("en", ""))
				var he := str(e.get("he", ""))
				n += 1
				# UITheme.tidy() shows "(A (B))" as "(A, B)": the inner "A (B)" of a data text also reads "A, B"
				var en2 := _flat_parens(en)
				if en != "":
					data_en[en.strip_edges().to_lower()] = true
					if en2 != en:
						data_en[en2.strip_edges().to_lower()] = true
				if he == "" or bool(e.get("stale", false)):
					if en.contains("{"):
						_add_pending_pattern(en)
					continue
				nt += 1
				data_rec["%s/%s/%s" % [src, rk, fk]] = he
				if en != "" and not catalog.has(en):
					_add(en, he)
					if en2 != en and not catalog.has(en2):
						_add(en2, _flat_parens(he))
	stats["data"] = n
	stats["data_translated"] = nt


static var pending_res: Array = []    # data templates ("By {end} your Israel ...") not translated yet


static func _add_pending_pattern(en: String) -> void:
	var rx := "^"
	var pos := 0
	for m in _ph_re.search_all(en):
		rx += _escape(en.substr(pos, m.get_start() - pos)) + "(.+?)"
		pos = m.get_end()
	if pos == 0:
		return
	rx += _escape(en.substr(pos)) + "$"
	var re := RegEx.create_from_string("(?is)" + rx)
	if re != null and re.is_valid():
		pending_res.append(re)


static func _pending_match(t: String) -> bool:
	for re in pending_res:
		if (re as RegEx).search(t) != null:
			return true
	return false


static var _paren_re: RegEx


static func _flat_parens(t: String) -> String:
	if not t.ends_with(")") or not t.contains(" ("):
		return t
	if _paren_re == null:
		_paren_re = RegEx.create_from_string("^(.*[^ ]) \\(([^()]*)\\)$")
	var m := _paren_re.search(t)
	return t if m == null else m.get_string(1) + ", " + m.get_string(2)


static func _add(en: String, he: String) -> void:
	if _ph_re.search(en) != null:
		_add_pattern(en, he)
		return
	catalog[en] = he
	lower[en.strip_edges().to_lower()] = he


static func _add_pattern(en: String, he: String) -> void:
	if _pattern_en.has(en):   # the same pattern again: among the UI catalogs the later file wins (ui_zzz_fix3 loads last); a data text never overrides a UI pattern
		if _ui_loading:
			(_pattern_en[en] as Dictionary)["he"] = he
		return
	var rx := "^"
	var names := []
	var pos := 0
	var lit := 0
	var prefix := ""
	for m in _ph_re.search_all(en):
		var chunk := en.substr(pos, m.get_start() - pos)
		if names.is_empty():
			prefix = chunk
		rx += _escape(chunk)
		lit += chunk.length()
		var nm := m.get_string(1)
		names.append(nm)
		rx += "(>?[-+−]?\\d[\\d,.]*(?:[-–]\\d[\\d,.]*)?(?:%|k|M|bn)?)" if nm.begins_with("#") else "(.+?)"
		pos = m.get_end()
	var tail := en.substr(pos)
	rx += _escape(tail) + "$"
	lit += tail.length()
	var re := RegEx.create_from_string("(?is)" + rx)
	if re == null or not re.is_valid():
		push_warning("L10n: bad pattern key " + en)
		return
	var p := {"re": re, "names": names, "he": he, "lit": lit, "en": en}
	patterns.append(p)
	_pattern_en[en] = p
	var pk := prefix.strip_edges(true, false).to_lower().substr(0, 2)
	if pk.length() < 2:
		wild.append(p)
	else:
		if not buckets.has(pk):
			buckets[pk] = []
		buckets[pk].append(p)


static func _escape(s: String) -> String:
	var out := ""
	for ch in s:
		if ch in ["\\", ".", "^", "$", "|", "?", "*", "+", "(", ")", "[", "]", "{", "}"]:
			out += "\\" + ch
		else:
			out += ch
	return out


static func _index_patterns() -> void:
	var by_lit := func(a, b): return int(a["lit"]) > int(b["lit"])
	wild.sort_custom(by_lit)
	for k in buckets:
		(buckets[k] as Array).sort_custom(by_lit)
	stats["patterns"] = patterns.size()


# ================================================================== lookups

static func t(s: String) -> String:
	## Translates a finished English string (no-op in English).
	if lang == "en" or s == "":
		return s
	return translate(s)


static func plain(s: String) -> String:
	## t() without the invisible direction marks: for text that is stored (a default save name), not only shown.
	return t(s).replace(char(0x200F), "").replace(char(0x2066), "").replace(char(0x2069), "")


static func data(source: String, record: String, field: String, english: String) -> String:
	## Data text by source file, record and field (game/data/i18n/<lang>/<source>.json); English if missing.
	if lang == "en":
		return english
	return str(data_rec.get("%s/%s/%s" % [source, record, field], t(english)))


static func memorial_paragraphs(d: Dictionary) -> Array:
	## The 7 October memorial: the user's own words. Never machine-translated; a translation is used only when the
	## user has put one in ending_oct7.json (paragraphs_he / closing_he).
	if lang != "en" and d.get("paragraphs_" + lang) is Array and not (d["paragraphs_" + lang] as Array).is_empty():
		return d["paragraphs_" + lang]
	return d.get("paragraphs", [])


static func translate(s: String) -> String:
	if not ready or lang == "en":
		return s
	var r: Array = _tr(s, 0)
	if not (r[1] as Array).is_empty():
		misses[s] = int(misses.get(s, 0)) + 1   # the whole text, as the screen shows it (fragments: audit())
		for m in r[1]:
			miss_parts[m] = int(miss_parts.get(m, 0)) + 1
	if rtl:
		return _bidi_lines(r[0])
	return r[0]


static var _he_re: RegEx
static var _signed_re: RegEx
static var _maqaf_re: RegEx


static func _bidi_lines(t: String) -> String:
	## Right-to-left pages hold two kinds of lines: Hebrew lines start with a right-to-left mark (U+200F, invisible) so
	## a paragraph that opens with a tag, a number or a name still reads right to left; lines still in English (data
	## text waiting for its translator, names) are isolated left to right (U+2066 ... U+2069), so their punctuation
	## stays at their end inside a right-to-left page.
	if _he_re == null:
		_he_re = RegEx.create_from_string("[" + char(0x0590) + "-" + char(0x05FF) + "]")
	var rlm := char(0x200F)
	var lri := char(0x2066)
	# v4final (her M1): a prefix hyphen between a Hebrew letter and a number ("כ-5", "מ-14", "ב-1949") becomes the
	# Hebrew maqaf (U+05BE, in both Hebrew fonts). An ASCII hyphen there read as the number's sign ("מ14-", "about
	# −5"); the maqaf is a right-to-left mark, so it stays with its prefix. Real signs ("−2", "+3") are not touched.
	if t.contains("-"):
		if _maqaf_re == null:
			_maqaf_re = RegEx.create_from_string("([" + char(0x05D0) + "-" + char(0x05EA) + "])-(?=[+−]?\\d)")   # also "ו-+1%" (the sign then keeps its isolate)
		t = _maqaf_re.sub(t, "$1" + char(0x05BE), true)
	var lines := t.split(char(10))
	for i in lines.size():
		var ln := lines[i]
		if ln.begins_with(rlm) or ln.begins_with(lri):
			continue
		if _he_re.search(ln) != null:
			# fix4-ui (her minor 3): a signed number in a Hebrew line keeps its sign in front ("+69", not "69+"): each
			# one is a left-to-right isolate (not after a digit or letter, so "1947-1949" and ids stay as they are)
			if _signed_re == null:
				_signed_re = RegEx.create_from_string("(?<![\\w" + char(0x2066) + "+\\-−])([+\\-−]\\d[\\d,.]*%?)")
			if _signed_re.search(ln) != null:
				ln = _signed_re.sub(ln, char(0x2066) + "$1" + char(0x2069), true)
			lines[i] = rlm + ln
		elif has_latin(ln):
			lines[i] = lri + ln + char(0x2069)
	return char(10).join(lines)


static func audit(s: String) -> Array:
	## The parts of s that stay in English for lack of a UI translation (data text waiting for its translator, names
	## and allowed Latin tokens are not listed).
	if lang == "en" or s.strip_edges() == "":
		return []
	var r: Array = _tr(s, 0)
	if not (r[1] as Array).is_empty():
		misses[s] = int(misses.get(s, 0)) + 1
		for m in r[1]:
			miss_parts[m] = int(miss_parts.get(m, 0)) + 1
	return r[1]


static func has_latin(s: String) -> bool:
	return _latin_re != null and _latin_re.search(s) != null


static func _tr(s: String, depth: int) -> Array:
	if s == "" or not has_latin(s):
		return [s, []]
	if memo.has(s):
		return memo[s]
	var res := _tr_uncached(s, depth)
	if depth >= 5 and not (res[1] as Array).is_empty():
		return res   # cut short by the recursion limit: do not remember it as untranslatable
	if memo.size() > MEMO_MAX:
		memo.clear()
	memo[s] = res
	return res


static func _tr_uncached(s: String, depth: int) -> Array:
	if catalog.has(s):
		return [catalog[s], []]
	var lo := s.strip_edges().to_lower()
	if lower.has(lo):
		return [_keep_edges(s, lower[lo]), []]
	if verbatim.has(lo):
		return [s, []]
	if data_en.has(lo) or (not pending_res.is_empty() and _pending_match(s.strip_edges())):
		# data text whose translation is not in yet: shown whole in English (never cut into pieces)
		pending[s.strip_edges()] = int(pending.get(s.strip_edges(), 0)) + 1
		return [s, []]
	if depth > 6:
		return [s, _miss(s)]
	# several lines: line by line (a line may be a key of its own, tags included)
	if s.contains("\n"):
		var out2: PackedStringArray = []
		var ms2: Array = []
		for line in s.split("\n"):
			var rl: Array = _tr(line, depth + 1)
			out2.append(rl[0])
			ms2.append_array(rl[1])
		return ["\n".join(out2), ms2]
	# BBCode: colours written for the colourblind palette are looked up as the standard ones
	if s.contains("[color=#") and UITheme.colourblind and (s.contains(UITheme.CB_GOOD) or s.contains(UITheme.CB_BAD)):
		var ns := s.replace(UITheme.CB_GOOD, UITheme.STD_GOOD).replace(UITheme.CB_BAD, UITheme.STD_BAD)
		var rn: Array = _tr(ns, depth + 1)
		return [_pal_he(UITheme.pal(rn[0])), rn[1]]
	# BBCode: a pattern for the whole tagged line first ("[b]{0}[/b] joins the coalition"), then run by run
	if s.contains("[") and s.contains("]"):
		var rw := _lookup_core(s, depth, 4, true)
		if rw.size() > 0:
			return rw
	if s.contains("[") and s.contains("]"):
		var tags := _tag_re.search_all(s)
		if not tags.is_empty():
			var out := ""
			var ms: Array = []
			var pos := 0
			for m in tags:
				var run := s.substr(pos, m.get_start() - pos)
				var rr: Array = _tr(run, depth + 1)
				out += rr[0]
				ms.append_array(rr[1])
				out += m.get_string()
				pos = m.get_end()
			var rr2: Array = _tr(s.substr(pos), depth + 1)
			out += rr2[0]
			ms.append_array(rr2[1])
			return [out, ms]
	# the rest: several strategies; the first whose parts all translate wins, else the one with the fewest misses
	var best: Array = []
	# leading / trailing whitespace, bullets and punctuation
	var em := _edge_re.search(s)
	if em != null and (em.get_string(1) != "" or em.get_string(3) != "") and em.get_string(2) != "":
		# fix4-ui: the text without its bullet and trailing whitespace (a stray CR too) but with its own full stop, for
		# keys that end in one ("- The treasury stood below zero in {#0} quarters (...), and ... in {#1}.")
		var lead := em.get_string(1)
		var rest := s.substr(lead.length()).strip_edges(false, true)
		if rest != "" and rest != s and rest != em.get_string(2) and _ph_re != null:
			var hit0 := _exact(rest)
			if hit0 == "":
				var r0 := _lookup_core(rest, depth, 0, true)
				if r0.size() > 0 and (r0[1] as Array).is_empty():
					hit0 = str(r0[0])
			if hit0 != "":
				return [lead + hit0 + s.substr(lead.length() + rest.length()), []]
		var core := em.get_string(2)
		# a translated data text behind a bullet or a colon ("• <event title>": the history sidebar) is translated;
		# only an untranslated one stays whole in English
		var hit := "" if verbatim.has(core.to_lower()) else _exact(core)
		if hit != "":
			return [em.get_string(1) + hit + _mirror_punct(em.get_string(3)), []]
		if data_en.has(core.to_lower()) or verbatim.has(core.to_lower()):
			if not verbatim.has(core.to_lower()):
				pending[core] = int(pending.get(core, 0)) + 1
			return [s, []]
		var rc := _lookup_core(core, depth)
		if rc.size() > 0:
			rc = [em.get_string(1) + rc[0] + _mirror_punct(em.get_string(3)), rc[1]]
			if (rc[1] as Array).is_empty():
				return rc
			best = rc
	var rp := _lookup_core(s, depth)
	if rp.size() > 0:
		if (rp[1] as Array).is_empty():
			return rp
		best = _better(best, rp)
	# several sentences: the longest run of whole sentences that is a key (data text plus a sentence the code adds)
	if s.contains(". "):
		var rs := _sentences(s, depth)
		if rs.size() > 0:
			if (rs[1] as Array).is_empty():
				return rs
			best = _better(best, rs)
	# lists: the longest runs of items that are keys (a key may itself contain the separator)
	for lsep in ["; ", ", "]:
		if s.contains(lsep):
			var rl2 := _runs(s, lsep, depth)
			if rl2.size() > 0:
				if (rl2[1] as Array).is_empty():
					return rl2
				best = _better(best, rl2)
	# compound text: "A — B", "A · B", "A: B", "A (B)"
	for sep in [" — ", "  ·  ", " · ", " | ", " – ", " - ", "    ", "   ", "  ", ": "]:
		var i := s.find(sep)
		if i > 0 and i < s.length() - sep.length():
			var ra: Array = _tr(s.substr(0, i), depth + 1)
			var rb: Array = _tr(s.substr(i + sep.length()), depth + 1)
			var ms3: Array = []
			ms3.append_array(ra[1]); ms3.append_array(rb[1])
			var r3 := [ra[0] + sep + rb[0], ms3]
			if ms3.is_empty():
				return r3
			best = _better(best, r3)
			break
	var po := s.rfind(" (")
	if po > 0 and s.ends_with(")"):
		var a2: Array = _tr(s.substr(0, po), depth + 1)
		var b2: Array = _tr(s.substr(po + 2, s.length() - po - 3), depth + 1)
		var ms4: Array = []
		ms4.append_array(a2[1]); ms4.append_array(b2[1])
		var r4 := [a2[0] + " (" + b2[0] + ")", ms4]
		if ms4.is_empty():
			return r4
		best = _better(best, r4)
	if not best.is_empty():
		return best
	return [s, _miss(s)]


static func _better(a: Array, b: Array) -> Array:
	## The result with fewer untranslated characters.
	if a.is_empty():
		return b
	return a if _miss_len(a[1]) <= _miss_len(b[1]) else b


static func _miss_len(ms: Array) -> int:
	var n := 0
	for m in ms:
		n += str(m).length()
	return n


static func _sentences(s: String, depth: int) -> Array:
	## Splits at ". " and translates the longest leading run of sentences found as a key, then the rest the same way.
	var parts := s.split(". ")
	if parts.size() < 2:
		return []
	var out: PackedStringArray = []
	var ms: Array = []
	var i := 0
	while i < parts.size():
		var found := false
		for j in range(parts.size(), i, -1):
			var chunk := ". ".join(parts.slice(i, j))
			var full := chunk if j == parts.size() else chunk + "."
			var hit := _exact_or_pattern(full, depth)
			if hit == "" and j < parts.size():
				hit = _exact_or_pattern(chunk, depth)
				if hit != "" and not hit.ends_with(".") and not hit.ends_with("?") and not hit.ends_with("!"):
					hit += "."
			if hit != "":
				out.append(hit)
				i = j
				found = true
				break
		if not found:
			var piece := parts[i] + ("." if i < parts.size() - 1 else "")
			var r: Array = _tr(piece, depth + 1)
			out.append(r[0])
			ms.append_array(r[1])
			i += 1
	return [" ".join(out), ms]


static func _runs(s: String, sep: String, depth: int) -> Array:
	## Like _sentences for a list: longest leading run of items found as a key, else one item translated on its own.
	var parts := s.split(sep)
	if parts.size() < 2:
		return []
	var out: PackedStringArray = []
	var ms: Array = []
	var i := 0
	while i < parts.size():
		var found := false
		for j in range(parts.size(), i, -1):
			if i == 0 and j == parts.size():
				continue   # the whole text was looked up already
			var hit := _exact_or_pattern(sep.join(parts.slice(i, j)), depth)
			if hit != "":
				out.append(hit)
				i = j
				found = true
				break
		if not found:
			var r: Array = _tr(parts[i], depth + 1)
			out.append(r[0])
			ms.append_array(r[1])
			i += 1
	return [sep.join(out), ms]


static func _exact_or_pattern(s: String, depth: int) -> String:
	## A whole-key translation of s (exact, or a pattern whose parts all translate), or "".
	var e := _exact(s)
	if e != "":
		return e
	if data_en.has(s.strip_edges().to_lower()) or verbatim.has(s.strip_edges().to_lower()) or (not pending_res.is_empty() and _pending_match(s.strip_edges())):
		return s
	var r := _lookup_core(s, depth + 1, 3, true)
	return str(r[0]) if r.size() > 0 else ""


static func _exact(s: String) -> String:
	if catalog.has(s):
		return catalog[s]
	return str(lower.get(s.strip_edges().to_lower(), ""))


static func _mirror_punct(p: String) -> String:
	return p


static func _pal_he(s: String) -> String:
	## The colourblind palette renames the colours in the text: green -> blue, red -> orange (Hebrew words too).
	return s.replace("[color=%s]ירוק" % UITheme.CB_GOOD, "[color=%s]כחול" % UITheme.CB_GOOD).replace("[color=%s]אדום" % UITheme.CB_BAD, "[color=%s]כתום" % UITheme.CB_BAD)


static func _keep_edges(src: String, tr: String) -> String:
	## Keeps the leading / trailing whitespace of src around a translation found for its trimmed text.
	var a := src.length() - src.strip_edges(true, false).length()
	var b := src.length() - src.strip_edges(false, true).length()
	return src.substr(0, a) + tr.strip_edges() + src.substr(src.length() - b) if (a > 0 or b > 0) else tr


static func _lookup_core(s: String, depth: int, min_lit := 0, strict := false) -> Array:
	## Exact, case-insensitive, then pattern lookup for one run of text. [] when nothing matched. Of several
	## matching patterns the first whose parts all translate wins (most literal text first); strict: only such a one.
	if catalog.has(s):
		return [catalog[s], []]
	var lo := s.to_lower()
	if lower.has(lo):
		return [lower[lo], []]
	var best: Array = []
	var tries := 0
	var cands: Array = buckets.get(lo.substr(0, 2), [])
	for list in [cands, wild]:
		for p in list:
			if int(p["lit"]) < min_lit:
				continue
			var m: RegExMatch = (p["re"] as RegEx).search(s)
			if m == null:
				continue
			var out := str(p["he"])
			var ms: Array = []
			var names: Array = p["names"]
			for i in names.size():
				var cap := m.get_string(i + 1)
				var val := cap
				if not str(names[i]).begins_with("#"):
					var rr: Array = _tr(cap, depth + 1)
					val = rr[0]
					ms.append_array(rr[1])
				out = out.replace("{" + str(names[i]) + "}", val)
			if ms.is_empty():
				return [out, ms]
			if best.is_empty() or ms.size() < (best[1] as Array).size():
				best = [out, ms]
			tries += 1
			if tries >= 6:
				break
	if strict:
		return []
	return best


static func _miss(s: String) -> Array:
	## [s] if s is UI text with no translation; [] for data text waiting for its translator and allowed Latin.
	var t0 := s.strip_edges()
	if t0 == "" or not has_latin(t0):
		return []
	if data_en.has(t0.to_lower()):
		pending[t0] = int(pending.get(t0, 0)) + 1
		return []
	var rest := _allow_re.sub(t0, "", true)
	if not has_latin(rest):
		return []
	return [t0]


static func data_pending(s: String) -> bool:
	return data_en.has(s.strip_edges().to_lower())


# ================================================================== text helpers for the UI

static func dir_align(a: HorizontalAlignment) -> HorizontalAlignment:
	## For custom-drawn text that should follow the reading direction (draw_string does not mirror).
	if not rtl:
		return a
	match a:
		HORIZONTAL_ALIGNMENT_LEFT: return HORIZONTAL_ALIGNMENT_RIGHT
		HORIZONTAL_ALIGNMENT_RIGHT: return HORIZONTAL_ALIGNMENT_LEFT
	return a


static func lang_name(code: String) -> String:
	return str(LANG_NAMES.get(code, code))


static func dump_misses(path: String, parts := false) -> void:
	## Writes this run's untranslated UI text (most frequent first) for the translators' to-do list; parts: the
	## untranslated pieces only.
	var src: Dictionary = miss_parts if parts else misses
	var keys := src.keys()
	keys.sort_custom(func(a, b): return int(src[a]) > int(src[b]))
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return
	var d := {}
	for k in keys:
		d[k] = ""
	f.store_string(JSON.stringify(d, "\t"))
