import sys,json,urllib.request,urllib.parse,re,html
UA="civ-game-art/1.0 (educational game; contact local)"
def api(p):
    p["format"]="json"
    u="https://commons.wikimedia.org/w/api.php?"+urllib.parse.urlencode(p)
    for i in range(4):
        try:
            return json.loads(urllib.request.urlopen(urllib.request.Request(u,headers={"User-Agent":UA}),timeout=60).read())
        except Exception as e:
            import time; time.sleep(3*(i+1))
    return {}
OK=re.compile(r"public domain|^pd|cc0|cc[- ]by|cc-zero|attribution",re.I)
def search(q,n=8):
    d=api({"action":"query","generator":"search","gsrsearch":q,"gsrnamespace":6,"gsrlimit":n*2,"prop":"imageinfo","iiprop":"url|extmetadata|size|mime","iiurlwidth":1280})
    out=[]
    for p in sorted(d.get("query",{}).get("pages",{}).values(),key=lambda p:p["index"]):
        ii=p["imageinfo"][0]
        if ii["mime"]!="image/jpeg" or ii["width"]<900: continue
        em=ii["extmetadata"]
        lic=em.get("LicenseShortName",{}).get("value","")
        if not OK.search(lic) or "NC" in lic or "ND" in lic: continue
        cred=re.sub(r"<[^>]+>","",em.get("Artist",{}).get("value","") or em.get("Credit",{}).get("value",""))
        out.append(dict(title=p["title"][5:],url=ii["descriptionurl"],image_url=ii["url"],thumb=ii["thumburl"],license=lic,credit=html.unescape(cred).strip()[:100],w=ii["width"],h=ii["height"]))
        if len(out)>=n: break
    return out
if __name__=="__main__":
    for q in sys.argv[1:]:
        print("##",q)
        for i,r in enumerate(search(q,6)): print(i,r["title"][:80],"|",r["license"],"|",r["w"],"x",r["h"],"|",r["credit"][:30])
