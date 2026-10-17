"""Replicate asset generation (see ../image_gen.md and ../3d_gen.md).

  python tools/gen.py image "<prompt>" out.png [--ref a.png --ref b.png] [--aspect 16:9] [--quality high] [--transparent]
  python tools/gen.py model in.png out.glb [--faces 40000] [--pbr]
  python tools/gen.py video "<prompt>" out.mp4 [--image first.png] [--last last.png] [--ref-image a.png ...]
                       [--ref-video v.mp4 ...] [--ref-audio a.mp3 ...] [--seconds 5] [--resolution 720p] [--aspect 21:9]
                       [--no-audio] [--seed N]          (bytedance/seedance-2.5, see ../video_gen.md)

Needs REPLICATE_API_TOKEN in the environment.
"""
import argparse, json, mimetypes, os, sys, time, urllib.error, urllib.request

API = "https://api.replicate.com/v1"
TOKEN = os.environ.get("REPLICATE_API_TOKEN", "")
TRELLIS = "firtoz/trellis:e8f6c45206993f297372f5436b90350817bd9b4a0d52d2a76df50c1c8afa2b3c"


def _req(method, url, data=None, headers=None):
    h = {"Authorization": f"Bearer {TOKEN}", "User-Agent": "Mozilla/5.0 civ-gen"}
    h.update(headers or {})
    r = urllib.request.Request(url, data=data, method=method, headers=h)
    try:
        with urllib.request.urlopen(r, timeout=600) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        sys.exit(f"HTTP {e.code} {url}: {e.read().decode(errors='replace')}")


def upload(path):
    boundary = "----civgen" + str(time.time_ns())
    mime = mimetypes.guess_type(path)[0] or "application/octet-stream"
    with open(path, "rb") as f:
        payload = f.read()
    body = (f"--{boundary}\r\nContent-Disposition: form-data; name=\"content\"; filename=\"{os.path.basename(path)}\"\r\n"
            f"Content-Type: {mime}\r\n\r\n").encode() + payload + f"\r\n--{boundary}--\r\n".encode()
    res = _req("POST", f"{API}/files", body, {"Content-Type": f"multipart/form-data; boundary={boundary}"})
    return res["urls"]["get"]


def predict(model, inp, attempts=4, fatal=True):
    err = None
    for i in range(attempts):
        out, err = _predict_once(model, inp)
        if err is None:
            return out
        print(f"attempt {i + 1} failed: {err}", file=sys.stderr)
        time.sleep(20 * (i + 1))
    if fatal:
        sys.exit(f"prediction failed after {attempts} attempts: {err}")
    return None


def _predict_once(model, inp):
    if ":" in model:  # owner/name:version for community models
        url, body = f"{API}/predictions", {"version": model.split(":", 1)[1], "input": inp}
    else:
        url, body = f"{API}/models/{model}/predictions", {"input": inp}
    p = _req("POST", url, json.dumps(body).encode(), {"Content-Type": "application/json", "Prefer": "wait=60"})
    while p["status"] not in ("succeeded", "failed", "canceled"):
        time.sleep(3)
        p = _req("GET", p["urls"]["get"])
    if p["status"] != "succeeded":
        return None, f"{p['status']}: {p.get('error')}"
    return p["output"], None


def download(url, out):
    os.makedirs(os.path.dirname(os.path.abspath(out)), exist_ok=True)
    r = urllib.request.Request(url, headers={"Authorization": f"Bearer {TOKEN}"})
    with urllib.request.urlopen(r, timeout=600) as resp, open(out, "wb") as f:
        f.write(resp.read())
    print("saved", out)


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    im = sub.add_parser("image")
    im.add_argument("prompt"); im.add_argument("out")
    im.add_argument("--ref", action="append", default=[])
    im.add_argument("--aspect", default="auto")
    im.add_argument("--quality", default="high")
    im.add_argument("--transparent", action="store_true")
    md = sub.add_parser("model")
    md.add_argument("image"); md.add_argument("out")
    md.add_argument("--faces", type=int, default=40000)  # API minimum is 40000
    md.add_argument("--pbr", action="store_true")
    au = sub.add_parser("audio")  # elevenlabs/music (see audio_gen.md): music, stingers, ambience
    au.add_argument("prompt"); au.add_argument("out")
    au.add_argument("--seconds", type=float, default=30.0)
    au.add_argument("--vocals", action="store_true")  # default instrumental
    au.add_argument("--format", default="mp3_high_quality")
    vd = sub.add_parser("video")  # bytedance/seedance-2.5 (see video_gen.md)
    vd.add_argument("prompt"); vd.add_argument("out")
    vd.add_argument("--image"); vd.add_argument("--last")
    vd.add_argument("--ref-image", action="append", default=[])
    vd.add_argument("--ref-video", action="append", default=[])
    vd.add_argument("--ref-audio", action="append", default=[])
    vd.add_argument("--seconds", type=int, default=5)
    vd.add_argument("--resolution", default="720p")
    vd.add_argument("--aspect", default="16:9")
    vd.add_argument("--no-audio", action="store_true")
    vd.add_argument("--seed", type=int)
    a = ap.parse_args()
    if not TOKEN:
        sys.exit("REPLICATE_API_TOKEN not set")

    if a.cmd == "image":
        fmt = os.path.splitext(a.out)[1].lstrip(".").lower() or "png"
        inp = {"prompt": a.prompt, "aspect_ratio": a.aspect, "quality": a.quality,
               "output_format": "jpeg" if fmt == "jpg" else fmt, "number_of_images": 1}
        if a.transparent:
            inp["background"] = "transparent"
        if a.ref:
            inp["input_images"] = [upload(r) for r in a.ref]
        out = predict("openai/gpt-image-2.5-flare", inp)
        download(out[0] if isinstance(out, list) else out, a.out)
    elif a.cmd == "video":
        inp = {"prompt": a.prompt, "duration": a.seconds, "resolution": a.resolution,
               "aspect_ratio": a.aspect, "generate_audio": not a.no_audio, "output_format": "mp4"}
        if a.seed is not None:
            inp["seed"] = a.seed
        if a.image:
            inp["image"] = upload(a.image)
            if a.last:
                inp["last_frame_image"] = upload(a.last)
                inp["aspect_ratio"] = "adaptive"
        if a.ref_image:
            inp["reference_images"] = [upload(r) for r in a.ref_image]
        if a.ref_video:
            inp["reference_videos"] = [upload(r) for r in a.ref_video]
        if a.ref_audio:
            inp["reference_audios"] = [upload(r) for r in a.ref_audio]
        out = predict("bytedance/seedance-2.5", inp, attempts=3)
        download(out if isinstance(out, str) else out[0], a.out)
    elif a.cmd == "audio":
        inp = {"prompt": a.prompt, "music_length_ms": int(a.seconds * 1000),
               "force_instrumental": not a.vocals, "output_format": a.format}
        out = predict("elevenlabs/music", inp)
        download(out if isinstance(out, str) else out[0], a.out)
    else:
        img = upload(a.image)
        inp = {"image": img, "face_count": a.faces, "enable_pbr": a.pbr, "generate_type": "Normal"}
        out = predict("tencent/hunyuan-3d-3.1", inp, attempts=2, fatal=False)
        if out is not None:
            download(out if isinstance(out, str) else out[0], a.out)
            return
        # Hunyuan 3.1 often reports "ResourceInsufficient"; fall back to TRELLIS.
        print("hunyuan-3d-3.1 unavailable, falling back to firtoz/trellis", file=sys.stderr)
        out = predict(TRELLIS, {"images": [img], "generate_model": True, "generate_color": False,
                                "texture_size": 1024, "mesh_simplify": 0.95})
        download(out["model_file"], a.out)


if __name__ == "__main__":
    main()
