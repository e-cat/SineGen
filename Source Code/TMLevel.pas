unit TMLevel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, TMKernel;

type
  TfmLevel = class(TForm)
    editLevel_0: TEdit;
    editLevel_1: TEdit;
    slLevel_0: TTrackBar;
    slLevel_1: TTrackBar;
    cbLevelLinked: TCheckBox;
    spLeft: TBevel;
    spRight: TBevel;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure editLevelChange(Sender: TObject);
    procedure editLevelKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure slLevelChange(Sender: TObject);
    procedure ControlExit(Sender: TObject);
    procedure cbLevelLinkedClick(Sender: TObject);
  private
    function SliderPartWidth: Integer;
    function Setting(Control: TObject): TTMSetting;
  end;
             
var
  fmLevel: TfmLevel;

implementation

uses
  CommCtrl, Math, Registry, Lite2, CtlUtils, TMConst, TMMain;

{$R *.dfm}

function MaxLabelWidth(ALabel: TTrackBarLabel; Instance: Pointer): Boolean;
begin
  with ALabel do
    if Width > PInteger(Instance)^ then
      PInteger(Instance)^ := Width;
  Result := True;
end;

function TfmLevel.SliderPartWidth: Integer;
begin
  Result := 0;
  EnumTrackBarLabels(slLevel_0, MaxLabelWidth, @Result);
  Inc(Result, slLevel_0.Width + slLevel_1.Width + 2);
end;

procedure TfmLevel.FormCreate(Sender: TObject);
begin
  SetupSliders(Self);
  CreateTrackBarLabels(slLevel_0, LevelSliderFactor, 6, True);
  Constraints.MinWidth := (Width - ClientWidth) + SliderPartWidth;
  Constraints.MaxWidth := Constraints.MinWidth;
  Constraints.MinHeight := (Height - ClientHeight) + PhysPixels(160);
  with TRegistry.Create do
    try
      if OpenKey(RegKey, False) then
      begin
        Inc(ControlUpdateCount);
        try
          fmLevel.cbLevelLinked.Checked := ValueExists(STMSLevel);
        finally
          Dec(ControlUpdateCount);
        end;
      end;
    finally
      Free;
    end;
  FormResize(nil);
end;

var
  ShowAllLabels: Boolean;

function AlignLabel(ALabel: TTrackBarLabel; Instance: Pointer): Boolean;
var
  TrackBar: TTrackBar;
begin
  with ALabel do
  begin
    TrackBar := TTrackBar(Owner);
    SetBounds((fmLevel.ClientWidth - Width) div 2, GetTickPos(TrackBar, Index)
      - Height div 2, Width, Height);
    Visible := ShowAllLabels or (Round((Index + 1) / LevelSliderFactor) mod 12 =
      0);
  end;
  Result := True;
end;

procedure TfmLevel.FormResize(Sender: TObject);
begin
  editLevel_0.Width := (ClientWidth - BorderWidth) div 2;
  editLevel_1.Left := editLevel_0.Width + BorderWidth;
  editLevel_1.Width := editLevel_0.Width;
  spLeft.Width := (ClientWidth - SliderPartWidth) div 2;
  spRight.Width := spLeft.Width;
  ShowAllLabels := slLevel_0.Height >= PhysPixels(30) + -Font.Height *
    slLevel_0.Max div (4 * LevelSliderFactor);
  EnumTrackBarLabels(slLevel_0, AlignLabel);
end;

function SingleSetting(Control: TObject): TTMSetting;
begin
  Result := TTMSetting(Ord(tmsLevel_0) + (Control as TComponent).Tag - 1);
end;

function TfmLevel.Setting(Control: TObject): TTMSetting;
begin
  if cbLevelLinked.Checked then
    Result := tmsLevel
  else
    Result := SingleSetting(Control);
end;

procedure TfmLevel.editLevelChange(Sender: TObject);
begin
  SetRealValueByControl(Setting(Sender), Sender, -1);
end;

procedure TfmLevel.editLevelKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ScrollRealSetting(Setting(Sender), Key, Shift);
end;

procedure TfmLevel.slLevelChange(Sender: TObject);
begin
  SetRealValueByControl(Setting(Sender), Sender, LevelSliderFactor);
end;

procedure TfmLevel.ControlExit(Sender: TObject);
var
  ExitSettings: TTMSettings;
begin
  if Sender = Self then
    ExitSettings := [tmsLevel_0, tmsLevel_1]
  else
    ExitSettings := [SingleSetting(Sender)];
  ExitControls(ExitSettings);
end;

procedure TfmLevel.cbLevelLinkedClick(Sender: TObject);
begin
  if cbLevelLinked.Checked and RespondControlEvent(Sender) then
    try
      TM.Level := RoundTo(TM.Level, -2);
    finally
      CurrentControl := nil;
    end;
end;

end.
