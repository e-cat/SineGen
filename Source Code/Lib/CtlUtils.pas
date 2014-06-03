{*******************************************************}
{                                                       }
{             Generic Delphi control utils              }
{                                                       }
{             Copyright (c) 2007-2008 eCat              }
{                                                       }
{*******************************************************}

unit CtlUtils;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls,
  ComCtrls, Lite;

function MessageBoxResFmt(Msg: PResStringRec; const Args: array of const;
  Flags: Integer): Integer;

type
  TControlEnumProc = function(Control: TControl; Instance: Pointer): Boolean;

function EnumerateControls(AContainer: TWinControl;
  AControllClass: TControlClass; AEnumProc: TControlEnumProc;
  AInstance: Pointer = nil): Boolean;
procedure SetEnableControls(const AControls: array of TControl;
  AEnabled: Boolean = True); overload;
function PhysPixels(ALogPixels: Integer): Integer;
procedure CenterControl(AControl: TControl; const APoint: TPoint);
function SaveFormPlacement(AForm: TCustomForm = nil): Boolean;
function RestoreFormPlacement(AForm: TCustomForm = nil;
  EnsureWorkArea: Boolean = True): Boolean;
function SaveFont(AFont: TFont = nil; const AID: string = ''): Boolean;
function RestoreFont(AFont: TFont = nil; const AID: string = ''): Boolean;

function SetTrackBarRange(ATrackBar: TTrackBar; AMin, AMax: Integer): Boolean; overload;
function SetTrackBarRange(ATrackBar: TTrackBar; const ARange: TIntRange): Boolean; overload;
function SetTrackBarRange(ATrackBar: TTrackBar; const AMin, AMax,
  AFactor: Real; ALogarithmic: Boolean = False): Boolean; overload;
function SetTrackBarRange(ATrackBar: TTrackBar; const ARange: TRange;
  const AFactor: Real; ALogarithmic: Boolean = False): Boolean; overload;

procedure SetTrackBarValue(ATrackBar: TTrackBar; const AFactor, AValue: Real;
  ALogarithmic: Boolean = False);
function TrackBarValue(ATrackBar: TTrackBar; const AFactor: Real;
  ALogarithmic: Boolean = False): Real;

type
  TTrackBarLabel = class(TLabel)
  private
    FIndex: Integer;
  public
    constructor Create(ATrackBar: TTrackBar; const ACaption: string;
      AIndex: Integer; AClickEvent: TMouseEvent = nil); reintroduce;
    property Index: Integer read FIndex;
  end;

procedure CreateTrackBarLabels(ATrackBar: TTrackBar; AFactor,
  AFrequency: Integer; ANegative: Boolean = False; AZeroClickEvent: TMouseEvent = nil);
function CreateZeroLabel(ATrackBar: TTrackBar;
  AClickEvent: TMouseEvent): TTrackBarLabel;
procedure CreateLogTrackBarScale(ATrackBar: TTrackBar; const AFactor: Real;
  AZeroClickEvent: TMouseEvent = nil); overload;
function CreateLogTrackBarScale(ATrackBar: TTrackBar; const AMin, AMax,
  AFactor: Real; AZeroClickEvent: TMouseEvent = nil): Boolean; overload;
function CreateLogTrackBarScale(ATrackBar: TTrackBar; const ARange: TRange;
  const AFactor: Real; AZeroClickEvent: TMouseEvent = nil): Boolean; overload;

type
  TTrackBarLabelEnumProc = function(ALabel: TTrackBarLabel;
    Instance: Pointer): Boolean;

function EnumTrackBarLabels(ATrackBar: TTrackBar;
  AEnumProc: TTrackBarLabelEnumProc; Instance: Pointer = nil): Boolean;
function GetTickPos(ATrackBar: TTrackBar; AIndex: Integer): Integer;
procedure AlignTrackBarLabels(ATrackBar: TTrackBar);
procedure AlignTrackBarsLabels(AContainer: TWinControl);
procedure SetEnableTrackBarLabels(ATrackBar: TTrackBar; AEnabled: Boolean = True);


procedure ClearTicks(ATrackBar: TTrackBar; ARedraw: Boolean);
procedure SetTrackBarSliderVisible(ATrackBar: TTrackBar; ASliderVisible: Boolean);

implementation

uses
  CommCtrl, Math, StrUtils, Registry, Lite2;

  
function MessageBoxResFmt(Msg: PResStringRec; const Args: array of const;
  Flags: Integer): Integer;
begin
  Result := Application.MessageBox(PChar(Format(LoadResString(Msg), Args)),
    PChar(Application.Title), Flags);
end;


function EnumerateControls(AContainer: TWinControl;
  AControllClass: TControlClass; AEnumProc: TControlEnumProc;
  AInstance: Pointer): Boolean;

  function DoEnumerate(Container: TWinControl): Boolean;
  var
    I: Integer;
    Control: TControl;
  begin
    Result := False;
    with Container do
      for I := 0 to ControlCount - 1 do
      begin
        Control := Controls[I];
        if (Control is AControllClass) and not AEnumProc(Control, AInstance) or
          (Control is TWinControl) and not DoEnumerate(TWinControl(Control))
          then
          Exit;
      end;
    Result := True;
  end;

begin
  Result := DoEnumerate(AContainer);
end;

procedure SetEnableControls(const AControls: array of TControl;
  AEnabled: Boolean);
var
  I: Integer;
begin
  for I := 0 to High(AControls) do
    AControls[I].Enabled := AEnabled;
end;

function PhysPixels(ALogPixels: Integer): Integer;
begin
  Result := MulDiv(ALogPixels, Screen.PixelsPerInch, 96);
end;

procedure CenterControl(AControl: TControl; const APoint: TPoint);
begin
  with AControl, APoint do
    SetBounds(X - Width div 2, Y - Height div 2, Width, Height);
end;

const
  SLeft      = 'Left';
  STop       = 'Top';
  SWidth     = 'Width';
  SHeight    = 'Height';
  SMaximized = 'Maximized';

function SaveFormPlacement(AForm: TCustomForm): Boolean;
var
  SaveLeft, SaveTop, SaveWidth, SaveHeight: Integer;

  procedure GetNormalPosition;
  var
    Placement: TWindowPlacement;
    WorkAreaRect: TRect;
  begin
    Placement.length := SizeOf(TWindowPlacement);
    GetWindowPlacement(AForm.Handle, @Placement);
    if not (AForm.BorderStyle in [bsToolWindow, bsSizeToolWin]) then
    begin
      if (AForm is TForm) and (TForm(AForm).FormStyle = fsMDIChild) and
        (Application.MainForm <> nil) then
        WorkAreaRect := Application.MainForm.ClientRect
      else
        WorkAreaRect := Screen.WorkAreaRect;
      OffsetRect(Placement.rcNormalPosition, WorkAreaRect.Left,
        WorkAreaRect.Top);
    end;
    with Placement.rcNormalPosition do
    begin
      SaveLeft := Left;
      SaveTop := Top;
      SaveWidth := Right - Left;
      SaveHeight := Bottom - Top;
    end;
  end;

begin
  if AForm = nil then
    AForm := Application.MainForm;
  with AForm, TRegistry.Create do
    try
      Result := OpenKey(RegKey, True);
      if Result then
      begin
        SaveLeft := Left;
        SaveTop := Top;
        SaveWidth := Width;
        SaveHeight := Height;
        if WindowState = wsMaximized then
          GetNormalPosition;
        WriteInteger(Name + SLeft, SaveLeft);
        WriteInteger(Name + STop, SaveTop);
        if BorderStyle in [bsSizeable, bsSizeToolWin] then
        begin
          WriteInteger(Name + SWidth, SaveWidth);
          WriteInteger(Name + SHeight, SaveHeight);
          WriteBool(Name + SMaximized, WindowState = wsMaximized);
        end;
      end;
    finally
      Free;
    end;
end;

function RestoreFormPlacement(AForm: TCustomForm;
  EnsureWorkArea: Boolean): Boolean;
var
  RestoreLeft, RestoreTop, RestoreWidth, RestoreHeight: Integer;
  WorkAreaRect: TRect;
  Maximized: Boolean;
begin
  if AForm = nil then
    AForm := Application.MainForm;
  with AForm, TRegistry.Create do
    try
      Result := OpenKey(RegKey, False) and ValueExists(Name + 'Left');
      if Result then
      begin
        RestoreLeft := ReadInteger(Name + SLeft);
        RestoreTop := ReadInteger(Name + STop);
        RestoreWidth := Width;
        RestoreHeight := Height;
        Maximized := False;
        if BorderStyle in [bsSizeable, bsSizeToolWin] then
        begin
          RestoreWidth := ReadInteger(Name + SWidth);
          RestoreHeight := ReadInteger(Name + SHeight);
          Maximized := ValueExists(Name + SMaximized) and ReadBool(Name +
            SMaximized);
        end;
        if EnsureWorkArea then
        begin
          if (AForm is TForm) and (TForm(AForm).FormStyle = fsMDIChild) and
            (Application.MainForm <> nil) then
            WorkAreaRect := Application.MainForm.ClientRect
          else
            WorkAreaRect := Screen.WorkAreaRect;
          with WorkAreaRect do
          begin
            RestoreWidth := Min(RestoreWidth, Right - Left);
            RestoreHeight := Min(RestoreHeight, Bottom - Top);
            RestoreLeft := EnsureRange(RestoreLeft, Left, Right - RestoreWidth);
            RestoreTop := EnsureRange(RestoreTop, Top, Bottom - RestoreHeight);
          end;
        end;
        SetBounds(RestoreLeft, RestoreTop, RestoreWidth, RestoreHeight);
        if Maximized then
          WindowState := wsMaximized;
      end;
    finally
      Free;
    end;
end;

const
  SFont  = 'Font';
  SName  = 'Name';
  SStyle = 'Style';
  SSize  = 'Size';
  SColor = 'Color';

function SaveFont(AFont: TFont; const AID: string): Boolean;
var
  Prefix: string;
begin
  if AFont = nil then
    AFont := Application.MainForm.Font;
  with AFont, TRegistry.Create do
    try
      Result := OpenKey(RegKey, True);
      if Result then
      begin
        Prefix := AID + SFont;
        WriteString(Prefix + SName, Name);
        WriteInteger(Prefix + SStyle, Byte(Style));
        WriteInteger(Prefix + SSize, Size);
        WriteInteger(Prefix + SColor, Color);
      end;
    finally
      Free;
    end;
end;

function RestoreFont(AFont: TFont; const AID: string): Boolean;
var
  Prefix: string;
begin
  if AFont = nil then
    AFont := Application.MainForm.Font;
  with AFont, TRegistry.Create do
    try
      Prefix := AID + SFont;
      Result := OpenKey(RegKey, False) and ValueExists(Prefix + SName);
      if Result then
      begin
        Name := ReadString(Prefix + SName);
        Style := TFontStyles(Byte(ReadInteger(Prefix + SStyle)));
        Size := ReadInteger(Prefix + SSize);
        Color := ReadInteger(Prefix + SColor);
      end;
    finally
      Free;
    end;
end;

{ Trackbars }

function SetTrackBarRange(ATrackBar: TTrackBar; AMin, AMax: Integer): Boolean;
var
  Temp: Integer;
begin
  Result := False;
  if AMin <= AMax then
    with ATrackBar do
    begin
      if Orientation = trVertical then
      begin
        Temp := AMin;
        AMin := -AMax;
        AMax := -Temp;
      end;
      if AMin <= Max then
      begin
        Min := AMin;
        Max := AMax;
      end
      else
      begin
        Max := AMax;
        Min := AMin;
      end;
      Result := True;
    end;
end;

function SetTrackBarRange(ATrackBar: TTrackBar;
  const ARange: TIntRange): Boolean;
begin
  Result := SetTrackBarRange(ATrackBar, ARange.Min, ARange.Max);
end;

function SetTrackBarRange(ATrackBar: TTrackBar; const AMin, AMax,
  AFactor: Real; ALogarithmic: Boolean): Boolean;
var
  MinSign, MaxSign: Integer;
  Min, Max: Real;
begin
  Result := False;
  if (AMin <= AMax) and (AFactor > 0) then
  begin
    if ALogarithmic then
    begin
      MinSign := Sign(AMin);
      MaxSign := Sign(AMax);
      if (MinSign = 0) or (MaxSign = 0) or (MinSign + MaxSign = 0) then
        Exit;
      Min := Log10(AMin);
      Max := Log10(AMax);
    end
    else
    begin
      Min := AMin;
      Max := AMax;
    end;
    Result := SetTrackBarRange(ATrackBar, Round(Min * AFactor), Round(Max *
      AFactor));
  end;
end;

function SetTrackBarRange(ATrackBar: TTrackBar; const ARange: TRange;
  const AFactor: Real; ALogarithmic: Boolean): Boolean;
begin
  Result := SetTrackBarRange(ATrackBar, ARange.Min, ARange.Max, AFactor,
    ALogarithmic);
end;


procedure SetTrackBarValue(ATrackBar: TTrackBar; const AFactor, AValue: Real;
  ALogarithmic: Boolean);
var
  Value: Real;
begin
  Value := AValue;
  if ALogarithmic then
    Value := Log10(Value);
  with ATrackBar do
    Position := SignFactor[Boolean(Orientation)] * Round(Value * AFactor);
end;

function TrackBarValue(ATrackBar: TTrackBar; const AFactor: Real;
  ALogarithmic: Boolean): Real;
begin
  with ATrackBar do
    Result := SignFactor[Boolean(Orientation)] * Position / AFactor;
  if ALogarithmic then
    Result := Power(10, Result);
end;


{ TTrackBarLabel }

constructor TTrackBarLabel.Create(ATrackBar: TTrackBar;
  const ACaption: string; AIndex: Integer; AClickEvent: TMouseEvent);
begin
  inherited Create(ATrackBar);
  Parent := ATrackBar.Parent;
  Align := alCustom;
  Caption := ACaption;
  FIndex := AIndex;
  if Assigned(AClickEvent) then
  begin
    Cursor := crHandPoint;
    OnMouseDown := AClickEvent;
  end;
end;

procedure CreateTrackBarLabels(ATrackBar: TTrackBar; AFactor,
  AFrequency: Integer; ANegative: Boolean; AZeroClickEvent: TMouseEvent);
var
  Pos, IndexBase, Interval, Factor: Integer;
  ClickEvents: array[Boolean] of TMouseEvent;
begin
  with ATrackBar do
  begin
    TickStyle := tsAuto;
    Pos := Min + 1;
    IndexBase := -Pos;
    Interval := AFactor * AFrequency;
    Dec(Pos, Pos mod Interval + Ord(Pos > 0) * Interval);
    Factor := SignFactor[(Orientation = trVertical) xor ANegative] * AFactor;
    ClickEvents[False] := nil;
    ClickEvents[True] := AZeroClickEvent;
    while Pos < Max do
    begin
      TTrackBarLabel.Create(ATrackBar, IntToStr(Pos div Factor), IndexBase +
        Pos, ClickEvents[Pos = 0]);
      Inc(Pos, Interval);
    end;
  end;
end;

function CreateZeroLabel(ATrackBar: TTrackBar;
  AClickEvent: TMouseEvent): TTrackBarLabel;
begin
  Result := TTrackBarLabel.Create(ATrackBar, '0', -(ATrackBar.Min + 1),
    AClickEvent);
end;

procedure CreateLogTrackBarScale(ATrackBar: TTrackBar; const AFactor: Real;
  AZeroClickEvent: TMouseEvent);
var
  Inverted: Boolean;
  Factor, Value: Real;
  Index, I, PrefixIndex, N, J, Pos: Integer;
  ClickEvents: array[Boolean] of TMouseEvent;
begin
  with ATrackBar do
  begin
    TickStyle := tsManual;
    Inverted := Orientation = trVertical;
    Factor := SignFactor[Inverted] * AFactor;
    Index := 0;
    ClickEvents[False] := nil;
    ClickEvents[True] := AZeroClickEvent;
    for I := Floor(IfThen(Inverted, -Max, Min) / AFactor) to Ceil(IfThen(
      Inverted, -Min, Max) / AFactor) do
    begin
      PrefixIndex := DivRem(I, 3, N);
      Value := IntPower(10, N);
      for J := 1 to 9 do
      begin
        Pos := Round((I + Log10(J)) * Factor);
        if InRange(Pos, Min, Max) then
        begin
          SetTick(Pos);
          if J in [1, 2, 5] then
            TTrackBarLabel.Create(ATrackBar, Format('%.7g%s%s', [J * Value,
              DupeString(' ', Ord(PrefixIndex <> 0)), MetricPrefixes[
              PrefixIndex]]), Index, ClickEvents[Pos = 0]);
          Inc(Index);
        end;
      end;
    end;
  end;
end;

function CreateLogTrackBarScale(ATrackBar: TTrackBar; const AMin, AMax,
  AFactor: Real; AZeroClickEvent: TMouseEvent): Boolean; overload;
begin
  Result := SetTrackBarRange(ATrackBar, AMin, AMax, AFactor, True);
  if Result then
    CreateLogTrackBarScale(ATrackBar, AFactor, AZeroClickEvent);
end;

function CreateLogTrackBarScale(ATrackBar: TTrackBar; const ARange: TRange;
  const AFactor: Real; AZeroClickEvent: TMouseEvent): Boolean; overload;
begin
  Result := CreateLogTrackBarScale(ATrackBar, ARange.Min, ARange.Max, AFactor,
    AZeroClickEvent);
end;


function EnumTrackBarLabels(ATrackBar: TTrackBar;
  AEnumProc: TTrackBarLabelEnumProc; Instance: Pointer): Boolean;
var
  I: Integer;
begin
  Result := False;
  with ATrackBar do
    for I := 0 to ComponentCount - 1 do
      if (Components[I] is TTrackBarLabel) and not AEnumProc(TTrackBarLabel(
        Components[I]), Instance) then
        Exit;
  Result := True;
end;

function GetTickPos(ATrackBar: TTrackBar; AIndex: Integer): Integer;
begin
  with ATrackBar do
  begin
    Result := SendMessage(Handle, TBM_GETTICPOS, AIndex, 0);
    if Result <> -1 then
      case Orientation of
        trHorizontal: Inc(Result, Left);
        trVertical: Inc(Result, Top);
      end;
  end;
end;

function AlignLabel(ALabel: TTrackBarLabel; Instance: Pointer): Boolean;
var
  Pos: Integer;
  TrackBar: TTrackBar;
begin
  with ALabel do
  begin
    TrackBar := TTrackBar(Owner);
    Pos := GetTickPos(TrackBar, Index);
    case TrackBar.Orientation of
      trHorizontal:
        SetBounds(Pos - Width div 2, TrackBar.BoundsRect.Bottom, Width,
          Height);
      trVertical:
        SetBounds(TrackBar.BoundsRect.Right + 1, Pos - Height div 2, Width,
          Height);
    end;
  end;
  Result := True;
end;

procedure AlignTrackBarLabels(ATrackBar: TTrackBar);
begin
  EnumTrackBarLabels(ATrackBar, AlignLabel);
end;

function AlignTrackBarLabelsProc(Control: TControl;
  Instance: Pointer): Boolean;
begin
  AlignTrackBarLabels(TTrackBar(Control));
  Result := True;
end;

procedure AlignTrackBarsLabels(AContainer: TWinControl);
begin
  EnumerateControls(AContainer, TTrackBar, AlignTrackBarLabelsProc);
end;

function EnableLabel(ALabel: TTrackBarLabel; Instance: Pointer): Boolean;
begin
  ALabel.Enabled := Boolean(Instance);
  Result := True;
end;

procedure SetEnableTrackBarLabels(ATrackBar: TTrackBar; AEnabled: Boolean);
begin
  EnumTrackBarLabels(ATrackBar, EnableLabel, Pointer(AEnabled));
end;


procedure ClearTicks(ATrackBar: TTrackBar; ARedraw: Boolean);
begin
  SendMessage(ATrackBar.Handle, TBM_CLEARTICS, Ord(ARedraw), 0);
end;

procedure SetTrackBarSliderVisible(ATrackBar: TTrackBar;
  ASliderVisible: Boolean);
begin
  SetWindowStyle(ATrackBar.Handle, TBS_NOTHUMB, not ASliderVisible);
end;

end.
