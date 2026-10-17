import sys, os
from PIL import Image, ImageDraw
# usage: sheet.py out.png cols cell_w cell_h dir suffix ids...
out, cols, cw, ch, d, suffix = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4]), sys.argv[5], sys.argv[6]
ids = sys.argv[7:]
rows = (len(ids) + cols - 1) // cols
sheet = Image.new("RGB", (cols * cw, rows * (ch + 16)), (20, 20, 30))
dr = ImageDraw.Draw(sheet)
for n, i in enumerate(ids):
    p = os.path.join(d, i + suffix + ".png")
    x, y = (n % cols) * cw, (n // cols) * (ch + 16)
    if os.path.exists(p):
        im = Image.open(p).convert("RGB").resize((cw, ch))
        sheet.paste(im, (x, y + 16))
    dr.text((x + 2, y + 2), i[:cw // 6], fill=(255, 230, 140))
sheet.save(out)
