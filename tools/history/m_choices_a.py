# -*- coding: utf-8 -*-
# Sourced choice sets for 1948-1986 events (each option: named decision-maker/advocate + verbatim quote from an opened page).
JVL_ALT = "https://www.jewishvirtuallibrary.org/the-altalena-affair"
JVL_REP = "https://www.jewishvirtuallibrary.org/german-holocaust-reparations"
UNEF = "https://peacekeeping.un.org/mission/past/unef1backgr2.html"
JVL_67 = "https://www.jewishvirtuallibrary.org/background-and-overview-six-day-war"
HAAR_JO = "https://web.archive.org/web/20100918104416/http://www.haaretz.com/print-edition/features/the-jordanian-option-the-plan-that-refuses-to-die-1.226164"
JVL_73 = "https://www.jewishvirtuallibrary.org/background-and-overview-yom-kippur-war"
RABIN_C = "https://www.rabincenter.org.il/en/?p=8990"
DJN = "https://web.archive.org/web/2026/https://digital.bentley.umich.edu/djnews/djn.1976.04.30.001/8"
AVALON_CD = "https://avalon.law.yale.edu/20th_century/campdav.asp"
BEGIN_PLAN = "https://db.begincenter.org.il/en/article/my-plan-for-peace"
JVL_YAMIT = "http://www.jewishvirtuallibrary.org/jsource/Peace/yamit.html"
CSM_81 = "https://www.csmonitor.com/1981/1104/110447.html"
CSM_85 = "https://www.csmonitor.com/1985/0107/dbisra-f.html"
MERIP = "https://www.merip.org/1985/01/israels-national-unity"
JVL_LEB85 = "https://www.jewishvirtuallibrary.org/cabinet-communique-on-the-withdrawal-from-lebanon"
CSM_85B = "https://www.csmonitor.com/1985/0422/ojune.html"

def c(claim, url, quote): return {"claim": claim, "url": url, "quote": quote}

CH = {
 "evt_1948_altalena": [
  {"label": "Order the IDF to seize the ship and its arms by force", "historical": True,
   "effects": {"morale": -2, "unlock_civic": ["mamlachtiyut"]},
   "note": "Ben-Gurion's order; the ship was shelled off Tel Aviv on 22 June 1948.",
   "cite": [c("Ben-Gurion ordered the ship taken by force", JVL_ALT, "Ben-Gurion ordered Yigael Yadin (acting Chief of Staff) to concentrate large forces on the Tel Aviv beach and to take the ship by force.")]},
  {"label": "Accept Begin's demand that the remaining arms equip the Irgun battalions inside the IDF", "historical": False,
   "effects": {"morale": 1, "production": 20, "intl_standing": -2},
   "note": "Menachem Begin's demand in the June 1948 talks; the government rejected it as 'an army within an army'.",
   "cite": [c("Begin asked that the rest of the arms equip the Irgun battalions; the government rejected it", JVL_ALT, "His second request, however, that the remainder be transferred to the IDF to equip the newly-incorporated Irgun battalions was rejected by the Government representatives")]}],
 "evt_1952_reparations_debate": [
  {"label": "Authorise negotiations with West Germany on reparations", "historical": True,
   "effects": {"gold": 50, "morale": -2, "unlock_civic": ["reparations_diplomacy"]},
   "note": "Ben-Gurion's government won the Knesset vote in January 1952; talks opened at The Hague in March.",
   "cite": [c("After the Knesset approved the resolution, delegations met at The Hague", JVL_REP, "Following Israel’s approval of the resolution, a West German delegation headed by Professor Franz Boehm met with the Israeli delegation")]},
  {"label": "Refuse any dealings with Germany ('blood money')", "historical": False,
   "effects": {"morale": 2, "gold": -40},
   "note": "Position of Menachem Begin and Herut.",
   "cite": [c("Begin and Herut opposed the reparations as blood money", JVL_REP, "Menachem Begin and the Herut Party were among the most vocal members of the opposition, who considered the reparations offer as blood money.")]}],
 "evt_1957_sinai_withdrawal": [
  {"label": "Withdraw from Gaza and Sharm el-Sheikh as UNEF deploys", "historical": True,
   "effects": {"intl_standing": 3, "territory": {"sinai": "returned_egypt", "gaza_strip": "egyptian_administered"}},
   "note": "Withdrawal from Gaza on 6-7 March and from Sharm el-Sheikh on 8-12 March 1957.",
   "cite": [c("Israel withdrew from Gaza and Sharm el-Sheikh in March 1957", UNEF, "The withdrawal from the Gaza Strip took place on 6 and 7 March 1957 and that from the Sharm el Sheikh area from 8 to 12 March.")]},
  {"label": "Keep holding the Gaza Strip and Sharm el-Sheikh", "historical": False,
   "effects": {"intl_standing": -5, "morale": 1},
   "note": "Israel's position from late January 1957 until March, when it held on to these two areas.",
   "cite": [c("Israel held on to Gaza and Sharm el-Sheikh after 22 January 1957", UNEF, "After 22 January 1957, Israel held on to the last two areas it still occupied.")]}],
 "evt_1967_tiran_crisis": [
  {"label": "Strike first rather than keep waiting", "historical": True,
   "effects": {"morale": 2},
   "note": "Chief of Staff Rabin warned against waiting; the war began with Israeli air strikes on 5 June.",
   "cite": [c("Rabin argued Israel could not afford to wait", JVL_67, "Rabin warned that Israel could not afford to wait to act.")]},
  {"label": "Wait for an international flotilla to test the blockade", "historical": False,
   "effects": {"gold_per_turn": -3, "intl_standing": 2},
   "note": "US President Johnson's attempt to organise a maritime flotilla, which failed.",
   "cite": [c("Johnson tried to organise an international flotilla", JVL_67, "President Johnson expressed the belief that the blockade was illegal and unsuccessfully tried to organize an international flotilla to test it.")]}],
 "evt_1967_allon_plan": [
  {"label": "Pursue the 'Jordanian option': return populated West Bank areas to Jordan, keep the Jordan Valley, Etzion bloc and Jerusalem", "historical": True,
   "effects": {"intl_standing": 1},
   "note": "Allon's 1968 concept; Haaretz (Pedatzur) writes that the Eshkol, Meir and Rabin governments adopted the Jordanian option.",
   "cite": [c("Alignment governments 1967-77 adopted the Jordanian option", HAAR_JO, "The Alignment-led governments under Levi Eshkol (1967-1969), Golda Meir (1969-1974) and Yitzhak Rabin (1974-1977) adopted the Jordanian option"),
            c("Allon's map kept the Jordan Valley, Gush Etzion and Jerusalem", HAAR_JO, "proposing that the Jordan Valley remain in Israeli hands, and that the same should be true for Gush Etzion, part of the Hebron foothills and united Jerusalem.")]},
  {"label": "Set up Palestinian autonomy in the West Bank (Allon's original July 1967 plan)", "historical": False,
   "effects": {"intl_standing": 2},
   "note": "Allon's original proposal to the cabinet of 27 July 1967.",
   "cite": [c("Allon's original plan proposed Palestinian autonomy", HAAR_JO, "When he placed the original \"Allon plan\" on the cabinet's table on July 27, 1967, he had proposed that a Palestinian autonomy be set up in the West Bank.")]}],
 "evt_1973_yom_kippur_war": [
  {"label": "Call up reserves but forgo a pre-emptive strike", "historical": True,
   "effects": {"morale": -2, "intl_standing": 2},
   "note": "Prime Minister Meir approved a partial call-up and refused pre-emption on 6 October.",
   "cite": [c("A partial call-up was approved; Meir refused pre-emptive action", JVL_73, "A few hours later, a partial call-up of reserves was approved, but Meir still refused to authorize Elazar to take military action.")]},
  {"label": "Full mobilisation and a pre-emptive air strike", "historical": False,
   "effects": {"morale": 2, "intl_standing": -4},
   "note": "Chief of Staff David Elazar's recommendation on the morning of 6 October.",
   "cite": [c("Elazar recommended full mobilisation and a pre-emptive strike", JVL_73, "on October 6 that Elazar first recommended a full, immediate mobilization of forces and a preemptive air strike.")]}],
 "evt_1975_sebastia": [
  {"label": "Accept a compromise: the settlers move to the Kadum army camp", "historical": True,
   "effects": {"intl_standing": -1},
   "note": "Rabin approved it after hesitation; Defence Minister Peres arranged the compromise.",
   "cite": [c("Rabin approved the Kadum settlement after hesitation", RABIN_C, "After some hesitation, he approved the establishment of the Jewish settlement in Kadum.")]},
  {"label": "Allow free Jewish settlement in the West Bank, as Gush Emunim demanded", "historical": False,
   "effects": {"intl_standing": -3, "morale": 1},
   "note": "Gush Emunim's demand, supported by Defence Minister Shimon Peres (JTA, 1976).",
   "cite": [c("Peres supported the Gush demands for free settlement", DJN, "mon Peres, who arranged the compromise, has made no secret of his support of the Gush demands for free Jewish settlement on the West Bank.")]}],
 "evt_1978_camp_david": [
  {"label": "Agree to full withdrawal from Sinai in exchange for peace and normal relations", "historical": True,
   "effects": {"intl_standing": 4, "morale": 2, "unlock_civic": ["peace_process"]},
   "note": "Camp David framework, 17 September 1978; Begin put the Sinai settlements question to the Knesset.",
   "cite": [c("Framework: full Egyptian sovereignty and Israeli withdrawal from Sinai", AVALON_CD, "the full exercise of Egyptian sovereignty up to the internationally recognized border between Egypt and mandated Palestine; the withdrawal of Israeli armed forces from the Sinai")]},
  {"label": "Insist that the Rafah-salient settlements stay in UN zones", "historical": False,
   "effects": {"intl_standing": -2, "morale": 1},
   "note": "Begin's December 1977 peace plan, presented in Washington and at Ismailia.",
   "cite": [c("Begin proposed that Sinai settlements continue to exist in UN zones", BEGIN_PLAN, "we have suggested the creation of limited UN zones in which our settlements will continue to exist.")]}],
 "evt_1982_sinai_withdrawal": [
  {"label": "Evacuate Yamit and the Sinai settlements on schedule", "historical": True,
   "effects": {"morale": -2, "intl_standing": 2},
   "note": "Official evacuation began 23 April 1982.",
   "cite": [c("Evacuation date for Yamit set for 23 April 1982", JVL_YAMIT, "The Sinai withdrawal was phased over a number of years and the date of evacuation for Yamit was set for April 23, 1982.")]},
  {"label": "Stop the withdrawal", "historical": False,
   "effects": {"intl_standing": -6, "morale": 1, "diplo": {"egypt": "hostile"}},
   "note": "Demand of the 'movement to stop the withdrawal', backed by the Tehiya party and Gush Emunim activists.",
   "cite": [c("The movement to stop the withdrawal was backed by Tehiya and Gush Emunim", CSM_81, "the ''movement to stop the withdrawal,'' which is headquartered in Yamit and enjoys the total support of the right-wing Tehiya Party")]}],
 "evt_1982_lebanon_war": [
  {"label": "Approve a limited operation to push the PLO 40 km from the border", "historical": True,
   "effects": {"morale": 1, "intl_standing": -3},
   "note": "What the cabinet approved on 5-6 June 1982. According to Schiff and Ya'ari, Defence Minister Sharon then expanded the operation step by step toward Beirut while telling ministers the moves were dictated by the situation; ministers later said they had been misled.",
   "cite": [c("The cabinet approved a 40 km incursion", CSM_85, "The Israeli Cabinet thought it was approving an incursion 40 kilometers north of its border to push Palestine Liberation Organization (PLO) fighters beyond the point where they could shell Israel's northern settlements"),
            c("Sharon moved forces forward into Beirut while telling ministers it was dictated by events", CSM_85, "Thus he deliberately and continually moved his troops forward, provoking the reluctant Syrians into what he felt was a necessary confrontation and bringing Israeli forces into Beirut")]},
  {"label": "Openly launch a broad war to expel the PLO from Lebanon and install an allied government", "historical": False,
   "effects": {"morale": -2, "intl_standing": -8, "gold_per_turn": -8},
   "note": "The 'grander design' Schiff and Ya'ari attribute to Defence Minister Ariel Sharon; it was never put to the cabinet as such.",
   "cite": [c("Sharon pursued a grander design: oust the PLO, install a Christian ally", CSM_85, "He aimed to oust the PLO from all Lebanon, confront and humble the Syrians, install a Christian ally as undisputed head of Lebanon")]}],
 "evt_1984_election_rotation": [
  {"label": "Form a national unity government with a rotating premiership", "historical": True,
   "effects": {"morale": 1, "unlock_civic": ["emergency_government"]},
   "note": "Peres for two years, then Shamir.",
   "cite": [c("Peres and Shamir both needed the national unity arrangement", MERIP, "Second, both Peres and Shamir, as individuals, needed something like the “national unity” arrangement to preserve their own standing as leaders of their respective parties")]},
  {"label": "Form a narrow Likud-led government", "historical": False,
   "effects": {"morale": -1},
   "note": "Likud's attempt, blocked when Ezer Weizman (Yahad) refused to join it despite Ariel Sharon's pressure.",
   "cite": [c("Weizman's move blocked a narrow Likud government", MERIP, "When Weizman decided to form a political faction together with the Alignment, he was in fact blocking the Likud’s chances of forming a narrow- based government.")]}],
 "evt_1985_security_zone": [
  {"label": "Withdraw to the border but keep a security zone held by the SLA with IDF backing", "historical": True,
   "effects": {"morale": 2, "gold_per_turn": 3, "territory": {"south_lebanon": "security_zone"}},
   "note": "Cabinet decision of 14 January 1985 (phase C).",
   "cite": [c("Phase C: IDF on the border with an SLA-held zone", JVL_LEB85, "Phase C - the IDF will deploy along the Israeli-Lebanese international border while maintaining a zone in southern Lebanon where local forces (SLA) will operate with IDF backing.")]},
  {"label": "Keep a much deeper security zone inside south Lebanon", "historical": False,
   "effects": {"morale": -1, "gold_per_turn": -4},
   "note": "Argued by Likud ministers Moshe Arens and Ariel Sharon, who voted against the withdrawal.",
   "cite": [c("Arens and Sharon argued for a much deeper security zone", CSM_85B, "Arens and Sharon argued that Israel should maintain a much deeper security zone inside south Lebanon than that advocated by Mr.")]}],
}
# Events whose choice sets could not be sourced to named advocates: choices removed.
NO_CHOICES = ["evt_1956_sinai_campaign", "evt_1966_military_government_ends", "evt_1972_munich", "evt_1976_land_day",
              "evt_1976_entebbe", "evt_1981_osirak", "evt_1981_golan_heights_law", "evt_1983_bank_shares_crisis",
              "evt_1985_jibril_exchange", "evt_1985_stabilization_plan"]
