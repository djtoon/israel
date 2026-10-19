"""A plain local HTTP server for the web build (no special headers: the no-threads build needs none).
   python -I build/web/serve.py [port] [dir]     (default 8060, build/web/out)
/__test/<name> serves C:/civ/progress/test_saves/<name> (test saves for the browser UI tests; never in the release)."""
import http.server, os, sys, functools, threading

PORT = 8060
ROOT = "C:/civ/build/web/out"
TEST = "C:/civ/progress/test_saves"


class H(http.server.SimpleHTTPRequestHandler):
    extensions_map = dict(http.server.SimpleHTTPRequestHandler.extensions_map,
                          **{".wasm": "application/wasm", ".pck": "application/octet-stream", ".js": "text/javascript",
                             ".webp": "image/webp"})

    def translate_path(self, path):
        p = path.split("?", 1)[0]
        if p.startswith("/__test/"):
            return os.path.join(TEST, os.path.basename(p))
        return super().translate_path(path)

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, *a):
        pass


def serve(port=PORT, root=ROOT):
    srv = http.server.ThreadingHTTPServer(("127.0.0.1", port), functools.partial(H, directory=root))
    t = threading.Thread(target=srv.serve_forever, daemon=True)
    t.start()
    return srv


if __name__ == "__main__":
    if len(sys.argv) > 1:
        PORT = int(sys.argv[1])
    if len(sys.argv) > 2:
        ROOT = sys.argv[2]
    s = serve(PORT, ROOT)
    print("serving %s on http://127.0.0.1:%d/" % (ROOT, PORT), flush=True)
    threading.Event().wait()
