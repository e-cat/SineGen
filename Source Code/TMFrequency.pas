unit TMFrequency;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Lite;

type
  TfmFrequency = class(TForm)
    editFrequency: TEdit;
    editFrequencyDifference: TEdit;
    slFrequency: TTrackBar;
    slFrequencyDifference: TTrackBar;
    lbNote: TListBox;
    panFrequencyAdjustment: TPanel;
    btnHalfFrequency: TButton;
    btnDoubleFrequency: TButton;
    btnNoteMatch: TButton;
    gbFrequencyDifference: TGroupBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure editFrequencyChange(Sender: TObject);
    procedure editFrequencyDifferenceChange(Sender: TObject);
    procedure editKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure slFrequencyChange(Sender: TObject);
    procedure slFrequencyDifferenceChange(Sender: TObject);
    procedure ControlExit(Sender: TObject);
    procedure lbNoteClick(Sender: TObject);
    procedure panFrequencyAdjustmentMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure panFrequencyAdjustmentMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure panFrequencyAdjustmentMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnHalfFrequencyClick(Sender: TObject);
    procedure btnDoubleFrequencyClick(Sender: TObject);
    procedure btnNoteMatchClick(Sender: TObject);
  private
    CapturePos: Integer;
    CaptureFrequency: Real;
    AdjustStrength: Real;
    AdjustResultPrec: Integer;
    procedure labelFDZeroMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;

var
  fmFrequency: TfmFrequency;

  FrequencySliderRange: TRange = (Min: 16; Max: 26e3);
  HighestNote: Integer = 70 {G10};
  LowestNote: Integer = -57 {C0};

function TMNoteFrequency(NoteIndex: Integer): Real;
function TMNoteByFrequency(const Frequency: Real; Exact: Boolean): Integer;

implementation

uses
  Math, Lite1, CtlUtils, TMKernel, TMMain;

{$R *.dfm}

function TMNoteFrequency(NoteIndex: Integer): Real;
begin
  Result := Prec(NoteFrequency(HighestNote - NoteIndex), 5);
end;

function TMNoteByFrequency(const Frequency: Real; Exact: Boolean): Integer;
var
  Error: Real;
begin
  Result := HighestNote - NoteByFrequency(Frequency, Error);
  if not InRange(Result, 0, (HighestNote - LowestNote)) or Exact and not
    IsZero(Error, 1e-3) then
    Result := -1;
end;

procedure TfmFrequency.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  CapturePos := Low(Integer);
  Constraints.MinWidth := (Width - ClientWidth) + editFrequency.Width;
  Constraints.MaxWidth := Constraints.MinWidth;
  Constraints.MinHeight := (Height - ClientHeight) + PhysPixels(260);
  SetupSliders(Self);
  CreateLogTrackBarScale(slFrequency, FrequencySliderRange,
    FrequencySliderFactor);
  CreateZeroLabel(slFrequencyDifference, labelFDZeroMouseDown);
  with lbNote.Items do
  begin
    BeginUpdate;
    try
      Clear;
      for I := HighestNote downto LowestNote do
        Add(NoteName(I));
    finally
      EndUpdate;
    end;
  end;
  FormResize(nil);
end;

procedure TfmFrequency.FormResize(Sender: TObject);
begin
  AlignTrackBarLabels(slFrequency);
  AlignTrackBarLabels(slFrequencyDifference);
end;

const
  Settings: array[1..2] of TTMSetting = (tmsFrequency, tmsFrequencyDifference);

procedure TfmFrequency.editFrequencyChange(Sender: TObject);
begin
  SetRealValueByControl(tmsFrequency, Sender);
end;

procedure TfmFrequency.editFrequencyDifferenceChange(Sender: TObject);
begin
  SetRealValueByControl(tmsFrequencyDifference, Sender);
end;

procedure TfmFrequency.editKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ScrollRealSetting(Settings[(Sender as TComponent).Tag], Key, Shift);
end;

procedure TfmFrequency.slFrequencyChange(Sender: TObject);
begin
  SetRealValueByControl(tmsFrequency, Sender, FrequencySliderFactor, True);
end;

procedure TfmFrequency.slFrequencyDifferenceChange(Sender: TObject);
begin
  SetRealValueByControl(tmsFrequencyDifference, Sender,
    FrequencyDifferenceSliderFactor);
end;

procedure TfmFrequency.ControlExit(Sender: TObject);
var
  ExitSettings: TTMSettings;
begin
  if Sender = Self then
    ExitSettings := [tmsFrequency, tmsFrequencyDifference]
  else
    ExitSettings := [Settings[(Sender as TComponent).Tag]];
  ExitControls(ExitSettings);
end;

procedure TfmFrequency.lbNoteClick(Sender: TObject);
begin
  SetRealValueByControl(tmsFrequency, Sender);
end;

procedure TfmFrequency.panFrequencyAdjustmentMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  AdjustPrec: Real;
begin
  CapturePos := Y;
  CaptureFrequency := TM.Frequency;
  AdjustPrec := 4 + X / (Sender as TControl).ClientWidth * 10;
  AdjustStrength := Exp(-AdjustPrec);
  AdjustResultPrec := 2 + Round(AdjustPrec / Ln(10));
end;

procedure TfmFrequency.panFrequencyAdjustmentMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (CapturePos <> Low(Integer)) and (TM <> nil) then
  begin
    TM.Frequency := Prec(CaptureFrequency * Exp((CapturePos - Y) *
      AdjustStrength), AdjustResultPrec);
  end;
end;

procedure TfmFrequency.panFrequencyAdjustmentMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CapturePos := Low(Integer);
end;

procedure TfmFrequency.btnHalfFrequencyClick(Sender: TObject);
begin
  if TM <> nil then
    TM.Frequency := TM.Frequency / 2;
end;

procedure TfmFrequency.btnDoubleFrequencyClick(Sender: TObject);
begin
  if TM <> nil then
    TM.Frequency := 2 * TM.Frequency;
end;

procedure TfmFrequency.btnNoteMatchClick(Sender: TObject);
begin
  if TM <> nil then
    TM.Frequency := TMNoteFrequency(TMNoteByFrequency(TM.Frequency, False));
end;

procedure TfmFrequency.labelFDZeroMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if TM <> nil then
    TM.FrequencyDifference := 0;
end;

end.
