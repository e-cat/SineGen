{*******************************************************}
{                                                       }
{                  Lite RTL for Delphi                  }
{                                                       }
{             Copyright (c) 2007-2008 eCat              }
{                                                       }
{*******************************************************}

unit Lite;

interface

uses
  Windows;

function DivRem(A, B: Integer; var Rem: Integer): Integer; overload;
function DivRem(A, B: Cardinal; var Rem: Cardinal): Cardinal; overload;
function ValueIndex(AValue: Integer; const AValues: array of Integer): Integer; overload;
function FindFirstNZBit(A: Integer; out Index: Integer): Boolean; overload;
function FindFirstNZBit(A: Int64; out Index: Integer): Boolean; overload;
function FindLastNZBit(A: Integer; out Index: Integer): Boolean; overload;
function FindLastNZBit(A: Int64; out Index: Integer): Boolean; overload;
function MakeInt64(Low, High: LongWord): Int64;
function MaxIntVal(BitCapacity: Integer): Int64;
function SignedRandom(Range: Integer): Integer; overload;
function SignedRandom: Real; overload;

function Wrap(AIndex: Integer; AMin, AMax: Integer): Integer;

type
  Int24 = packed array[0..2] of Byte;
  PInt24 = ^Int24;

  Bytes     = array[0..MaxInt - 1] of Byte;
  ShortInts = array[0..MaxInt - 1] of ShortInt;
  Words     = array[0..MaxInt div SizeOf(Word) - 1] of Word;
  SmallInts = array[0..MaxInt div SizeOf(SmallInt) - 1] of SmallInt;
  Ints24    = array[0..MaxInt div SizeOf(Int24) - 1] of Int24;
  LongWords = array[0..MaxInt div SizeOf(LongWord) - 1] of LongWord;
  LongInts  = array[0..MaxInt div SizeOf(Longint) - 1] of LongInt;

  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array[0..MaxInt div SizeOf(TRGBTriple) - 1] of TRGBTriple;

  TProc = procedure;
  //TFunction = function(const X: Extended): Extended;

  TRange = record
    Min, Max: Extended;
  end;

  TIntRange = record
    Min, Max: Integer;
  end;

  TIntPair       = array[0..1] of Integer;
  TRealPair      = array[0..1] of Real;
  TIntBoolArray  = array[Boolean] of Integer;
  TRealBoolArray = array[Boolean] of Real;

  TDWORDID = array[0..3] of Char;

const
  SignFactor: TIntBoolArray = (1, -1);

function InRange(const AValue: Extended; const ARange: TRange): Boolean; overload;
function InRange(const AValue: Integer; const ARange: TIntRange): Boolean; overload;
function EnsureRange(const AValue: Extended; const ARange: TRange): Extended; overload;
function EnsureRange(const AValue: Integer; const ARange: TIntRange): Integer; overload;
function Range(const Min, Max: Extended): TRange; overload;
function Range(Min, Max: Integer): TIntRange; overload;
function ValidRange(const ARange: TRange): Boolean; overload;
function ValidRange(const ARange: TIntRange): Boolean; overload;
function EqualRange(const R1, R2: TRange): Boolean; overload;
function EqualRange(const R1, R2: TIntRange): Boolean; overload;
function IntersectRange(const R1, R2: TRange): TRange; overload;
function IntersectRange(const R1, R2: TIntRange): TIntRange; overload;

{ Metric prefixes }

resourcestring
  SYocto = 'y';
  SZepto = 'z';
  SAtto  = 'a';
  SFemto = 'f';
  SPico  = 'p';
  SNano  = 'n';
  SMicro = 'u';
  SMilli = 'm';
  SKilo  = 'k';
  SMega  = 'M';
  SGiga  = 'G';
  STera  = 'T';
  SPeta  = 'P';
  SExa   = 'E';
  SZetta = 'Z';
  SYotta = 'Y';

const
  MetricPrefixes: array[-8..8] of string = (SYocto, SZepto, SAtto, SFemto,
    SPico, SNano, SMicro, SMilli, '', SKilo, SMega, SGiga, STera, SPeta, SExa,
    SZetta, SYotta);

var
  PowerdBFactor: Extended;
  AmpdBFactor: Extended;

function AmpdBRatio(const Ratio: Extended): Extended;
function AmpdB(const Ratio: Extended): Extended;
function AmpdBMean(const Ratios: array of Extended): Extended;

const
  _2Pi = 2 * Pi;
  TrigRange: TRange = (Min: -Pi; Max: Pi);
  DegFactor = 180 / Pi;

function Cycle(const Theta: Real): Real; overload;
function Cycle(const Theta: Extended): Extended; overload;

function UpdateCRC(CRCValue: LongWord; const Data; Count: Integer): LongWord;
function CRC(const Data; Count: Integer): LongWord;

function FileCRC32(const FileName: string): LongWord;

function LongString(Buffer: PChar; Length: Integer): string;

type
  PPHashItem = ^PHashItem;
  PHashItem = ^THashItem;
  THashItem = record
    Next: PHashItem;
    Key: string;
    Value: TObject;
  end;

  TStringIndex = class
  private
    Buckets: array of PHashItem;
    function FirstItem(const Key: string): PPHashItem;
    function GetItem(const Key: string): Pointer;
    procedure SetItem(const Key: string; Value: Pointer);
  protected
    function Find(const Key: string): PPHashItem;
    function HashOf(const Key: string): Cardinal; virtual;
  public
    constructor Create(Size: Cardinal = $100);
    destructor Destroy; override;
    procedure Add(const Key: string; Value: TObject);
    procedure Clear;
    procedure Remove(const Key: string);
    property Items[const Key: string]: Pointer read GetItem write SetItem; default;
  end;

function ProgramName: string;

type
  TIniProc = procedure(const Name, Value: string);

procedure ReadIniFile(const FileName: string; IniProc: TIniProc); overload;

procedure ChangeWindowStyle(AHandle: HWND; AIncludeStyles,
  AExcludeStyles: Integer);
procedure SetWindowStyle(AHandle: HWND; AStyle: Integer; ABool: Boolean);
procedure SetTopmost(Handle: HWND; IsTopmost: Boolean);

type
  TGetStringProc = function(out S: string): Boolean;

function FitStr(Wnd: HWND; const Rect: TRect;
  GetStringProc: TGetStringProc): string;

function TextInClipboard: string;
procedure SetClipboard(Format: Cardinal; const Buffer; Size: Integer);
procedure SimulateKeystroke(VK: Byte);

type
  TKbLEDIndex = (kbledScroll, kbledNum, kbledCaps);

procedure ToggleKbLED(LEDIndex: TKbLEDIndex);

procedure TurnOffFeedbackCursor;

procedure SimpleAppProc(InitProc, OnRun: TProc; var WndClass: WNDCLASS;
  var Wnd: HWND; WndStyle: Cardinal = WS_POPUP; WndExStyle: Cardinal = 0;
  const WndName: string = '');

implementation

function DivRem(A, B: Integer; var Rem: Integer): Integer;
asm
        PUSH    EDX
        CDQ
        IDIV    [ESP]
        MOV     [ECX],EDX
        ADD     ESP,4
end;

function DivRem(A, B: Cardinal; var Rem: Cardinal): Cardinal;
asm
        PUSH    EDX
        XOR     EDX,EDX
        DIV     [ESP]
        MOV     [ECX],EDX
        ADD     ESP,4
end;

function ValueIndex(AValue: Integer; const AValues: array of Integer): Integer;
begin
  for Result := 0 to High(AValues) do
    if AValues[Result] = AValue then
      Exit;
  Result := -1;
end;

function FindFirstNZBit(A: Integer; out Index: Integer): Boolean;
asm
        BSF     EAX,EAX
        MOV     [EDX],EAX
        SETNZ   AL
end;

function FindFirstNZBit(A: Int64; out Index: Integer): Boolean;
asm
        BSF     EDX,dword ptr [A]
        JNZ     @@1
        BSF     EDX,dword ptr [A+4]
        JZ      @@2
        ADD     EDX,$20
@@1:
        MOV     [EAX],EDX
@@2:
        SETNZ   AL
end;

function FindLastNZBit(A: Integer; out Index: Integer): Boolean;
asm
        BSR     EAX,EAX
        MOV     [EDX],EAX
        SETNZ   AL
end;

function FindLastNZBit(A: Int64; out Index: Integer): Boolean;
asm
        BSR     EDX,dword ptr [A+4]
        JZ      @@1
        ADD     EDX,$20
        JMP     @@2
@@1:
        BSR     EDX,dword ptr [A]
@@2:
        MOV     [EAX],EDX
        SETNZ   AL
end;

function MakeInt64(Low, High: LongWord): Int64;
asm
end;

function MaxIntVal(BitCapacity: Integer): Int64;
begin
  Result := Int64(1) shl (BitCapacity - 1) - 1;
end;

function SignedRandom(Range: Integer): Integer;
begin
  Result := Random(2 * Range - 1) - Range + 1;
end;

function SignedRandom: Real;
begin
  Result := 2 * (Random - 0.5);
end;

function Wrap(AIndex: Integer; AMin, AMax: Integer): Integer;
begin
  Assert(AMin <= AMax);
  if AIndex < AMin then
    Result := AMax
  else
  if AIndex > AMax then
    Result := AMin
  else
    Result := AIndex;
end;

function InRange(const AValue: Extended; const ARange: TRange): Boolean;
begin
  Result := (AValue >= ARange.Min) and (AValue <= ARange.Max);
end;

function InRange(const AValue: Integer; const ARange: TIntRange): Boolean;
begin
  Result := (AValue >= ARange.Min) and (AValue <= ARange.Max);
end;

function EnsureRange(const AValue: Extended; const ARange: TRange): Extended;
begin
  Result := AValue;
  with ARange do
  begin
    Assert(Min <= Max);
    if Result < Min then
      Result := Min;
    if Result > Max then
      Result := Max;
  end;
end;

function EnsureRange(const AValue: Integer; const ARange: TIntRange): Integer;
begin
  Result := AValue;
  with ARange do
  begin
    Assert(Min <= Max);
    if Result < Min then
      Result := Min;
    if Result > Max then
      Result := Max;
  end;
end;

function Range(const Min, Max: Extended): TRange;
begin
  Result.Min := Min;
  Result.Max := Max;
end;

function Range(Min, Max: Integer): TIntRange;
begin
  Result.Min := Min;
  Result.Max := Max;
end;

function ValidRange(const ARange: TRange): Boolean;
begin
  Result := ARange.Min <= ARange.Max;
end;

function ValidRange(const ARange: TIntRange): Boolean;
begin
  Result := ARange.Min <= ARange.Max;
end;

function EqualRange(const R1, R2: TRange): Boolean;
begin
  Result := (R1.Min = R2.Min) and (R1.Max = R2.Max);
end;

function EqualRange(const R1, R2: TIntRange): Boolean;
begin
  Result := (R1.Min = R2.Min) and (R1.Max = R2.Max);
end;

function IntersectRange(const R1, R2: TRange): TRange;
begin
  with Result do
  begin
    if R1.Min > R2.Min then
      Min := R1.Min
    else
      Min := R2.Min;
    if R1.Max < R2.Max then
      Max := R1.Max
    else
      Max := R2.Max;
  end;
end;

function IntersectRange(const R1, R2: TIntRange): TIntRange;
begin
  with Result do
  begin
    if R1.Min > R2.Min then
      Min := R1.Min
    else
      Min := R2.Min;
    if R1.Max < R2.Max then
      Max := R1.Max
    else
      Max := R2.Max;
  end;
end;

function AmpdBRatio(const Ratio: Extended): Extended;
begin
  Result := Exp(Ratio / AmpdBFactor);
end;

function AmpdB(const Ratio: Extended): Extended;
begin
  Result := Ln(Ratio) * AmpdBFactor;
end;

function AmpdBMean(const Ratios: array of Extended): Extended;
var
  Sum: Extended;
  I: Integer;
begin
  Sum := 0;
  for I := 0 to High(Ratios) do
    Sum := Sum + AmpdBRatio(Ratios[I]);
  Result := AmpdB(Sum / Length(Ratios));
end;

function Cycle(const Theta: Real): Real;
begin
  Result := Frac(Theta / _2Pi);
  if Result < 0 then
    Result := Result + 1;
end;

function Cycle(const Theta: Extended): Extended;
begin
  Result := Frac(Theta / _2Pi);
  if Result < 0 then
    Result := Result + 1;
end;

var
  CRCTable: array[Byte] of LongWord;
  CRCTableComputed: Boolean;

procedure ComputeCRCTable;
var
  I, J: Integer;
  C: LongWord;
begin
  for I := 0 to $FF do
  begin
    C := I;
    for J := 0 to 7 do
      if C and 1 <> 0 then
        C := $EDB88320 xor (C shr 1)
      else
        C := C shr 1;
    CRCTable[I] := C;
  end;
  CRCTableComputed := True;
end;

function UpdateCRC(CRCValue: LongWord; const Data; Count: Integer): LongWord;
var
  I: Integer;
begin
  Result := not CRCValue;
  if not CRCTableComputed then
    ComputeCRCTable;
  for I := 0 to Count - 1 do
    Result := CRCTable[(Result xor Bytes(Data)[I]) and $FF] xor (Result shr 8);
  Result := not Result;
end;

function CRC(const Data; Count: Integer): LongWord;
begin
  Result := UpdateCRC(0, Data, Count);
end;

function FileCRC32(const FileName: string): LongWord;
var
  F: file;
  Buf: array[0..$FFF] of Byte;
  Read: Cardinal;
begin
  AssignFile(F, FileName);
  FileMode := 0;
  Reset(F, 1);
  try
    Result := 0;
    while True do
    begin
      BlockRead(F, Buf, SizeOf(Buf), Read);
      if Read = 0 then
        Break;
      Result := UpdateCRC(Result, Buf, Read)
    end;
  finally
    CloseFile(F);
  end;
end;

function LongString(Buffer: PChar; Length: Integer): string;
begin
  SetString(Result, Buffer, Length);
end;

{ TStringIndex }

procedure TStringIndex.Add(const Key: string; Value: TObject);
var
  Bucket: PHashItem;
  Dest: PPHashItem;
begin
  Dest := FirstItem(Key);
  New(Bucket);
  Bucket^.Key := Key;
  Bucket^.Value := Value;
  Bucket^.Next := Dest^;
  Dest^ := Bucket;
end;

procedure TStringIndex.Clear;
var
  I: Integer;
  P, N: PHashItem;
begin
  for I := 0 to High(Buckets) do
  begin
    P := Buckets[I];
    while P <> nil do
    begin
      N := P^.Next;
      Dispose(P);
      P := N;
    end;
    Buckets[I] := nil;
  end;
end;

constructor TStringIndex.Create(Size: Cardinal);
begin
  SetLength(Buckets, Size);
end;

destructor TStringIndex.Destroy;
begin
  Clear;
end;

function TStringIndex.Find(const Key: string): PPHashItem;
begin
  Result := FirstItem(Key);
  while (Result^ <> nil) and (Result^.Key <> Key) do
    Result := @Result^.Next;
end;

function TStringIndex.FirstItem(const Key: string): PPHashItem;
begin
  Result := @Buckets[HashOf(Key) mod Cardinal(Length(Buckets))];
end;

function TStringIndex.GetItem(const Key: string): Pointer;
var
  P: PHashItem;
begin
  Result := nil;
  P := Find(Key)^;
  if P <> nil then
    Result := P^.Value;
end;

function TStringIndex.HashOf(const Key: string): Cardinal;
begin
  Result := CRC(Pointer(Key)^, Length(Key));
end;

procedure TStringIndex.Remove(const Key: string);
var
  P: PHashItem;
  Prev: PPHashItem;
begin
  Prev := Find(Key);
  P := Prev^;
  if P <> nil then
  begin
    Prev^ := P^.Next;
    Dispose(P);
  end;
end;

procedure TStringIndex.SetItem(const Key: string; Value: Pointer);
var
  P: PHashItem;
begin
  P := Find(Key)^;
  if P <> nil then
    P^.Value := Value;
end;

function ProgramName: string;
var
  First, Ext, P: PChar;
begin
  Result := ParamStr(0);
  First := PChar(Result);
  Ext := First + Length(Result);
  P := Ext - 1;
  while (P > First) and not (P^ in ['/', '\']) do
  begin
    if P^ = '.' then
      Ext := P;
    Dec(P);
  end;
  if P > First then
    Inc(P);
  SetString(Result, P, Ext - P);
end;

procedure ReadIniFile(const FileName: string; IniProc: TIniProc);
var
  F: TextFile;
  S: string;
  I, Len, I0, J0, I1: Integer;
begin
  AssignFile(F, FileName);
  FileMode := 0;
  Reset(F);
  try
    while not Eof(F) do
    begin
      ReadLn(F, S);
      Len := Length(S);
      I := Pos('#', S);
      if I <> 0 then
        Len := I - 1;
      while (Len > 0) and (S[Len] <= ' ') do
        Dec(Len);
      SetLength(S, Len);
      I := Pos('=', S);
      if I <> 0 then
      begin
        I0 := 1;
        while (I0 < I) and (S[I0] <= ' ') do
          Inc(I0);
        J0 := I - 1;
        while (J0 > 0) and (S[J0] <= ' ') do
          Dec(J0);
        if J0 >= I0 then
        begin
          I1 := I + 1;
          while (I1 <= Len) and (S[I1] <= ' ') do
            Inc(I1);
          IniProc(Copy(S, I0, J0 - I0 + 1), Copy(S, I1, MaxInt));
        end;
      end;
    end;
  finally
    CloseFile(F);
  end;
end;

procedure ChangeWindowStyle(AHandle: HWND; AIncludeStyles,
  AExcludeStyles: Integer);
var
  Styles: Integer;
begin
  Styles := GetWindowLong(AHandle, GWL_STYLE);
  if Styles <> 0 then
    SetWindowLong(AHandle, GWL_STYLE, (Styles or AIncludeStyles) and not
      AExcludeStyles);
end;

procedure SetWindowStyle(AHandle: HWND; AStyle: Integer; ABool: Boolean);
var
  Styles: Integer;
begin
  Styles := GetWindowLong(AHandle, GWL_STYLE);
  if Styles <> 0 then
    SetWindowLong(AHandle, GWL_STYLE, Styles and not AStyle or
      Ord(ABool <> False) * AStyle);
end;

procedure SetTopmost(Handle: HWND; IsTopmost: Boolean);
const
  InsertAfter: array[Boolean] of Cardinal = (HWND_NOTOPMOST, HWND_TOPMOST);
begin
  SetWindowPos(Handle, InsertAfter[IsTopmost], 0, 0, 0, 0, SWP_NOMOVE or
    SWP_NOSIZE or SWP_NOACTIVATE);
end;

function FitStr(Wnd: HWND; const Rect: TRect;
  GetStringProc: TGetStringProc): string;
var
  DC: HDC;
  Size: TSize;
begin
  DC := GetDC(Wnd);
  try
    with Rect do
      while GetStringProc(Result) and GetTextExtentPoint32(DC, PChar(Result),
        Length(Result), Size) and (Size.cx > Right - Left) do;
  finally
    ReleaseDC(Wnd, DC);
  end;
end;

function TextInClipboard: string;
var
  Data: THandle;
begin
  OpenClipboard(0);
  Data := GetClipboardData(CF_TEXT);
  try
    if Data <> 0 then
      Result := PChar(GlobalLock(Data))
    else
      Result := '';
  finally
    if Data <> 0 then
      GlobalUnlock(Data);
    CloseClipboard;
  end;
end;

procedure SetClipboard(Format: Cardinal; const Buffer; Size: Integer);
var
  Data: THandle;
  DataPtr: Pointer;
begin
  OpenClipboard(0);
  EmptyClipboard;
  OpenClipboard(0);
  try
    Data := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, Size);
    try
      DataPtr := GlobalLock(Data);
      try
        Move(Buffer, DataPtr^, Size);
        SetClipboardData(Format, Data);
      finally
        GlobalUnlock(Data);
      end;
    except
      GlobalFree(Data);
      raise;
    end;
  finally
    CloseClipboard;
  end;
end;

procedure SimulateKeystroke(VK: Byte);
begin
  keybd_event(VK, 0, 0, 0);
  keybd_event(VK, 0, KEYEVENTF_KEYUP, 0);
end;

procedure ToggleKbLED(LEDIndex: TKbLEDIndex);

  procedure SimulateLockKeyEvent(UpFlag: Cardinal = 0);
  const
    VKCodes: array[TKbLEDIndex] of Byte = (VK_SCROLL, VK_NUMLOCK, VK_CAPITAL);
    ScanCodes: array[TKbLEDIndex] of Byte = ($46, $45, $3A);
    ExKeyFlags: array[TKbLEDIndex] of Cardinal = (0, KEYEVENTF_EXTENDEDKEY, 0);
  begin
    keybd_event(VKCodes[LEDIndex], ScanCodes[LEDIndex], ExKeyFlags[LEDIndex] or
      UpFlag, 0);
  end;

begin
  SimulateLockKeyEvent;
  SimulateLockKeyEvent(KEYEVENTF_KEYUP);
end;

(* HW routine that works only for DIN keyboards
const
  IOCTL_KEYBOARD_SET_INDICATORS   = $B0008;
  IOCTL_KEYBOARD_QUERY_INDICATORS = $B0040;
type
  TKeyboardIndicatorParameters = record
    UnitId: Word;
    LedFlags: Word;
  end;
var
  kip: TKeyboardIndicatorParameters;
  Dummy: Cardinal;
  h: THandle;
begin
  DefineDosDevice(DDD_RAW_TARGET_PATH, 'Keybd', '\Device\KeyboardClass0');
  h := CreateFile('\\.\Keybd', 0, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
    OPEN_EXISTING, 0, 0);
  DefineDosDevice(DDD_REMOVE_DEFINITION, 'Keybd', nil);
  DeviceIoControl(h, IOCTL_KEYBOARD_SET_INDICATORS, @kip, SizeOf(kip), nil, 0,
    Dummy, nil);
  CloseHandle(h);
*)

procedure TurnOffFeedbackCursor;
var
  Msg: TMsg;
begin
  if PostThreadMessage(GetCurrentThreadId, 0, 0, 0) then
    GetMessage(Msg, 0, 0, 0);
end;

procedure SimpleAppProc(InitProc, OnRun: TProc; var WndClass: WNDCLASS;
  var Wnd: HWND; WndStyle, WndExStyle: Cardinal; const WndName: string);
var
  Mutex: THandle;
  Msg: TMsg;
begin
  Mutex := CreateMutex(nil, True, PChar(ProgramName + '_Running'));
  if WaitForSingleObject(Mutex, 0) = WAIT_OBJECT_0 then
  begin
    if Assigned(InitProc) then
      InitProc;
    WndClass.hInstance := HInstance;
    Windows.RegisterClass(WndClass);
    Wnd := CreateWindowEx(WndExStyle, WndClass.lpszClassName, PChar(WndName),
      WndStyle, 0, 0, 0, 0, 0, 0, HInstance, nil);
    if Assigned(OnRun) then
      OnRun;
    while GetMessage(Msg, 0, 0, 0) do
      DispatchMessage(Msg);
    DestroyWindow(Wnd);
  end;
  CloseHandle(Mutex);
end;

initialization
  PowerdBFactor := 10 / Ln(10);
  AmpdBFactor   := 20 / Ln(10);

end.
