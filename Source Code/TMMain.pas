unit TMMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Menus, SNAIcon, Lite, WaveFmt,
  TMKernel;

type
  TfmMain = class(TForm)
    MainMenu1: TMainMenu;
    Options1: TMenuItem;
    miFadeIn: TMenuItem;
    miFadeOut: TMenuItem;
    N2: TMenuItem;
    miFont: TMenuItem;
    miMinimizeToSNA: TMenuItem;
    miAbout: TMenuItem;
    dlgFont: TFontDialog;
    snaiAccessIcon: TSNAIcon;
    PopupMenu1: TPopupMenu;
    miActive: TMenuItem;
    N1: TMenuItem;
    miExit: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure miFadeInClick(Sender: TObject);
    procedure miFadeOutClick(Sender: TObject);
    procedure miFontClick(Sender: TObject);
    procedure miMinimizeToSNAClick(Sender: TObject);
    procedure miAboutClick(Sender: TObject);
    procedure snaiAccessIconMinimizeTo(Sender: TObject);
    procedure miActiveClick(Sender: TObject);
    procedure miExitClick(Sender: TObject);
    procedure dlgFontApply(Sender: TObject; Wnd: HWND);
    procedure test1Click(Sender: TObject);
    procedure test21Click(Sender: TObject);
    procedure test31Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure UpdateTitle;
    procedure ApplicationRestore(Sender: TObject);
    procedure WMSysColorChange(var Message: TMessage); message WM_SYSCOLORCHANGE;
  public
    procedure AssignFontToChildren;
    procedure UpdateControls(Sender: TObject; Settings: TTMSettings);
    procedure ArrangeByDefault;
  end;

const
  LevelSliderFactor = 50;
  FrequencySliderFactor = 1e3;
  FrequencySliderPrecision = 4;
  FrequencyDifferenceSliderFactor = 1000;
  PhaseSliderFactor = 10 * DegFactor;
  SliderSize = 21;

var
  fmMain: TfmMain;
  TM: TTM;
  CanActivate: Boolean;
  PCMFormats: TPCMFormats;
  StartTime: TDateTime;
  CurrentControl: TObject;
  ControlUpdateCount: Integer;

procedure ExitControls(Settings: TTMSettings);
function RespondControlEvent(Control: TObject): Boolean;
procedure SetWorkFunctionByControl(Sender: TObject);
procedure SetRealValueByControl(AIndex: TTMSetting; AControl: TObject;
  const AFactor: Real = 1; ALogarithmic: Boolean = False);

procedure Toggle;
procedure ScrollRealSetting(Setting: TTMSetting; var Key: Word;
  Shift: TShiftState);
function ActiveTime: TDateTime;
procedure Initialize;

procedure UpdateValueControls(AEditControl: TEdit;
  ASliderControl: TTrackBar; const AValue, AEditFactor, ASliderFactor: Real;
  ALogSlider: Boolean = False; const ALogSliderPrecision: Integer = 0);
procedure UpdateValueControlsEnable(AEditControl: TEdit;
  ASliderControl: TTrackBar; AEnabled: Boolean);

procedure SetupSliders(AContainer: TWinControl);
  
type
  TFuncProc = function(const X: Real; Instance: Pointer): Real;

procedure DrawFuncGraph(APaintBox: TPaintBox; AFuncProc: TFuncProc;
  const APhase: Real = 0; AInstance: Pointer = nil);

procedure DrawTMFuncGraph(APaintBox: TPaintBox; const AFuncRec: TTMFuncRec;
  const APhase: Real = 0);

implementation

uses
  Types, Math, Registry, CommCtrl,
{$IF RTLVersion >= 15.0}
  Themes,
{$IFEND}
  Lite1, Lite2, CtlUtils,
  TMConst, TMPower, TMFunction, TMFuncParams, TMLevel, TMFrequency,
  TMPhase, TMModulation, TMDuration, TMMaster, TMOutput, TMTimer,
  TMAbout;

{$R *.dfm}
{$R WindowsXP.res}

function SetupSlider(Control: TControl; Instance: Pointer): Boolean;
begin
  with TTrackBar(Control) do
  begin
    ThumbLength := PhysPixels(SliderSize);
    ChangeWindowStyle(Handle, 0, TBS_ENABLESELRANGE);
  end;
  Result := True;
end;

procedure SetupSliders(AContainer: TWinControl);
begin
  EnumerateControls(AContainer, TTrackBar, SetupSlider);
end;

procedure ExitControls(Settings: TTMSettings);
var
  Setting: TTMSetting;
begin
  if TM <> nil then
  begin
    for Setting := Low(TTMSetting) to High(TTMSetting) do
      if (Setting in Settings) and not TM.Accept[Setting] then
        Exclude(Settings, Setting);
    fmMain.UpdateControls(TM, Settings);
  end;
end;

function RespondControlEvent(Control: TObject): Boolean;
begin
  Result := (TM <> nil) and (ControlUpdateCount = 0);
  if Result then
    CurrentControl := Control;
end;

procedure SetWorkFunctionByControl(Sender: TObject);
begin
  if RespondControlEvent(Sender) then
    try
      with (Sender as TComboBox) do
        TM.WorkFunctions[TTMWave(Tag)] := TTMWorkFunctionClass(
          Items.Objects[ItemIndex]);
    finally
      CurrentControl := nil;
    end;
end;

procedure SetRealValueByControl(AIndex: TTMSetting; AControl: TObject;
  const AFactor: Real; ALogarithmic: Boolean);
var
  Value: Extended;
  I: Integer;
begin
  if RespondControlEvent(AControl) then
    try
      if AControl is TEdit then
        if TryStrToFloat((AControl as TEdit).Text, Value) then
          Value := Value / AFactor
        else
          Exit
      else
      if AControl is TTrackBar then
      begin
        Value := TrackBarValue(AControl as TTrackBar, AFactor, ALogarithmic);
        if ALogarithmic then
          Value := Prec(Value, FrequencySliderPrecision);
      end
      else
      if AControl = fmFrequency.lbNote then
      begin
        I := fmFrequency.lbNote.ItemIndex;
        if I = -1 then
          Exit;
        Value := TMNoteFrequency(I);
      end
      else
        Exit;
      TM.RealSettings[AIndex] := Value;
    finally
      CurrentControl := nil;
    end;
end;

procedure Toggle;
begin
  if (TM <> nil) then
    TM.Active := not TM.Active and CanActivate;
end;

procedure ScrollRealSetting(Setting: TTMSetting; var Key: Word;
  Shift: TShiftState);
var
  Value, LFactor, Base, Granularity: Real;
  Sign, E: Integer;
begin
  if (TM <> nil) and (Key in [VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT]) then
    with TM do
    begin
      Value := RealSettings[Setting];
      Sign := SignFactor[Key in [VK_DOWN, VK_NEXT]];
      E := 0;
      Granularity := 1;
      Base := 10;
      case Setting of
        tmsFrequency, tmsAMFrequency, tmsBMFrequency, tmsFMFrequency,
          tmsPDMFrequency:
          E := Floor(Log10(Value) + Sign * 1e-12) - 1;
        tmsFrequencyDifference:
          E := -2;
        tmsPhaseDifference, tmsPDMAmplitude:
          begin
            Granularity := Pi / 36;
            Base := 6;
          end;
      end;
      Inc(E, Ord(Key in [VK_PRIOR, VK_NEXT]));
      LFactor := Granularity * IntPower(Base, E);
      RealSettings[Setting] := (Round(Value / LFactor) + Sign) * LFactor;
      Key := 0;
    end;
end;

procedure DrawFuncGraph(APaintBox: TPaintBox; AFuncProc: TFuncProc;
  const APhase: Real; AInstance: Pointer);
var
  NX, NY, X, Y0, Y1: Integer;
  KX, KY: Real;
  Start: Boolean;

  function NormFunc(const Offset: Real = 0): Integer;
  begin
    Result := NY - Round(KY * AFuncProc(APhase + KX * (X - NX + Offset),
      AInstance));
  end;

  procedure StepGraph(Y: Integer);
  begin
    with APaintBox.Canvas do
      if Start then
        MoveTo(X, Y)
      else
        LineTo(X, Y);
    Start := False;
  end;

begin
  with APaintBox, Canvas do
  begin
    Pen.Color := clBtnHighlight;
    NX := (Width - 1) div 2;
    NY := (Height - 1) div 2;
    MoveTo(NX, 0);
    LineTo(NX, NY * 2 + 1);
    MoveTo(0, NY);
    LineTo(NX * 2 + 1, NY);
    if Assigned(AFuncProc) then
    begin
      Pen.Color := Font.Color;
      KX := Pi / NX;
      KY := NY;
      Start := True;
      for X := 0 to NX * 2 do
      begin
        Y0 := NormFunc(-0.5);
        Y1 := NormFunc(0.5);
        if Abs(Y1 - Y0) > NY div 2 then
        begin
          StepGraph(Y0);
          StepGraph(Y1);
        end
        else
          StepGraph(NormFunc);
      end;
    end;
  end;
end;

function TMFuncProc(const X: Real; Instance: Pointer): Real;
begin
  Result := TTMWorkFunction(Instance).Func(X);
end;

procedure DrawTMFuncGraph(APaintBox: TPaintBox; const AFuncRec: TTMFuncRec;
  const APhase: Real);
var
  F: TTMWorkFunction;
  Proc: TFuncProc;
begin
  F := nil;
  Proc := nil;
  with AFuncRec do
    if FuncClass <> nil then
    begin
      F := FuncClass.Create(Params);
      Proc := TMFuncProc;
    end;
  try
    DrawFuncGraph(APaintBox, Proc, APhase, F);
  finally
    F.Free;
  end;
end;

function ActiveTime: TDateTime;
begin
  Result := Now - StartTime;
end;

const
  tmsRealSettings1 = [tmsFrequency, tmsFrequencyDifference, tmsPhaseDifference,
    tmsAMLevel, tmsAMFrequency, tmsBMLevel, tmsBMFrequency, tmsFMLevel,
    tmsFMFrequency, tmsPDMAmplitude, tmsPDMFrequency, tmsTransitionTime,
    tmsPassageTime, tmsBufferTime, tmsPrebufferTime];

procedure SaveFuncParamsToStream(const FuncParams: TTMFuncParams;
  Stream: TStream);
var
  I: Integer;
begin
  with FuncParams, Stream do
  begin
    WriteBuffer(DCOffset, SizeOf(DCOffset));
    WriteBuffer(Inv, SizeOf(Inv));
    WriteBuffer(Abs, SizeOf(Abs));
    WriteBuffer(Power, SizeOf(Power));
    WriteBuffer(Tweak, SizeOf(Tweak));
    WriteBuffer(TweakSym, SizeOf(TweakSym));
    WriteBuffer(TweakCurved, SizeOf(TweakCurved));
    for I := 0 to High(Specific) do
      WriteBuffer(Specific[I], SizeOf(Specific[I]));
  end;
end;

procedure LoadFuncParamsFromStream(var FuncParams: TTMFuncParams;
  Stream: TStream);
var
  I: Integer;
begin
  with FuncParams, Stream do
  begin
    ReadBuffer(DCOffset, SizeOf(DCOffset));
    ReadBuffer(Inv, SizeOf(Inv));
    ReadBuffer(Abs, SizeOf(Abs));
    ReadBuffer(Power, SizeOf(Power));
    ReadBuffer(Tweak, SizeOf(Tweak));
    ReadBuffer(TweakSym, SizeOf(TweakSym));
    ReadBuffer(TweakCurved, SizeOf(TweakCurved));
    SetLength(Specific, (Size - Position) div SizeOf(Specific[0]));
    for I := 0 to High(Specific) do
      ReadBuffer(Specific[I], SizeOf(Specific[I]));
  end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
var
  pcmf: TPCMFormats;
begin                                        
  Application.OnRestore := ApplicationRestore;
  UpdateTitle;
  snaiAccessIcon.InfoBalloon.Title := ProductName;
  with TRegistry.Create do
    try
      if OpenKey(RegKey, False) then
      begin
        SetLength(pcmf, $40);    
        SetLength(pcmf, ReadBinaryData(SFormats, Pointer(pcmf)^, Length(pcmf) *
          SizeOf(TPCMFormat)) div SizeOf(TPCMFormat));
        PCMFormats := pcmf;
        if ValueExists(SMinimizeToSNA) then
          miMinimizeToSNA.Checked := ReadBool(SMinimizeToSNA);
        miMinimizeToSNAClick(nil);
      end;
    finally
      Free;
    end;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(TM);
end;

procedure TfmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  I: Integer;
  Setting: TTMSetting;
  S: string;
  Stream: TMemoryStream;
begin
  try
    if Visible then
    begin
      SaveFormPlacement;
      for I := 0 to MDIChildCount - 1 do
        SaveFormPlacement(MDIChildren[I]);
      SaveFont;
    end;
    with TRegistry.Create do
      try
        if OpenKey(RegKey, True) then
        begin
          WriteBool(SMinimizeToSNA, snaiAccessIcon.MinimizeTo);
          WriteBinaryData(SFormats, Pointer(PCMFormats)^, Length(PCMFormats)
            * SizeOf(TPCMFormat));
          if TM <> nil then
            with TM do
            begin
              for Setting := Low(TTMSetting) to High(TTMSetting) do
              begin
                S := TMSettingNames[Setting];
                with TMSettingsInfo[Setting] do
                  case Kind of
                    tmskWorkFunction:
                      WriteString(S, StringByObject(TMWorkFuncs, TObject(
                        WorkFunctions[Wave])));
                    tmskFuncParams:
                      begin
                        Stream := TMemoryStream.Create;
                        try
                          SaveFuncParamsToStream(FuncsParams[Wave], Stream);
                          WriteBinaryData(S, Stream.Memory^, Stream.Size);
                        finally
                          Stream.Free;
                        end;
                      end;
                  end;
                if Setting in tmsRealSettings1 then
                  WriteFloat(S, RealSettings[Setting]);
              end;
              if TMLevel.fmLevel.cbLevelLinked.Checked and (Level_0 = Level_1)
                then
              begin
                DeleteValue(STMSLevel_0);
                DeleteValue(STMSLevel_1);
                WriteFloat(STMSLevel, Level);
              end
              else
              begin
                DeleteValue(STMSLevel);
                WriteFloat(STMSLevel_0, Level_0);
                WriteFloat(STMSLevel_1, Level_1);
              end;
              WriteBool(STMSFadeIn, FadeIn);
              WriteBool(STMSFadeOut, FadeOut);
              WriteString(STMSDevice, DeviceName);
              WriteString(STMSOutputFile, CaptureFile);
            end;
        end;
      finally
        Free;
      end;
  except
    Application.HandleException(Self);
  end;
end;

procedure TfmMain.AssignFontToChildren;
var
  I: Integer;
begin
  for I := 0 to MDIChildCount - 1 do
    MDIChildren[I].Font := Font;
  fmFunction.CalcHeight;
  fmLevel.FormResize(nil);
  fmFrequency.FormResize(nil);
  InvalidateRect(fmFrequency.lbNote.Handle, nil, True);
  fmPhase.FormResize(nil);
end;

procedure TfmMain.FormShow(Sender: TObject);
var
  I: Integer;
begin
  RestoreFont;
  AssignFontToChildren;
  if not RestoreFormPlacement then
    CenterControl(Self, CenterPoint(Screen.DesktopRect));
  ArrangeByDefault;
  for I := 0 to MDIChildCount - 1 do
    RestoreFormPlacement(MDIChildren[I], False);
  if TM <> nil then
    UpdateControls(TM, tmsAny);
end;

procedure TfmMain.ArrangeByDefault;
begin
  fmPower.SetBounds(0, 0, fmLevel.Width, 0);
  fmFunction.SetBounds(fmPower.Width, 0, fmFrequency.Width, 0);
  fmLevel.SetBounds(0, fmPower.Height, 0, 0);
  fmPhase.SetBounds(0, fmLevel.BoundsRect.Bottom, 0, 0);
  fmFrequency.SetBounds(fmLevel.Width, fmFunction.Height, 0,
    fmPhase.BoundsRect.Bottom - fmFunction.Height);
  fmModulation.SetBounds(fmFunction.BoundsRect.Right, 0, 0, 0);
  fmFuncParams.SetBounds(fmFunction.BoundsRect.Right, fmModulation.Height,
    PhysPixels(220), 0);
  fmOutput.SetBounds(fmFuncParams.BoundsRect.Right, fmModulation.Height, 0, 0);
  fmTimer.SetBounds(fmFuncParams.BoundsRect.Right, fmOutput.BoundsRect.Bottom,
    fmTimer.Width, fmTimer.Height);
  fmDuration.SetBounds(fmModulation.BoundsRect.Right - fmDuration.Width,
    fmTimer.BoundsRect.Bottom, fmDuration.Width, fmDuration.Height);
  fmMaster.SetBounds(0, fmPhase.BoundsRect.Bottom, fmDuration.Left, 150);
end;

procedure TfmMain.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  if Msg.CharCode = VK_RETURN then
  begin
    fmPower.OnOff(Self);
    Handled := True;
  end;
end;

procedure TfmMain.UpdateTitle;
var
  Title: string;
begin
  Title := ProductName;
  if (TM <> nil) and TM.Active then
    Title := TM.SettingsInfo + ' - ' + Title;
  Caption := Title;
  snaiAccessIcon.Title := Title;
  Application.Title := Title;
end;

procedure UpdateValueControls(AEditControl: TEdit;
  ASliderControl: TTrackBar; const AValue, AEditFactor, ASliderFactor: Real;
  ALogSlider: Boolean = False; const ALogSliderPrecision: Integer = 0);
const
  EditStrFormats: array[Boolean] of string = ('%1:g', '%.*f');
var
  SetBySlider: Boolean;
  SliderPrecision: Integer;
begin
  if AEditControl <> CurrentControl then
  begin
    SetBySlider := CurrentControl = ASliderControl;
    SliderPrecision := 0;
    if SetBySlider then
    begin
      if ALogSlider then
        SliderPrecision := FracLen(AValue, ALogSliderPrecision)
      else
        SliderPrecision := Ceil(Log10(Abs(ASliderFactor / AEditFactor)) -
          1e-7);
      SliderPrecision := Max(SliderPrecision, 0);
    end;
    AEditControl.Text := Format(EditStrFormats[SetBySlider], [SliderPrecision,
      AValue * AEditFactor]);
  end;
  if ASliderControl <> CurrentControl then
    SetTrackBarValue(ASliderControl, ASliderFactor, AValue, ALogSlider);
end;

procedure UpdateValueControlsEnable(AEditControl: TEdit;
  ASliderControl: TTrackBar; AEnabled: Boolean);
begin
  SetEnableControls([AEditControl, ASliderControl], AEnabled);
  if not AEnabled then
    AEditControl.Clear;
  SetTrackBarSliderVisible(ASliderControl, AEnabled);
  SetEnableTrackBarLabels(ASliderControl, AEnabled);
end;

procedure TfmMain.UpdateControls(Sender: TObject; Settings: TTMSettings);

  procedure UpdateWorkFunctionCombo(AComboControl: TComboBox;
    const Value: TTMWorkFunctionClass);
  begin
    if AComboControl <> CurrentControl then
      AComboControl.ItemIndex := AComboControl.Items.IndexOfObject(TObject(
        Value));
  end;

  procedure UpdateWorkFunctionComboEnable(AComboControl: TComboBox;
    AWorkFunctionSettingIndex: TTMSetting);
  var
    BEnabled: Boolean;
  begin
    BEnabled := TTM(Sender).Accept[AWorkFunctionSettingIndex];
    AComboControl.Enabled := BEnabled;
    if BEnabled then
      Include(Settings, AWorkFunctionSettingIndex)
    else
      AComboControl.ItemIndex := -1;
  end;

  procedure UpdateLevelControls(AEditControl: TEdit; ASliderControl: TTrackBar;
    const AValue: Real; ANegative: Boolean);
  begin
    UpdateValueControls(AEditControl, ASliderControl, AValue,
      SignFactor[ANegative], LevelSliderFactor);
  end;

  procedure UpdateFrequencyControls(AEditControl: TEdit;
    ASliderControl: TTrackBar; const AValue: Real);
  begin
    UpdateValueControls(AEditControl, ASliderControl, AValue, 1,
      FrequencySliderFactor, True, FrequencySliderPrecision);
  end;
  
  procedure UpdatePhaseControls(AEditControl: TEdit; ASliderControl: TTrackBar;
    const AValue: Real);
  begin
    UpdateValueControls(AEditControl, ASliderControl, AValue, DegFactor,
      PhaseSliderFactor);
  end;

  procedure UpdateValueControlsEnableA(AEditControl: TEdit;
    ASliderControl: TTrackBar; AEnabled: Boolean; ASettingIndex: TTMSetting);
  begin
    UpdateValueControlsEnable(AEditControl, ASliderControl, AEnabled);
    if AEnabled then
      Include(Settings, ASettingIndex);
  end;

  procedure UpdateValueControlsEnableB(AEditControl: TEdit;
    ASliderControl: TTrackBar; ASettingIndex: TTMSetting);
  begin
    UpdateValueControlsEnableA(AEditControl, ASliderControl,
      TTM(Sender).Accept[ASettingIndex], ASettingIndex);
  end;

  procedure UpdateModulationControls(AWorkFunctionComboControl: TComboBox;
    ALevelEditControl: TEdit; ALevelSliderControl: TTrackBar;
    AFrequencyEditControl: TEdit; AFrequencySliderControl: TTrackBar;
    AWorkFunctionSettingIndex, ALevelSettingIndex,
    AFrequencySettingIndex: TTMSetting);
  begin
    with TTM(Sender) do
    begin
      if AWorkFunctionSettingIndex in Settings then
        UpdateWorkFunctionCombo(AWorkFunctionComboControl, WorkFunctions[
          TMSettingsInfo[AWorkFunctionSettingIndex].Wave]);
      if Settings * [tmsActive, tmsWorkFunction, AWorkFunctionSettingIndex] <>
        [] then
      begin
        UpdateValueControlsEnableB(ALevelEditControl, ALevelSliderControl,
          ALevelSettingIndex);
        UpdateValueControlsEnableB(AFrequencyEditControl,
          AFrequencySliderControl, AFrequencySettingIndex);
      end;
      if (ALevelSettingIndex in Settings) and (ALevelSettingIndex <>
        tmsPDMAmplitude) then
        UpdateLevelControls(ALevelEditControl, ALevelSliderControl,
          RealSettings[ALevelSettingIndex], False);
      if AFrequencySettingIndex in Settings then
        UpdateFrequencyControls(AFrequencyEditControl, AFrequencySliderControl,
          RealSettings[AFrequencySettingIndex]);
    end;
  end;

const
  OnOffStrings: array[Boolean] of string = (SOn, SOff);
  NotifyStrings: array[Boolean] of string = (SOffNotify, SOnNotify);
var
  BEnabled: Boolean;
  pcmf: TPCMFormat;
  FuncParamsWave: TTMWave;
  FuncParamsFuncChanged: Boolean;
begin
  if not (csDestroying in Application.ComponentState) then
  begin
    Inc(ControlUpdateCount);
    try
      with fmPower, fmLevel, fmFunction, fmFrequency, fmPhase, fmModulation,
        fmDuration, fmOutput, fmTimer, TTM(Sender) do
      begin
        OnSettingsChange := UpdateControls;
        if tmsActive in Settings then
        begin
          btnOnOff.Caption := OnOffStrings[Active];
          if Active then
          begin
            StartTime := Now;
            timerActiveTimer(nil);
          end
          else
            fmPower.Caption := SPowerCaptionOff;
          SetEnableControls([comboDevice, btnOutputSetup, editOutputFile,
            btnBrowseOutputFile], not Active);
          cmbWorkFunction.Enabled := Accept[tmsWorkFunction];
          timerActive.Enabled := Active;
          miActive.Checked := Active;
          if (CurrentControl = timerOnOff) and snaiAccessIcon.Visible then
            snaiAccessIcon.InfoBalloon.Text := Format(NotifyStrings[Active],
              [SettingsInfo]);
          UpdateTimerEnable;
        end;
        if tmsWorkFunction in Settings then
          UpdateWorkFunctionCombo(cmbWorkFunction, WorkFunction);
        if Settings * [tmsActive, tmsWorkFunction] <> [] then
        begin
          BEnabled := Accept[tmsLevel];
          UpdateValueControlsEnableA(editLevel_0, slLevel_0, BEnabled,
            tmsLevel_0);
          UpdateValueControlsEnableA(editLevel_1, slLevel_1, BEnabled,
            tmsLevel_1);
          BEnabled := Accept[tmsLevel_1];
          cbLevelLinked.Enabled := BEnabled;
          if not BEnabled then
            cbLevelLinked.Checked := True;
          BEnabled := Accept[tmsFrequency];
          UpdateValueControlsEnableA(editFrequency, slFrequency, BEnabled,
            tmsFrequency);
          SetEnableControls([lbNote, panFrequencyAdjustment, btnHalfFrequency,
            btnDoubleFrequency, btnNoteMatch, cmbFMWorkFunction], BEnabled);
          if not BEnabled then
            lbNote.ItemIndex := -1;
          UpdateValueControlsEnableB(editFrequencyDifference,
            slFrequencyDifference, tmsFrequencyDifference);
          UpdateValueControlsEnableB(editPhaseDifference, slPhaseDifference,
            tmsPhaseDifference);
          BEnabled := Accept[tmsPhaseOffset];
          paintPhaseOffset.Enabled := BEnabled;
          if BEnabled then
            Include(Settings, tmsPhaseOffset)
          else
          begin
            gbPhaseOffset.Caption := SPhaseOffsetCaption;
            paintPhaseOffset.Repaint;
          end;
          UpdateWorkFunctionComboEnable(cmbAMWorkFunction, tmsAMWorkFunction);
          UpdateWorkFunctionComboEnable(cmbBMWorkFunction, tmsBMWorkFunction);
          UpdateWorkFunctionComboEnable(cmbFMWorkFunction, tmsFMWorkFunction);
          UpdateWorkFunctionComboEnable(cmbPDMWorkFunction, tmsPDMWorkFunction);
        end;
        if (tmsFuncParams in Settings) and Active and Accept[tmsPhaseOffset]
          then
          Include(Settings, tmsPhaseOffset);
        if tmsLevel_0 in Settings then
          UpdateLevelControls(editLevel_0, slLevel_0, Level_0, True);
        if tmsLevel_1 in Settings then
          UpdateLevelControls(editLevel_1, slLevel_1, Level_1, True);
        if tmsFrequency in Settings then
        begin
          UpdateFrequencyControls(editFrequency, slFrequency, Frequency);
          if lbNote <> CurrentControl then
            lbNote.ItemIndex := TMNoteByFrequency(Frequency, True);
        end;
        if tmsFrequencyDifference in Settings then
          UpdateValueControls(editFrequencyDifference, slFrequencyDifference,
            FrequencyDifference, 1, FrequencyDifferenceSliderFactor);
        if tmsPhaseDifference in Settings then
          UpdatePhaseControls(editPhaseDifference, slPhaseDifference,
            PhaseDifference);
        if tmsPhaseOffset in Settings then
        begin
          if Active then
            gbPhaseOffset.Caption := Format(SPhaseOffsetCaption1,
              [RadToDegCycleStr(PhaseOffset, 1)]);
          paintPhaseOffset.Repaint;
        end;
        UpdateModulationControls(cmbAMWorkFunction, editAMLevel, slAMLevel,
          editAMFrequency, slAMFrequency, tmsAMWorkFunction, tmsAMLevel,
          tmsAMFrequency);
        UpdateModulationControls(cmbBMWorkFunction, editBMLevel, slBMLevel,
          editBMFrequency, slBMFrequency, tmsBMWorkFunction, tmsBMLevel,
          tmsBMFrequency);
        UpdateModulationControls(cmbFMWorkFunction, editFMLevel, slFMLevel,
          editFMFrequency, slFMFrequency, tmsFMWorkFunction, tmsFMLevel,
          tmsFMFrequency);
        UpdateModulationControls(cmbPDMWorkFunction, editPDMAmplitude,
          slPDMAmplitude, editPDMFrequency, slPDMFrequency, tmsPDMWorkFunction,
          tmsPDMAmplitude, tmsPDMFrequency);
        if tmsPDMAmplitude in settings then
          UpdatePhaseControls(editPDMAmplitude, slPDMAmplitude, PDMAmplitude);
        FuncParamsWave := TTMWave(fmFuncParams.tcWaves.TabIndex);
        FuncParamsFuncChanged := TMWorkFuncSettings[FuncParamsWave] in
          Settings;
        if (TMFuncParamsSettings[FuncParamsWave] in Settings) or
          FuncParamsFuncChanged then
          fmFuncParams.UpdateControls(FuncParamsFuncChanged);
        if tmsTransitionTime in Settings then
          editTransitionTime.Text := FloatToStr(TransitionTime);
        if tmsPassageTime in Settings then
          editPassageTime.Text := FloatToStr(PassageTime);
        if tmsFadeIn in Settings then
        begin
          miFadeIn.Checked := FadeIn;
        end;
        if tmsFadeOut in Settings then
        begin
          miFadeOut.Checked := FadeOut;
        end;
        if tmsPCMFormat in Settings then
        begin
          fmOutput.Caption := Format(SOutputCaption, [PCMFormatToStr(
            PCMFormat)]);
        end;
        if tmsDevice in Settings then
        begin
          if comboDevice <> CurrentControl then
            comboDevice.ItemIndex := DeviceID + 1;
          Include(Settings, tmsAux1);
        end;
        if tmsOutputFile in Settings then
        begin
          editOutputFile.Text := CaptureFile;
        end;
        if tmsAux1 in Settings then
        begin
          CanActivate := FindFirstSupportedOutPCMFormat(DeviceID, PCMFormats,
            pcmf);
          if CanActivate then
            PCMFormat := pcmf
          else
            fmOutput.Caption := SOutputCaptionUnknownFormat;
          btnOnOff.Enabled := CanActivate;
        end;
        if Active or (tmsActive in Settings) then
          UpdateTitle;
        {if (Settings * [tmsFrequency, tmsLevel, tmsPhaseDifference] <> []) and
          (lvMacro <> CurrentControl) then
          lvMacro.Selected := nil;}
      end;
    finally
      Dec(ControlUpdateCount);
    end;
  end;
end;

procedure TfmMain.miFadeInClick(Sender: TObject);
begin
  if TM <> nil then
    TM.FadeIn := not TM.FadeIn;
end;

procedure TfmMain.miFadeOutClick(Sender: TObject);
begin
  if TM <> nil then
    TM.FadeOut := not TM.FadeOut;
end;

procedure TfmMain.miFontClick(Sender: TObject);
begin
  dlgFont.Font := Font;
  if dlgFont.Execute then
    dlgFontApply(nil, 0);
end;

procedure TfmMain.dlgFontApply(Sender: TObject; Wnd: HWND);
begin
  Font := dlgFont.Font;
  AssignFontToChildren;
end;

procedure TfmMain.miMinimizeToSNAClick(Sender: TObject);
begin
  snaiAccessIcon.MinimizeTo := miMinimizeToSNA.Checked;
end;

procedure TfmMain.miAboutClick(Sender: TObject);
begin
  with TfmAbout.Create(Application) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfmMain.snaiAccessIconMinimizeTo(Sender: TObject);
begin
  Enabled := False; // disable restore animation
end;

procedure TfmMain.ApplicationRestore(Sender: TObject);
begin
  snaiAccessIcon.InfoBalloon.Text := '';
  Enabled := True;
end;

procedure TfmMain.miActiveClick(Sender: TObject);
begin
  Toggle;
end;

procedure TfmMain.miExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfmMain.WMSysColorChange(var Message: TMessage);
begin
{$IF RTLVersion >= 15.0}
  ThemeServices.UpdateThemes;
{$IFEND}
  inherited;
  SendMessage(fmFrequency.slFrequency.Handle, TBM_CLEARSEL, 1, 0);
  SendMessage(fmLevel.slLevel_0.Handle, TBM_CLEARSEL, 1, 0);
  SendMessage(fmLevel.slLevel_1.Handle, TBM_CLEARSEL, 1, 0);
  SendMessage(fmPhase.slPhaseDifference.Handle, TBM_CLEARSEL, 1, 0);
end;

procedure RestoreParams(Settings: TTMSettings = tmsAny);
var
  Setting: TTMSetting;
  S: string;
  Stream: TMemoryStream;
  TempFuncParams: TTMFuncParams;
begin
  try
    with TRegistry.Create do
      try
        if OpenKey(RegKey, False) then
          with TM do
          begin
            if tmsOutputFile in Settings then
              CaptureFile := ReadString(STMSOutputFile);
            if tmsDevice in Settings then
              DeviceID := Max(fmOutput.comboDevice.Items.IndexOf(
                ReadString(STMSDevice)) - 1, -1);
            if tmsFadeIn in Settings then
              FadeIn := ReadBool(STMSFadeIn);
            if tmsFadeOut in Settings then
              FadeOut := ReadBool(STMSFadeOut);
            if tmsLevel in Settings then
              if TMLevel.fmLevel.cbLevelLinked.Checked then
                Level := ReadFloat(STMSLevel)
              else
              begin
                Level_0 := ReadFloat(STMSLevel_0);
                Level_1 := ReadFloat(STMSLevel_1);
              end;
            TempFuncParams.Custom := nil;
            for Setting := Low(TTMSetting) to High(TTMSetting) do
              if Setting in Settings then
              begin
                S := TMSettingNames[Setting];
                with TMSettingsInfo[Setting] do
                  case Kind of
                    tmskWorkFunction:
                      WorkFunctions[Wave] := TTMWorkFunctionClass(
                        ObjectByString(TMWorkFuncs, ReadString(S)));
                    tmskFuncParams:
                      if ValueExists(S) then
                      begin
                        Stream := TMemoryStream.Create;
                        with Stream do
                          try
                            Size := $100;
                            Size := ReadBinaryData(S, Memory^, Size);
                            LoadFuncParamsFromStream(TempFuncParams, Stream);
                            FuncsParams[Wave] := TempFuncParams;
                          finally
                            Free;
                          end;
                      end;
                  end;
                if Setting in tmsRealSettings1 then
                  RealSettings[Setting] := ReadFloat(S);
              end;
          end;
      finally
        Free;
      end;
  except
    Application.HandleException(Application);
  end;
end;

procedure Initialize;
var
  I: Integer;
  S: string;
  Ch: Char;
begin
  TM := TTM.Create;
  RestoreParams(tmsAny);
  for I := 1 to ParamCount do                      // load program file
  begin
    S := ParamStr(I);
    Ch := UpCase(S[1]);
    Delete(S, 1, 1);
    try
      with TM do
        case Ch of
          'S': WorkFunction := TTMSineFunction;
          'Q': WorkFunction := TTMSquareFunction;  // R ?
          'T': WorkFunction := TTMTriangleFunction;
          'W': WorkFunction := TTMWhiteNoiseFunction;
          'P': WorkFunction := TTMPinkNoiseFunction;
          'L': Level := -Abs(StrToFloat(S));
          'F': Frequency := StrToFloat(S);
          'D': PhaseDifference := DegToRad(StrToFloat(S));
        end;
    except
      on EConvertError do;
    end;
  end;
  if ParamCount <> 0 then
  begin
    fmMain.UpdateControls(TM, [tmsAux1]);
    fmMain.WindowState := wsMinimized;
    fmMain.Enabled := False;
    TM.Active := True;
  end;
end;

procedure TfmMain.test1Click(Sender: TObject);

begin
 { TTMTableFunction.SetTable([0,0.2,0.3,0.5,0.7,1,0.5,0.3,0]);
  if (TM <> nil) and TM.Active and (TM.WorkFunction = TTMTableFunction) then
    fmPhase.paintPhaseOffset.Repaint;  }
end;

procedure TfmMain.test21Click(Sender: TObject);
begin
{  TTMTableFunction.SetTable('C:\Documents and Settings\user\Desktop\tab1.wav');
  if (TM <> nil) and TM.Active and (TM.WorkFunction = TTMTableFunction) then
    fmPhase.paintPhaseOffset.Repaint;   }
end;

procedure TfmMain.test31Click(Sender: TObject);
begin
  tm.WorkFunction := nil;
end;

initialization
  PCMFormats := DefPCMFormats;

end.
