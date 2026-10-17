"""Commons search: python cs.py "query" [n]  -> lists files with license/credit (images only, >=800px)."""
import sys, json, urllib.request, urllib.parse, re
UA = {"User-Agent": "Mozilla/5.0 (civ-art-ref/1.0; research)"}
def api(**p):
    p["format"] = "json"
    u = "https://commons.wikimedia.org/w/api.php?" + urllib.parse.urlencode(p)
    return json.loads(urllib.request.urlopen(urllib.request.Request(u, headers=UA), timeout=60).read())
def strip(s): return re.sub(r"<[^>]+>", "", s or "").strip()
def search(q, n=10):
    r = api(action="query", generator="search", gsrsearch=q, gsrnamespace=6, gsrlimit=n, prop="imageinfo",
            iiprop="url|size|mime|extmetadata", iiurlwidth=1600)
    out = []
    for pg in sorted(r.get("query", {}).get("pages", {}).values(), key=lambda x: x.get("index", 0)):
        ii = (pg.get("imageinfo") or [{}])[0]
        if not ii.get("mime", "").startswith("image/jpeg") and not ii.get("mime", "").startswith("image/png"): continue
        m = ii.get("extmetadata", {})
        out.append(dict(title=pg["title"], page=ii.get("descriptionurl"), thumb=ii.get("thumburl"), orig=ii.get("url"),
            w=ii.get("width"), h=ii.get("height"), license=strip(m.get("LicenseShortName", {}).get("value")),
            credit=strip(m.get("Artist", {}).get("value"))[:120], desc=strip(m.get("ImageDescription", {}).get("value"))[:160]))
    return out
if __name__ == "__main__":
    for o in search(sys.argv[1], int(sys.argv[2]) if len(sys.argv) > 2 else 10):
        print(f"{o['title']} | {o['w']}x{o['h']} | {o['license']} | {o['credit']} | {o['desc']}\n   {o['page']}")
