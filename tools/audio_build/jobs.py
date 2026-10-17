# name -> (category, prompt, seconds, loop, use)
J = {}


def add(n, c, p, s, loop, use):
    J[n] = (c, p, s, loop, use)


S = " Instrumental, no vocals, dignified and neutral, seamless ambient start and end, no abrupt ending."
era = {
    1: ("Independence and mass immigration, 1948-1956",
        ["1950s Israeli pioneer folk feel, accordion, fiddle and warm strings, hopeful and earnest, steady walking tempo 92 bpm, Mediterranean modal melody, dusty and sunlit",
         "Early statehood, solo clarinet and nylon-string guitar over soft strings and hand drum, tentative hope, hora-like lilt at 100 bpm, 1950s Eastern Mediterranean colour"]),
    2: ("State-building, 1957-1966",
        ["Optimistic 1960s Israeli kibbutz and building-the-country mood, mandolin, acoustic guitar, accordion, light strings and clarinet, confident mid-tempo 108 bpm, warm and constructive",
         "Mid-century Israeli modernist orchestral piece, pizzicato strings, flute, vibraphone and gentle brass, industrious and forward-looking, 96 bpm, desert-and-city colour"]),
    3: ("After the Six-Day War, 1967-1976",
        ["Reflective 1970s Israeli orchestral mood, oud and cello with sustained strings, solemn, weighty and uncertain, slow 70 bpm, minor Mediterranean modes, cinematic restraint",
         "Late 1960s and 1970s Israeli sound, electric piano, soft acoustic guitar, strings and flute, wistful and tense undercurrent, 84 bpm, patient and contemplative"]),
    4: ("Political change and stabilization, 1977-1987",
        ["1980s Israeli pop-orchestral instrumental, warm synth pads, fretless bass, piano, strings and soft saxophone, hopeful and measured, 90 bpm, Mediterranean melodic colour",
         "Late 1970s and 1980s peace-era mood, acoustic guitar, oud, soft synthesizer and string ensemble, calm optimism with a thoughtful edge, 80 bpm"]),
    5: ("Immigration from the former USSR and the Oslo process, 1988-1997",
        ["1990s hopeful orchestral piece blending Russian-tinged violin and accordion with Middle Eastern percussion and oud, bittersweet and expectant, 88 bpm, new arrivals and new beginnings",
         "1990s cautious optimism, piano, strings, ney flute and light electronic textures, emotional and reflective, 76 bpm, peace-process atmosphere"]),
    6: ("High-tech growth and the Second Intifada, 1998-2007",
        ["Early 2000s Israeli electronic-orchestral hybrid, pulsing synth arpeggios, strings, subtle darbuka, driven but anxious, 104 bpm, startup energy shadowed by tension",
         "Serious 2000s mood, low cello, piano, glassy electronic textures and muted percussion, restrained and tense, 78 bpm, dignified and sombre"]),
    7: ("Gas, desalination and cyber, 2008-2016",
        ["Modern Tel Aviv electronic-orchestral hybrid, deep warm synth bass, sleek strings, light percussion, oud accents, confident and technological, 100 bpm, sea-and-industry atmosphere",
         "Contemporary cinematic piece with gentle electronic beats, piano, strings and kanun, clean and optimistic about water and energy, 92 bpm, Mediterranean sunrise"]),
    8: ("The late 2010s and 2020s",
        ["Contemporary Israeli cinematic orchestral and electronic, expansive strings, piano, subtle oud and darbuka, thoughtful and weighty, 86 bpm, modern Mediterranean city mood",
         "Spacious modern ambient-orchestral piece, soft pads, solo cello, piano and distant percussion, reflective and uncertain yet resolute, 72 bpm"]),
}
for i, (t, ps) in era.items():
    for k, p in enumerate(ps):
        add(f"era{i}_{'ab'[k]}", "music", p + S, 100, True, f"Era {i}: {t}, track {'AB'[k]}")
add("war_a", "music", "Tense serious war-time underscore, low strings ostinato, deep frame drum, dark brass swells, sparse piano, anxious and grave, not triumphal, 100 bpm, Middle Eastern minor modes" + S, 60, True, "War situation theme A")
add("war_b", "music", "Sombre wartime underscore, cello and bass drones, muted percussion, distant horn, ticking pulse, apprehensive and heavy, no heroics, 84 bpm" + S, 60, True, "War situation theme B")
add("peace", "music", "Calm hopeful peace theme, warm strings, piano, oud and flute, gentle open harmony, serene Mediterranean dawn, 68 bpm" + S, 60, True, "Peace/treaty situation theme")
add("endgame", "music", "Reflective closing theme, slow piano and full strings swelling gradually, solo oud, sense of looking back across decades, dignified and bittersweet, 64 bpm" + S, 60, True, "End-game situation theme")
st = {
    "war_begins": ("Short dramatic orchestral stinger: ominous low brass hit and timpani, tense, no melody resolution", 5),
    "ceasefire": ("Short orchestral stinger: tension releasing, soft sustained strings resolving, single gentle horn note, relieved and sober", 5),
    "peace_treaty": ("Short hopeful stinger: warm strings, piano and oud rising to a calm major resolution, dignified", 6),
    "election": ("Short civic stinger: brisk ceremonial strings and snare roll, then a clean confident chord, formal and neutral", 5),
    "fork_decided": ("Short decisive stinger: single deep drum hit, a pizzicato phrase and a firm cadence chord", 5),
    "research_complete": ("Short bright stinger: shimmering glockenspiel and soft synth arpeggio rising, curious and satisfying", 5),
    "era_change": ("Short grand stinger: sweeping strings crescendo, harp glissando and timpani roll, a new chapter begins", 8),
    "game_end_good": ("Short warm stinger: full strings and piano resolving to a gently glowing major chord, humble not boastful", 8),
    "game_end_mixed": ("Short bittersweet stinger: strings and solo cello resolving to an ambiguous suspended chord, reflective", 8),
}
for n, (p, s) in st.items():
    add(n, "stingers", p + ", instrumental, clean ending with natural decay", s, False, "Stinger: " + n)
amb = {
    "coast": "Soundscape: Mediterranean coast, gentle waves washing on sand, distant gulls, soft sea breeze, extremely minimal faint ambient pad, no melody, no drums",
    "city": "Soundscape: busy Israeli city street ambience, distant traffic, muffled crowd murmur, occasional scooter far away (no intelligible speech), faint warm pad, no melody, no drums",
    "desert": "Soundscape: Negev desert wind, steady dry breeze over sand and rock, occasional distant bird, sparse low drone, no melody, no drums",
    "jerusalem": "Soundscape: Jerusalem old stone city at evening, soft wind through narrow alleys, distant city hum, swallows, a faint low warm pad, no melody, no drums, no chanting",
}
for n, p in amb.items():
    add(n, "ambience", p + ", loopable and steady, no vocals", 45, True, "Ambient loop: " + n)
