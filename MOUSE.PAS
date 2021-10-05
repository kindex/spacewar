
Unit Mouse;
Interface
Uses Dos;
Const
        MOUSEinT = $33; {mouse driver interrupt}
  LEFTBUTtoN = 1; {bit 0}
  RIGHTBUTtoN = 2; {bit 1}
  MIDDLEBUTtoN = 4; {bit 2}

  CURSor_LOCATION_CHANGED = 1; {event mask bits}
  LEFT_BUTtoN_PRESSED = 2;
  LEFT_BUTtoN_RELEASED = 4;
  RIGHT_BUTtoN_PRESSED = 8;
  RIGHT_BUTtoN_RELEASED = 16;
  MIDDLE_BUTtoN_PRESSED = 32;
  MIDDLE_BUTtoN_RELEASED = 64;

Type
        mouseType = (twoButton,threeButton,another);
  buttonState = (buttonDown,buttonUp);
  direction = (moveRight,moveLeft,moveUp,moveDown,noMove);
  grCursorType = Record
          xH,yH : Byte; {x,y Hot Point}
    data  : Pointer;  {cursor look Pointer}
  end;

Var
        mouse_present : Boolean;
  mouse_buttons : mouseType;
  eventX,eventY,eventButtons : Word; {any event handler should update}
  eventhappened : Boolean;           {these Vars to use getLastEvent }
  XMotions,YMotions : Word;          {per 8 pixels}
  mouseCursorLevel : Integer;

  {if > 0 mouse cursor is visiable, otherwise not, containes the level
   of showMouseCursor/hideMouseCursor}

Const
        LastMask : Word = 0;
  lastHandler : Pointer = Nil;

  {when changing the interrupt handler temporarily, save BEForE the
   change these to Variables, and restore them when neccessary}

  lastCursor : grCursorType = (
                                                          xH : 0;
                                                    yH : 0;
                                                  data : nil );

  {when changing Graphic cursor temporarily, save these values BEForE
          the change, and restore when neccessary}

Const
        click_Repeat  = 10; { Recommended value For waitForRelease timeOut }

Procedure initMouse; {when replacing mouse mode do that..!}
Procedure show;
Procedure hide;
Function  X : Word;
Function  Y : Word;
function  push:boolean;
function  push2:boolean;
function  mo(x1,y1,x2,y2:integer):boolean;
Function  getButton(Button : Byte) : buttonState;
Function  buttonPressed : Boolean;
Procedure setMouseCursor(x,y : Word);
Function  LastXPress(Button : Byte) : Word;
Function  LastYPress(Button : Byte) : Word;
Function  ButtonPresses(Button : Byte) : Word; {from last last check}
Function  LastXRelease(Button : Byte) : Word;
Function  LastYRelease(Button : Byte) : Word;
Function  ButtonReleases(Button : Byte) : Word; {from last last check}
Procedure mouseBox(left,top,right,bottom : Word); {limit mouse rectangle}
Procedure GraphicMouseCursor(xHotPoint,yHotPoint : Byte; dataofs : Pointer);
Procedure HardwareTextCursor(fromLine,toLine : Byte);
Procedure softwareTextCursor(screenMask,cursorMask : Word);
Function  recentXmovement : direction;
Function  recentYmovement : direction;
Procedure setArrowCursor;
Procedure setWatchCursor;
Procedure setUpArrowCursor;
Procedure setLeftArrowCursor;
Procedure setCheckMarkCursor;
Procedure setPointingHandCursor;
Procedure setDiagonalCrossCursor;
Procedure setRectangularCrossCursor;
Procedure setHourGlassCursor;
Procedure setNewWatchCursor;
Procedure setEventHandler(mask : Word; handler  : Pointer);
Procedure setDefaultHandler(mask : Word);
Procedure enableLightPenEmulation;
Procedure disableLightPenEmulation;
Procedure defineSensetivity(x,y : Word);
Procedure setHideCursorBox(left,top,right,bottom : Word);
Procedure defineDoubleSpeedTreshHold(treshHold : Word);
Procedure disableTreshHold;
Procedure defaultTreshHold;
Procedure setMouseGraph;
Procedure resetMouseGraph;
Procedure waitForRelease(timeOut : Word);
Procedure swapEventHandler(mask : Word; handler : Pointer);
{ return old in lastMask and lastHandler }
Function  getMouseSaveStateSize : Word;
{ get mouse from interrupted Program, and stop it ..}
Procedure interceptMouse;
Procedure restoreMouse;

{**********************}Implementation{*********************}

Const watchData : Array [0..31] of Word =
        ($E007,$C003,$8001,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$8001,$C003,$E007,
         $0,$1FF8,$318C,$6186,$4012,$4022,$4042,$718C,$718C,$4062,$4032,
         $4002,$6186,$318C,$1FF8,$0);
Const arrowData : Array [0..31] of Word =
        ($FFFF,$8FFF,$8FFF,$87FF,$83FF,$81FF,$80FF,$807F,$803F,$801F,$800F,
         $801F,$807F,$887F,$DC3F,$FC3F,
         $0,$0,$2000,$3000,$3800,$3C00,$3E00,$3F00,$3F80,$3FC0,
         $3FE0,$3E00,$3300,$2300,$0180,$0180);
Const UpArrowCursor : Array [0..31] of Word =
         ($f9ff,$f0ff,$e07f,$e07f,$c03f,$c03f,$801f,$801f,
          $f,$f,$f0ff,$f0ff,$f0ff,$f0ff,$f0ff,$f0ff,
          $0,$600,$f00,$f00,$1f80,$1f80,$3fc0,$3fc0,
          $7fe0,$600, $600, $600, $600, $600, $600, $600);
Const  LeftArrowCursor : Array [0..31] of Word
       = ($fe1f,$f01f,$0,   $0,   $0,   $f01f,$fe1f,$ffff,
          $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
          $0,   $c0,  $7c0, $7ffe,$7c0, $c0,  $0,   $0,
          $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0);
Const  CheckMarkCursor : Array [0..31] of Word
       = ($fff0,$ffe0,$ffc0,$ff81,$ff03,$607, $f,   $1f,
          $c03f,$f07f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
          $0,   $6,   $c,   $18,  $30,  $60,  $70c0,$1d80,
          $700, $0,   $0,   $0,   $0,   $0,   $0,   $0);
Const  PointingHandCursor : Array [0..31] of Word
       = ($e1ff,$e1ff,$e1ff,$e1ff,$e1ff,$e000,$e000,$e000,
          $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0,
          $1e00,$1200,$1200,$1200,$1200,$13ff,$1249,$1249,
          $f249,$9001,$9001,$9001,$8001,$8001,$8001,$ffff);
Const  DiagonalcrossCursor : Array [0..31] of Word
       = ($7e0, $180, $0,   $c003,$f00f,$c003,$0,   $180,
          $7e0, $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
          $0,   $700e,$1c38,$660, $3c0, $660, $1c38,$700e,
          $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0);
Const  RectangularCrossCursor : Array [0..31] of Word
       = ($fc3f,$fc3f,$fc3f,$0,$0,   $0,   $fc3f,$fc3f,
          $fc3f,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,
          $0,   $180, $180, $180, $7ffe,$180, $180, $180,
          $0,   $0,   $0,   $0,   $0,   $0,   $0,   $0);
Const  HourglassCursor : Array [0..31] of Word
       = ($0,   $0,   $0,   $0,   $8001,$c003,$e007,$f00f,
          $e007,$c003,$8001,$0,   $0,   $0,   $0,   $ffff,
          $0,   $7ffe,$6006,$300c,$1818,$c30, $660, $3c0,
          $660, $c30, $1998,$33cc,$67e6,$7ffe,$0,   $0);
Const newWatchCursor : Array [0..31] of Word
       = ( $ffff, $c003, $8001, $0, $0, $0, $0, $0, $0,
           $0, $0, $0, $0, $8001, $c003, $ffff, $0, $0,
           $1ff8, $2004, $4992, $4022, $4042, $518a, $4782,
           $4002, $4992, $4002, $2004, $1ff8, $0, $0 );
Const
        mouseGraph : Boolean = False; {assume Text mode upon entry}
Type
        box = Record
          left,top,right,bottom : Word;
  end; {Do not change field order !!!}
Var
  hideBox : box;
  reg : Registers;  {general Registers used}
  grMode,
  grDrv : Integer; {detect Graphic mode if any}
  grCode : Integer;     {return initGraph code in here}
  interceptX,
  interceptY : Word;
Procedure callMouse;
begin
        intr(MOUSEinT,REG);
end; {callMouse}
Procedure initMouse;
Var
        overRideDriver : Boolean; { True if we over-ridden stupid driver hercules b}
begin
    overRideDriver := False;
    if (mouseGraph and (mem[0:$449] = 7)) then begin { assume no mda - hercules}
          mem[0:$449] := 6;
      overRideDriver := True;
    end;
          {trick stupid mouse driver to know we are in Graphic mode}
        With reg do
                                begin
                ax:=0; {detect genius mouse}
          bx:=0; {be sure what mode we get}
          callMouse;
          mouse_present := (ax <> 0); {not an iret..}
          if ((bx and 2) <> 0) then
                                                mouse_buttons := twoButton
          else if ((bx and 3) <> 0)        then
                                                 mouse_buttons := threeButton
          else
                                                mouse_buttons := another; {unknown to us}
        end; {with}
    if (overRideDriver) then
          mem[0:$449] := 7;
          {restore the stupid situation}
       eventX := 0;
       eventButtons := 0;
       eventY := 0;
       eventhappened := False;
       XMotions := 8;
       YMotions := 16;
       mouseCursorLevel := 0; { not visiable, one show to appear }
end; {initMouse}
Procedure show;
begin
        reg.ax:=1; {enable cursor display}
        callMouse;
        inc(mouseCursorLevel);
end; {showMouseCursor}
Procedure hide;
begin
        reg.ax:=2; {disable cursor display}
        callMouse;
        dec(mouseCursorLevel);
end; {hideMouseCursor}
Function X : Word;
begin
        reg.ax := 3;
        callMouse;
        X := reg.cx;
end; {getMouseX}
Function Y : Word;
begin
        reg.ax := 3;
        callMouse;
        Y := reg.dx;
end; {getMouseX}
function mo;
begin
  if (x>x1)and(y>y1)and(x<x2)and(y<y2) then mo:=true
  else mo:=false;
end;
function push:boolean;
begin
  if getbutton(leftbutton)=buttondown then push:=true
  else push:=false;
end;
function push2:boolean;
begin
  if getbutton(rightbutton)=buttondown then push2:=true
  else push2:=false;
end;
Function getButton(Button : Byte) : buttonState;
begin
        reg.ax := 3;
        callMouse;
        if ((reg.bx and Button) <> 0) then
                getButton := buttonDown
                {bit 0 = left, 1 = right, 2 = middle}
        else getButton := buttonUp;
end; {getButton}
Function buttonPressed : Boolean;
begin
        reg.ax := 3;
        callMouse;
         if ((reg.bx and 7) <> 0) then
                buttonPressed := True
        else buttonPressed := False;
end; {buttonPressed}
Procedure setMouseCursor(x,y : Word);
begin
        With reg do begin
                ax := 4;
                cx := x;
                dx := y; {prepare parameters}
                callMouse;
        end; {with}
end; {setMouseCursor}
Function lastXPress(Button : Byte) : Word;
begin
        reg.ax := 5;
        reg.bx := Button;
        callMouse;
        lastXPress := reg.cx;
end; {lastXpress}
Function lastYPress(Button : Byte) : Word;
begin
        reg.ax := 5;
        reg.bx := Button;
        callMouse;
        lastYPress := reg.dx;
end; {lastYpress}
Function buttonPresses(Button : Byte) : Word; {from last check}
begin
        reg.ax := 5;
        reg.bx := Button;
        callMouse;
        buttonPresses := reg.bx;
end; {buttonPresses}
Function lastXRelease(Button : Byte) : Word;
begin
        reg.ax := 6;
        reg.bx := Button;
        callMouse;
        lastXRelease := reg.cx;
end; {lastXRelease}
Function lastYRelease(Button : Byte) : Word;
begin
        reg.ax := 6;
        reg.bx := Button;
        callMouse;
        lastYRelease := reg.dx;
end; {lastYRelease}
Function buttonReleases(Button : Byte) : Word; {from last check}
begin
        reg.ax := 6;
        reg.bx := Button;
        callMouse;
        buttonReleases := reg.bx;
end; {buttonReleases}
Procedure swap(Var a,b : Word);
Var c : Word;
begin
        c := a;
        a := b;
        b := c; {swap a and b}
end; {swap}
Procedure mouseBox(left,top,right,bottom : Word);
begin
        if (left > right) then swap(left,right);
        if (top > bottom) then swap(top,bottom); {make sure they are ordered}
        reg.ax := 7;
        reg.cx := left;
        reg.dx := right;
        callMouse; {set x range}
        reg.ax := 8;
        reg.cx := top;
        reg.dx := bottom;
        callMouse; {set y range}
end; {mouseBox}
Procedure GraphicMouseCursor(xHotPoint,yHotPoint : Byte; dataofs : Pointer);
{define 16*16 cursor mask and screen mask, pointed by data,
        dataofs is Pointer to data of the masks.}
begin
        reg.ax := 9;
        reg.bx := xHotPoint;
        reg.cx := yHotPoint;
        reg.dx := ofs(dataofs^);        {DS:DX point to masks}
        reg.es := seg(dataofs^);
        callMouse;
        lastCursor.xH := xHotPoint;
        lastCursor.yH := yHotPoint;
        lastCursor.data := dataofs;
        {save it in lastCursor, if someone needs to change cursor temporary}
end; {GraphicMouseCursor}
Procedure HardwareTextCursor(fromLine,toLine : Byte);
{set Text cursor to Text, using the scan lines from..to,
(Continued to next message)
--- FreeMail 1.07b
 * origin: Meredith Place BBS * Tucson, AZ * 602-579-0869 * (1:300/15)
<<<>>>
Date: 03-02-93 (20:07)              Number: 14561 of 14567 (Echo)
  to: ROBERT BAKER                  Refer#: NONE
From: STEVE CONNET                    Read: NO
Subj: MOUSE               6/10      Status: PUBLIC MESSAGE
Conf: F-PASCAL (1221)            Read Type: GENERAL (+)

(Continued from previous message)

        same as intr 10 cursor set in bios :
        color scan lines 0..7, monochrome 0..13 }

begin
{        reg.ah:=$10;
        reg.ch:=fromLine;
        reg.cl:=toLine;
}
        reg.ax := 10;
        reg.bx := 1; {hardware Text}
        reg.cx := fromLine;
        reg.dx := toLine;
        callMouse;
end; {hardwareTextCursor}
Procedure softwareTextCursor(screenMask,cursorMask : Word);
{ when in this mode the cursor will be achived by anding the screen Word
        With the screen mask (Attr,Char in high,low order) and
        xoring the cursor mask, ussually used by putting the screen attr
        we want preserved in screen mask (and 0 into screen mask Character
        Byte), and Character + attributes we want to set into cursor mask}
begin
        reg.ax := 10;
        reg.bx := 0;    {software cursor}
        reg.cx := screenMask;
        reg.dx := cursorMask;
        callMouse;
end;
Function recentXmovement : direction;
{from recent call to which direction did we move ?}
Var d : Integer;
begin
        reg.ax := 11;
        callMouse;
        d := reg.cx;
        if (d > 0)
                then recentXmovement := moveRight
        else if (d < 0)
                then recentXmovement := moveLeft
        else recentXmovement := noMove;
end; {recentXmovement}
Function recentYmovement : direction;
{from recent call to which direction did we move ?}
Var
   d : Integer;
begin
        reg.ax := 11;
        callMouse;
        d := reg.dx;
        if (d > 0)
                then recentYmovement := moveDown
        else if (d < 0)
                then recentYmovement := moveUp
        else recentYmovement := noMove;
end; {recentYmovement}
Procedure setWatchCursor;
begin
        GraphicMouseCursor(0,0,@watchData);
end; {setWatchCursor}
Procedure setNewWatchCursor;
begin
   GraphicMouseCursor(0, 0, @newWatchCursor);
end; {setNewWatchCursor}
Procedure setUpArrowCursor;

begin
        GraphicMouseCursor(5, 0, @upArrowCursor);
end; {setUpArrowCursor}
Procedure setLeftArrowCursor;
begin
        GraphicMouseCursor(0, 3, @leftArrowCursor);
end; {setLeftArrowCursor}
Procedure setCheckMarkCursor;
begin
        GraphicMouseCursor(6, 7, @checkMarkCursor);
end; {setCheckMarkCursor}
Procedure setPointingHandCursor;
begin
        GraphicMouseCursor(5, 0, @pointingHandCursor);
end; {setPointingHandCursor}
Procedure setDiagonalCrossCursor;
begin
        GraphicMouseCursor(7, 4, @diagonalCrossCursor);
end; {setDiagonalCrossCursor}
Procedure setRectangularCrossCursor;
begin
        GraphicMouseCursor(7, 4, @rectangularCrossCursor);
end; {setRectangularCrossCursor}
Procedure setHourGlassCursor;
begin
        GraphicMouseCursor(7, 7, @hourGlassCursor);
end; {setHourGlassCursor}
Procedure setArrowCursor;
begin
        GraphicMouseCursor(1,1,@arrowData);
end; {setArrowCursor}
Procedure setEventHandler(mask : Word; handler  : Pointer);
{handler must be a Far interrupt routine }
begin
        reg.ax := 12; {set event handler Function in mouse driver}
        reg.cx := mask;
        reg.es := seg(handler^);
        reg.dx := ofs(handler^);
        callMouse;
        lastMask := mask;
        lastHandler := handler;
end; {set event Handler}
{$F+} Procedure defaultHandler; Assembler; {$F-}
Asm
   push ds; { save TP mouse driver }
   mov ax, SEG @data;
   mov ds, ax; { ds = TP:ds, not the driver's ds }
   mov eventX, cx; { where in the x region did it occur }
   mov eventY, dx;
   mov eventButtons, bx;
   mov eventHappened, 1; { eventHapppened := True }
   pop ds; { restore driver's ds }
   ret;
end;
Function GetLastEvent(Var x,y : Word;
        Var left_button,right_button,middle_button : buttonState) : Boolean;

begin
        getLastEvent := eventhappened; {indicate if any event happened}
        eventhappened := False; {clear to next read/event}
        x := eventX;
        y := eventY;
        if ((eventButtons and LEFTBUTtoN) <> 0) then
                left_button := buttonDown
        else left_button := buttonUp;
        if ((eventButtons and RIGHTBUTtoN) <> 0) then
                right_button := buttonDown
        else right_button := buttonUp;
        if ((eventButtons and MIDDLEBUTtoN) <> 0) then
                middle_button := buttonDown
        else middle_button := buttonUp;
end; {getLastEvent}
Procedure setDefaultHandler;
{get only event mask, and set event handler to defaultHandler}
begin
        setEventHandler(mask,@defaultHandler);
end; {setDefaultHandler}
Procedure enableLightPenEmulation;
begin
        reg.ax := 13;
        callMouse;
end; {enableLightPenEmulation}
Procedure disableLightPenEmulation;
begin
        reg.ax := 14;
        callMouse;
end;  {disableLightPenEmulation}
Procedure defineSensetivity(x,y : Word);
begin
        reg.ax := 15;
        reg.cx := x; {# of mouse motions to horizontal 8 pixels}
        reg.dx := y; {# of mouse motions to vertical 8 pixels}
        callMouse;
        XMotions := x;
        YMotions := y; {update global Unit Variables}
end; {defineSensetivity}
Procedure setHideCursorBox(left,top,right,bottom : Word);
begin
        reg.ax := 16;
        reg.es := seg(HideBox);
        reg.dx := ofs(HideBox);
        HideBox.left := left;
        HideBox.right := right;
        HideBox.top := top;
        HideBox.bottom := bottom;
        callMouse;
end; {setHideCursorBox}
Procedure defineDoubleSpeedTreshHold(treshHold : Word);
begin
        reg.ax := 17;
        reg.dx := treshHold;
        callMouse;
end; {defineDoubleSpeedTreshHold - from what speed to Double mouse movement}
Procedure disableTreshHold;
begin
        defineDoubleSpeedTreshHold($7FFF);
end; {disableTreshHold}
Procedure defaultTreshHold;
begin
        defineDoubleSpeedTreshHold(64);
end; {defaultTreshHold}
Procedure setMouseGraph;
begin
        mouseGraph := True;
end; {setMouseGraph}
Procedure resetMouseGraph;
begin
        mouseGraph := False;
end; {resetMouseGraph}
Procedure waitForRelease;
Var
    sHour, sMinute, sSecond, sSec100 : Word;    { Time at start }
    cHour, cMinute, cSecond, cSec100 : Word;    { Current time  }
    stopSec                          : longInt;
    currentSec                    : longInt;
    Delta                            : longInt;
begin
    getTime(sHour, sMinute, sSecond, sSec100);
    stopSec := (sHour*36000 + sMinute*600 + sSecond*10 + sSec100 + timeOut) mod

                    (24*360000);
    Repeat
           getTime(cHour, cMinute, cSecond, cSec100);
           currentSec := (cHour*36000 + cMinute*600 + cSecond*10 + cSec100);
           Delta := currentSec - stopSec;
    Until (not ButtonPressed) or (Delta >=0) and (Delta < 36000);
end; {waitForRelease}
Procedure swapEventHandler;
begin
   reg.ax := $14;
   reg.cx := mask;
        reg.es := seg(handler^);
        reg.dx := ofs(handler^);
        callMouse;
   lastMask := reg.cx;
   lastHandler := ptr(reg.es,reg.dx);
end; {swapEventHandler}
Function getMouseSaveStateSize;
begin
   reg.ax := $15;
   callMouse;
   getMouseSaveStateSize := reg.bx;
end; {getMouseSaveStateSize}
Procedure interceptMouse;
begin
   With reg do begin
      ax := 3;
      callMouse; { get place .. }
      interceptX := cx;
      interceptY := dx;
      ax := 31;
      callMouse;
   end; { disable mouse driver .. }
end; {interceptMouse}
Procedure restoreMouse;
begin
   With reg do begin
      ax := 32; { restore mouse driver .. }
      callMouse;
      ax := 4;
      cx := interceptX;
      dx := interceptY;
      callMouse;
   end; { With .. }
end; {restoreMouse}

Var
    OldExitProc : Pointer;
{$f+}Procedure MyExitProc;
begin
    ExitProc := OldExitProc;
    resetMouseGraph;
    initMouse;
end; { myExitProc }
begin   {Unit initialization}
   eventX := 0;
   eventY := 0;
   eventHappened := False; { initialize ... }
        initMouse; {detect in global Variables}
        setArrowCursor; {start like that in Graphic mode}
        OldExitProc := ExitProc;
        ExitProc    := @MyExitProc;
end. {mouseLib}
