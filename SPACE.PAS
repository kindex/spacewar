program spaceracer_1_12; {  14.5.99 }
uses crt,svga,iva,graph,dos,blast;
const sop=0.999;
      grav=0.05;
      maxfog=500;
      maxlas=5;
      pol=10;
      maxc=5;
      maxstar=100;
      maxkey=10;
      maxp=450;
      maxi=30; {300}
      maxb=30;
      version='1.16 (99) (6.12.1999) demo 4';
      vers='1.16';
      mapx=20; mapy=13;
      maxsb=6;
      maxfil=10;
const portkey:array[1..2,1..maxkey]of byte=((1,$48,$50,$4b,$4d,$e,$1d,$2b,$1c,$36),(1,$11,$1f,$1e,$20,$10,$0f,$29,$2,$3a));
      del:array[1..10]of byte=(1,2,2,3,15,15,50,50,0,0);
   filen:array[1..maxfil]of string[12]=
   ('s10.bmp','s20.bmp','s30.bmp','s40.bmp','s50.bmp','s60.bmp','s70.bmp','s80.bmp','cil.bmp','cill.bmp');
      get:array[1..9]of string[30]=('Ammo','A.for 2','A.for 3','A.for 4','Rok.','Sam.rok.','Atomka','Salut','Health');
    wrad:array[1..8]of integer=(0,100,300,100,200,400,300,300);
    svg:array[1..5]of string[9]=('320x200-','640x400 !','640x480-','800x600+','1024x768');
    sb:array[1..maxsb]of string[12]=('glass','bang','tank','xploshor','bang','effect');
type    pixell=array[0..255]of ^ppp;
        ppixel=^pixell;
        ppp=record
                rl,l:real;
                c:byte;
             end;
        bmp=array[0..31,0..31]of byte;
        tstar=object
                x,y,c:byte;
                procedure init(ax,ay,ac:byte);
                procedure draw(cc:byte);
             end;
        point=object
             x,y,lrx,lry:real;
             procedure move;
            end;
        tfog=object
              hit,fogx,fogy:byte;
              x,y:integer;
              procedure move;
              procedure draw;
              procedure init(lx,ly,llx,lly:integer);
            end;
        tlas=object
              hit,who,lhit,rhit:byte;
              x,y,lrx,lry:integer;
              lmx,lmy,lmlrx,lmlry:integer;
              lx:real;
              procedure move;
              procedure draw(c:integer);
              procedure init(rx,ry,lwho:integer;rlx:real);
            end;
        ship=object(point)
            mes:string[30];
            atac:byte;
            nal:longint;
            lx,ly,rx,ry,lal:real;
            com,killed,lastmove:boolean;
            sk,hit,skor,rad,mt,man,taran,armor:real;
            ehit,erad,emt,eman,etaran,earmor:real;
            aroc1,aroc,maxpix,win,eroc,die:byte;
            star:array[1..maxkey]of byte;
            rkey,lkey,key:array[1..maxkey]of boolean;
            sname:string;
            ammo:array[1..15]of integer;
            acm,anext:integer;
            pix,lpix,epix:ppixel;
            procedure init(dx,dy:real);
            procedure move(ifd:boolean);
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
           tip,who,vz,ltip:byte;
           std1:integer;
           lx,sk,lol:real;
           procedure move;
           procedure draw(c:integer);
         end;
    iskr=object(point)
           x2,y2,lx2,ly2:array[1..17]of integer;
           sk,lx:real;
           tip,hit,ltip:byte;
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
    star:array[1..maxstar]of tstar;
    fog:array[1..maxfog]of tfog;
    las:array[1..maxlas]of tlas;
    buf:array[1..maxsb]of pointer;
    sbs:array[1..maxsb]of word;
    is:array[1..maxi]of  ^iskr;
    pul:array[1..maxp]of pula;
    b:array[1..maxb]of bomb;
    wea:array[1..10]of pointer;
    weapon:array[1..maxfil]of ^bmp;
    z:array[1..10]of zv;
    c:array[1..maxc]of cil;
    mp:array[0..mapx+1,0..mapy+1]of map;
    maxz,n,work,maxs,fpps,levtip,colc,svgmode,level:byte;
    hh,mm,ss,s100:word;
    ii,mx,my,k,m,fps,time,cpu,i,j,hod:longint;
    endg,game,def,taranb,avtor:boolean;
    ll,umn:real;
    ff:file;
    vec:procedure;
procedure tstar.init;
begin x:=ax; y:=ay; c:=ac;end;
procedure tstar.draw;
begin
  if cc=0 then putpixel(x*3,y*2,0) else putpixel(x*3,y*2,c);
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
procedure tlas.init;
begin
  lrx:=rx;
  lry:=ry;
  x:=rx; y:=ry; lx:=rlx; hit:=1; who:=lwho; rhit:=1;
  s[who].hit:=s[who].hit+10;
end;
procedure tlas.draw;
begin
  if (c<>0)and(hit<>0) then
  begin
    setcolor(c);
    line(x,my-y,lrx,my-lry);
  end;
  if (c=0)and(lhit<>0)or(hit=0) then
  begin
    setcolor(0);
    line(lmx,my-lmy,lmlrx,my-lmlry);
  end;
end;
procedure tlas.move;
var i,j,rx,ry,n:integer;
    ok:boolean;
begin
  if (hit=0)and(rhit>1)then inc(rhit);
  if rhit>10 then rhit:=0;
  if hit>3 then hit:=0;
  if hit=0 then exit;
  lhit:=hit;
  inc(hit);
  lmx:=x;
  lmy:=y;
  lmlrx:=lrx;
  lmlry:=lry;
  ok:=false;
  for j:=r(s[who].rad) to mx do
  begin
    rx:=round(x+cos(lx)*j);
    ry:=round(y+sin(lx)*j);
    if (rx<0)or(rx>mx)or(ry<0)or(ry>my) then break;
      for i:=1 to maxs do
      begin
       if i=who then continue;
       if (sqrt(sqr(rx-s[i].x)+sqr(ry-s[i].y))<s[i].rad){and(s[i].hit>0)} then
           begin
             s[i].hit:=s[i].hit-5;
             ok:=true;
             for n:=1 to random(3)+4 do
             initis(rx,ry,random(50)/10+3,random(60)/10);
             break;
          end;
     end;
   if ok then break;
  end;
  lrx:=rx;
  lry:=ry;
end;
procedure tfog.init;
begin
  x:=lx; y:=ly; hit:=1; fogx:=llx; fogy:=lly;
end;
procedure tfog.move;
begin
  if hit=0 then exit;
  inc(hit);
  if hit>50 then hit:=0;
end;
procedure tfog.draw;
var i,lx,ly,c:integer;
begin
  if hit=0then exit;
  if hit<20 then
  for i:=1 to 1 do
  begin
    lx:=x+random(fogx)-fogx div 2;
    ly:=y+random(fogy)-fogy div 2;
    c:=random(20)+230;
    setactivepage(0); putpixel(lx,my-ly,c);
    setactivepage(1); putpixel(lx,my-ly,c);
  end
  else
  for i:=1 to 1 do
  begin
    lx:=x+random(fogx)-fogx div 2;
    ly:=y+random(fogy)-fogy div 2;
    setactivepage(0); putpixel(lx,my-ly,0);
    setactivepage(1); putpixel(lx,my-ly,0);
  end;
  if hit=50 then
  begin
    setactivepage(0); barr(x-fogx,my-(y-fogx),x+fogx,my-(y+fogx),0);
    setactivepage(1); barr(x-fogx,my-(y-fogy),x+fogx,my-(y+fogy),0);
  end;
end;
procedure map.draw;
begin
  if tip=1 then barr(x,my-y2+1,x2-1,my-y,c);
end;
procedure point.move;
begin
  lrx:=x; lry:=y;
end;
procedure cil.move;
var i,j:integer;
    step:boolean;
begin
  inherited move;
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
  if c<>0 then
  case tip of
  1: for i:=1 to 30 do   for j:=0 to 29 do   putpixel(r(x)+i,my-r(y+j),weapon[9]^[j,i]);
  2,4: for i:=1 to 30 do   for j:=0 to 29 do   putpixel(r(x)+i,my-r(y+j),weapon[10]^[j,i])
   end
    else barr(r(lrx),my-r(lry),r(lrx)+31,my-r(lry+29),0);
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
  for i:=1 to maxpix do if pix^[i]<>nil then dispose(pix^[i]);
  for i:=1 to maxpix do if pix^[i]<>nil then dispose(epix^[i]);
  for i:=1 to maxpix do if pix^[i]<>nil then dispose(lpix^[i]);
  dispose(pix);
  dispose(lpix);
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
   putpixel(r(lrx),my-r(lry),0);
   putpixel(r(lrx-1),my-r(lry+1),0);
   putpixel(r(lrx-1),my-r(lry-1),0);
   putpixel(r(lrx+1),my-r(lry+1),000);
   putpixel(r(lrx+1),my-r(lry-1),000);
   for i:=1 to 15 do putpixel(r(lrx-i),my-r(lry),0);
   for i:=1 to 15 do putpixel(r(lrx+i),my-r(lry),0);
   for i:=1 to 15 do putpixel(r(lrx),my-r(lry+i),0);
   for i:=1 to 15 do putpixel(r(lrx),my-r(lry-i),0);
 end
end;
procedure zv.move;
var i,j:integer;
begin
  inherited move;
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
  inherited move;
  ltip:=tip;
  lx2:=x2; ly2:=y2;
  if hit>30 then tip:=0;
  if tip=0 then exit;
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
  if ltip=0 then exit;
  if (c<>0)and(tip=1) then
   for i:=1 to 16 do
    begin
     setcolor(10+i*2+hit);
     line(x2[i],my-y2[i],x2[i+1],my-y2[i+1]);
    end
  else
  if ltip=1 then
   begin
    setcolor(0);
      for i:=1 to 16 do
      line(lx2[i],my-ly2[i],lx2[i+1],my-ly2[i+1]);
    end
end;
procedure bomb.draw;
var i,n,m:integer;
    e,ex,ey:real;
begin
 if tip=7 then
 begin
  if std2<30 then
   for i:=1 to 100 do
   begin
    e:=random(630)/100;
    ex:=r(x+cos(e)*std2);
    ey:=r(y+sin(e)*std2);
    n:=r(ex)div 32+1;
    m:=r(ey)div 32+1;
    if mp[n,m].tip=0 then
    begin
      setactivepage(0);
      putpixel(r(ex),my-r(ey),random(20)+std2*2+10);
      setactivepage(1);
      putpixel(r(ex),my-r(ey),random(20)+std2*2+10);
    end;
  end
  else
   for i:=1 to random(10) do
   begin
    e:=random(630)/100;
    ex:=r(x+cos(e)*30);
    ey:=r(y+sin(e)*30);
    n:=r(ex)div 32+1;
    m:=r(ey)div 32+1;
    setcolor(0);
    if mp[n,m].tip=0 then
    begin
      setactivepage(0);
      line(r(x),my-r(y),r(ex),my-r(ey));
      setactivepage(1);
      line(r(x),my-r(y),r(ex),my-r(ey));
    end;
  if std2=60 then
  begin
      setactivepage(0);
       sector(r(x),my-r(y),0,360,30,30);
      setactivepage(1);
       sector(r(x),my-r(y),0,360,30,30);
  end;
 end;
 end;
 if tip=5 then
 begin
  if std2<10 then
   for i:=1 to 40 do
   begin
    e:=random(63)/10;
    ex:=r(x+cos(e)*std2);
    ey:=r(y+sin(e)*std2);
    n:=r(ex)div 32+1;
    m:=r(ey)div 32+1;
    if mp[n,m].tip=0 then
    begin
      setactivepage(0);
     putpixel(r(ex),my-r(ey),random(30)+std2*5);
      setactivepage(1);
     putpixel(r(ex),my-r(ey),random(30)+std2*5);
    end;
  end
  else
   for i:=1 to 4 do
   begin
    e:=random(63)/10;
    ex:=r(x+cos(e)*10);
    ey:=r(y+sin(e)*10);
    n:=r(ex)div 32+1;
    m:=r(ey)div 32+1;
    setcolor(0);
    if mp[n,m].tip=0 then
    begin
      setactivepage(0);
      line(r(x),my-r(y),r(ex),my-r(ey));
      setactivepage(1);
      line(r(x),my-r(y),r(ex),my-r(ey));
    end;
  end;
  if std2=20 then
  begin
      setactivepage(0);
       sector(r(x),my-r(y),0,360,10,10);
      setactivepage(1);
       sector(r(x),my-r(y),0,360,10,10);
  end;
 end;
end;
procedure bomb.move;
var i,j,n:integer;
begin
  inherited move;
 if tip=0 then exit;
 if tip=5 then if std2>20 then begin tip:=0; std2:=0; end;
 if std2>0 then
 begin
   inc(std2);
   for i:=1 to maxs do if sqrt(sqr(x-s[i].x)+sqr(y-s[i].y))-s[i].rad<std2 then s[i].hit:=s[i].hit-2/4;
 end;
 if std2>60 then begin tip:=0; std2:=0; end;
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
  play(buf[(work+1)],sbs[(work+1)]-100,11050);
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
  inherited move;
   lol:=l; ltip:=tip;
  if (tip=5) or (tip=6) then
     if sk<8 then sk:=sk*1.1 else sk:=sk*0.9;
  if (tip=4) then
     if sk<15 then sk:=sk*1.1 else sk:=sk*0.9;
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
{  if (tip=4) then
  begin
   if (lx<pi+pi/2)and(lx>pi/2) then begin lx:=lx+0.01; if sk>2 then sk:=sk*0.99; end;
   if (lx>pi+pi/2)or((lx<pi/2)and(lx>-pi/2)) then begin lx:=lx-0.02;if sk>1 then sk:=sk*0.99; end;
  end;}
  if (tip>5)or(tip=4) then
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
  if x<-30 then tip:=0;
  if x>mx+30 then tip:=0;
  if y<-30 then tip:=0;
  if y>my+30 then tip:=0;
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
 if (vz=0)and(tip=6)and(sqrt(sqr(x-s[i].x)+sqr(y-s[i].y))<s[i].rad) then vz:=2;
 if (vz=0)and(tip=5)and(sqrt(sqr(x-s[i].x)+sqr(y-s[i].y))<s[i].rad) then vz:=4;
 if (vz>0)and(random(1)=0) then
 begin
  vz:=vz-1;
  for j:=1 to maxb do
    if b[j].tip=0 then break;
    b[j].init(x+random(20)-10,y+random(20)-10,5);
    if vz=0 then self.tip:=0;
    if vz=0 then self.std1:=0;
  end;
{  i:=r(x) div 32+1;
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
       end;}
end;
procedure pula.draw;
var i:integer;
begin
  if ltip=0 then exit;
 if (tip<>0)and(c>0) then for i:=1 to 4 do
  begin
    setcolor(c-i*5);
    if (pp[i].x<0)or(pp[i].x>mx)or(pp[i].y<0)or(pp[i].y>my)then break;
    line(pp[i].x,my-pp[i].y,pp[i+1].x,my-pp[i+1].y)
  end
  else for i:=1 to 4 do
    begin
    setcolor(0);
{    if (pp[i].x<0)or(pp[i].x>mx)or(pp[i].y<0)or(pp[i].y>my)then break;}
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
   setcolor(0);
   line(r(lrx),my-r(lry),r(lrx+cos(lx)*5),my-r(lry+sin(lx)*5));
   circle(r(lrx),my-r(lry),1);
  end;
  if ((tip=1)or(tip=2)or(tip=3)or(tip=4)) then
  if c=0 then putpixel(r(lrx),my-r(lry),0) else putpixel(r(x),my-r(y),c);
  if (c>0)and((tip=3)or(tip=4)) then
  begin
    putpixel(r(x),my-r(y-1),c-5);
    putpixel(r(x-1),my-r(y),c-5);
    putpixel(r(x+1),my-r(y),c-5);
    putpixel(r(x),my-r(y+1),c-5);
  end else
  if ((tip=3)or(tip=4)) then
  begin
    putpixel(r(lrx),my-r(lry-1),c);
    putpixel(r(lrx-1),my-r(lry),c);
    putpixel(r(lrx+1),my-r(lry),c);
    putpixel(r(lrx),my-r(lry+1),c);
  end;
  if tip>6 then
  begin
    if c>0 then
    begin
      setcolor(40);
      line(r(x),my-r(y),r(x+cos(lx)*5),my-r(y+sin(lx)*5));
      circle(r(x),my-r(y),2);
      circle(r(x),my-r(y),3);
    end
  else
   begin
      setcolor(0);
      line(r(lrx),my-r(lry),r(lrx+cos(lx)*5),my-r(lry+sin(lx)*5));
      circle(r(lrx),my-r(lry),2);
      circle(r(lrx),my-r(lry),3);
    end
  end
end;
procedure ship.init;
var i,j:integer;
begin
 killed:=false; lastmove:=false;
 mes:='';
 x:=dx; y:=dy;   aroc:=0;aroc1:=0; mt:=emt*umn; man:=eman;
 rx:=dx;ry:=dy; armor:=earmor; taran:=etaran;
 lx:=pi/2;
 sk:=5; hit:=ehit;
 rad:=erad;
 for i:=0 to maxpix do pix^[i]^:=epix^[i]^;
 for i:=0 to maxpix do lpix^[i]^:=pix^[i]^;
 acm:=5; anext:=0;
 for i:=2 to 4 do ammo[i]:=50;
 for i:=5 to 6 do ammo[i]:=3;
 for i:=7 to 8 do ammo[i]:=2;
end;
var    hh2,mm2,ss2,ss200:word;
       hh3,mm3,ss3,ss300:word;
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
if ifd then begin    inherited move;
 lal:=lx; rkey:=lkey; lkey:=key;
                  for i:=1 to maxpix do lpix^[i]^:=pix^[i]^;
            end;
 for i:=1 to maxpix do
  if pix^[i]^.rl<rad*0.4 then pix^[i]^.rl:=rad*0.4;
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
  if aroc1>0 then dec(aroc1);
  ix:=x; iy:=y;
 { if abs(x-rx)>0.1 then} x:=x+(x-rx)*sop {else rx:=x};
{  if abs(y-ry)>0.02 then} y:=y+(y-ry)*sop {else ry:=y};
  if levtip=2 then
  begin
    if x<mx/2 then x:=x+grav*umn;
    if x>mx/2 then x:=x-grav*umn;
    if y<my/2 then y:=y+grav*umn;
    if y>my/2 then y:=y-grav*umn;
  end
  else if levtip<6 then y:=y-grav*umn
       else
       begin
         if y<0 then y:=y+grav*umn;
         if y>my then y:=y-grav*umn;
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
  if key[7] then if aroc1=0 then begin push(1); aroc1:=3; end;
  if key[8] then  if (ammo[acm]>0)and(aroc=0) then begin push(acm); dec(ammo[acm]); aroc:=del[acm]; end;
  if key[10] then if (aroc=0)and(nal>=40) then
  begin
    aroc:=20;
    for i:=1 to maxlas do if (las[i].hit=0)and(las[i].rhit=0) then break;
    las[i].init(r(x),r(y),work,lx);
    dec(nal,40);
  end;
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
   nal:=nal+30;
 end;
 if avtor then key[6]:=true;
 sky:=abs(y-ry)*0.5+0.1;
 skx:=abs(x-rx)*0.5+0.1;
end;
procedure ship.draw;
var i,j,ii:integer;
begin
 setcolor(c);
 if c=0 then
 begin
 for i:=1 to star[1] do
 if lpix^[i+1]^.c>10 then
 begin
  setcolor(0);
  line(r(lrx)+r(cos(lpix^[i]^.l+lal)*lpix^[i]^.rl{+lx}),my-r(lry+sin(lpix^[i]^.l+lal)*lpix^[i]^.rl),
  r(lrx+cos(lpix^[i+1]^.l+lal)*lpix^[i+1]^.rl{+lx}),my-r(lry+sin(lpix^[i+1]^.l+lal)*lpix^[i+1]^.rl));
 end;
 for j:=2 to 5 do
 if rkey[j] then
 for i:=star[j-1] to star[j] do
 if lpix^[i+1]^.c>10 then
 begin
  setcolor(0);
  line(r(lrx)+r(cos(lpix^[i]^.l+lal)*lpix^[i]^.rl{+lx}),my-r(lry+sin(lpix^[i]^.l+lal)*lpix^[i]^.rl),
  r(lrx+cos(lpix^[i+1]^.l+lal)*lpix^[i+1]^.rl{+lx}),my-r(lry+sin(lpix^[i+1]^.l+lal)*lpix^[i+1]^.rl));
 end;
 end
 else
 begin
 if lastmove then exit;
 for i:=1 to star[1] do
 if pix^[i+1]^.c>10 then
 begin
  if c<>0 then setcolor(pix^[i+1]^.c);
  line(r(x)+r(cos(pix^[i]^.l+lx)*pix^[i]^.rl{+lx}),my-r(y+sin(pix^[i]^.l+lx)*pix^[i]^.rl),
  r(x+cos(pix^[i+1]^.l+lx)*pix^[i+1]^.rl{+lx}),my-r(y+sin(pix^[i+1]^.l+lx)*pix^[i+1]^.rl));
 end;
 if (hod mod 1) =0 then
 for i:=r(hit) to r(ehit/3) do
{ putpixel(r(x-cos(lx)*rad*0.7)+random(10)-5,my-r(y-sin(lx)*rad*0.7)+random(10)-5,random(15)+230);}
 begin
   for ii:=1 to maxfog+1 do if fog[ii].hit=0 then break;
   if ii<>(maxfog+1) then fog[ii].init(r(x-cos(lx)*rad*0.7),r(y-sin(lx)*rad*0.7),abs(r(x-rx))+10,abs(r(y-ry))+10);
 end;
 for j:=2 to 5 do
 if lkey[j] then
 for i:=star[j-1] to star[j] do
 if pix^[i+1]^.c>10 then
 begin
  if c<>0 then setcolor(pix^[i+1]^.c);
  line(r(x)+r(cos(pix^[i]^.l+lx)*pix^[i]^.rl{+lx}),my-r(y+sin(pix^[i]^.l+lx)*pix^[i]^.rl),
  r(x+cos(pix^[i+1]^.l+lx)*pix^[i+1]^.rl{+lx}),my-r(y+sin(pix^[i+1]^.l+lx)*pix^[i+1]^.rl));
 end;
end;
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
 lpix:=new(ppixel);
 for i:=0 to maxpix do new(pix^[i]);
 for i:=0 to maxpix do new(lpix^[i]);
 for i:=0 to maxpix do new(epix^[i]);
 while not eof(ff) do
  begin
   inc(n);
   blockread(ff,j,1);
  if (pix^[n]<>nil) then new(pix^[n+1]);
  if epix^[n]<>nil then new(epix^[n+1]);
  if lpix^[n]<>nil then new(lpix^[n+1]);
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
procedure face;
var i,j:integer;
    sss,sss2:string;
    fps:longint;
    ff:file;
const c:record  x,y:integer; end=(x:25;y:25);
begin
  gettime(hh2,mm2,ss2,ss200);
  barr(mx div 2-30,40,mx div 2+50,60,0);
  fps:=hod div((hh2-hh)*3600+(mm2-mm)*60+(ss2-ss+1));
  sss2:=st(fps)+' fps';
  setcolor(255);outtextxy(mx div 2-textwidth (sss2)div 2,50,sss2);
  if length(st(r(hod mod 30)))=1 then sss:=st((hod div (30*60)))+':'+st(((hod div 30))mod 60)+':'+'0'+st(r(hod mod 30))
  else sss:=st((hod div (30*60)))+':'+st((hod div 30)mod 60)+':'+st(r(hod mod 30));
  setcolor(255);outtextxy(mx div 2-textwidth (sss)div 2,40,sss);
  setcolor(250);
  barr(c.x-25,c.x-25,c.x+25,c.x+25,0);barr(mx-c.x-25,c.x-25,mx-c.x+25,c.x+25,0);
  circle(c.x,c.y,25);circle(mx-c.x,c.y,25);
  line(c.x,c.y,r(c.x+cos(s[2].hit/s[2].ehit*pi+pi)*23),r(c.y+sin(s[2].hit/s[2].ehit*pi+pi)*20));
  line(mx-c.x,c.y,mx-r(c.x+cos(s[1].hit/s[1].ehit*pi+pi)*23),r(c.y+sin(s[1].hit/s[1].ehit*pi+pi)*20));
  outtextxy(c.x+1-textwidth(st(r(s[2].hit)))div 2,c.y+2,st(r(s[2].hit)));
  outtextxy(mx-c.x+1-textwidth(st(r(s[1].hit)))div 2,c.y+2,st(r(s[1].hit)));
  barr(100,10,130,20,0);outtextxy(100,10,st(s[2].nal));
  barr(mx-130,10,mx-100,20,0);outtextxy(mx-130,10,st(s[1].nal));
  for i:=0 to 31 do
    for j:=0 to 31 do
      putpixel(i+60,j+10,weapon[s[2].acm]^[29-j,i]);
  for i:=0 to 31 do
    for j:=0 to 31 do
      putpixel(mx-i-60,j+10,weapon[s[1].acm]^[29-j,i]);
  barr(60,40,90,60,0);barr(mx-60,40,mx-90,60,0);
  outtextxy(70,45,st(s[2].ammo[s[2].acm]));
  outtextxy(mx-80,45,st(s[1].ammo[s[1].acm]));
  barr((mx div 2)-30,5,(mx div 2)+30,35,0);
  settextstyle(7,0,1);
  setcolor(100);
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
  setcolor(240);
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
       s[l].move(false); s[m].move(false);
       j:=0;
       while (sqrt(sqr(s[l].x-s[m].x)+sqr(s[l].y-s[m].y))<(s[l].rad+s[m].rad)*0.7)and(j<100) do
       begin
         inc(j);
         s[l].move(false);
         s[m].move(false);
       end;
    end;
  end;
end;
procedure init;
begin
  for i:=1 to 10 do
  begin
    new(weapon[i]);
    assign(ff,filen[i]);
    reset(ff,1);
    seek(ff,1077);
{$i-}    blockread(ff,weapon[i]^,32*32); {$i+}
    if ioresult=0 then;
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
  if lp-l>pi then l:=l+2*pi else
  if l-lp>pi then lp:=lp+2*pi;
  if (l>5)or(lp<1)then lp:=lp+pi*2;
  if (lp>5)or(l<1)then l:=l+pi*2;
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
  if (not s[j].killed)and(abs(l-lp)<0.25) then
  key[10]:=true else key[10]:=false;
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
    ff:file;
    sss:string;
    b:byte;
begin
  readship:='first.shp';
  i:=0;
  findfirst('*.shp',anyfile,ss);
  while doserror=0 do
  begin
   inc(i);
   men[i]:=ss.name;
   assign(ff,ss.name); reset(ff,1);
   seek(ff,9); blockread(ff,b,1); seek(ff,9);blockread(ff,sss,b+1); close(ff);
   men[i]:=ss.name+'   '+sss;
   findnext(ss);
  end;
  menu(i,15,0);
  readship:=men[v];
end;
procedure win(z1,z2,z3,z4,z5,z6:integer; name:string);
var i:integer;
begin
 i:=random(maxsb)+1;
 play(buf[i],sbs[i]-100,11050);
 iva.win(z1,z2,z3,z4,z5,z6,name);
end;
procedure help;
var f:file of char;
    c:char;
begin
  assign(f,'readme.txt');
{$i-}  reset(f);{$i+}
   if ioresult<>0 then
   begin
     writeln('Файл помощи "ReadMe.Txt" не найден ! Press any key...');
     repa;
     exit;
   end;
  repeat
    read(f,c); write(c); if not keypressed then delay(1000+random(2000));
    if not keypressed then if c=#13 then  begin play(buf[2],sbs[2]-100,11050); delay(6000); end
    else play(buf[3],sbs[3]-100,11050);
  until eof(f);
 close(f);
 readkey;
end;
procedure shipmenu;
const once:array[1..5]of string[20]=('первого','второго','третьего','четвертого','пятого');
lABEL next;
begin
 repeat
    win(30,7,50,15,14,1,'Spase War');
    print(30,6,14,1,'╔════ Space War: ═══╗');
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
        print(5,11,14,1,'Лазер');print(20,11,14,1,'R.Shift'); print(40,11,14,1,'CapsLock');
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
{                 win(1,1,80,25,15,1,'Установки Игрока');}
                 win(10,12,70,15,15,1,'Имя игрока');
                 write('Имя: '); readln(names[v2-1]);
                 win(37,12,43,15,15,1,'Кто');
                 men[1]:='Игрок';
                 men[2]:='Комп ';
                 menu(2,15,1);
                 if v=1 then comps[v2-1]:=false else comps[v2-1]:=true;
                 for i:=1 to 5 do men[i]:='Атакует '+once[i]+' ';
                 win(30,11,50,17,15,1,'Кого');
                 menu(5,14,1);
                 win(1,1,80,25,15,0,'Выберите корабль');
                 atacs[v2-1]:=v;
                 ships[v2-1]:=readship;
              end;
         else break
         end
       until false;
     6:begin
        win(2,2,78,23,14,0,'Помощь');
        help;
        readkey;
       end;
     4:repeat
        win(28,9,52,18,15,1,'Опции');
        men[1]:='Разрешение Экрана';
        men[2]:='Снег';
        men[3]:='Скорость';
        men[4]:='Таран';
        men[5]:='Гравитация';
        men[6]:='Auto repair';
        men[7]:='Кол.Звезд';
        men[8]:='Кол.Парашут.';
        t2:=v2;
        menu(8,15,1);
        v2:=v;
        case v2 of
         3:begin
             win(10,13,70,16,14,1,'Скорость');
             write('Введите умножение скорости (0.1-10) : '); readln(umn);
           end;
         7:begin
             win(10,13,70,16,14,1,'Количество звезд');
             write('Введите rоличество звезд (0-5) : '); readln(maxz);
           end;
         8:begin
             win(10,13,70,16,14,1,'Количество парашутистов');
             write('Введите rоличество парашутистов (0-5) : '); readln(colc);
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
            win(35,10,45,16,14,1,'РЭ');
            for i:=1 to 5 do men[i]:=svg[i];
            menu(5,14,1);
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
            win(33,10,47,14,14,1,'Гравитация');
            men[1]:=           'Есть';
            men[2]:=           'Нет';
            men[3]:=           'В центре';
            menu(3,14,1);
            case v of
             1: levtip:=1;
             2: levtip:=6;
             3: levtip:=2;
            end;
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
    if not s[i].lastmove then begin s[i].lastmove:=true; continue;  end;
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
taranb:=true;levtip:=1;  umn:=1; colc:=1; maxz:=2;
  avtor:=false{true};  game:=false; fpps:=40; {las:=false;}
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
procedure draw0;
begin
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to maxstar do star[i].draw(0);
    for i:=1 to maxz do z[i].draw(0);
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to maxs do s[i].draw(0);
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to maxp do pul[i].draw(0);
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to maxb do b[i].draw(0);
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to colc do c[i].draw(0);
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to maxi do is[i]^.draw(0);
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to maxlas do las[i].draw(0);
end;
procedure move;
begin
    for i:=1 to maxlas do las[i].move;
    for i:=1 to maxfog do fog[i].move;
    for i:=1 to maxi do is[i]^.move;
    for i:=1 to maxs do if s[i].com then ai(i);
    for i:=1 to maxs do begin work:=i; s[i].move(true); end;
    for i:=1 to maxz do z[i].move;
    for i:=1 to maxp do pul[i].move;
    for i:=1 to colc do c[i].move;
    if snow then if random(level)=0 then initp(1);
    for i:=1 to maxb do b[i].move;
    for i:=1 to maxs do if s[i].lx>pi*2 then s[i].lx:=s[i].lx-pi*2;
    for i:=1 to maxs do if s[i].lx<0 then s[i].lx:=s[i].lx+pi*2;
    if taranb then taran;
end;
procedure draw;
begin
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to maxstar do star[i].draw(1);
    for i:=1 to maxs do s[i].draw(9);
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to maxz do z[i].draw(1);
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to maxp do pul[i].draw(245);
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to maxb do b[i].draw(5);
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to colc do c[i].draw(50);
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to maxi do is[i]^.draw(5);
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to maxfog do fog[i].draw;
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    for i:=1 to maxlas do las[i].draw(110);
end;
procedure retrace; assembler;
asm
        mov  dx,3dah;
@vert1: in   al,dx;
        test al,8;
        jz   @vert1
@vert2: in   al,dx;
        test al,8;
        jnz  @vert2;
end;
procedure legal;
var ff:file;
    buf:array[0..7]of byte;
begin
  assign(ff,'user.dat');
  reset(ff,1);
  blockread(ff,buf,8);
  close(ff);
  j:=0;
  for i:=0 to 7 do if buf[i]<>mem[$f000:$fff5+i] then begin writeln('illegal copy'); i:=1 div j; halt;end;
end;
BEGIN { ******************** Начало программы *********************** }
 legal;
 prep;
repeat
  initsb;
  speakeron;
  for i:=1 to maxsb do sbs[i]:=fsize(sb[i]);
  for i:=1 to maxsb do getmem(buf[i],sbs[i]);
  for i:=1 to maxsb do loadsb(sb[i],buf[i],sbs[i],0);
  shipmenu;
  init;
  initsvga(0,svgmode-1); mx:=getmaxx;my:=getmaxy;
  setactivepage(0);barr(0,0,mx,my,0);
  setactivepage(1);barr(0,0,mx,my,0);
  maxs:=cj;
  for i:=1 to maxs do
  begin
   s[i].load(ships[i],comps[i],atacs[i]);
   s[i].init(s[i].erad+(mx)/maxs*(i),pol+s[i].erad);
  end;
  gettime(hh,mm,ss,s100);
  game:=true;endg:=false;
  for i:=0 to mapx+1 do
     for j:=0 to mapy+1 do  mp[i,j].tip:=0;
  hod:=0;
  for i:=10 to maxstar do star[i].init(random(255),random(255),random(15)+230);
  star[1].init(100,100,255); star[2].init(105,120,250); star[3].init(80,115,245);
  star[4].init(88,130,250); star[5].init(60,113,250); star[6].init(50,111,250);
  star[7].init(35,130,255);
  repeat
    inc(hod);
    for i:=1 to maxc do if c[i].tip=0 then begin c[i].hit:=1;c[i].tip:=1; c[i].y:=my; c[i].x:=random(mx);c[i].rad:=10; end;
    if keypressed then readkey;
    for i:=1 to maxz do if z[i].tip=0 then z[i].init(random(mx),random(my),random(15));
    draw0;
    move;
    if keypressed then readkey;
{    sky;}
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    draw;
    setactivepage((hod) mod 2); setvisualpage(((hod+1) mod 2));
    face;
    setactivepage((hod+1) mod 2); setvisualpage(((hod) mod 2));
    killer;
    retrace;
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