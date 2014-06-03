unit Lite1;

interface

uses
  Windows, SysUtils, Math, Lite;

const
  DoubleRange: TRange = (Min: -MaxDouble; Max: MaxDouble);
  NonNegativeRange: TRange = (Min: 0; Max: MaxDouble);

type
  TStringIIndex = class(TStringIndex)
  protected
    function GetItem(const Key: string): Pointer;
    procedure SetItem(const Key: string; Value: Pointer);
  public
    procedure Add(const Key: string; Value: Pointer);
    procedure Remove(const Key: string);
    property Items[const Key: string]: Pointer read GetItem write SetItem; default;
  end;

function IntLen(const X: Extended): Integer;
function FracLen(const AValue: Extended; APrecision: Integer): Integer;
function Prec(const AValue: Double; APrecision: Integer): Double;

type
  TBinaryUnit = (buBit, buByte);

resourcestring
  SBitLetter = 'b';
  SByteLetter = 'B';
  SKi = 'Ki';
  SMi = 'Mi';
  SGi = 'Gi';
  STi = 'Ti';
  SPi = 'Pi';
  SEi = 'Ei';
  SZi = 'Zi';
  SYi = 'Yi';

const
  BinaryUnitLetters: array[TBinaryUnit] of string = (SBitLetter, SByteLetter);
  BinaryPrefixes: array[0..8] of string = ('', SKi, SMi, SGi, STi, SPi, SEi,
    SZi, SYi);

function BinarySizeToStr(const Size: Int64; Units: TBinaryUnit = buByte): string;

function RadToDegCycleStr(const AValue: Extended; Precision: Integer): string;

function UTC: TDateTime;
function TimeToStrEx(const Time: TDateTime): string;

function EnsureFileExt(const FileName, Extension: string): string;

type
  TParamDataType = (dtInteger, dtBoolean, dtReal, dtString);

  TParamRec = record
    ID: string;
    Data: Pointer;
    DataType: TParamDataType;
  end;

function MakeParamRec(const ID: string; Data: Pointer;
  DataType: TParamDataType): TParamRec;

function IsDupFile(const FileName1, FileName2: string): Boolean;
procedure ReadIniFile(IniProc: TIniProc); overload;
procedure ReadIniFile(const DestParamTable: array of TParamRec); overload;

function Hue(const Hue: Real): TColorRef;

function NoteFrequency(NoteIndex: Integer): Real;
function NoteByFrequency(const Frequency: Real; var Error: Real): Integer;
function NoteName(Index: Integer): string;

function IsMouseCircleGesture(var Center: TPoint): Boolean;

implementation

{ TStringIIndex }

procedure TStringIIndex.Add(const Key: string; Value: Pointer);
begin
  inherited Add(AnsiUpperCase(Key), Value);
end;

function TStringIIndex.GetItem(const Key: string): Pointer;
begin
  Result := inherited Items[AnsiUpperCase(Key)];
end;

procedure TStringIIndex.Remove(const Key: string);
begin
  inherited Remove(AnsiUpperCase(Key));
end;

procedure TStringIIndex.SetItem(const Key: string; Value: Pointer);
begin
  inherited Items[AnsiUpperCase(Key)] := Value;
end;

function IntLen(const X: Extended): Integer;
begin
  Result := 0;
  if X <> 0 then
    Result := Trunc(Log10(Abs(X))) + 1;
end;

function FracLen(const AValue: Extended; APrecision: Integer): Integer;
begin
  if AValue <> 0 then
    Result := APrecision - IntLen(AValue)
  else
    Result := 0;
end;

function Prec(const AValue: Double; APrecision: Integer): Double;
begin
  Result := RoundTo(AValue, -FracLen(AValue, APrecision));
end;

function BinarySizeToStr(const Size: Int64; Units: TBinaryUnit = buByte): string;
var
  Base, I, Prec: Integer;
  FmtVal: Real;

  procedure CalcFmtVal;
  begin
    FmtVal := Size / (Int64(1) shl (Base * 10));
  end;

begin
  Base := 0;
  Prec := 0;
  FmtVal := 0;
  if FindLastNZBit(Size, I) then
  begin
    Base := I div 10;
    CalcFmtVal;
    Prec := 3;
    if FmtVal >= 999.5 then
    begin
      Inc(Base);
      CalcFmtVal;
      Dec(Prec);
    end;
  end;
  Result := Format('%.*g %s%s', [Prec, FmtVal, BinaryPrefixes[Base],
    BinaryUnitLetters[Units]]);
end;

function RadToDegCycleStr(const AValue: Extended; Precision: Integer): string;
var
  Cycles: Extended;
  IntCycles: Integer;
  CyclesStr: string;
begin
  Cycles := AValue / _2Pi;
  IntCycles := Round(Cycles);
  if IntCycles <> 0 then
    CyclesStr := Format('%dc, ', [IntCycles]);
  Result := Format('%s%.*f', [CyclesStr, Precision, (Cycles - IntCycles) *
    360]);
end;

function UTC: TDateTime;
var
  st: TSystemTime;
begin
  GetSystemTime(st);
  with st do
    Result := EncodeDate(wYear, wMonth, wDay) +
      EncodeTime(wHour, wMinute, wSecond, wMilliseconds);
end;

function TimeToLocal(const UTC: TDateTime): TDateTime;
var
  st, lt: TSystemTime;
begin
  DateTimeToSystemTime(UTC, st);
  SystemTimeToTzSpecificLocalTime(nil, st, lt);
  Result := SystemTimeToDateTime(lt);
end;

function TimeToStrEx(const Time: TDateTime): string;
var
  Days: Integer;
begin
  DateTimeToString(Result, 'HH:mm:ss', Time);
  Days := Trunc(Time);
  if Days <> 0 then
    Result := Format('%d %s', [Days, Result]);
end;

function EnsureFileExt(const FileName, Extension: string): string;
begin
  Result := FileName;
  if not SameText(ExtractFileExt(Result), Extension) then
    Result := Result + Extension;
end;

function IsDupFile(const FileName1, FileName2: string): Boolean;
var
  F1, F2: file;
  Buf1, Buf2: array[0..$7FF] of Byte;
  Read1, Read2: Cardinal;
begin
  AssignFile(F1, FileName1);
  AssignFile(F2, FileName2);
  FileMode := 0;
  Reset(F1, 1);
  try
    Reset(F2, 1);
    try
      Result := False;
      if FileSize(F1) <> FileSize(F2) then
        Exit;
      while True do
      begin
        BlockRead(F1, Buf1, SizeOf(Buf1), Read1);
        BlockRead(F2, Buf2, SizeOf(Buf2), Read2);
        if Read1 <> Read2 then
          Exit;
        if Read1 = 0 then
          Break;
        if not CompareMem(@Buf1, @Buf2, Read1) then
          Exit;
      end;
      Result := True;
    finally
      CloseFile(F2);
    end;
  finally
    CloseFile(F1);
  end;
end;

procedure ReadIniFile(IniProc: TIniProc);
begin
  ReadIniFile(ChangeFileExt(ParamStr(0), '.ini'), IniProc);
end;

type
  TParamTable = array[0..0] of TParamRec;

threadvar
  ParamTable: ^TParamTable;
  ParamTableLength: Integer;

procedure DefIniProc(const Name, Value: string);
var
  I, J, E: Integer;
begin
  for I := 0 to ParamTableLength - 1 do
    with ParamTable^[I] do
      if SameText(Name, ID) then
        case DataType of
          dtInteger:
            begin
              Val(Value, J, E);
              if E = 0 then
                Integer(Data^) := J;
            end;
          dtBoolean:
            begin
              Val(Value, J, E);
              if E = 0 then
                Boolean(Data^) := J <> 0
              else
                if SameText(Value, 'True') or SameText(Value, 'Yes') then
                  Boolean(Data^) := True
                else
                if SameText(Value, 'False') or SameText(Value, 'No') then
                  Boolean(Data^) := False;
            end;
          dtReal:
            try
              Real(Data^) := StrToFloat(Value);
            except
              on EConvertError do;
            end;
          dtString: string(Data^) := Value;
        end;
end;

function MakeParamRec(const ID: string; Data: Pointer;
  DataType: TParamDataType): TParamRec;
begin
  Result.ID := ID;
  Result.Data := Data;
  Result.DataType := DataType;
end;

procedure ReadIniFile(const DestParamTable: array of TParamRec);
begin
  ParamTable := @TParamTable(DestParamTable[0]);
  ParamTableLength := Length(DestParamTable);
  ReadIniFile(DefIniProc);
end;

function Hue(const Hue: Real): TColorRef;
var
  X: Real;

  function Comp(const Offset: Real): Integer;
  begin
    Result := Round(EnsureRange(2 - Abs(X - Offset), 0, 1) * $FF);
  end;

begin
  X := Hue / 60;
  Result := RGB(Comp(0) + Comp(6), Comp(2), Comp(4));
end;

function NoteFrequency(NoteIndex: Integer): Real;
begin
  Result := 440 * Power(2, NoteIndex / 12);
end;

function NoteByFrequency(const Frequency: Real; var Error: Real): Integer;
var
  RealIndex: Real;
begin
  RealIndex := 12 * Log2(Frequency / 440);
  Result := Round(RealIndex);
  Error := 2 * Abs(RealIndex - Result);
end;

function NoteName(Index: Integer): string;
const
  Offset = MaxInt div 2 div 12;
  Sharp: array[0..1] of string = ('', '#');
var
  I: Integer;
begin
  Inc(Index, Offset * 12 - 3);
  if Index < 0 then
    Exit;
  I := Index mod 12 + 4;
  if I > 8 then
    Inc(I);
  Result := Format('%s%s%d', [Chr(Ord('A') + I div 2 mod 7), Sharp[I and 1],
    Index div 12 - Offset + 5]);
end;

var
  MouseTrackBuf: array[Byte] of TPoint;
  MouseTrackCount, MouseIdleCount: Integer;

function IsMouseCircleGesture(var Center: TPoint): Boolean;

  function IsCircleTrack(const Points: array of TPoint;
    var Center: TPoint): Boolean;
  var
    I, Len: Integer;
    XX, YY: array of Integer;
    Theta, ThetaLast, A, AA: Double;
  begin
    Result := False;
    Len := Length(Points);
    if Len >= 8 then
    begin
      SetLength(XX, Len);
      SetLength(YY, Len);
      for I := 0 to Len - 1 do
        with Points[I] do
        begin
          XX[I] := X;
          YY[I] := Y;
        end;
      Center.X := (MinIntValue(XX) + MaxIntValue(XX)) div 2;
      Center.Y := (MinIntValue(YY) + MaxIntValue(YY)) div 2;
      AA := 0;
      ThetaLast := 0;
      for I := 0 to Len - 1 do
      begin
        Theta := ArcTan2(XX[I] - Center.X, Center.Y - YY[I]);
        if I > 0 then
        begin
          A := Theta - ThetaLast;
          if InRange(Abs(A), Pi, 2 * Pi) then
            if A > 0 then
              A := A - Pi * 2
            else
              A := A + Pi * 2;
          if Abs(A) > (Pi / 2) then
            Exit;
          AA := AA + A;
        end;
        ThetaLast := Theta;
      end;
      Result := Abs(AA) > 2 * Pi;
    end;
  end;

var
  Point: TPoint;
begin
  Result := False;
  GetCursorPos(Point);
  if ((Point.X <> MouseTrackBuf[0].X) or (Point.Y <> MouseTrackBuf[0].Y)) then
  begin
    MouseTrackCount := Min(MouseTrackCount, Length(MouseTrackBuf) - 1);
    Move(MouseTrackBuf[0], MouseTrackBuf[1], MouseTrackCount *
      SizeOf(TPoint));
    MouseTrackBuf[0] := Point;
    Inc(MouseTrackCount);
    Result := IsCircleTrack(Slice(MouseTrackBuf, MouseTrackCount), Center);
    if Result then
      MouseTrackCount := 0;
    MouseIdleCount := 0;
  end
  else
  begin
    Inc(MouseIdleCount);
    if MouseIdleCount >= 3 then
      MouseTrackCount := 0;
  end;
end;

end.
