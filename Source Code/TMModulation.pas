unit TMModulation;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Lite, TMKernel;

type
  TfmModulation = class(TForm)
    gbAM: TGroupBox;
    gbBM: TGroupBox;
    gbFM: TGroupBox;
    gbPDM: TGroupBox;
    cmbAMWorkFunction: TComboBox;
    cmbBMWorkFunction: TComboBox;
    cmbFMWorkFunction: TComboBox;
    cmbPDMWorkFunction: TComboBox;
    editAMLevel: TEdit;
    editBMLevel: TEdit;
    editFMLevel: TEdit;
    editPDMAmplitude: TEdit;
    editAMFrequency: TEdit;
    editBMFrequency: TEdit;
    editFMFrequency: TEdit;
    editPDMFrequency: TEdit;
    slAMLevel: TTrackBar;
    slBMLevel: TTrackBar;
    slFMLevel: TTrackBar;
    slPDMAmplitude: TTrackBar;
    slAMFrequency: TTrackBar;
    slBMFrequency: TTrackBar;
    slFMFrequency: TTrackBar;
    slPDMFrequency: TTrackBar;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    Bevel7: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure cmbWorkFunctionSelect(Sender: TObject);
    procedure editChange(Sender: TObject);
    procedure editPDMAmplitudeChange(Sender: TObject);
    procedure editKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure slLevelChange(Sender: TObject);
    procedure slFrequencyChange(Sender: TObject);
    procedure slPDMAmplitudeChange(Sender: TObject);
    procedure ControlExit(Sender: TObject);
  private
    function Setting(Control: TObject): TTMSetting;
  end;

var
  fmModulation: TfmModulation;

  ModFrequencySlidersRange: TRange = (Min: 0.25; Max: 400);
  
implementation

{$R *.dfm}

uses
  CtlUtils, TMMain;

procedure TfmModulation.FormCreate(Sender: TObject);
begin
  Constraints.MinWidth := (Width - ClientWidth) + gbPDM.BoundsRect.Right;
  Constraints.MaxWidth := Constraints.MinWidth;
  Constraints.MinHeight := (Height - ClientHeight) + PhysPixels(180);
  cmbAMWorkFunction.Items := TMWorkFuncs;
  cmbBMWorkFunction.Items := TMWorkFuncs;
  cmbFMWorkFunction.Items := TMWorkFuncs;
  cmbPDMWorkFunction.Items := TMWorkFuncs;
  SetupSliders(Self);
  CreateTrackBarLabels(slAMLevel, LevelSliderFactor, 6);
  CreateLogTrackBarScale(slAMFrequency, ModFrequencySlidersRange,
    FrequencySliderFactor);
  CreateTrackBarLabels(slBMLevel, LevelSliderFactor, 6);
  CreateLogTrackBarScale(slBMFrequency, ModFrequencySlidersRange,
    FrequencySliderFactor);
  CreateTrackBarLabels(slFMLevel, LevelSliderFactor, 6);
  CreateLogTrackBarScale(slFMFrequency, ModFrequencySlidersRange,
    FrequencySliderFactor);
  CreateTrackBarLabels(slPDMAmplitude, Round(PhaseSliderFactor / DegFactor),
    90);
  CreateLogTrackBarScale(slPDMFrequency, ModFrequencySlidersRange,
    FrequencySliderFactor);
  FormResize(nil);
end;

procedure TfmModulation.FormResize(Sender: TObject);
begin
  AlignTrackBarsLabels(Self);
end;

procedure TfmModulation.cmbWorkFunctionSelect(Sender: TObject);
begin
  SetWorkFunctionByControl(Sender);
end;

const
  Settings: array[1..8] of TTMSetting = (tmsAMLevel, tmsAMFrequency,
    tmsBMLevel, tmsBMFrequency, tmsFMLevel, tmsFMFrequency, tmsPDMAmplitude,
    tmsPDMFrequency);

function TfmModulation.Setting(Control: TObject): TTMSetting;
begin
  Result := Settings[(Control as TComponent).Tag];
end;

procedure TfmModulation.editChange(Sender: TObject);
begin
  SetRealValueByControl(Setting(Sender), Sender);
end;

procedure TfmModulation.editPDMAmplitudeChange(Sender: TObject);
begin
  SetRealValueByControl(tmsPDMAmplitude, Sender, DegFactor);
end;

procedure TfmModulation.editKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ScrollRealSetting(Settings[(Sender as TComponent).Tag], Key, Shift);
end;

procedure TfmModulation.slLevelChange(Sender: TObject);
begin
  SetRealValueByControl(Setting(Sender), Sender, LevelSliderFactor);
end;

procedure TfmModulation.slFrequencyChange(Sender: TObject);
begin
  SetRealValueByControl(Setting(Sender), Sender, FrequencySliderFactor, True);
end;

procedure TfmModulation.slPDMAmplitudeChange(Sender: TObject);
begin
  SetRealValueByControl(Setting(Sender), Sender, PhaseSliderFactor);
end;

procedure TfmModulation.ControlExit(Sender: TObject);
var
  ExitSettings: TTMSettings;
begin
  if Sender = Self then
    ExitSettings := [tmsAMLevel, tmsAMFrequency, tmsFMLevel, tmsFMFrequency,
      tmsPDMAmplitude, tmsPDMFrequency]
  else
    ExitSettings := [Settings[(Sender as TComponent).Tag]];
  ExitControls(ExitSettings);
end;

end.
