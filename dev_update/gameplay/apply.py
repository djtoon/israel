import json,sys,re
f,t=sys.argv[1],sys.argv[2]
p='C:/civ/game/data/i18n/he/'+f
d=json.load(open(p,encoding='utf-8'))
ents=[(r,k) for r,fs in d.items() if r!='_meta' for k in fs]
n=0;bad=0
for ln in open(t,encoding='utf-8').read().split('\n'):
    if '|' not in ln: continue
    i,x=ln.split('|',1)
    i=int(i); r,k=ents[i-1]; e=d[r][k]
    x=x.replace('\\"','"')
    for ph in re.findall(r'\{[^}]*\}|\[/?[a-z]+[^\]]*\]',e['en']):
        if ph not in x: print('PLACEHOLDER MISSING',i,ph); bad+=1
    e['he']=x; n+=1
json.dump(d,open(p,'w',encoding='utf-8'),ensure_ascii=False,indent=1)
print('applied',n,'bad',bad)
