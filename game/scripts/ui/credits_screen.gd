class_name CreditsScreen
extends UIWindow
## Credits (start screen and game menu): the title and its author, the fonts (OFL), the photo references the event
## illustrations were painted from (title, credit, licence and link for every manifest event with a `ref`; CC BY and
## CC BY-SA credits are required), the AI-generation note, the map data and the history sources. Scrolls; fits 1280x720.
## Names, titles of works, licences and links stay as published in every language (L10n.skip / keep_ltr).

const MANIFEST := "res://data/art_manifest.json"
const MAP_SOURCES := "res://../sources/map_sources.json"

const FONTS := [
	["Cinzel", "The Cinzel Project Authors (Natanael Gama)", "https://github.com/NDISCOVER/Cinzel", "titles"],
	["Crimson Pro", "The Crimson Pro Project Authors (Jacques Le Bailly)", "https://github.com/Fonthausen/CrimsonPro", "body text"],
	["Frank Ruhl Libre", "The Frank Ruhl Libre Project Authors (Yanek Iontef)", "https://github.com/fontef/frankruhllibre", "Hebrew text"],
	["Noto Sans Hebrew", "The Noto Project Authors", "https://github.com/notofonts/hebrew", "Hebrew fallback"],
]
const MAP_DATA := [
	["Natural Earth", "public domain", "https://www.naturalearthdata.com"],
	["© OpenStreetMap contributors", "ODbL 1.0", "https://www.openstreetmap.org/copyright"],
	["Terrain Tiles (Mapzen, AWS Open Data): SRTM, ETOPO1 and other public elevation data", "see the provider's attribution list", "https://github.com/tilezen/joerd/blob/master/docs/attribution.md"],
	["WorldClim 2 (Fick & Hijmans, 2017)", "CC BY 4.0", "https://www.worldclim.org"],
]

var _list: VBoxContainer
var refs_shown := 0          # photo references listed (the UI test checks them against the manifest)
var refs_required := 0       # of which CC BY / CC BY-SA


func _init() -> void:
	super._init("Credits")


func open() -> void:
	refresh()
	visible = true


func refresh() -> void:
	clear_body()
	refs_shown = 0
	refs_required = 0
	_list = scroll_body(560)
	_list.add_theme_constant_override("separation", 4)
	# title and author
	var t := UITheme.title("Israel: The Birth of a Nation", 30, UIKit.GOLD_LIGHT)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_list.add_child(t)
	var by := UITheme.label("Created by Dan Shamir", 22, UIKit.TEXT, "body_bold")
	by.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_list.add_child(by)
	var tag := UITheme.label("A strategy game in the style of Civilization VI: lead the State of Israel from 14 May 1948 to 7 October 2023.", 16, UIKit.TEXT_DIM)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_list.add_child(tag)
	# AI tools
	_section("Art, models and music")
	_para("Illustrations, models and music generated with AI tools.")
	_para("The event illustrations are paintings made from the reference photographs listed below. An illustration made from a photograph under a Creative Commons licence credits its author and licence here and is shared under the same licence (CC BY-SA: ShareAlike).")
	# fonts
	_section("Fonts")
	_para("All fonts are used under the SIL Open Font License, Version 1.1 (OFL). The licence texts are in assets/fonts/.")
	for f in FONTS:
		_credit_line("%s  ·  %s  ·  OFL 1.1" % [f[0], f[1]], f[2], str(f[3]))
	# photo references
	_section("Event illustrations: reference photographs")
	_para("Title of the photograph, author or source, licence and link, as published.")
	for r in photo_refs():
		var lic := str(r.get("license", ""))
		var line := "%s  ·  %s  ·  %s" % [str(r.get("title", "")), str(r.get("credit", "")), lic]
		_credit_line(line, str(r.get("url", "")), str(r.get("caption", "")))
		refs_shown += 1
		if lic.begins_with("CC BY"):
			refs_required += 1
	# map and history sources
	_section("Map data")
	for m in MAP_DATA:
		_credit_line("%s  ·  %s" % [m[0], m[1]], m[2], "")
	_section("History sources")
	_para("Every event, date, place and number in the game cites a published source that was opened and quoted. Each event shows its source ids; the Civilopedia lists them, and the full list with links and verbatim quotes is in sources/SOURCES.md (history), sources/MAP_SOURCES.md (borders and places) and sources/SIM_SOURCES.md (gameplay). Where sources disagree, the game says so and cites both.")
	_section("Engine")
	_credit_line("Godot Engine  ·  © 2014-present Godot Engine contributors, © 2007-2014 Juan Linietsky, Ariel Manzur  ·  MIT License", "https://godotengine.org/license", "")
	var sp := Control.new()
	sp.custom_minimum_size = Vector2(0, 8)
	_list.add_child(sp)
	var foot := HBoxContainer.new()
	foot.alignment = BoxContainer.ALIGNMENT_END
	foot.add_child(UITheme.button("Close", close, 18))
	body.add_child(foot)


static func photo_refs() -> Array:
	## [{id, caption, title, credit, license, url}] for every art-manifest event (and portrait) with a reference photo.
	var out := []
	if not FileAccess.file_exists(MANIFEST):
		return out
	var d = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
	if not (d is Dictionary):
		return out
	for sect in ["events", "portraits"]:
		var s = d.get(sect, {})
		var items: Array = []
		if s is Dictionary:
			for k in (s as Dictionary).keys():
				var v = s[k]
				if v is Dictionary:
					var vv: Dictionary = (v as Dictionary).duplicate()
					vv["id"] = k
					items.append(vv)
		elif s is Array:
			items = s
		for v in items:
			var r = (v as Dictionary).get("ref", null)
			if not (r is Dictionary) or str((r as Dictionary).get("url", "")) == "":
				continue
			out.append({"id": str(v.get("id", "")), "caption": str(v.get("caption", v.get("name", ""))),
				"title": str(r.get("title", "")), "credit": str(r.get("credit", "")),
				"license": str(r.get("license", "")), "url": str(r.get("url", ""))})
	return out


func _section(text: String) -> void:
	var sp := Control.new()
	sp.custom_minimum_size = Vector2(0, 6)
	_list.add_child(sp)
	_list.add_child(UITheme.section(text))


func _para(text: String) -> void:
	var l := UITheme.label(text, 16, UIKit.TEXT)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(900, 0)
	_list.add_child(l)


func _credit_line(text: String, url: String, what: String) -> void:
	## One credit: names, titles, licences and links exactly as published (not translated, left to right); `what`
	## (the event or the use of a font) is translated.
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	if what != "":
		var w := UITheme.label(what, 16, UIKit.GOLD_LIGHT, "body_bold")
		w.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		w.custom_minimum_size = Vector2(900, 0)
		v.add_child(w)
	var l := L10n.raw_label(UITheme.label("", 16, UIKit.TEXT), text)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(900, 0)
	v.add_child(l)
	if url != "":
		var u := L10n.raw_label(UITheme.label("", 16, Color(0.62, 0.74, 0.95)), url)
		u.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
		u.custom_minimum_size = Vector2(900, 0)
		u.text_direction = Control.TEXT_DIRECTION_LTR
		v.add_child(u)
	_list.add_child(v)
