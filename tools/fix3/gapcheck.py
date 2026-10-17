import json,re,sys
sys.stdout.reconfigure(encoding='utf-8')
D='C:/civ/game/data/'
A=json.load(open(D+'actors.json',encoding='utf-8'))['actors']
M=json.load(open(D+'art_manifest.json',encoding='utf-8'))['portraits']
ev={e['id']:e['date'] for e in json.load(open(D+'events.json',encoding='utf-8'))}
ART={"usa":"us","west_germany":"germany","ussr":"ussr","palestinian_authority":"pa","eec_eu":"eu","uk":"uk"}
ALIAS={"usa":["us"],"ussr":["russia"],"west_germany":["germany"],"eec_eu":["eu"],"uk":["britain"],"palestinian_authority":["pa"]}
PRE={"uae":["uae"]}
def start(a):
    if 'exists_from' in a: return int(a['exists_from'][:4])
    if 'exists_from_event' in a: return int(ev[a['exists_from_event']][:4])
    return 1948
gaps={}
for a in A:
    al=[a['id']]+ALIAS.get(a['id'],[])
    cov=[(v.get('era_from',-9999),v.get('era_to',9999)) for v in M.values() if v.get('actor') in al]
    ys=[y for y in range(max(1948,start(a)),2024) if not any(f<=y<=t for f,t in cov)]
    if cov and ys or '-v' in sys.argv:
        # compress
        r=[];
        for y in ys:
            if r and r[-1][1]==y-1: r[-1][1]=y
            else: r.append([y,y])
        gaps[a['id']]=r;
for k,v in gaps.items(): print(k,'has_portraits' if any(x.get('actor') in [k]+ALIAS.get(k,[]) for x in M.values()) else 'NONE',v)
tot=sum(len(r) for k,v in gaps.items() for r in v)
print('gap ranges',tot)
