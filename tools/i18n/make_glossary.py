#!/usr/bin/env python3
"""game/i18n/glossary_he.json = tools/i18n/glossary_hand.json + every place name that has a name_he in the data.

    python tools/i18n/make_glossary.py
"""
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
D = os.path.join(ROOT, "game", "data")


def main():
    hand = json.load(open(os.path.join(os.path.dirname(__file__), "glossary_hand.json"), encoding="utf-8"))
    places = {}
    for c in json.load(open(os.path.join(D, "cities.json"), encoding="utf-8")):
        if c.get("name_he"):
            places[c["name"]] = c["name_he"]
    m = json.load(open(os.path.join(D, "map.json"), encoding="utf-8"))
    for p in m.get("places", []) + m.get("natural_wonders", []):
        if p.get("name_he"):
            places.setdefault(p["name"], p["name_he"])
    out = {"_about": "Standard Hebrew forms for translators (game/i18n/I18N.md). 'places' comes from the name_he fields "
                     "of cities.json and map.json: fix a place there, then run tools/i18n/make_glossary.py.",
           "_style": hand.pop("_style")}
    out.update(hand)
    out["places"] = dict(sorted(places.items()))
    with open(os.path.join(ROOT, "game", "i18n", "glossary_he.json"), "w", encoding="utf-8", newline="\n") as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
        f.write("\n")
    print({k: len(v) for k, v in out.items() if isinstance(v, dict)})


if __name__ == "__main__":
    main()
