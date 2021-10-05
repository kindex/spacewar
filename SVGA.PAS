Unit Svga;
Interface
Uses Graph;
Var Error,I,Gd,Gm:Integer;
var ff:file;
    buf:array[0..256*4]of byte;
CONST AutoMode = 127;
Procedure InitSvga(D,M:Byte);
Procedure ModeInfo;
Implementation
Procedure ModeInfo;
Var MaxX,MaxY,MaxC:Word;
    MaxXS,MaxYS,MaxCS:String;
Begin
OutText(GetDriverName);
MaxX:=GetMaxX+1;
MaxY:=GetMaxY+1;
MaxC:=GetMaxColor+1;
Str(MaxX,MaxXS);
Str(MaxY,MaxYS);
Str(Maxc,MaxCS);
SetColor(2);
OutTextXY(1,1,'XMax-'+MaxXS);
OutTextXY(1,10,'YMax-'+MaxYS);
OutTextXY(1,20,'ColorMax-'+MaxCS);
End;
Function BGI256AutoDetect:integer; FAR;
          begin
            BGI256AutoDetect := AutoMode; {return max mode if good}
          end;

Procedure InitSvga(D,M:Byte);
          Begin
          If D=1 Then
            GD := InstallUserDriver('svga16m',nil)
             Else
            GD := InstallUserDriver('svga256m',nil);
            Gm := M;
            InitGraph(GD,Gm,'');  {GM is set by autodetect}
            Error := GraphResult;
            If Error <> 0 then
            Begin
              Writeln(Error,' Error: Could not initialize BGI driver');
              Writeln(GraphErrorMsg(Error));
              Exit;
            End;
  assign(ff,'pal8.bmp');
  reset(ff,1);
  seek(ff,54);
  blockread(ff,buf,256*4);
  close(ff);
  port[$3c8]:=0;
  for i:=0 to 255 do
  begin
(*r*)  port[$3c9]:=buf[(i*4)+2] div 4;
(*g*)  port[$3c9]:=buf[(i*4)+1] div 4;
(*b*)  port[$3c9]:=buf[(i*4)+0] div 4;
  end;

end;
end.