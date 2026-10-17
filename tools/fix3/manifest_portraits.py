import json,sys,re
sys.path.insert(0,'tools/fix3')
import portraits
p='game/data/art_manifest.json'
raw=open(p,encoding='utf-8').read()
m=json.loads(raw)
for i,n,r,a,f,t,look in portraits.P:
    m['portraits'][i]={"file":f"res://assets/images/portraits/{i}.png","file_small":f"res://assets/images/portraits/{i}_256.png","name":n,"role":r,"era_from":f,"era_to":t,"actor":a}
json.dump(m,open(p,'w',encoding='utf-8'),indent=1,ensure_ascii=False)
print(len(m['portraits']))
