"""Add art_manifest.json events["fork_*"] entries (load-modify-save): a linked event's picture or a new fork painting."""
import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from forks import F
P = "C:/civ/game/data/art_manifest.json"
LINK = {
"fork_1959_wadi_salib":"1959_wadi_salib","fork_1949_capital":"1950_jerusalem_capital","fork_1949_austerity":"1949_austerity",
"fork_1949_refugee_return":"1949_lausanne_conference","fork_1960_eichmann_venue":"1960_eichmann_capture","fork_1962_eichmann_sentence":"1961_eichmann_trial",
"fork_1965_german_relations":"1965_west_germany_relations","fork_1956_sevres_collusion":"1956_sinai_campaign","fork_1949_first_coalition":"1949_first_knesset_election",
"fork_1967_waiting_period":"1967_tiran_crisis","fork_1967_allon_territories":"1967_allon_plan","fork_1969_rogers_plan":"1969_war_of_attrition",
"fork_1971_black_panthers":"1971_black_panthers","fork_1973_no_preemption":"1973_yom_kippur_war","fork_1974_agranat":"1973_agranat_commission",
"fork_1975_sebastia":"1975_sebastia","fork_1976_entebbe":"1976_entebbe","fork_1978_sinai_settlements":"1978_camp_david","fork_1980_osirak":"1981_osirak",
"fork_1982_lebanon_scope":"1982_lebanon_war","fork_1985_stabilization":"1985_stabilization_plan","fork_1975_sinai_ii":"1975_sinai_ii",
"fork_1977_sadat_visit":"1977_sadat_visit","fork_1981_golan_law":"1981_golan_heights_law","fork_1984_unity_government":"1984_election_rotation",
"fork_1983_bank_shares":"1983_bank_shares_crisis","fork_1985_lebanon_withdrawal":"1985_security_zone","fork_1979_treaty_ratification":"1979_egypt_peace_treaty",
"fork_1988_intifada_response":"1987_first_intifada","fork_1991_gulf_restraint":"1991_gulf_war_scuds","fork_1991_madrid":"1991_madrid_conference",
"fork_1993_oslo_channel":"1993_oslo_i","fork_2000_lebanon":"2000_lebanon_withdrawal","fork_2000_camp_david":"2000_camp_david","fork_2003_road_map":"2003_road_map",
"fork_2004_disengagement":"2005_gaza_disengagement","fork_1997_hebron_protocol":"1997_hebron_protocol","fork_1995_oslo_ii":"1995_oslo_ii",
"fork_1996_early_election":"1996_election","fork_2011_social_budget":"2011_social_protests","fork_2015_congress_speech":"2015_netanyahu_congress_speech",
"fork_2018_nation_state_law":"2018_nation_state_law","fork_2020_annexation":"2020_annexation_suspended","fork_2022_lebanon_maritime":"2022_lebanon_maritime_deal",
"fork_2023_judicial_overhaul":"2023_judicial_overhaul_crisis","fork_2020_covid":"2020_covid_first_case","fork_2010_flotilla_inquiry":"2010_mavi_marmara",
"fork_2010_carmel_fire_review":"2010_carmel_fire","fork_1952_reparations_talks":"1952_reparations_debate","fork_1955_kasztner_appeal":"1955_kasztner_verdict",
"fork_1957_gaza_and_sharm":"1957_sinai_withdrawal","fork_1969_eshkol_successor":"1969_meir_pm","fork_1974_canal_disengagement":"1974_sinai_disengagement",
"fork_1984_ethiopian_rescue":"1984_operation_moses","fork_1991_ethiopian_homes":"1991_operation_solomon","fork_2007_annapolis_terms":"2007_annapolis",
"fork_2010_freeze_extension":"2009_settlement_freeze","fork_2022_bennett_lapid_collapse":"2021_bennett_lapid_government",
"fork_1960_lavon_inquiry":"1954_lavon_affair","fork_1964_lavon_new_inquiry":"1954_lavon_affair","fork_1955_defence_minister":"1954_lavon_affair",
"fork_1955_hula":"1951_hula_drainage","fork_1959_water_carrier":"1964_national_water_carrier","fork_1960_dimona":"1957_dimona_reactor",
"fork_1951_iraqi_airlift_pace":"1951_ezra_nehemiah","fork_1955_north_african_aliyah":"1951_mass_immigration","fork_1950_camp_schooling":"1950_maabarot",
"fork_1948_dissident_militias":"1948_bernadotte","fork_1948_palmach_dissolution":"1948_idf_founded","fork_1982_golan_druze_strike":"1981_golan_heights_law",
"fork_1983_lebanon_accord":"1982_lebanon_war","fork_1990_housing_crisis":"1989_fsu_aliyah","fork_1990_immigrant_engineers":"1989_fsu_aliyah",
"fork_1978_soviet_dropouts":"1969_soviet_aliyah","fork_1972_diploma_tax":"1969_soviet_aliyah","fork_1950_constitution":"1949_first_knesset_election",
"fork_1952_broad_coalition":"1951_election","fork_1965_rafi_split":"1963_eshkol_pm","fork_1977_ehrlich_liberalisation":"1977_election_mahapakh",
"fork_1977_rabin_account":"1974_rabin_pm","fork_1970_us_initiative_gahal":"1970_attrition_ceasefire","fork_1979_autonomy_guidelines":"1978_camp_david",
"fork_1989_shamir_elections":"1990_unity_government_falls","fork_1992_yozma":"1998_mirabilis_icq","fork_2005_philadelphi":"2005_gaza_disengagement",
"fork_2004_referendum":"2005_gaza_disengagement","fork_2007_iron_dome":"2011_iron_dome","fork_2010_gas_royalties":"2010_leviathan_gas",
"fork_2013_gas_export_cap":"2009_tamar_gas","fork_2015_gas_outline":"2010_leviathan_gas","fork_2015_iran_deal_lobbying":"2015_jcpoa",
"fork_2011_un_statehood_bid":"2012_unga_67_19","fork_2008_olmert_offer":"2007_annapolis","fork_2013_kerry_prisoners":"2011_shalit_exchange",
"fork_2016_turkey_reconciliation":"2010_mavi_marmara","fork_2021_green_pass_reopening":"2020_vaccination_campaign","fork_2021_raam_coalition":"2021_bennett_lapid_government",
"fork_2014_zero_vat":"2011_social_protests","fork_2011_cottage_cheese_boycott":"2011_social_protests","fork_1963_german_scientists":"1965_west_germany_relations",
"fork_1957_bonn_arms_crisis":"1965_west_germany_relations","fork_1957_suez_test":"1956_sinai_campaign","fork_1980_jerusalem_basic_law":"1967_jerusalem_unification",
"fork_1995_jerusalem_land":"1967_jerusalem_unification","fork_1961_narrow_or_wider_coalition":"1951_election",
}
m = json.load(open(P, encoding="utf-8"))
ev = m["events"]
n_link = n_new = 0
for fid, e in LINK.items():
    src = ev["evt_" + e]
    ev[fid] = {k: src[k] for k in ("file", "file_small", "caption") if k in src}
    ev[fid]["alias_of"] = "evt_" + e
    n_link += 1
for (fid, cap, d) in F:
    f = f"C:/civ/game/assets/images/events/{fid}.png"
    if not os.path.exists(f) or not os.path.exists(f.replace(".png", "_768.png")):
        print("missing", fid); continue
    ev[fid] = {"file": "res://assets/images/events/%s.png" % fid, "file_small": "res://assets/images/events/%s_768.png" % fid, "caption": cap, "painted_for": "fork"}
    n_new += 1
json.dump(m, open(P, "w", encoding="utf-8"), indent=1, ensure_ascii=False)
print("linked", n_link, "new", n_new)
