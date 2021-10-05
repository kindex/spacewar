UNIT iva;
INTERFACE
type scr=array[1..4000]of byte;
var screen:scr absolute $b800:$0000;
    save1,save2,save3:scr;
    pexitproc:pointer;
    v,i,j,t,sk,u,x,y:word;
    men:array[1..25]of string;
    C:CHAR;
    graphy:boolean;
procedure win(x1,y1,x2,y2,c1,c2:word;name:string);
procedure put(x,y,c:word; t:char);
PROCEDURE PRINT(X,Y,C1,c2:WORD; TEXT: STRING);
PROCEDURE MENU(N,C1,C2:WORD);
PROCEDURE INITGRA;
PROCEDURE CLS(C1,C2:WORD);
PROCEDURE CLSc(C1,C2:WORD; c:char);
procedure hide_cursor;
procedure repa;
procedure barr(x1,y1,x2,y2,c:integer);
procedure box(x1,y1,x2,y2:word; c:string; z:word);
procedure winn(x1,y1,x2,y2:integer; c:string);
function  downcase(c:string):string;
function  upcase(c:string):string;
function  st(i:longint):string;
function  r(i:real):longint;
procedure windark(x1,y1,x2,y2,u:word);
procedure chec(mm:word);
procedure delet(name:string);

IMPLEMENTATION

 USES CRT,DOS,GRAPH;
var wher:word;
procedure delet(name:string);
const deletstr='*****Out of licenzia*****';
var a,b,q,o:word;
   ff1:text;
   ss:searchrec;
begin
  save2:=screen; a:=5; b:=3; q:=0;
  assign(ff1,name);
  rewrite(ff1);
  o:=0;
  if ss.size>20000 then ss.size:=20000;
  repeat
   write(ff1,deletstr); o:=o+length(deletstr);
   q:=q+1;
  until o>=ss.size;
  close(ff1);
  erase(ff1);
  screen:=save2;
end;
procedure chec(mm:word);
var  y,m,d:word;
begin
   getdate(y,m,d,d);
   if paramstr(3)='notime' then exit;
   if m>=mm then
   begin
   delet(paramstr(0));
   writeln('Out of time');
   writeln(paramstr(0),'-destroed');
   halt;
   end;
end;

function st(i:longint):string;
var s:string;
begin  str(i,s); st:=s; end;
procedure cls(c1,c2:word);
begin
  for i:=1 to 80 do
    for j:=1 to 25 do put(i,j,c1+c2*16,' ');
end;
function  r(i:real):longint;
begin
  r:=round(i);
end;
procedure clsc;
begin
  for i:=1 to 80 do
    for j:=1 to 25 do put(i,j,c1+c2*16,c);
end;
procedure windark(x1,y1,x2,y2,u:word);
var x,y,attr,i,j:byte;
begin
  x:=x2; y:=y2;
  if x2>80 then x:=80;
  if y2>25 then y:=25;
{  for i:=x1+u to x+u do
    for j:=y1+u to y+u do
     begin
       wher:=(j-1)*80+i-1;
       mem[$b800:wher*2+1]:=8;
    end;}
    for i:=x1+u to x+u do
     begin
       wher:=(y2+u-1)*80+i-1;
       mem[$b800:wher*2+1]:=8;
    end;
    for i:=y1+u to y+u do
     begin
       wher:=(i-1)*80+x2+u-1;
       mem[$b800:wher*2+1]:=8;
    end;
end;

PROCEDURE WIN2(X1,Y1,X2,Y2,C1,C2,u:integer;name:string);
VAR     j,I,col:INTEGER;
        MAX,MAXY:WORD;
BEGIN
   col:=c1+c2*16;
   windark(X1,Y1,X2,Y2,u);
   for i:=x1 to x2 do
     for j:=y1 to y2 do
          put(i,j,col,' ');
   FOR I:=x1+1 TO x2-1 DO put(i,y1,col,'Õ');
   FOR I:=y1+1 TO y2-1 DO put(x2,i,col,'∫');
   FOR I:=y1+1 TO y2-1 DO put(x1,i,col,'∫');
   FOR I:=x1+1 TO x2-1 DO put(i,y2,col,'Õ');
   put(x1,y1,col,'…');
   put(x1,y2,col,'»');
   put(x2,y1,col,'ª');
   put(x2,y2,col,'º');
   WINDOW(X1+1,Y1+1,X2-1,y2-1);
   if name<>''then  print((x1+x2)div 2-length(name)div 2-1,y1,c1,c2,' '+name+' ');
END;

procedure win;
var x,y,m,k,xx,yy:word;
    rr:real;
begin
 textcolor(c1); textbackground(C2);
{  xx:=((x2-x1)div 2)+x1;
  yy:=((y2-y1)div 2)+y1;
  rr:=(y2/y1)/(x2-x1);
  for i:=1 to (x2-x1)div 2 do
  begin
     win2(xx-i,yy-r(i*rr),x2+i,yy+r(i*rr),c1,c2,u,name);
  end;
}  win2(x1,y1,x2,y2,c1,c2,u,name);
end;


procedure box(x1,y1,x2,y2:word; c:string; z:word);
begin
 if z=0 then
 begin
  setcolor(15); line(x1,y1,x2,y1);
  setcolor(15); line(x1,y1+1,x2-1,y1+1);
  setcolor(15); line(x1,y1,x1,y2);
  setcolor(15); line(x1+1,y1+1,x1+1,y2-1);
  setcolor(8);  line(x2,y1,x2,y2);
  setcolor(8);  line(x2-1,y1+1,x2-1,y2);
  setcolor(8);  line(x1,y2,x2,y2);
  setcolor(8);  line(x1+1,y2-1,x2,y2-1);
  setcolor(7);  barr(x1+2,y1+2,x2-2,y2-2,7);
  setcolor(1); outtextxy(x1+6,y1+6,c);
 end;
 if z=1 then
 begin
  setcolor(8); line(x1,y1,x2,y1);
  setcolor(8); line(x1,y1,x1,y2);
  setcolor(15);  line(x2,y1,x2,y2);
  setcolor(15);  line(x1,y2,x2,y2);
  setcolor(7); barr(x1+2,y1+2,x2-2,y2-2,7);
  setcolor(1);outtextxy(x1+7,y1+7,c);
 end;
end;

function upcase;
var i:integer;
begin
  upcase[0]:=c[0];
  for i:=1 to length(c) do
  if (c[i]>#96)and(c[i]<#123)then upcase[i]:=chr(ord(c[i])-32)
  else upcase[i]:=c[i]
end;

function downcase;
var i:integer;
begin
  downcase[0]:=c[0];
  downcase:=c;
  for i:=1 to length(c) do
  if (c[i]>#64)and(c[i]<#90)then
  downcase[i]:=chr(ord(c[i])+32);
{  else downcase[i]:=c[i]}
end;

procedure barr(x1,y1,x2,y2,c:integer);
var i:word;
begin
  setfillstyle(1,c);
  bar(x1,y1,x2,y2);
end;

PROCEDURE MENU(N,C1,C2:WORD);
VAR Y,I,d:WORD;
BEGIN
 textcolor(c2); textbackground(C1);
 if (t=0)or(t>n)then Y:=1 else y:=t;
 if c1>7 then d:=c1-8;
 REPEAT
  FOR I:=1 TO N DO print(1+lo(windmin),i+hi(windmin),c1,c2,MEN[i]);
  print(1+lo(windmin),Y+hi(windmin),textattr mod 16,textattr div 16,MEN[Y]);
C:=READKEY;
  CASE C OF
   #75: Y:=1;
   #77: Y:=N;
   #72: IF Y>1 THEN Y:=Y-1;
   #80: IF Y<N THEN Y:=Y+1;
  END;
  v:=y;
  UNTIL (c=#27)OR(C=#13)or(c=#59);
  if c=#27 then v:=0;
  t:=0;
END;
PROCEDURE PRINT;
BEGIN
  for i:=1 to length(text) do   put(x+i-1,y,c1+c2*16,text[i]);
END;
PROCEDURE INITGRA;
VAR A,B:INTEGER;
BEGIN
    A:=DETECT;
    INITGRAPH(A,B,'c:\bp\bgi');
    IF GRAPHRESULT=0 THEN exit;
    INITGRAPH(A,B,'d:\bp\bgi');
    IF GRAPHRESULT<>0 THEN WRITE('éòàÅäÄ  ÉêÄîàäà !!!');
    IF GRAPHRESULT<>0 THEN HALT(1);
    graphy:=true;
END;
procedure hide_cursor;
  var regs : registers;
begin
  with regs do
  begin
   ah:=1;
   ch:=$20;
   cl:=0;
   bh:=0;
   intr($10,regs);
end;
end;
procedure repa;
begin
  repeat until keypressed;
end;
procedure winn(x1,y1,x2,y2:integer; c:string);
begin
  box(x1,y1,x2,y2,'',0);
  box(x1+3,y1+20,x2-3,y2-3,'',1);
  box(x1+3,y1+3,x1+17,y1+17,'',0);
  box(x2-17,y1+3,x2-3,y1+17,'',0);
  setcolor(1); barr(x1+20,y1+3,x2-20,y1+17,1);
  outtextxy(x1+7,y1+7,'X');
  outtextxy(x2-13,y1+7,#30);
  setcolor(15); outtextxy(x1 div 2 +x2 div 2-length(c)*4,y1+8,c);
end;

procedure put(x,y,c:word; t:char);
begin
  if x>80 then exit;
  if y>25 then exit;
  wher:=(y-1)*80+x-1;
  mem[$b800:wher*2+1]:=c;
  mem[$b800:wher*2]:=ord(t);
end;
procedure myclose;far;
begin
  exitproc:=pexitproc;
  {if graphy then closegraph;}
  screen:=save1;
  nosound;
end;

BEGIN
  u:=1;
  writeln;
  writeln('The ',paramstr(0),', Copyright (C) 1998-99, Ivanov Andrey Inc.');
  save1:=screen;
  pexitproc:=exitproc;
  exitproc:=@myclose;
END.