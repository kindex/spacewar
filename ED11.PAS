uses crt,svga,iva,graph,dos,mouse; {16.5.99}
const key:array[1..5]of string=('Body','Up','Down','Left','Right');
var ff:file;
    p:pointer;
    pix:array[0..200]of record
                         rl,l:real;
                         c:byte;
                        end;
   i,j,n,col,o:byte;
   ix,iy,jx,jy,k,maxpix:integer;
   name:string[79];
   rrr:array[1..9]of char;
   mt,man,hit,rad,taran,armor:real;
   roc:byte;
   s:word;
function input(x,y:integer):real;
var i,j,ix,iy,p:integer;
    n:string;
    t:real;
    c:char;
begin
  n:='';
 repeat
  repeat
    c:=readkey;
    if c in ['1','2','3','4','5','6','7','8','9','0','.'] then n:=n+c;
    barr(x,y,x+100,y+30,200);
    setcolor(250);outtextxy(x,y,n);
  until c=#13;
  val(n,t,p);
 until p=0;
 input:=t;
end;
procedure help(max:integer);
var i,x,y:integer;
    ff:text;
    m:string;
begin
  barr(0,0,640,480,100);
  setcolor(0); y:=1;
  assign(ff,'edit.hlp');
  {$i-}reset(ff); {$i+}
  if ioresult=0then
  begin
    while not eof(ff) do
    begin
      readln(ff,m);
      inc(y);
      outtextxy(10,y*30,m);
    end;
    close(ff);
  end
  else outtextxy(100,100,'File edit.hlp not found');
  outtextxy(200,450,'Pres eny key');
  repa;
  barr(0,0,640,480,0);
  for i:=1 to max do
  begin
    setcolor(pix[i].c);
    line(320+r(cos(pix[i].l)*pix[i].rl),240+r(sin(pix[i].l)*pix[i].rl),
     320+r(cos(pix[i-1].l)*pix[i-1].rl),240+r(sin(pix[i-1].l)*pix[i-1].rl));
  end;
end;
procedure quit;
begin
   gotoxy(1,22);
   writeln('The Space Explorer Ship Editor 1.0');
   writeln('Copyright (c) Ivanov Andrey 17.5.1999');
   writeln('Free ware !');
   freemem(p,s);
   writeln('Ok');
   halt;
end;
begin
  write('Input name (enter for new): ');readln(name);
  if name<>'' then
  begin
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
 blockread(ff,name,256);
 blockread(ff,mt,6);
 blockread(ff,man,6);
 blockread(ff,hit,6);
 blockread(ff,rad,6);
 blockread(ff,taran,6);
 blockread(ff,armor,6);
 blockread(ff,roc,1);
 blockread(ff,maxpix,1);
 k:=1;
 while not eof(ff) do
  begin
   inc(n);
   blockread(ff,j,1);
   pix[n].l:=0.5*pi+(1*pi-(j/20+pi/2));
   blockread(ff,j,1);
   pix[n].rl:=j;
   blockread(ff,j,1);
   pix[n].c:=j;
   if (pix[n].c=1)then begin inc(o);dec(n);end;
  end;
  maxpix:=n;
  close(ff);
  i:=n;
  end
  else
  begin
    mt:=0.15; man:=0.1; hit:=111; roc:=3;  taran:=1; armor:=1;
    rad:=5;
    i:=0;o:=1;
    maxpix:=0;
  end;
  initsvga(0,3);
  settextstyle(0,0,2);
  setcolor(120);
  for i:=10 downto 1 do begin setcolor(i*3+40);  line(1,1,i div 2+i mod 2+10,25-i div 2); end;
  for i:=10 downto 1 do begin setcolor(40+i*3);  line(1,1,20-i div 2        ,20);end;
  setcolor(0);
  setfillstyle(1,0);
  sector(17,23,0,360,6,4);
  s:=imagesize(1,1,32,32);
  getmem(p,s);
  getimage(1,1,32,32,p^);
  barr(1,1,32,32,0);
  pix[0].l:=0;
  pix[0].rl:=0;
  setcolor(40);
  line(320,0,320,480);
  line(0,240,640,240);
  line(640,0,640,600);
  line(0,480,800,480);
  for k:=1 to 255*2 do begin setcolor(k div 2); line(640,k,800,k);end;
  col:=250;
  putimage(ix,iy,p^,xorput);
  i:=maxpix;
  for i:=1 to maxpix do
  begin
    setcolor(pix[i].c);
    line(320+r(cos(pix[i].l)*pix[i].rl),240+r(sin(pix[i].l)*pix[i].rl),
     320+r(cos(pix[i-1].l)*pix[i-1].rl),240+r(sin(pix[i-1].l)*pix[i-1].rl));
  end;
  repeat
    barr(0,481,640,600,200);
    setcolor(255);
    outtextxy(10,500,'Taran: '+st(r(taran*100)));
    outtextxy(10,530,'Armor: '+st(r(armor*100)));
    outtextxy(10,560,'Rad  : '+st(r(rad)));
    outtextxy(210,500,'Hit : '+st(r(hit)));
    outtextxy(210,530,'Mt  : '+st(r(mt*100)));
    outtextxy(210,560,'Man : '+st(r(man*100)));
    outtextxy(410,560,'Roc : '+st(r(Roc)));
    outtextxy(410,500,'< Next > '+key[o]);
    outtextxy(410,530,'Help');
    barr(640,550,800,600,col); setcolor(240);
    circle(320,240,r(rad*5));
    repeat
      repeat
       jx:=x; jy:=y;
      until (jx<>ix)or(jy<>iy)or(keypressed)or(push)or(push2);
       putimage(ix,iy,p^,xorput);
       putimage(jx,jy,p^,xorput);
       ix:=jx; iy:=jy;
    until push or keypressed or push2;
   if mo(10,500,210,530) then taran:=input(10,500);
   if mo(10,530,210,560) then armor:=input(10,530);
   if mo(10,560,210,590) then rad:=input(10,560);
   if mo(210,500,410,530) then hit:=input(210,500);
   if mo(210,530,410,560) then mt:=input(210,530);
   if mo(210,560,410,590) then man:=input(210,560);
   if mo(410,560,610,590) then roc:=r(input(410,560));
   if mo(410,530,610,560) then help(i);
   if mo(410,500,610,530) then
   begin
    inc(i); inc(o);    pix[i].l:=1;   pix[i].rl:=1;   pix[i].c:=1; if o>5 then o:=1;
    repeat until not push;
   end;
   if mo(640,0,800,510) then col:=y div 2;
   if mo(1,1,640,480) then
   if push then
   begin
    inc(i);
    pix[i].rl:=sqrt((320-mouse.x)*(320-mouse.x)+(240-mouse.y)*(240-mouse.y));
    if (pix[i].rl/5)>(rad) then
    begin
     setcolor(0);
     circle(320,240,r(rad*5));
     rad:=pix[i].rl/5;
    end;
    if (x>320)and(y>240)then pix[i].l:=pi-arctan((mouse.x-320)/(mouse.y-240))-0.5*pi;
    if (x<320)and(y<240)then pix[i].l:=pi-arctan((320-mouse.x)/(240-mouse.y))+0.5*pi;
    if (x>320)and(y<240)then pix[i].l:=1.5*pi+arctan((mouse.x-320)/(240-mouse.y));
    if (x<320)and(y>240)then pix[i].l:=1.5*pi+arctan((320-mouse.x)/(mouse.y-240))+pi;
    pix[i].c:=col;
    setcolor(col);
    line(320+r(cos(pix[i].l)*pix[i].rl),240+r(sin(pix[i].l)*pix[i].rl),
     320+r(cos(pix[i-1].l)*pix[i-1].rl),240+r(sin(pix[i-1].l)*pix[i-1].rl));
  repeat until not push;
  end;
  if push2 then
  begin
    setcolor(0);
    line(320+r(cos(pix[i].l)*pix[i].rl),240+r(sin(pix[i].l)*pix[i].rl),
     320+r(cos(pix[i-1].l)*pix[i-1].rl),240+r(sin(pix[i-1].l)*pix[i-1].rl));
    if i>1 then dec(i);
    repeat until not push2;
  end;
  if keypressed then if readkey=#27 then break;
 until (i>100);
  closegraph;
  write('File name (enter for exit): ');readln(name);
  if name='' then quit;
  if pos('.',name)=0 then name:=name+'.shp';
  assign(ff,name);
  rewrite(ff,1);
  rrr:='SpaceShip';
  blockwrite(ff,rrr,9);
  write('Name: '); readln(name);
  blockwrite(ff,name,256);
  blockwrite(ff,mt,6);
  blockwrite(ff,man,6);
  blockwrite(ff,hit,6);
  blockwrite(ff,rad,6);
  blockwrite(ff,taran,6);
  blockwrite(ff,armor,6);
  blockwrite(ff,roc,1);
  n:=i-1;
  blockwrite(ff,n,1);
  for i:=1 to n do
  begin
   j:=r(pix[i].l*20);
   blockwrite(ff,j,1);
   j:=r(pix[i].rl);
   blockwrite(ff,j,1);
   j:=pix[i].c;
   blockwrite(ff,j,1);
  end;
  close(ff);
  writeln('Ok');
  quit;
end.
