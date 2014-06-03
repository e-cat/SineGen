unit TMFuncParams;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, TMKernel, Menus;

type
  TfmFuncParams = class(TForm)
    tcWaves: TTabControl;
    Timer1: TTimer;
    panFuncGraph: TPanel;
    pbFuncGraph: TPaintBox;
    PageControl1: TPageControl;
    tsDCOffset: TTabSheet;
    tsPower: TTabSheet;
    tsTweak: TTabSheet;
    tsUnique: TTabSheet;
    divDCOTop: TPanel;
    editDCOffset: TEdit;
    slDCOffset: TTrackBar;
    divPowerTop: TPanel;
    editPower: TEdit;
    slPower: TTrackBar;
    divParamTop: TPanel;
    cmbParam: TComboBox;
    editParam: TEdit;
    slParam: TTrackBar;
    divTweakTop: TPanel;
    editTweak: TEdit;
    cbTweakSym: TCheckBox;
    cbTweakCurved: TCheckBox;
    slTweak: TTrackBar;
    cbInv: TCheckBox;
    cbAbs: TCheckBox;
    PopupMenu1: TPopupMenu;
    miReset: TMenuItem;
    TabSheet5: TTabSheet;
    pbTable: TPaintBox;
    Panel5: TPanel;
    btnBrowseTable: TButton;
    procedure tcWavesChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ControlAction(Sender: TObject);
    procedure cmbParamChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure pbFuncGraphPaint(Sender: TObject);
    procedure miResetClick(Sender: TObject);
  private
    Func: TTMWorkFunctionClass;
    Params: TTMFuncParams;
    SpecificParamSelectedIndexes: array of Integer;
    SpecificParamSliderFactor: Real;
    labelDefParamValue: TLabel;
    procedure UpdateSpecificParamControls(ParamSelectionChanged: Boolean);
    procedure labelResetMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure labelPowerOneMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  public
    procedure UpdateControls(FunctionChanged: Boolean);
  end;

var
  fmFuncParams: TfmFuncParams;

implementation

{$R *.dfm}

uses
  Lite, Lite1, CtlUtils, TMMain;

const
  PowerSliderFactor    = 1000;
  TweakSliderFactor    = 1000;
  DCOffsetSliderFactor = 1000;

procedure TfmFuncParams.UpdateSpecificParamControls(ParamSelectionChanged: Boolean);
var
  I: Integer;
begin
  Inc(ControlUpdateCount);
  try
    I := cmbParam.ItemIndex;
    if ParamSelectionChanged then
    begin
      UpdateValueControlsEnable(editParam, slParam, I <> -1);
      labelDefParamValue.Visible := I <> -1;
      ClearTicks(slParam, False);
      if I <> -1 then
        with Func.SpecificParamInfo(I), Range do
        begin
          SpecificParamSliderFactor := 1e3 / (Max - Min);
          SetTrackBarRange(slParam, Round(Min * SpecificParamSliderFactor),
            Round(Max * SpecificParamSliderFactor));
          slParam.SetTick(Round(DefaultValue * SpecificParamSliderFactor));
          AlignTrackBarLabels(slParam);
        end;
    end;
    if I <> -1 then
      UpdateValueControls(editParam, slParam, Params.Specific[I], 1,
        SpecificParamSliderFactor);
  finally
    Dec(ControlUpdateCount);
  end;
end;

procedure TfmFuncParams.UpdateControls(FunctionChanged: Boolean);

  procedure UpdateCBControl(ACheckBoxControl: TCheckBox; AChecked: Boolean);
  begin
    if ACheckBoxControl <> CurrentControl then
      with ACheckBoxControl do
        Checked := Enabled and AChecked;
  end;

var
  Wave: TTMWave;
  I, FuncIndex, SPCount, OldCount: Integer;
  AppParams: TTMFuncParamMask;
begin
  Inc(ControlUpdateCount);
  try
    Wave := TTMWave(tcWaves.TabIndex);
    if TM <> nil then
    begin
      Params := TM.FuncsParams[Wave];
      if FunctionChanged then
      begin
        Func := TM.WorkFunctions[Wave];
        FuncIndex := TMWorkFuncs.IndexOfObject(TObject(Func));
        AppParams := [];
        SPCount := 0;
        if Func <> nil then
          with Func do
          begin
            AppParams := ApplicableParams;
            SPCount := SpecificParamCount;
          end;
        tsDCOffset.TabVisible := tmfpDCOffset in AppParams;
        cbInv.Enabled := tmfpInv in AppParams;
        cbAbs.Enabled := tmfpAbs in AppParams;
        tsPower.TabVisible := tmfpPower in AppParams;
        tsTweak.TabVisible := tmfpTweak in AppParams;
        with Func, Params, cmbParam, Items do
        begin
          OldCount := Length(Specific);
          SetLength(Specific, SPCount);
          Clear;
          tsUnique.TabVisible := SPCount > 0;
          for I := 0 to SPCount - 1 do
            with SpecificParamInfo(I) do
            begin
              Add(DispName);
              if I >= OldCount then
                Specific[I] := DefaultValue;
            end;
          if FuncIndex <> -1 then
            ItemIndex := SpecificParamSelectedIndexes[FuncIndex]
          else
            ItemIndex := 0;
        end;
      end;
      pbFuncGraph.Repaint;
      with Params do
      begin
        UpdateValueControls(editDCOffset, slDCOffset, DCOffset, 1,
          DCOffsetSliderFactor);
        UpdateCBControl(cbInv, Inv);
        UpdateCBControl(cbAbs, Abs);
        UpdateValueControls(editPower, slPower, Power, 1,
          PowerSliderFactor, True, 4);
        UpdateValueControls(editTweak, slTweak, Tweak, 1,
          TweakSliderFactor);
        if cbTweakSym <> CurrentControl then
          cbTweakSym.Checked := TweakSym;
        if cbTweakCurved <> CurrentControl then
          cbTweakCurved.Checked := TweakCurved;
      end;
      UpdateSpecificParamControls(FunctionChanged);
    end;
  finally
    Dec(ControlUpdateCount);
  end;
end;

procedure TfmFuncParams.tcWavesChange(Sender: TObject);
begin
  UpdateControls(True);
end;

procedure TfmFuncParams.FormCreate(Sender: TObject);
begin
  SetLength(SpecificParamSelectedIndexes, TMWorkFuncs.Count);
  SetupSliders(Self);
  CreateLogTrackBarScale(slPower, Range(0.1, 10), 1000, labelPowerOneMouseDown);

  CreateZeroLabel(slDCOffset, labelResetMouseDown).Tag := 1;
  CreateZeroLabel(slTweak, labelResetMouseDown).Tag := 5;

  labelDefParamValue := TTrackBarLabel.Create(slParam, '^', 0,
    labelResetMouseDown);
  labelDefParamValue.Tag := 8;

  FormResize(nil);
end;

procedure TfmFuncParams.FormResize(Sender: TObject);
var
  I: Integer;
begin
  I := BorderWidth;
  editDCOffset.Width := divDCOTop.Width - I;
  editParam.Width := divParamTop.Width - I;
  editPower.Width := divPowerTop.Width - I;
  cmbParam.Width := divParamTop.Width - I;
  editTweak.Width := divTweakTop.Width - I;
  AlignTrackBarsLabels(Self);
end;

procedure TfmFuncParams.Timer1Timer(Sender: TObject);
var
  dbg_Str: string;
begin
  if _dbg_ModAct then dbg_Str := 'modulate ';
  if _dbg_Change then dbg_Str := dbg_Str + 'change ';
  Caption := dbg_Str;
end;

procedure TfmFuncParams.ControlAction(Sender: TObject);
var
  Value: Extended;
  Tag: Integer;
  Log: Boolean;
  Factor: Real;
  Index: Integer;
  BoolValue: Boolean;
begin
  if RespondControlEvent(Sender) then
    try
      BoolValue := False;
      Index := -1;
      Tag := (Sender as TComponent).Tag;
      if Tag = 8 then
        Index := cmbParam.ItemIndex;
      if (Sender is TEdit) then
      begin
        if not TryStrToFloat((Sender as TEdit).Text, Value) then
          Exit;
      end
      else
      if Sender is TTrackBar then
      begin
        Factor := 1000;
        if Tag = 8 then
          Factor := SpecificParamSliderFactor;
        Log := Tag = 4;
        Value := TrackBarValue(Sender as TTrackBar, Factor, Log);
        if Log then
          Value := Prec(Value, 4);
      end
      else
      if Sender is TTrackBarLabel then
        case Tag of
          4: Value := 1;
          8: Value := Func.SpecificParamInfo(Index).DefaultValue;
        else
          Value := 0;
        end
      else
      if Sender is TCheckBox then
        BoolValue := (Sender as TCheckBox).Checked
      else
        Exit;
      with Params do
        case Tag of
          1: DCOffset := Value;
          2: Inv := BoolValue;
          3: Abs := BoolValue;
          4: Power := Value;
          5: Tweak := Value;
          6: TweakSym := BoolValue;
          7: TweakCurved := BoolValue;
          8: Specific[Index] := Value;
        end;
      TM.FuncsParams[TTMWave(tcWaves.TabIndex)] := Params;
    finally
      CurrentControl := nil;
    end;
end;

procedure TfmFuncParams.cmbParamChange(Sender: TObject);
begin
  UpdateSpecificParamControls(True);
end;

procedure TfmFuncParams.labelPowerOneMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  (Sender as TComponent).Tag := 4;
  ControlAction(Sender);
end;

procedure TfmFuncParams.labelResetMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ControlAction(Sender);
end;

procedure TfmFuncParams.pbFuncGraphPaint(Sender: TObject);
var
  Rec: TTMFuncRec;
begin
  Rec.FuncClass := Func;
  Rec.Params := Params;
  DrawTMFuncGraph(Sender as TPaintBox, Rec);
end;

procedure TfmFuncParams.miResetClick(Sender: TObject);
begin
  TM.FuncsParams[TTMWave(tcWaves.TabIndex)] := InitialTMFuncParams;
end;

end.
