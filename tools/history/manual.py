# -*- coding: utf-8 -*-
import copy
import m_choices_a, m_fix_a
NEW_SOURCES = []
PATCHES = {}
def P(eid): return PATCHES.setdefault(eid, {})
for eid, p in m_fix_a.P.items():
    q = P(eid)
    if "set" in p: q.setdefault("set", {}).update(p["set"])
    if "set_ap" in p: q.setdefault("set", {})["affected_populations"] = p["set_ap"]
    if "append_summary" in p: q["append_summary"] = p["append_summary"]
    if "cite" in p: q.setdefault("cite", []).extend(p["cite"])
    if "effects" in p: q.setdefault("effects", {}).update(p["effects"])
for eid, ch in m_choices_a.CH.items():
    P(eid).setdefault("set", {})["choices"] = copy.deepcopy(ch)
for eid in m_choices_a.NO_CHOICES:
    P(eid).setdefault("set", {})["choices"] = []
