"""montage.py out.png cell_px cols img1 img2 ...  (labels = file stem; transparent shown on checker)"""
import sys, os
from PIL import Image, ImageDraw
out, cell, cols = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
files = sys.argv[4:]
rows = (len(files) + cols - 1) // cols
M = Image.new("RGB", (cols * cell, rows * (cell + 16)), (40, 40, 40))
d = ImageDraw.Draw(M)
for i, f in enumerate(files):
    im = Image.open(f).convert("RGBA")
    im.thumbnail((cell, cell))
    bg = Image.new("RGBA", im.size, (200, 200, 200, 255))
    ck = ImageDraw.Draw(bg)
    for y in range(0, im.size[1], 8):
        for x in range(0, im.size[0], 8):
            if (x // 8 + y // 8) % 2: ck.rectangle([x, y, x + 7, y + 7], fill=(150, 150, 150, 255))
    bg.alpha_composite(im)
    x, y = (i % cols) * cell, (i // cols) * (cell + 16)
    M.paste(bg.convert("RGB"), (x, y))
    d.text((x + 3, y + cell + 2), os.path.splitext(os.path.basename(f))[0][:cell // 6], fill=(255, 255, 255))
M.save(out)
