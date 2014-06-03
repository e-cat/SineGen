unit TMPhase;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TfmPhase = class(TForm)
    gbPhaseDifference: TGroupBox;
    gbPhaseOffset: TGroupBox;
    editPhaseDifference: TEdit;
    slPhaseDifference: TTrackBar;
    paintPhaseOffset: TPaintBox;
    divPDTop: TPanel;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure editPhaseDifferenceChange(Sender: TObject);
    procedure editPhaseDifferenceKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure slPhaseDifferenceChange(Sender: TObject);
    procedure ControlExit(Sender: TObject);
    procedure paintPhaseOffsetMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure paintPhaseOffsetMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure paintPhaseOffsetMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure paintPhaseOffsetPaint(Sender: TObject);
  private
    DragPos: Integer;
    procedure labelPDZeroMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  end;

var
  fmPhase: TfmPhase;

implementation

uses
  Lite, CtlUtils, TMKernel, TMMain;

{$R *.dfm}

procedure TfmPhase.FormCreate(Sender: TObject);
begin
  DragPos := Low(Integer);
  Constraints.MinHeight := (Height - ClientHeight) + PhysPixels(130);
  SetupSliders(Self);
  CreateTrackBarLabels(slPhaseDifference, Round(PhaseSliderFactor / DegFactor),
    90, False, labelPDZeroMouseDown);
  FormResize(nil);
end;

procedure TfmPhase.FormResize(Sender: TObject);
begin
  editPhaseDifference.Width := divPDTop.Width - BorderWidth;
  AlignTrackBarLabels(slPhaseDifference);
end;

procedure TfmPhase.editPhaseDifferenceChange(Sender: TObject);
begin
  SetRealValueByControl(tmsPhaseDifference, Sender, DegFactor);
end;

procedure TfmPhase.editPhaseDifferenceKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  ScrollRealSetting(tmsPhaseDifference, Key, Shift);
end;

procedure TfmPhase.slPhaseDifferenceChange(Sender: TObject);
begin
  SetRealValueByControl(tmsPhaseDifference, Sender, PhaseSliderFactor);
end;

procedure TfmPhase.ControlExit(Sender: TObject);
begin
  ExitControls([tmsPhaseDifference]);
end;

procedure TfmPhase.labelPDZeroMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if TM <> nil then
    TM.PhaseDifference := 0;
end;

procedure TfmPhase.paintPhaseOffsetMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DragPos := X;
end;

procedure TfmPhase.paintPhaseOffsetMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin                                                       
  if (DragPos <> Low(Integer)) and (X <> DragPos) then
  begin
    if TM <> nil then
      TM.PhaseOffset := TM.PhaseOffset - _2Pi * (X - DragPos) / (Sender as
        TControl).ClientWidth;
    DragPos := X;
  end;
end;

procedure TfmPhase.paintPhaseOffsetMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  DragPos := Low(Integer);
end;

procedure TfmPhase.paintPhaseOffsetPaint(Sender: TObject);
var
  FuncRec: TTMFuncRec;
  Phase: Real;
begin
  FuncRec.FuncClass := nil;
  Phase := 0;
  if (Sender as TControl).Enabled and (TM <> nil) and TM.Active then
    with TM, FuncRec do
    begin
      FuncClass := WorkFunction;
      Params := FuncParams;
      Phase := PhaseOffset;
    end;
  DrawTMFuncGraph(Sender as TPaintBox, FuncRec, Phase);
end;

end.
