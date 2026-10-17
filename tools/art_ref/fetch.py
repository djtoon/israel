"""python fetch.py "File:Name.jpg" event_id  -> downloads ~1600px version to progress/event_refs/<id>.jpg, prints manifest 'ref' JSON, saves progress/event_refs/<id>.ref.json"""
import sys, json, urllib.request
sys.path.insert(0, __file__.rsplit("/",1)[0].rsplit("\\",1)[0])
import cs
t, eid = sys.argv[1], sys.argv[2]
if not t.startswith("File:"): t = "File:" + t
r = cs.api(action="query", titles=t, prop="imageinfo", iiprop="url|size|mime|extmetadata", iiurlwidth=1600)
pg = list(r["query"]["pages"].values())[0]; ii = pg["imageinfo"][0]; m = ii["extmetadata"]
url = ii.get("thumburl") or ii["url"]
ext = "png" if ii["mime"] == "image/png" else "jpg"
out = f"C:/civ/progress/event_refs/{eid}.{ext}"
d = urllib.request.urlopen(urllib.request.Request(url, headers=cs.UA), timeout=120).read()
open(out, "wb").write(d)
ref = {"url": ii["descriptionurl"], "image_url": ii["url"].split("?")[0], "license": cs.strip(m.get("LicenseShortName", {}).get("value")),
       "credit": cs.strip(m.get("Artist", {}).get("value"))[:200] or cs.strip(m.get("Credit", {}).get("value"))[:200], "title": pg["title"][5:]}
json.dump(ref, open(f"C:/civ/progress/event_refs/{eid}.ref.json", "w"), indent=1)
print(out, json.dumps(ref))
