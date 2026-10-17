import sys, os
from PIL import Image, ImageDraw, ImageFont
out=sys.argv[1]; files=sys.argv[2:]
W=384; cols=6
ims=[]
for f in files:
    im=Image.open(f).convert("RGB"); r=W/im.width; im=im.resize((W,int(im.height*r)))
    ims.append((os.path.basename(f),im))
H=max(i.height for _,i in ims)+20
rows=(len(ims)+cols-1)//cols
sheet=Image.new("RGB",(W*cols,H*rows),(10,14,30))
d=ImageDraw.Draw(sheet)
for k,(n,im) in enumerate(ims):
    x=(k%cols)*W; y=(k//cols)*H
    sheet.paste(im,(x,y+20)); d.text((x+4,y+3),n[:60],fill=(240,210,120))
sheet.save(out,quality=85)
