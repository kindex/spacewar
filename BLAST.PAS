unit blast;
interface
var irq,irqmask,base,sbreset,writestatus,writedata,dataavail,readdata,freq:word;
    oldvec:pointer;
    played,nobl:boolean;
    i,j,softint:integer;
    bl,s3:string;

procedure writeDSP(value:byte);
procedure play(sound:pointer; size:word; freq:word);
procedure initsb;
function speakerON:byte;
function speakerOFF:byte;
procedure closesb;
procedure loadsb(name:string; var buf:pointer; size:word; n:longint);
function fsize(name:string):longint;

implementation
uses crt,dos;
function fsize(name:string):longint;
var filename:string;
var ff:file;
begin
  filename:=name;
  if pos('.',filename)=0 then filename:=filename+'.wav';
  assign(ff,filename);
  system.reset(ff,1); fsize:=filesize(ff); close(ff);
end;
procedure loadsb(name:string;var  buf:pointer; size:word; n:longint);
var filename:string;
    ff:file;
begin
  if nobl then exit;
  filename:=name;
  if pos('.',filename)=0 then filename:=filename+'.wav';
  assign(ff,filename);
  system.reset(ff,1);
  seek(ff,n);
  blockread(ff,buf^,size);
  close(ff);
end;
procedure closesb;
begin
  if nobl then exit;
  setintvec(softint,oldvec);
  port[$21]:=port[$21]or irqmask;
  speakeroff;
end;
{$F+}
procedure sbhandler;interrupt;
var b:byte;
begin
  b:=port[dataavail];
  played:=true;
  port[$20]:=$20;
end;
{$F-}
function readDSP:byte;
begin
  if nobl then exit;
   while port[dataavail]and $80=0 do;
   readdsp:=port[readdata];
end;
procedure dmacontinue;
begin
  if nobl then exit;
  writedsp($d4);
end;
procedure dmastop;
begin
  if nobl then exit;
  writedsp($d0);
end;
function readADC:byte;
begin
  if nobl then exit;
  writedsp($20);
  readADC:=readDSP;
end;
procedure writeDAC(level:byte);
begin
  if nobl then exit;
  writedsp($10);
  writedsp(level);
end;
function speakerON:byte;
begin
  if nobl then exit;
  writedsp($d1);
end;
function speakerOFF:byte;
begin
  if nobl then exit;
  writedsp($d3);
end;
function resetDSP:boolean;
begin
  if nobl then exit;
 port[sbreset]:=1; delay(10);
 port[sbreset]:=0; delay(10);
 if (port[dataavail]and $80=$80)and (port[readdata]=$aa)then resetdsp:=true
 else resetdsp:=false
end;
procedure initsb;
begin
  bl:=getenv('Blaster'); writeln(bl);
  s3:=copy(bl,pos('A',bl)+1,3);
  val('$'+s3,base,j);
  writeln('Base: ',base);
  sbreset:=base+$06;
  writestatus:=base+$0c;
  writedata:=base+$0c;
  dataavail:=base+$0e;
  readdata:=base+$0a;
  irq:=5;
  port[sbreset]:=1;delay(10);
  port[sbreset]:=0;delay(10);
  if((port[dataavail]and $80)=$80)and(port[readdata]=$aa)then
  begin
    writeln('Init SB');
    writeDSP($d1); nobl:=false;
  end
  else
  begin
     writeln('Not init SB');
     nobl:=true{  halt(1)};
  end;
  writeln('Reset DSP'); resetdsp;
  softint:=irq+$68; getintvec(softint,oldvec); setintvec(softint,addr(sbhandler));
  irqmask:=1 shl (irq mod 8); port[$21]:=port[$21]and not irqmask;
end;
procedure play(sound:pointer; size:word; freq:word);
var time,page,offset:word;
begin
  if nobl then exit;
  played:=false;
  size:=size-1;
  offset:=seg(sound^)shl 4+ ofs(sound^);
  page:=(seg(sound^)+ofs(sound^)shr 4)shr 12;
  port[$0a]:=5;
  port[$0c]:=0;
  port[$0b]:=$49;
  port[$02]:=lo(offset);
  port[$02]:=hi(offset);
  port[$83]:=page;
  port[$03]:=lo(size);
  port[$03]:=hi(size);
  port[$0a]:=1;
  time:=256-1000000 div freq;
  writedsp($40);
  writedsp(time);
  writedsp($14);
  writedsp(lo(size));
  writedsp(hi(size));
end;
procedure writeDSP(value:byte);
begin
  if nobl then exit;
   while (port[writestatus]and $80)<>0 do;
   port[writedata]:=value;
end;

end.