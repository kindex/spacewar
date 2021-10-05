program spaceracer_1_0; {  14.5.99 }
uses crt,svga,iva,graph,dos,blast;
const sop=0.9999;
      grav=0.02;  pol=10;       maxkey=9;
      pultip=6;
      maxp=450;
      maxi=30; {300}
      maxz=2;
      maxb=30;
      version='1.11 (82 blaster demo) (7.10.1999) demo';
      vers='1.11';
      maxc=5; mapx=20; mapy=13;
      maxsb=6;
const portkey:array[1..2,1..maxkey]of byte=((1,$48,$50,$4b,$4d,$e,$1d,$2b,$1c),(1,$11,$1f,$1e,$20,$10,$0f,$29,$2));
      del:array[1..10]of byte=(1,2,2,2,6,6,15,15,0,0);
   filen:array[1..9]of string[12]=('s10.bmp','s20.bmp','s30.bmp','s40.bmp','s50.bmp','s60.bmp','s70.bmp','s80.bmp','s00.bmp');
      get:array[1..9]of string[30]=('Ammo','A.for 2','A.for 3','A.for 4','Rok.','Sam.rok.','Atomka','Salut','Health');
    wrad:array[1..8]of integer=(0,100,300,100,200,400,300,300);
    svg:array[1..6]of string[9]=('320x200','640x400','640x480','800x600','1024x768','1280x1024');
    sb:array[1..maxsb]of string[12]=('glass','bang','tank','xploshor','bang','effect');
type    pixell=array[0..255]of ^ppp;
        ppixel=^pixell;
        ppp=record
                rl,l:real;
                c:byte;
             end;
        bmp=array[1..961]of byte;
        point=object
             x,y:real;
            end;
        ship=object(point)
            mes:string[30];
            atac:byte;
            nal:longint;
            lx,ly,rx,ry,lastx,lasty,lastlx:real;
            com,killed:boolean;
            sk,hit,skor,rad,mt,man,taran,armor:real;
            ehit,erad,emt,eman,etaran,earmor:real;
            roc,aroc,maxpix,win,eroc,die:byte;
            star:array[1..maxkey]of byte;
            lkey,key:array[1..maxkey]of boolean;
            sname:string;
            ammo:array[1..15]of integer;
            acm,anext:integer;
            pix:ppixel;
            epix:ppixel;
            procedure init(dx,dy:real);
            procedure move;
            procedure kill;
            procedure load(name:string; lcom:boolean; lat:byte);
            procedure draw(c:integer);
            procedure push(ltip:byte);
          end;
    bomb=object(point)
           tip,std2:integer;     { 1-пуля }  { 2 падающяя }
           procedure init(lx,ly:real;ltip:byte);
           procedure move;
           procedure draw(c:integer);
         end;
    pula=object(point)
           pp:array[1..5]of record x,y:integer; end;
           tip,who,vz:byte;
           std1:integer;
           lx,sk:real;
           procedure move;
           procedure draw(c:integer);
         end;
    iskr=object(point)
           x2,y2:array[1..17]of integer;
           sk,lx:real;
           tip,hit:byte;
           procedure init(rx,ry,lsk,lll:real);
           procedure draw(c:integer);
           procedure move;
         end;
     zv=object(point)
          tip,hit:byte;
          procedure init(lx,ly:real; ltip:byte);
          procedure draw(c:integer);
          procedure move;
         end;
     cil=object(point)
           tip,hit,rad:byte;
          procedure draw(c:integer);
          procedure move;
         end;
     map=object
           tip,hit:byte;
          procedure draw(x,y,x2,y2,c:integer);
         end;
var s:array[1..5]of ship;
    n,work,hod,maxs,fpps,levtip,colc:byte;
    hh,mm,ss,s100:word;
    las,endg,game,def,taranb,avtor:boolean;
    svgmode,level:byte;
    ii,mx,my,k,m:integer;
    fps,time,cpu,i,j:longint;
    buf:array[1..maxsb]of pointer;
    sbs:array[1..maxsb]of word;
    ll:real;
    is:array[1..maxi]of ^iskr;
    pul:array[1..maxp]of pula;
    b:array[1..maxb]of bomb;
    ff:file;
    vec:procedure;
    wea:array[1..10]of pointer;
    weapon:array[1..9]of ^bmp;
    z:array[1..maxz]of zv;
    c:array[1..maxc]of cil;
    mp:array[0..mapx,0..mapy]of map;
procedure map.draw;
begin
  if tip=1 then barr(x,my-y2+1,x2-1,my-y,c);
end;
procedure cil.move;
var i,j:integer;
    step:boolean;
begin
  if tip=0 then exit;
  if hit<=0 then tip:=0;
  if tip=1 then y:=y-1;
  if tip=2 then y:=y-5;
  if tip=3 then x:=x+random(2);
  step:=false;
  if tip<4 then
  for i:=1 to mapx do
    for j:=1 to mapy do
       if (x+rad>i*32-32)and(x-rad<(i*32))and(y+rad>j*32-32)and(y-rad<(j*32))and(y<j*32-32)and(mp[i,j].tip>0)then step:=true;
  if tip<4 then
    begin
      if step then tip:=3
      else
      if tip<>1 then tip:=2;
    end;
{  if tip<>4 then if y<=pol+5 then tip:=3;}
  if (tip=3)and(x>=mx) then tip:=0;
  if y<=0 then hit:=0;
  if y<=0 then tip:=0;
  if tip=4 then y:=y-10;
end;
procedure cil.draw;
var i:integer;
begin
  if hit=0 then exit;
  if tip=0 then exit;
  setcolor(c);
  if tip=1 then
  begin
   if c<>0then setcolor(250);
   ellipse(r(x),my-r(y+5),0,180,15,10);
   ellipse(r(x),my-r(y+5),15,180-15,5,10);
   ellipse(r(x),my-r(y+5),15,180-15,15,2);
   line(r(x),my-r(y),r(x)+15,my-r(y+5));
   line(r(x),my-r(y),r(x)-15,my-r(y+5));
   line(r(x),my-r(y),r(x)-5,my-r(y+7));
   line(r(x),my-r(y),r(x)+5,my-r(y+7));
  end;
  setcolor(c);
  line(r(x),r(my-y),r(x),my-r(y+5));
  line(r(x),r(my-y),r(x)-3,my-r(y-5));
  line(r(x),r(my-y),r(x)+3,my-r(y-5));
  line(r(x),my-r(y+5),r(x)-3,my-r(y));
  line(r(x),my-r(y+5),r(x)+3,my-r(y));
  if tip=4 then for i:=1 to 5 do putpixel(r(x+random(5)-2),my-r(y+random(5)-2),40);
end;
procedure initp(ww:byte);
var i,j:integer;
begin
 for i:=1 to maxp do if pul[i].tip=0 then break;
 pul[i].x:=random(mx);
 pul[i].y:=my-5;
 pul[i].sk:=2;
 pul[i].lx:=pi/2+pi+random(10)/40;
 pul[i].tip:=random(8)+1;
 for j:=1 to 5 do pul[i].pp[j].x:=r(pul[i].x);
 for j:=1 to 5 do pul[i].pp[j].y:=r(pul[i].y);
 pul[i].who:=ww;
end;
procedure ship.kill;
var i,j:integer;
begin
{  for i:=0 to 255 do if pix^[i]<>nil then dispose(pix^[i]);}
{  for i:=0 to 255 do if epix^[i]<>nil then dispose(epix^[i]);}
  dispose(pix);
  dispose(epix);
end;
procedure zv.init(lx,ly:real; ltip:byte);
var i,j:integer;
begin
  hit:=1; tip:=ltip; x:=lx; y:=ly;
 i:=r(x)div 32+1;j:=r(y)div 32+1;if mp[i,j].tip<>0then tip:=0;
 i:=r(x+15)div 32+1;j:=r(y)div 32+1;if mp[i,j].tip<>0then tip:=0;
 i:=r(x-15)div 32+1;j:=r(y)div 32+1;if mp[i,j].tip<>0then tip:=0;
 i:=r(x)div 32+1;j:=r(y+15)div 32+1;if mp[i,j].tip<>0then tip:=0;
 i:=r(x)div 32+1;j:=r(y-15)div 32+1;if mp[i,j].tip<>0then tip:=0;
end;
procedure zv.draw(c:integer);
var i,j:integer;
begin
 if hit=0 then exit;
 if tip=0 then exit;
 if c>0 then
 begin
   putpixel(r(x),my-r(y),245);
   putpixel(r(x-1),my-r(y+1),234);putpixel(r(x-1),my-r(y-1),234);putpixel(r(x+1),my-r(y+1),234);putpixel(r(x+1),my-r(y-1),234);
   for i:=1 to 15 do putpixel(r(x-i),my-r(y),240-i);
   for i:=1 to 15 do putpixel(r(x+i),my-r(y),240-i);
   for i:=1 to 15 do putpixel(r(x),my-r(y+i),240-i);
   for i:=1 to 15 do putpixel(r(x),my-r(y-i),240-i);
 end
 else
 begin
   putpixel(r(x),my-r(y),0);
   putpixel(r(x-1),my-r(y+1),0);putpixel(r(x-1),my-r(y-1),0);putpixel(r(x+1),my-r(y+1),000);putpixel(r(x+1),my-r(y-1),000);
   for i:=1 to 15 do putpixel(r(x-i),my-r(y),0);
   for i:=1 to 15 do putpixel(r(x+i),my-r(y),0);
   for i:=1 to 15 do putpixel(r(x),my-r(y+i),0);
   for i:=1 to 15 do putpixel(r(x),my-r(y-i),0);
 end
end;
procedure zv.move;
var i,j:integer;
begin
 if tip=0 then exit;
{ y:=y-random(5);
 x:=x-random(3)-1;}
 i:=r(x)div 32+1;j:=r(y)div 32+1;if mp[i,j].tip<>0then tip:=0;
 i:=r(x+15)div 32+1;j:=r(y)div 32+1;if mp[i,j].tip<>0then tip:=0;
 i:=r(x-15)div 32+1;j:=r(y)div 32+1;if mp[i,j].tip<>0then tip:=0;
 i:=r(x)div 32+1;j:=r(y+15)div 32+1;if mp[i,j].tip<>0then tip:=0;
 i:=r(x)div 32+1;j:=r(y-15)div 32+1;if mp[i,j].tip<>0then tip:=0;
 if y<pol then tip:=0;
end;
procedure initis(lx,ly,sk,ll:real);
var i,j:integer;
begin
  if random(2)=0 then
  begin
     for i:=1 to maxi do if is[i]^.tip=0 then break;
     is[i]^.init(lx,ly,sk,ll);
  end;
end;
procedure iskr.init;
var i:integer;
begin
  for i:=1 to 17 do x2[i]:=r(rx);
  for i:=1 to 17 do y2[i]:=r(ry);
  x:=rx; y:=ry;
  sk:=lsk;
  lx:=lll;
  tip:=1;
  hit:=1;
end;
procedure iskr.move;
var i,j:integer;
begin
  if tip=0 then exit;
  if hit>40 then tip:=0;
  inc(hit);
  if (x<0)or(x>mx)or(y<0)or(y>my)then tip:=0;
  for i:=17 downto 2 do x2[i]:=x2[i-1];
  for i:=17 downto 2 do y2[i]:=y2[i-1];
  i:=r(x)div 32+1;
  j:=r(y)div 32+1;
  if mp[i,j].tip=0 then
  begin
    x:=x+cos(lx)*sk;
    y:=y+sin(lx)*sk;
  end;
    x2[1]:=r(x);
    y2[1]:=r(y);
  if (lx<pi+pi/2)and(lx>pi/2) then begin lx:=lx+0.01; if sk>2 then sk:=sk*0.99; end;
  if (lx>pi+pi/2)or((lx<pi/2)and(lx>-pi/2)) then begin lx:=lx-0.02;if sk>1 then sk:=sk*0.99; end;
end;
procedure iskr.draw;
var i,j:integer;
begin
  if tip=0 then exit;
  if (c<>0)and(tip=1) then
   for i:=1 to 16 do
    begin
     setcolor(10+i*2+hit);
     line(x2[i],my-y2[i],x2[i+1],my-y2[i+1]);
    end
  else if tip=1 then
   begin
    setcolor(0);
      for i:=1 to 16 do
      line(x2[i],my-y2[i],x2[i+1],my-y2[i+1]);
    end
end;
procedure bomb.draw;
var i,n,m:integer;
    e,ex,ey:real;
begin
 if tip=7 then
 begin
   for i:=1 to 100 do
   begin
    e:=random(630)/100;
    ex:=r(x+cos(e)*std2);
    ey:=r(y+sin(e)*std2);
    n:=r(ex)div 32+1;
    m:=r(ey)div 32+1;
    if mp[n,m].tip=0 then  putpixel(r(ex),my-r(ey),random(30)+std2);
  end;
 end;
 if tip=5 then
 begin
   for i:=1 to 40 do
   begin
    e:=random(63)/10;
    ex:=r(x+cos(e)*std2);
    ey:=r(y+sin(e)*std2);
    n:=r(ex)div 32+1;
    m:=r(ey)div 32+1;
    if mp[n,m].tip=0 then  putpixel(r(ex),my-r(ey),random(30)+std2);
  end;
 end;
end;
procedure bomb.move;
var i,j,n:integer;
begin
 if tip=0 then exit;
 if tip=5 then if std2>10 then begin tip:=0; std2:=0; end;
 if std2>0 then
 begin
   inc(std2);
   for i:=1 to maxs do if sqrt(sqr(x-s[i].x)+sqr(y-s[i].y))-s[i].rad<std2 then s[i].hit:=s[i].hit-2/4;
 end;
 if std2>50 then begin tip:=0; std2:=0; end;
 if (tip=8)and(std2>5) then
 begin
  std2:=0;
  tip:=0;
  for i:=1 to 63 do
  begin
    for j:=1 to maxp do if pul[j].tip=0 then break;
    pul[j].tip:=2;
    pul[j].x:=x;
    pul[j].y:=y;
    pul[j].sk:=5+random(3);
    pul[j].lx:=i/10;
    for n:=1 to 5 do pul[j].pp[n].x:=r(x);
    for n:=1 to 5 do pul[j].pp[n].y:=r(y);
   end;
 end;
end;
procedure bomb.init;
begin
  x:=lx; y:=ly; tip:=ltip; std2:=1;
end;
procedure ship.push;
var i,j:integer;
    w,e,lp:real;
begin
  play(buf[(work+1)],sbs[(work+1)],11050);
  for i:=1 to maxp do if pul[i].tip=0 then break;
  pul[i].vz:=0;
  pul[i].tip:=ltip;
  pul[i].who:=work;
  pul[i].x:=x+cos(lx)*rad*1.1;
  pul[i].y:=y+sin(lx)*rad*1.1;
  pul[i].lx:=lx;
  e:=sqrt(sqr(ry-(sin(lx)*rad+y))+sqr(rx-(cos(lx)*rad+x)));
  pul[i].sk:=abs((e-rad));
  if e<rad then
  pul[i].sk:=-pul[i].sk;
  case pul[i].tip of
   1..4: if pul[i].sk<0 then pul[i].sk:=pul[i].sk+5 else pul[i].sk:=pul[i].sk+5;
   5..6: if pul[i].sk<0 then pul[i].sk:=pul[i].sk+1 else pul[i].sk:=pul[i].sk+1;
   7..8: if pul[i].sk<0 then pul[i].sk:=pul[i].sk+3 else pul[i].sk:=pul[i].sk+3;
  end;
  case pul[i].tip of
   4..8: pul[i].sk:=abs(pul[i].sk);
  end;
{  if sqrt(sqr(ry-y)+sqr(rx-x))>rad then
     if pul[i].sk<0 then pul[i].sk:=-20;}
  for j:=1 to 5 do pul[i].pp[j].x:=r(x+cos(lx)*rad);
  for j:=1 to 5 do pul[i].pp[j].y:=r(y+sin(lx)*rad);
end;
procedure pula.move;
var i,j,l,m,u:integer;
    lp:real;
begin
  if (tip=5) or (tip=6) then
     if sk<5 then sk:=sk*1.1 else sk:=sk*0.9;
  for i:=5 downto 2 do pp[i]:=pp[i-1];
  pp[1].x:=r(x);
  pp[1].y:=r(y);
  {IF sk<0 THEN  x:=x-cos(lx)*sk ELSE}IF VZ=0 THEN x:=x+cos(lx)*sk;
 { IF sk<0 THEN  y:=y-sin(lx)*sk else}IF VZ=0 THEN y:=y+sin(lx)*sk ; {if lx>pi/2+pi then lx:=lx+0.02 else lx:=lx-0.02;}
  if (tip=2) then
  begin
   if (lx<pi+pi/2)and(lx>pi/2) then begin lx:=lx+0.04; if sk>1 then sk:=sk*0.99; end;
   if (lx>pi+pi/2)or((lx<pi/2)and(lx>-pi/2)) then begin lx:=lx-0.04;if sk>1 then sk:=sk*0.99; end;
  end;
  if (tip=4) then
  begin
   if (lx<pi+pi/2)and(lx>pi/2) then begin lx:=lx+0.01; if sk>2 then sk:=sk*0.99; end;
   if (lx>pi+pi/2)or((lx<pi/2)and(lx>-pi/2)) then begin lx:=lx-0.02;if sk>1 then sk:=sk*0.99; end;
  end;
  if tip=6 then
  begin
    i:=s[who].atac;
    if (x>s[i].x)and(y>s[i].y)then lp:=pi-arctan((x-s[i].x)/(y-s[i].y))-0.5*pi+pi;
    if (x<s[i].x)and(y<s[i].y)then lp:=pi-arctan((s[i].x-x)/(s[i].y-y))+0.5*pi+pi;
    if (x>s[i].x)and(y<s[i].y)then lp:=1.5*pi+arctan((x-s[i].x)/(s[i].y-y))+pi;
    if (x<s[i].x)and(y>s[i].y)then lp:=1.5*pi+arctan((s[i].x-x)/(y-s[i].y))+pi+pi;
    while lp>pi*2 do lp:=lp-pi*2;
    while lp<0 do lp:=lp+pi*2;
    if (lp-lx<2)and(lp-lx>0) then lx:=lx+0.1;
    if (lx-lp<2)and(lx-lp>0) then lx:=lx-0.1;
  end;
  if x<0 then tip:=0;
  if x>mx then tip:=0;
  if y<0 then tip:=0;
  if y>my then tip:=0;
  for l:=1 to maxs do
  if ((tip=1)or(tip=2)or(tip=3)or(tip=4))and(sqrt(sqr(x-s[l].x)+sqr(y-s[l].y))<s[l].rad)and(s[i].hit>0) then
  begin s[l].hit:=s[l].hit-tip; tip:=0; inc(s[s[l].atac].nal); end;
  for l:=1 to maxc do
  if ((tip=1)or(tip=2)or(tip=3)or(tip=4))and(sqrt(sqr(x-c[l].x)+sqr(y-c[l].y))<c[l].rad)and(c[l].hit>0)and(c[l].tip=1) then
  begin  c[l].tip:=2; tip:=0; inc(s[who].nal,5); end;
 if tip>6 then
  if std1>50 then
   begin
    for i:=1 to maxb do if b[i].tip=0 then break;
    b[i].init(x,y,tip);
    self.tip:=0;
    self.std1:=0;
   end;
  if tip>0 then inc(std1)
  else std1:=0;
  for i:=1 to maxs do
 if (tip>6)and(sqrt(sqr(x-s[i].x)+sqr(y-s[i].y))<s[i].rad) then
 begin
  for j:=1 to maxb do
    if b[j].tip=0 then
         break;
    b[j].init(x,y,tip);
    self.tip:=0;
    self.std1:=0;
  end;
 for i:=1 to maxs do
 if (vz=0)and((tip=6)or(tip=5))and(sqrt(sqr(x-s[i].x)+sqr(y-s[i].y))<s[i].rad) then vz:=5;
 if (vz>0)and(random(1)=0) then
 begin
  vz:=vz-1;
  for j:=1 to maxb do
    if b[j].tip=0 then
         break;
    b[j].init(x+random(20)-10,y+random(20)-10,5);
    if vz=0 then self.tip:=0;
    if vz=0 then self.std1:=0;
  end;
  i:=r(x) div 32+1;
  j:=r(y) div 32+1;
   if (mp[i,j].tip>0)then
       begin
         if (tip=5)or(tip=6)then vz:=5;
         if (tip>6)then
         begin
            for i:=1 to maxb do if b[i].tip=0 then break;
            b[i].init(x,y,tip);
         end;
         tip:=0;
       end;
end;
procedure pula.draw;
var i:integer;
begin
  if tip=0 then exit;
  if c>0 then for i:=1 to 4 do
  begin
    setcolor(c-i*5);
    if (pp[i].x<0)or(pp[i].x>mx)or(pp[i].y<0)or(pp[i].y>my)then break;
    line(pp[i].x,my-pp[i].y,pp[i+1].x,my-pp[i+1].y)
  end
  else for i:=1 to 4 do
    begin
    setcolor(c);
    if (pp[i].x<0)or(pp[i].x>mx)or(pp[i].y<0)or(pp[i].y>my)then break;
    line(pp[i].x,my-pp[i].y,pp[i+1].x,my-pp[i+1].y)
  end;
  if (c<>0)and((tip=6) or(tip=5)) then
  begin
   setcolor(40+(tip-5)*20);
   line(r(x),my-r(y),r(x+cos(lx)*5),my-r(y+sin(lx)*5));
   circle(r(x),my-r(y),1);
  end
  else
  if (tip=5)or(tip=6) then
  begin
   setcolor(c);
   line(r(x),my-r(y),r(x+cos(lx)*5),my-r(y+sin(lx)*5));
   circle(r(x),my-r(y),1);
  end;
  if ((tip=1)or(tip=2)or(tip=3)or(tip=4)) then putpixel(r(x),my-r(y),c);
  if (c>0)and((tip=3)or(tip=4)) then
  begin
    putpixel(r(x),my-r(y-1),c-5);
    putpixel(r(x-1),my-r(y),c-5);
    putpixel(r(x+1),my-r(y),c-5);
    putpixel(r(x),my-r(y+1),c-5);
  end else
  if ((tip=3)or(tip=4)) then
  begin
    putpixel(r(x),my-r(y-1),c);
    putpixel(r(x-1),my-r(y),c);
    putpixel(r(x+1),my-r(y),c);
    putpixel(r(x),my-r(y+1),c);
  end;
  if tip>6 then
  begin
    if c>0 then setcolor(40) else setcolor(0);
   line(r(x),my-r(y),r(x+cos(lx)*5),my-r(y+sin(lx)*5));
   circle(r(x),my-r(y),2);
    circle(r(x),my-r(y),3);
  end;
end;
procedure ship.init;
var i,j:integer;
begin
 killed:=false;
 mes:='';
 x:=dx; y:=dy;  roc:=200{eroc}; aroc:=0; mt:=emt; man:=eman;
 rx:=dx;ry:=dy; armor:=earmor; taran:=etaran;
 lx:=pi/2;
 sk:=5; hit:=ehit;
 rad:=erad;
 for i:=0 to maxpix do pix^[i]^:=epix^[i]^;
 acm:=5; anext:=0;
 for i:=2 to 4 do ammo[i]:=50;
 for i:=5 to 6 do ammo[i]:=3;
 for i:=7 to 8 do ammo[i]:=2;
end;
var    hh2,mm2,ss2,ss200:word;
procedure endgame;
var i:integer;
begin
 for i:=1 to maxsb do freemem(buf[i],sbs[i]);
 window(1,1,80,25);
 gotoxy(1,20);
 textattr:=15;
 if game then
 begin
 for i:=1 to maxs do s[i].kill;
  closegraph;
  SetIntVec($9,@vec);
  writeln('Fps: ',fps div ((hh2-hh)*3600+(mm2-mm)*60+(ss2-ss)));
 end;
  if  ((hh2-hh)*3600+(mm2-mm)*60+(ss2-ss))>0 then writeln('Frames per second: ',fps div ((hh2-hh)*3600+(mm2-mm)*60+(ss2-ss)));
  writeln('Cpu: ',r(cpu*18.5),' +ps');
  writeln;
  writeln('The Space War, Version '+version);
  writeln('Coppyright (C) Ivanov Andrey 1999');
  writeln('Freeware !');
  halt;
end;
procedure ship.move;
var ix,iy:real;
    i,n,m:integer;
    ex,ey,sky,skx:real;
begin
  lastx:=x;lasty:=y; lastlx:=lx;
  if not killed then
  for i:=1 to maxc do
    if (sqrt(sqr(x-c[i].x)+sqr(y-c[i].y))<c[i].rad+rad)and(c[i].hit>0)and(c[i].tip>0)and(c[i].tip<4) then
      begin
        c[i].tip:=4; inc(nal,7);
      end;

   if hit<ehit/5 then hit:=hit-(ehit/5-hit)/100;
  if (not killed)and(hit<=0)then
  begin
    for i:=1 to maxb do if b[i].tip=0 then break;
    b[i].init(x,y,8);
    killed:=true;
    for i:=1 to maxs do if c[i].tip=0 then break;
    with c[i] do begin hit:=1; tip:=1; c[i].x:=self.x; c[i].y:=self.y; end;
  end;
  if anext>0 then dec(anext);
  if aroc>0 then dec(aroc);
  ix:=x; iy:=y;
  if abs(x-rx)>0.1 then x:=x+(x-rx)*sop else rx:=x;
  if abs(y-ry)>0.02 then y:=y+(y-ry)*sop else ry:=y;
  if levtip=2 then
  begin
    if x<mx/2 then x:=x+grav;
    if x>mx/2 then x:=x-grav;
    if y<my/2 then y:=y+grav;
    if y>my/2 then y:=y-grav;
  end
  else if levtip<6 then y:=y-grav
       else
       begin
         if y<0 then y:=y+grav;
         if y>my then y:=y-grav;
       end;
  if x<0 then begin  ix:=ix+mx; x:=x+mx; end;
  if x>mx then begin  ix:=ix-mx; x:=x-mx; end;
  if hit>0 then
  if y<pol+rad then
  begin
    if sqrt(sqr(y-ry)+sqr(x-rx))>1 then
    begin
{      for i:=1 to maxpix do
       if (pix^[i]^.rl*sin(pix^[i]^.l+lx)+y-pol)<10
         then
         begin
            initis(pix^[i]^.rl*cos(pix^[i]^.l+lx)+x,pix^[i]^.rl*sin(pix^[i]^.l+lx)+y,random(50)/10+3,random(63)/10);
            pix^[i]^.rl:=pix^[i]^.rl*(random(3)/10+0.5);
            hit:=hit-0.1
         end;}
     y:=pol+1+rad;
     if (x-ix)<0 then ix:=ix+((x-ix)*0.5);
     if (x-ix)>0 then ix:=ix+((x-ix)*0.5);
   end
    else y:=pol+rad;
  end;

  rx:=ix; ry:=iy;
  if ammo[acm]=0 then if (acm<8)and(anext<1) then begin inc(acm);anext:=10;key[9]:=false;end
  else begin acm:=2; anext:=10;key[9]:=false; end;
  if hit>0 then
  begin
  if key[1] then  endg:=true;
  if key[2] then  if y<my then begin x:=x+cos(lx)*mt; y:=y+sin(lx)*mt; end;
  if key[3] then  if y<my then begin x:=x-cos(lx)*mt; y:=y-sin(lx)*mt; end;
  if key[4] then  if y>pol then lx:=lx+man;
  if key[5] then  if y>pol then lx:=lx-man;
  if key[7] then if aroc=0 then begin push(1); aroc:=3; end;
  if key[8] then  if (ammo[acm]>0)and(aroc=0) then begin push(acm); dec(ammo[acm]); aroc:=del[acm]; end;
  if key[9] then   if(anext<1) then if (acm<8)then begin inc(acm);anext:=10;key[9]:=false end
  else begin acm:=2; anext:=10;key[9]:=false; end;
  if key[6] then
    if (nal>10)and(hit<ehit) then
    begin
      lx:=lx+0.0001;
      hit:=hit+1;
      dec(nal,4);
      for i:=1 to maxpix do if (epix^[i]^.rl-pix^[i]^.rl)>1 then
      begin
        pix^[i]^.rl:=pix^[i]^.rl+0.5;
        skor:=skor-4;
      end
    end
  else pix^[i]^.rl:=epix^[i]^.rl;
 end;
 for i:=1 to maxz do if z[i].tip>0 then
 if sqrt(sqr(x-z[i].x)+sqr(y-z[i].y))<rad then
 begin
   if z[i].tip>9 then z[i].tip:=9;
   mes:=get[z[i].tip];
   case z[i].tip of
    1..4: ammo[z[i].tip]:=ammo[z[i].tip]+10;
    5..6: ammo[z[i].tip]:=ammo[z[i].tip]+3;
    7..8: ammo[z[i].tip]:=ammo[z[i].tip]+2;
    9: hit:=hit+ehit*0.2;
   end;
   z[i].tip:=0;
   nal:=nal+50;
 end;
 if avtor then key[6]:=true;
 sky:=abs(y-ry)*0.5+0.1;
 skx:=abs(x-rx)*0.5+0.1;
{1} if mp[r(x)div 32+1,r(y+rad)div 32+1].tip>0 then
 begin
   barr(32*(r(x)div 32+1)-32,my-32*(r(y+rad)div 32)-32,32*(r(x)div 32+1),my-32*(r(y+rad)div 32),100);
   y:=32*(r(y+rad)div 32)-rad; ry:=y+sky;
 end else
{2}  if mp[r(x)div 32+1,r(y-rad)div 32+1].tip>0 then
 begin
   barr(32*(r(x)div 32+1)-32,my-32*(r(y-rad)div 32)-32,32*(r(x)div 32+1),my-32*(r(y-rad)div 32),100);
   y:=32*(r(y+rad)div 32)+rad; if abs(sky)<0.15 then ry:=y-skx else ry:=y;;
 end else
{3}  if mp[r(x+rad)div 32+1,r(y)div 32+1].tip>0 then
 begin
   barr(32*(r(x+rad)div 32+1)-32,my-32*(r(y)div 32)-32,32*(r(x+rad)div 32+1),my-32*(r(y)div 32),200);
   x:=32*(r(x+rad)div 32)-rad; rx:=x+skx;
 end else
{4}  if mp[r(x-rad)div 32+1,r(y)div 32+1].tip>0 then
 begin
   barr(32*(r(x-rad)div 32+1)-32,my-32*(r(y)div 32)-32,32*(r(x-rad)div 32+1),my-32*(r(y)div 32),50);
   x:=32*(r(x+rad)div 32)+rad; rx:=x-skx;
 end else if erad>16 then
{5}  if mp[r(x+rad)div 32+1,r(y-rad)div 32+1].tip>0 then
 begin
   barr(32*(r(x+rad)div 32+1)-32,my-32*(r(y-rad)div 32)-32,32*(r(x+rad)div 32+1),my-32*(r(y-rad)div 32),120);
   y:=32*(r(y+rad)div 32)+rad; ry:=y-sky;
   x:=32*(r(x+rad)div 32)-rad; rx:=x+skx;
 end else
{6}  if mp[r(x-rad)div 32+1,r(y-rad)div 32+1].tip>0 then
 begin
   barr(32*(r(x-rad)div 32+1)-32,my-32*(r(y-rad)div 32)-32,32*(r(x-rad)div 32+1),my-32*(r(y-rad)div 32),120);
   y:=32*(r(y+rad)div 32)+rad; ry:=y-sky;
   x:=32*(r(x+rad)div 32)+rad; rx:=x-skx;
 end else
{7}  if mp[r(x+rad)div 32+1,r(y+rad)div 32+1].tip>0 then
 begin
   barr(32*(r(x+rad)div 32+1)-32,my-32*(r(y-rad)div 32)-32,32*(r(x+rad)div 32+1),my-32*(r(y-rad)div 32),120);
   y:=32*(r(y+rad)div 32)-rad; ry:=y+sky;
   x:=32*(r(x+rad)div 32)-rad; rx:=x+skx;
 end else
{8}  if mp[r(x-rad)div 32+1,r(y+rad)div 32+1].tip>0 then
 begin
   barr(32*(r(x+rad)div 32+1)-32,my-32*(r(y-rad)div 32)-32,32*(r(x+rad)div 32+1),my-32*(r(y-rad)div 32),120);
   y:=32*(r(y+rad)div 32)-rad; ry:=y+sky;
   x:=32*(r(x-rad)div 32)+rad; rx:=x-skx;
 end
end;
procedure ship.draw;
var i,j:integer;
begin
 setcolor(c);
{ circle(r(x),my-r(y),10);
 line(r(x),my-r(y),r(x+cos(lx)*20),my-r(y+sin(lx)*20));}
 if (c=0) then if (lastlx=lx)and(lastx=x)and(lasty=y)then exit
 else
 begin
 for i:=1 to star[1] do
 if pix^[i+1]^.c>10 then
 begin
  setcolor(0);
  line(r(lastx)+r(cos(pix^[i]^.l+lastlx)*pix^[i]^.rl{+lx}),my-r(lasty+sin(pix^[i]^.l+lastlx)*pix^[i]^.rl),
  r(lastx+cos(pix^[i+1]^.l+lastlx)*pix^[i+1]^.rl{+lx}),my-r(lasty+sin(pix^[i+1]^.l+lastlx)*pix^[i+1]^.rl));
 end;
 for j:=2 to 5 do
 if lkey[j] then
 for i:=star[j-1] to star[j] do
 if pix^[i+1]^.c>10 then
 begin
  setcolor(0);
  line(r(lastx)+r(cos(pix^[i]^.l+lastlx)*pix^[i]^.rl{+lx}),my-r(lasty+sin(pix^[i]^.l+lastlx)*pix^[i]^.rl),
  r(lastx+cos(pix^[i+1]^.l+lastlx)*pix^[i+1]^.rl{+lx}),my-r(lasty+sin(pix^[i+1]^.l+lastlx)*pix^[i+1]^.rl));
 end;

 end;
 for i:=1 to star[1] do
 if pix^[i+1]^.c>10 then
 begin
  if c<>0 then setcolor(pix^[i+1]^.c);
  line(r(x)+r(cos(pix^[i]^.l+lx)*pix^[i]^.rl{+lx}),my-r(y+sin(pix^[i]^.l+lx)*pix^[i]^.rl),
  r(x+cos(pix^[i+1]^.l+lx)*pix^[i+1]^.rl{+lx}),my-r(y+sin(pix^[i+1]^.l+lx)*pix^[i+1]^.rl));
 end;
 for i:=r(hit) to r(ehit/3) do
 putpixel(r(x-cos(lx)*rad*0.7)+random(10)-5,my-r(y-sin(lx)*rad*0.7)+random(10)-5,random(15)+230);
 for j:=2 to 5 do
 if lkey[j] then
 for i:=star[j-1] to star[j] do
 if pix^[i+1]^.c>10 then
 begin
  if c<>0 then setcolor(pix^[i+1]^.c);
  line(r(x)+r(cos(pix^[i]^.l+lx)*pix^[i]^.rl{+lx}),my-r(y+sin(pix^[i]^.l+lx)*pix^[i]^.rl),
  r(x+cos(pix^[i+1]^.l+lx)*pix^[i+1]^.rl{+lx}),my-r(y+sin(pix^[i+1]^.l+lx)*pix^[i+1]^.rl));
 end;
 if las then line(r(x),r(my-y),r(x+cos(lx)*1000),r(my-y-sin(lx)*1000));
end;
procedure ship.load;
var rrr:array[1..9]of char;
    i,j,k,n:byte;
begin
  com:=lcom; atac:=lat; die:=0; nal:=100;
  if pos('.',name)=0 then name:=name+'.shp';
  assign(ff,name);
 {$i-} reset(ff,1); {$i+}
 if ioresult<>0 then
 begin
  assign(ff,'ship.dat');
  reset(ff,1);
 end;
 seek(ff,0);
 blockread(ff,rrr,9);
 if rrr='SpaceShip' then  else exit;
 blockread(ff,sname,256);
 blockread(ff,emt,6);
 blockread(ff,eman,6);
 blockread(ff,ehit,6);
 blockread(ff,erad,6);
 blockread(ff,etaran,6);
 blockread(ff,earmor,6);
 blockread(ff,eroc,1);
 blockread(ff,maxpix,1);
 k:=1;
 n:=1;
 pix:=new(ppixel);
 epix:=new(ppixel);
 for i:=0 to maxpix do new(pix^[i]);
 for i:=0 to maxpix do new(epix^[i]);
 while not eof(ff) do
  begin
   inc(n);
   blockread(ff,j,1);
  if (pix^[n]<>nil) then new(pix^[n+1]);
  if epix^[n]<>nil then new(epix^[n+1]);
   epix^[n]^.l:=pi+(1*pi-(j/20+pi/2));
   blockread(ff,j,1);
   epix^[n]^.rl:=j/5;
   blockread(ff,j,1);
   epix^[n]^.c:=j;
   if (epix^[n]^.c=1)then begin star[k]:=n-1;inc(k);dec(n);end;
  end;
  star[k]:=n-1;
  maxpix:=n;
  win:=0;
  close(ff);
  writeln(sizeof(self),'-',n);
end;
{$f+}
procedure keyb; interrupt;
var i,j:integer;
begin
for j:=1 to 2 do
 for i:=1 to maxkey do
   if port[$60]=portkey[j,i] then s[j].key[i]:=true;

for j:=1 to 2 do
 for i:=1 to maxkey do
   if port[$60]=portkey[j,i]+$80 then s[j].key[i]:=false;
 inline ($60);
 vec;
end;
{Ff-}
procedure nebo;
begin
  initsvga(0,svgmode-1); mx:=getmaxx;my:=getmaxy;
  for i:=1 to 1000 do putpixel(random(mx),random(my),120+random(100));
  setcolor(240);
  k:=random(2);
  for i:=0 to mx do
   begin
     m:=k;
     k:=random(3)-1;
     line(i,my-k-pol+5,i-1,my-m-pol+5);
   end;
end;
procedure face;
var i,j:integer;
    ff:file;
const c:record  x,y:integer; end=(x:25;y:25);
begin
  setcolor(240);
  barr(c.x-25,c.x-25,c.x+25,c.x+25,0);barr(mx-c.x-25,c.x-25,mx-c.x+25,c.x+25,0);
  circle(c.x,c.y,25);circle(mx-c.x,c.y,25);
  line(c.x,c.y,r(c.x+cos(s[2].hit/s[2].ehit*pi+pi)*23),r(c.y+sin(s[2].hit/s[2].ehit*pi+pi)*20));
  line(mx-c.x,c.y,mx-r(c.x+cos(s[1].hit/s[1].ehit*pi+pi)*23),r(c.y+sin(s[1].hit/s[1].ehit*pi+pi)*20));
  outtextxy(c.x+1-textwidth(st(r(s[2].hit)))div 2,c.y+2,st(r(s[2].hit)));
  outtextxy(mx-c.x+1-textwidth(st(r(s[1].hit)))div 2,c.y+2,st(r(s[1].hit)));
  barr(100,10,130,20,0);outtextxy(100,10,st(s[2].nal));
  barr(mx-130,10,mx-100,20,0);outtextxy(mx-130,10,st(s[1].nal));
  for i:=1 to 30 do
    for j:=1 to 30 do
      putpixel(i+60,j+10,weapon[s[2].acm]^[i+(30-j)*32]);
  for i:=1 to 30 do
    for j:=1 to 30 do
      putpixel(mx-i-60,j+10,weapon[s[1].acm]^[i+(30-j)*32]);
  barr(60,40,90,60,0);barr(mx-60,40,mx-90,60,0);
  outtextxy(70,45,st(s[2].ammo[s[2].acm]));
  outtextxy(mx-80,45,st(s[1].ammo[s[1].acm]));
  barr((mx div 2)-30,5,(mx div 2)+30,35,100);
  settextstyle(7,0,1);
  if not def then
  begin
    outtextxy((mx div 2)-25,20-textheight(st(s[3].die))div 2,st(s[3].die));
    outtextxy((mx div 2)+25-textwidth(st(s[2].die+s[1].die)),20-textheight(st(s[1].die+s[2].die))div 2,st(s[1].die+s[2].die));
  end;
  if def then
  begin
    outtextxy((mx div 2)-25,20-textheight(st(s[3].die))div 2,st(s[2].win));
    outtextxy((mx div 2)+25-textwidth(st(s[1].win)),20-textheight(st(s[1].win))div 2,st(s[1].win));
  end;
  settextstyle(0,0,0);
  barr(10,60,150,70,0);
  if s[2].mes<>'' then outtextxy(10,61,'You got '+s[2].mes);
  barr(mx-150,60,mx,70,0);
  if s[1].mes<>'' then outtextxy(mx-130,61,'You got '+s[1].mes);
end;
procedure mydelay;
var i,j:longint;
    h,m,s,s100:word;
begin
    inc(fps);
    j:=0;
    for i:=0 to r((cpu*18.5)/fpps) do inc(j);
{   gettime(h,m,s,s100);
   while (s100 mod 3)>1 do gettime(h,m,s,s100);}
{    time:=meml[0:$046c];
    while time=meml[0:$046c] do inc(i);
{    while (port[$3da]and 4)=4 do inc(i);}
end;
procedure taran;
var i,j,l,m:integer;
begin
  for l:=1 to maxs do
   for m:=1 to maxs do
   begin
    if l=m then continue;
    if l<m then continue;
    if sqrt(sqr(s[l].x-s[m].x)+sqr(s[l].y-s[m].y))<(s[l].rad*0.8+s[m].rad*0.8) then
    begin
       for i:=1 to s[l].maxpix do
       if sqrt(sqr(s[m].x-(s[l].x+cos(s[l].pix^[m]^.l+s[l].lx)*s[l].pix^[i]^.rl))+
              (sqr(s[m].y-(s[l].y+sin(s[l].pix^[m]^.l+s[l].lx)*s[l].pix^[i]^.rl))))<(s[m].rad)    then
         begin
      with s[l] do initis(pix^[i]^.rl*cos(pix^[i]^.l+lx)+x,pix^[i]^.rl*sin(pix^[i]^.l+lx)+y,random(50)/10+3,random(63)/10);
           s[l].pix^[i]^.rl:=s[l].pix^[i]^.rl*(random(3)/10+0.7);
         end;
       for i:=1 to s[m].maxpix do
       if sqrt(sqr(s[l].x-(s[m].x+cos(s[m].pix^[i]^.l+s[m].lx)*s[m].pix^[i]^.rl))+
              (sqr(s[l].y-(s[m].y+sin(s[m].pix^[i]^.l+s[m].lx)*s[m].pix^[i]^.rl))))<(s[l].rad)
         then
         begin
        with s[m] do initis(pix^[i]^.rl*cos(pix^[i]^.l+lx)+x,pix^[i]^.rl*sin(pix^[i]^.l+lx)+y,random(50)/10+3,random(63)/10);
           s[m].pix^[i]^.rl:=s[m].pix^[i]^.rl*(random(3)/10+0.7);
         end;
       s[l].hit:=s[l].hit-abs(s[m].x-s[m].rx)*(s[m].taran/s[l].armor);
       s[m].nal:=s[m].nal+r(abs(s[m].x-s[m].rx)*(s[m].taran/s[l].armor));
       s[m].hit:=s[m].hit-abs(s[l].x-s[l].rx)*(s[l].taran/s[m].armor);
       s[l].nal:=s[l].nal+r(abs(s[l].x-s[l].rx)*(s[l].taran/s[m].armor));
       ll:=s[l].rx; s[l].rx:=s[l].x+(s[m].rx-s[m].x)*s[m].taran/s[l].armor; s[m].rx:=s[m].x+(ll-s[l].x)*s[l].taran/s[m].armor;
       ll:=s[l].ry; s[l].ry:=s[l].y+(s[m].ry-s[m].y); s[m].ry:=s[m].y+(ll-s[l].y);
       s[l].move; s[m].move;
       j:=0;
       while (sqrt(sqr(s[l].x-s[m].x)+sqr(s[l].y-s[m].y))<(s[l].rad+s[m].rad)*0.7)and(j<100) do
       begin
         inc(j);
         s[l].move;
         s[m].move;
       end;
    end;
  end;
end;
procedure init;
begin
  for i:=1 to 8 do
  begin
    new(weapon[i]);
    assign(ff,filen[i]);
    reset(ff,1);
    seek(ff,1077);
    blockread(ff,weapon[i]^,961);
    close(ff);
  end;
  cpu:=0;
  for j:=1 to 3 do
  begin
   time:=meml[0:$046c];
   while time=meml[0:$046c] do ;
   inc(time,2);
   i:=0;
   while time<>meml[0:$046c] do inc(i);
   cpu:=i+cpu;
  end;
  cpu:=cpu div 3;
  for i:=1 to maxi do new(is[i]);
  for i:=1 to maxi do is[i]^.tip:=0;
  for i:=1 to maxc do c[i].tip:=0;
  for i:=1 to maxc do c[i].hit:=0;
  fps:=0;
  randomize;
  for i:=1 to 100 do s[1].key[i]:=FALSE;
  for i:=1 to 100 do s[2].key[i]:=false;
  for i:=1 to maxp do pul[i].tip:=0;
  GetIntVec($9,@vec);
  SetIntVec($9,Addr(keyb));
  fillchar(pul,sizeof(pul),0);
  fillchar(b,sizeof(b),0);
end;
procedure ai(com:integer);
var lp,sl,l:real;
    i,j:integer;
begin
 j:=s[com].atac;
 with s[com] do
 begin
  l:=lx;
  if (x>s[j].x)and(y>s[j].y)then lp:=pi-arctan((x-s[j].x)/(y-s[j].y))-0.5*pi+pi;
  if (x<s[j].x)and(y<s[j].y)then lp:=pi-arctan((s[j].x-x)/(s[j].y-y))+0.5*pi+pi;
  if (x>s[j].x)and(y<s[j].y)then lp:=1.5*pi+arctan((x-s[j].x)/(s[j].y-y))+pi;
  if (x<s[j].x)and(y>s[j].y)then lp:=1.5*pi+arctan((s[j].x-x)/(y-s[j].y))+pi+pi;
  while lp>pi*2 do lp:=lp-pi*2;
  while lp<0 do lp:=lp+pi*2;
  while l>pi*2 do l:=l-pi*2;
  while l<0 do l:=l+pi*2;
  if (l>5)or(lp<1)then lp:=lp+pi*2;
  if (lp>5)or(l<1)then l:=l+pi*2;
  if not s[j].killed then
  if ((l-lp)>0.051)and(lp<l)and((l-lp)<pi) then
  key[5]:=true else  key[5]:=false;
  if not s[j].killed then
  if ((lp-l)>0.051)and(lp>l)and((lp-l)<pi) then
  key[4]:=true else key[4]:=false;
   key[2]:=false;
  if (not s[j].killed)and(abs(l-lp)<0.5)and(s[j].y<my) then
   begin
     key[7]:=true;
     if (sqrt(sqr(x-s[j].x)+sqr(y-s[j].y))<wrad[acm])and(sqrt(sqr(x-s[j].x)+sqr(y-s[j].y))>30) then key[8]:=true;
   end
  else
  begin
    key[7]:=false;
    key[8]:=false;
    key[2]:=true;
    for i:=1 to maxp do
    if pul[i].tip>0 then
    if sqrt(sqr(pul[i].x-x-cos(lx)*rad)+sqr(pul[i].y-y-sin(lx)*rad))<rad then
    key[2]:=false;
  end;
  key[6]:=true;
 end;
end;
var tt,vv,t2,v2,cj:byte;
    NAMES:array[1..5]of string;
    comps:array[1..5]of boolean;
    atacs:array[1..5]of byte;
    ships:array[1..5]of string;
    snow:boolean;
    leve:integer;
const tf:array[false..true]of string[10]=('Игрок','Комп');
function readship:string;
var ss:searchrec;
    i,j:integer;
begin
  readship:='first.shp';
  i:=0;
  findfirst('*.shp',anyfile,ss);
  while doserror=0 do
  begin
   inc(i);
   men[i]:=ss.name;
   findnext(ss);
  end;
  menu(i,14,4);
  readship:=men[v];
end;
procedure win(z1,z2,z3,z4,z5,z6:integer; name:string);
var i:integer;
begin
 i:=random(maxsb)+1;
 play(buf[i],sbs[i],11050);
 iva.win(z1,z2,z3,z4,z5,z6,name);
end;
procedure shipmenu;
lABEL next;
begin
 repeat
    win(30,7,50,15,14,1,'Spase Wars');
    print(30,6,14,1,'╔═══ Space Wars: ═══╗');
    print(30,7,14,1,'╟─── Version '+vers+' ──╢');
    men[1]:='..';
    men[2]:='Игра';
    men[3]:='Управление';
    men[4]:='Опции';
    men[5]:='Игроки';
    men[6]:='Помощь';
    men[7]:='Миссии';
    t:=vv;
    menu(7,14,1);
    vv:=v;
    case vv of
     1:endgame;
     2:break;
     7:begin
         win(28,7,52,18,14,1,'Миссии');
         men[1]:='Стрельбище(Defmath)';
         men[2]:='Убей компa(Cooperariv)';
         men[3]:='АД';
         men[4]:='Игрок-Комп';
         men[5]:='Комп-Комп';
         menu(5,14,1);
         case v of
          1: begin
               cj:=2; atacs[1]:=2;atacs[2]:=1;
               snow:=false;
               def:=true;  goto next;
             end;
          5: begin
               cj:=2; atacs[1]:=2;atacs[2]:=1;
               snow:=false; comps[1]:=true;comps[2]:=true;
               def:=true; goto next;
             end;
          4: begin
               cj:=2; atacs[1]:=2; atacs[2]:=1; comps[2]:=true;
               snow:=false;
               def:=true; goto next;
             end;
          2: begin
               cj:=3; atacs[1]:=3; atacs[2]:=3;atacs[3]:=1;
               snow:=false;
               def:=false; goto next;
             end;
          3: begin
               cj:=5; atacs[1]:=2; atacs[2]:=1;
               snow:=true;
               def:=true;  goto next;
             end;
         end;
       end;
     3:begin
        win(1,1,80,25,14,1,'Управление');
        print(20,2,14,1,'1 игрок');
        print(40,2,14,1,'2 игрок');
        print(5,3,14,1,'Вверх');     print(20,3,14,1,'Up'); print(40,3,14,1,'w');
        print(5,4,14,1,'Вниз');   print(20,4,14,1,'Down'); print(40,4,14,1,'s');
        print(5,5,14,1,'Влево');   print(20,5,14,1,'Left'); print(40,5,14,1,'a');
        print(5,6,14,1,'Вправо');  print(20,6,14,1,'Right'); print(40,6,14,1,'d');
        print(5,7,14,1,'Восстановить'); print(20,7,14,1,'Backspace'); print(40,7,14,1,'q');
        print(5,8,14,1,'Пули'); print(20,8,14,1,'Ctrl'); print(40,8,14,1,'Tab');
        print(5,9,14,1,'Ракеты'); print(20,9,14,1,'\'); print(40,9,14,1,'`');
        print(5,10,14,1,'Другое оружие');print(20,10,14,1,'Enter'); print(40,10,14,1,'1');
        repa;
       end;
     5:repeat
         men[1]:='Col-vo:'+st(cj);
         for i:=1 to cj do men[1+i]:='Player '+st(i)+': '+names[i]+' '+tf[comps[i]]+' '+st(atacs[i])+' '+ships[i];
         win(20,12,60,19,14,1,'Players');
         t2:=v2;
         menu(1+cj,14,1);
         v2:=v;
         case v2 of
          1:begin
              win(38,13,42,18,14,1,'P');
              for i:=1 to 4 do men[i]:=' '+st(i+1)+' ';
              menu(4,14,1);
              cj:=v+1;
            end;
          2..6:begin
                 win(1,1,80,25,14,4,'Установки Игрока');
                 write('Имя: '); readln(names[v2-1]);
                 men[1]:='Игрок';
                 men[2]:='Комп';
                 menu(2,14,4);
                 if v=1 then comps[v2-1]:=false else comps[v2-1]:=true;
                 for i:=1 to 5 do men[i]:='Atac: '+st(i)+' ';
                 menu(5,14,1);
                 atacs[v2-1]:=v;
                 ships[v2-1]:=readship;
              end;
         else break
         end
       until false;
     6:begin
        win(2,2,78,23,14,0,'Помощь');
        writeln('Copyright Ivanov Andrey');
        writeln('Etc....');
        repa;
       end;
     4:repeat
        win(28,9,52,16,14,4,'Опции');
        men[1]:='Разрешение Экрана';
        men[2]:='Снег';
        men[3]:='fps';
        men[4]:='Таран';
        men[5]:='Лазер';
        men[6]:='Auto repair';
        t2:=v2;
        menu(6,14,4);
        v2:=v;
        case v2 of
         3:begin
             win(10,13,70,16,14,1,'FPS');
             write('Enter number of fps ('+st(fpps)+'): '); readln(fpps);
           end;
         2:begin
             win(36,10,44,13,14,1,'Снег');
             men[1]:='Да';
             men[2]:='Нет';
             menu(2,14,1);
             if v=1 then snow:=true else snow:=false;
             if snow then
             begin
               win(20,6,60,16,14,1,'Снег');
               writeln('Макс.снега (1..1000)');
               writeln('1-Оч.много, 100- мало');
               write('Enter: ');readln(level);
             end;
           end;
         1:begin
            win(35,10,45,17,14,1,'РЭ');
            for i:=1 to 6 do men[i]:=svg[i];
            menu(6,14,1);
            svgmode:=v;
           end;
         4:begin
            win(35,10,45,13,14,1,'Таран');
            men[1]:=           '  Вкл.   ';
            men[2]:=           '  Выкл.  ';
            menu(2,14,1);
            if v=1 then taranb:=true else taranb:=false;
           end;
         6:begin
            win(35,10,45,13,14,1,'Auto r');
            men[1]:=           '  Вкл.   ';
            men[2]:=           '  Выкл.  ';
            menu(2,14,1);
            if v=1 then avtor:=true else avtor:=false;
           end;
         5:begin
            win(35,10,45,13,14,1,'Лазер');
            men[1]:=           '  Вкл.   ';
            men[2]:=           '  Выкл.  ';
            menu(2,14,1);
            if v=1 then las:=true else las:=false;
           end;
           else break;
        end;
    until false;
   end;
  until false;
next:  window(1,1,80,25);
end;
procedure killer;
begin
    for i:=1 to maxs do
    if (s[i].hit<=0)and(
           (s[i].y<0)
         or((s[i].hit<-150)and((levtip<>2)or(levtip<>6))
         or((s[i].hit<-50)and((levtip=2)or(levtip=6))))) then
    begin
     inc(s[i].die);
     if i=1 then
       begin
         inc(s[2].win);
         inc(s[2].nal,100);
       end
     else
       begin
         inc(s[1].win);
         inc(s[1].nal,100);
       end;
     s[i].draw(0);
     s[i].init(random(r(mx-2*s[i].erad))+s[i].erad,pol+s[i].erad);
     if not def then if i=1 then s[3].atac:=2;
     if not def then if i=2 then s[3].atac:=1;
    end;
end;
procedure prep;
begin
  avtor:=true;  game:=false; fpps:=40; las:=false;
  svgmode:=2;
  hide_cursor;
  cj:=2; def:=true;
  snow:=false;
  level:=10;
  for i:=1 to 2 do comps[i]:=false;
  for i:=3 to 5 do comps[i]:=true;
  atacs[1]:=2; atacs[2]:=1; atacs[3]:=1; atacs[4]:=2; atacs[5]:=1;
  ships[1]:='first.shp';
  ships[2]:='ot.shp';
  ships[3]:='vik.shp';
  ships[4]:='ship.shp';
  ships[5]:='turbo.shp';
end;
procedure sky;
var k,i,j,n,m:integer;
    bad:boolean;
begin
  for k:=1 to 10 do
  begin
    i:=random(mx);
    j:=random(my);
    bad := false;
    n:=((i) div 32)+1;
    m:=((j) div 32)+1;
    if (mp[n,m].tip>0)then bad:=true;
    if not bad then putpixel(i,my-j,0);
  end;
    if not bad then if random(10)=0 then  putpixel(i,my-j,RANDOM(GETMAXCOLOR));
end;
BEGIN { ******************** Начало программы *********************** }
 prep;
repeat
  initsb;
  speakeron;
  for i:=1 to maxsb do sbs[i]:=fsize(sb[i]);
  for i:=1 to maxsb do getmem(buf[i],sbs[i]);
  for i:=1 to maxsb do loadsb(sb[i],buf[i],sbs[i],0);
{  play(buf[1],fsize('glass')-100,11050);}  shipmenu;
  init;
  nebo;
  maxs:=cj;
  for i:=1 to maxs do
  begin
   s[i].load(ships[i],comps[i],atacs[i]);
   s[i].init(s[i].erad+(mx)/maxs*(i),pol+s[i].erad);
  end;
  gettime(hh,mm,ss,s100);
  game:=true;
  taranb:=true;
  endg:=false;
  levtip:=1;
  colc:=0;
  for i:=0 to mapx do
     for j:=0 to mapy do  mp[i,j].tip:=0;
{  for i:=1 to 100 do mp[random(mapx),random(mapy-7)+5].tip:=1;}
    for i:=1 to mapx do
       for j:=1 to mapy do if mp[i,j].tip=1 then mp[i,j].draw(i*32-32,(j*32)-32,i*32,(j*32),230);

{  for i:=1 to 255 do begin setcolor(i); line(i,0,i,600);end;}
  repeat
    for i:=1 to maxc do if c[i].tip=0 then begin c[i].hit:=1;c[i].tip:=1; c[i].y:=my; c[i].x:=random(mx);c[i].rad:=10; end;
    if keypressed then readkey;
    for i:=1 to maxz do if z[i].tip=0 then z[i].init(random(mx),random(my),random(15));
    sky;
{    for i:=1 to mapx do
       for j:=1 to mapy do mp[i,j].draw(i*32-32,j+32-32,i*32,j*32,0);}
    for i:=1 to maxz do z[i].draw(0);
    for i:=1 to maxs do s[i].draw(0);
    for i:=1 to maxp do pul[i].draw(0);
    for i:=1 to maxb do b[i].draw(0);
    for i:=1 to maxi do is[i]^.draw(0);
    for i:=1 to colc do c[i].draw(0);
    for i:=1 to maxs do if s[i].com then ai(i);
    for i:=1 to maxs do begin work:=i; s[i].move; end;
    for i:=1 to maxz do z[i].move;
    for i:=1 to maxp do pul[i].move;
    for i:=1 to colc do c[i].move;
    if snow then if random(level)=0 then initp(1);
    for i:=1 to maxb do b[i].move;
    for i:=1 to maxi do is[i]^.move;
    for i:=1 to maxs do if s[i].lx>pi*2 then s[i].lx:=s[i].lx-pi*2;
    for i:=1 to maxs do if s[i].lx<0 then s[i].lx:=s[i].lx+pi*2;
    if taranb then taran;
    if keypressed then readkey;
    for i:=1 to maxs do s[i].lkey:=s[i].key;
    for i:=1 to maxs do s[i].draw(9);
    for i:=1 to maxz do z[i].draw(1);
    for i:=1 to maxp do pul[i].draw(245);
    for i:=1 to maxb do b[i].draw(5);
    for i:=1 to maxi do is[i]^.draw(5);
    for i:=1 to colc do c[i].draw(50);
    face;
    mydelay;
    killer;
    if keypressed then readkey;
  until endg;
  gettime(hh2,mm2,ss2,ss200);
 if game then
 begin
 for i:=1 to maxs do s[i].kill;
  closegraph;
  SetIntVec($9,@vec);
 end;
 game:=false;
 until 1<0;
end.