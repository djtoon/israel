# -*- coding: utf-8 -*-
"""Lead's final overrides, applied after the verifier-fix patches (writes patches/r2_vfix_zz_lead.json)."""

# NOTE (lead decision, after round 3): evt_1983_neve_dekalim deliberately keeps its "1983" id although its date
# is 1980 (CBS settlement year; set by patches/r2_vfix_1967b.json). Event ids are permanent and the sim
# references this one, so the id/date mismatch is intentional - do not "fix" it by renaming the id.

import json, os
H = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(H, "patches", "r2_vfix_zz_lead.json")
NQ, NR = "not quantified", "none reported"
UN_NAKBA = "https://www.un.org/unispal/about-the-nakba/"
JVL_MYTH = "https://www.jewishvirtuallibrary.org/myths-and-facts-the-refugees"
UNCCP = "https://documents.un.org/doc/undoc/gen/nl5/107/33/pdf/nl510733.pdf"
RW_UNRWA = "https://reliefweb.int/organization/unrwa"
JVL_TOT = "https://www.jewishvirtuallibrary.org/total-casualties-arab-israeli-conflict"
NOBEL66 = "https://www.nobelprize.org/prizes/literature/1966/summary/"
BOI = "https://boi.org.il/en/bank-of-israel/about-the-bank-of-israel/"

def c(claim, url, quote, page=""):
    d = {"claim": claim, "url": url, "quote": quote}
    if page: d["page"] = page
    return d

PATCHES = [
 {"id": "evt_1948_palestinian_displacement",
  "set": {"summary": "Between late 1947 and 1949 most Palestinian Arabs in the territory that became Israel fled or were expelled; the UN describes the result as the permanent displacement of more than half of the Palestinian population. Contemporary estimates of the number of refugees include 472,000 (UN Mediator, 1948), about 711,000 from Israel-controlled territory (statistical expert of the UN Conciliation Commission, 1950) and about 750,000 Palestine refugees whom UNRWA served when it began operations in 1950. Israel made any repatriation conditional on a formal peace settlement, and the refugees and their descendants became UNRWA's caseload.",
          "effects": {"intl_standing": -4, "displacement": [{"group": "palestinian_arabs", "low": 472000, "high": 750000, "from": ["galilee", "negev", "haifa", "tel_aviv", "lod", "ramla", "safed", "tiberias", "acre", "beersheba"], "note": "UN Mediator 472,000 (1948); UNCCP 711,000 (1950); UNRWA about 750,000 served in 1950"}]},
          "affected_populations": [{"group": "palestinian_arabs", "displaced": [472000, 750000], "note": "UN Mediator 472,000; UNCCP 711,000; UNRWA about 750,000 (1950)."},
                                   {"group": "israelis", "displaced": NQ, "note": "Displacement of Jewish communities in 1948 is not covered by the sources cited for this event."}]},
  "add_cite": [c("UN: permanent displacement of more than half of the Palestinian population", UN_NAKBA, "The result of the war was the permanent displacement of more than half of the Palestinian population."),
               c("UN Mediator's estimate: 472,000 refugees", JVL_MYTH, "472,000, and calculated that only about 360,000 Arab refugees required aid."),
               c("UNCCP statistical expert: about 711,000 refugees from Israel-controlled territory (A/1367/Rev.1, para. 15)", UNCCP, "territory amount to approximately 711,000", "General Assembly Official Records, 5th session, Suppl. 18 (A/1367/Rev.1), para. 15 (PDF p. 30)")]},
 {"id": "evt_1948_arab_invasion",
  "set": {"summary": "The day after the declaration, forces of Egypt, Transjordan, Syria, Iraq and Lebanon entered the former Mandate territory; Transjordan's Arab Legion operated mainly in areas allotted to the Arab state and in the Jerusalem zone. For the whole 1948-49 war, the Jewish Virtual Library's casualty table gives 6,373 Israelis killed and an estimated 10,000 Arabs killed, a combined estimate for Palestinians and the Arab armies.",
          "effects": {"morale": -3, "gold": -50, "diplo": {"egypt": "war", "jordan": "war", "syria": "war", "iraq": "war", "lebanon": "war"},
                      "casualties": {"israel": {"killed": [6373, 6373]}, "arabs_and_palestinians": {"killed": [10000, 10000]}}},
          "affected_populations": [{"group": "israelis", "killed": [6373, 6373]},
                                   {"group": "palestinians_and_arab_armies", "killed": [10000, 10000], "note": "JVL estimate combining Palestinians and the invading armies; all Arab figures are estimates."}]},
  "add_cite": [c("JVL table: 1948 war, Israel 6,373 killed, about 10,000 Arabs killed", JVL_TOT, "War of Independence 1948 6,373")]},
 {"id": "evt_1966_agnon_nobel",
  "set": {"summary": "S. Y. Agnon shared the 1966 Nobel Prize in Literature with the poet Nelly Sachs, cited 'for his profoundly characteristic narrative art with motifs from the life of the Jewish people'."},
  "add_cite": [c("1966 prize divided equally between Agnon and Nelly Sachs", NOBEL66, "The Nobel Prize in Literature 1966 was divided equally between Shmuel Yosef Agnon")]},
 {"id": "evt_1954_bank_of_israel",
  "add_cite": [c("Bank of Israel Law passed 24 Aug 1954, effective 1 Dec 1954", BOI, "The Bank of Israel Law, 5714-1954 was passed by the Knesset on August 24th, 1954, and became effective on December 1 of the same year.")]},
]
json.dump({"patches": PATCHES}, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("wrote", OUT)

# ---- resolve the 1948-66 verifier 'needs_source' items by editing the vfix texts ----
import copy
V = json.load(open(os.path.join(H, "patches", "r2_vfix_1948.json"), encoding="utf-8"))
vid = {p["id"]: p for p in V["patches"]}
def from_v(eid):
    return copy.deepcopy(vid[eid]["set"])
extra = []
s = from_v("evt_1948_lydda_ramle")
s["summary"] = s["summary"].replace("Morris gives 50,000-60,000 people, the Institute for Palestine Studies about 70,000 including neighbouring villages", "the Institute for Palestine Studies puts the number at about 70,000 including neighbouring villages")
for a in s.get("affected_populations", []):
    if a["group"] == "palestinian_arabs":
        a["displaced"] = [70000, 70000]; a["note"] = "Palestinian sources: more than 400 killed inside Lydda, close to 1,000 including deaths on the march; IPS about 70,000 expelled."
if "effects" in s:
    for d in s["effects"].get("displacement", []):
        d["low"] = 70000; d["high"] = 70000; d["note"] = "Institute for Palestine Studies, about 70,000 incl. neighbouring villages"
extra.append({"id": "evt_1948_lydda_ramle", "set": {k: s[k] for k in ("summary", "affected_populations") if k in s} | ({"effects": s["effects"]} if "effects" in s else {})})
s = from_v("evt_1948_operation_hiram")
s["summary"] = s["summary"].replace("Morris documents killings of civilians and prisoners at Safsaf, Jish and other villages; the", "The")
for a in s.get("affected_populations", []):
    if a["group"] == "palestinian_arabs": a["note"] = "Some 25,000 additional refugees forced out of Galilee (UN Mediator's representative, FRUS 3 Nov 1948)."
extra.append({"id": "evt_1948_operation_hiram", "set": {"summary": s["summary"], "affected_populations": s["affected_populations"]}})
s = from_v("evt_1950_maabarot")
s["summary"] = s["summary"].replace(" By the end of 1951 roughly 220,000-250,000 people lived in about 125 of them.", "")
extra.append({"id": "evt_1950_maabarot", "set": {"summary": s["summary"]}})
s = from_v("evt_1964_national_water_carrier")
s["summary"] = s["summary"].replace("The National Water Carrier, built by Mekorot, began pumping", "In 1964 the National Water Carrier, built by Mekorot, began pumping")
extra.append({"id": "evt_1964_national_water_carrier", "set": {"summary": s["summary"], "date": "1964-01-01", "date_precision": "year"}})
extra.append({"id": "evt_1965_west_germany_relations", "set": {"date": "1965-05-01", "date_precision": "month"}})
s = from_v("evt_1966_samu")
s["summary"] = s["summary"].replace(" One Israeli soldier was killed.", " Israel did not give its casualty figures to the UN observers.")
for a in s.get("affected_populations", []):
    if a["group"].startswith("israeli"):
        a.pop("killed", None); a["killed"] = "not quantified"; a["note"] = "Israel declined to produce its casualties as witnesses to UN observers (S/7593)."
ef = s.get("effects")
if ef and "casualties" in ef: ef["casualties"].pop("israel", None)
extra.append({"id": "evt_1966_samu", "set": {k: s[k] for k in ("summary", "affected_populations", "effects") if k in s}})
extra.append({"id": "evt_1948_yemenite_mizrahi_balkan_children_affair", "set": {"date": "1948-05-14", "date_precision": "year"}})
extra.append({"id": "evt_1975_maale_adumim", "set": {"date": "1975-12-01", "date_precision": "month"}})

E_NOW = {e["id"]: e for e in json.load(open(r"C:\civ\game\data\events.json", encoding="utf-8"))}
mi = E_NOW["evt_1951_mass_immigration"]["summary"]
mi = mi.replace("over 300,000 of whom had arrived by the end of 1951 as communities", "with an Israel State Archives table counting 377,251 immigrants from Muslim countries between May 1948 and the end of 1952, as communities")
extra.append({"id": "evt_1951_mass_immigration", "set": {"summary": mi}, "remove_claims": ["Over 260,000 Jews from Arab and Muslim countries had arrived by 1951"],
              "add_cite": [c("Israel State Archives table: 377,251 immigrants from Muslim countries, May 1948-end 1952", "https://www.jewishvirtuallibrary.org/immigrants-to-israel-1948-1952", "Total Muslim countries 377,251")]})
qb = E_NOW["evt_1953_qibya"]["summary"].replace("blowing up some 45-50 houses", "blowing up some 41-50 houses (UN observers counted 41 dwellings and a school)")
extra.append({"id": "evt_1953_qibya", "set": {"summary": qb}})
PATCHES += extra
json.dump({"patches": PATCHES}, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("wrote with extras", len(PATCHES))
