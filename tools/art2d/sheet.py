import sys,glob,os
from PIL import Image,ImageDraw
kind,out=sys.argv[1],sys.argv[2]
if kind=="p": files=sorted(glob.glob("C:/civ/game/assets/images/portraits/*_256.png")); tw,th,cols=200,200,9
else: files=sorted(glob.glob("C:/civ/game/assets/images/events/*_768.png")); tw,th,cols=320,180,5
rows=(len(files)+cols-1)//cols
S=Image.new("RGB",(cols*tw,rows*(th+14)),"black");d=ImageDraw.Draw(S)
for i,f in enumerate(files):
    im=Image.open(f).resize((tw,th));x,y=(i%cols)*tw,(i//cols)*(th+14);S.paste(im,(x,y+14))
    d.text((x+2,y+1),os.path.basename(f)[:-4].replace("_256","").replace("_768","")[:38],fill="white")
S.save(out);print(len(files),S.size)
