unit TMKernel;

interface

uses
  Types, Lite, SysUtils, Classes, WaveFmt, WaveInOut;

const
  TMMaxChannels = 8;

type
  TWaveState = record
    Theta, Amp, ThetaVel, Phase: Real;
  end;

  TWaveChange = record
    Amp_Chg, ThetaVel_Chg, Phase_Chg: Real;
  end;

  TTMCustomFuncParams = class
  protected
    function Copy: TTMCustomFuncParams; virtual; abstract;
  end;

  TTMTableFunctionTable = class(TTMCustomFuncParams)
  private
    FTable: TSingleDynArray;
  protected
    function Copy: TTMCustomFuncParams; override;
  public
    constructor Create(const ATable: array of Single); overload;
    constructor Create(const SourceFileName: string); overload;
    property Table: TSingleDynArray read FTable write FTable;
  end;

  TTMCustomClass = class of TTMCustomFuncParams;

  TTMFuncParam = (tmfpDCOffset, tmfpInv, tmfpAbs, tmfpPower, tmfpTweak);

  TTMFuncParamMask = set of TTMFuncParam;

  TTMFuncParams = record
    DCOffset: Real;
    Inv, Abs: Boolean;
    Power: Real;
    Tweak: Real;
    TweakSym: Boolean;
    TweakCurved: Boolean;
    Specific: array of Real;
    Custom: TTMCustomFuncParams;
  end;

  TTMFuncSpecificParamInfo = record
    Name: string;
    DispName: string;
    Range: TRange;
    DefaultValue: Real;
  end;

  TTMWorkFunction = class
  private
    FDCOffset: Real;
    FDCOffsetValid: Boolean;
    FDCOffsetOrig, FDCOffsetFac: Real;
    FInv, FAbs: Boolean;
    FPower: Real;
    FPowerValid: Boolean;
    FTweak: Real;
    FTweakValid: Boolean;
    FTweakSym, FTweakCurved: Boolean;
    FTweakOrig, FTweakFac: TRealBoolArray;
    FTweakExp: Real;
    FTweakPos: Boolean;
    class function ParamValue(const Params: TTMFuncParams; Index: Integer): Real;
  protected
    function BaseFunc(const Theta: Real): Real; virtual; abstract;
    function GetSpecificParam(Index: Integer): Real; virtual;
    procedure InitSpecificParam(Index: Integer; const Value: Real); virtual;
  public
    class function ApplicableParams: TTMFuncParamMask; virtual; 
    constructor Create(const Params: TTMFuncParams); virtual;
    function EqualParams(const Params: TTMFuncParams): Boolean; virtual;
    class function CustomParamsClass: TTMCustomClass; virtual;
    function Func(const Theta: Real): Real; virtual;
    class function SpecificParamInfo(Index: Integer): TTMFuncSpecificParamInfo; virtual;
    class function SpecificParamCount: Integer; virtual;
  end;

  TTMWorkFunctionClass = class of TTMWorkFunction;

  TTMPeriodicFunction = class(TTMWorkFunction);

  TTMSineFunction = class(TTMPeriodicFunction)
  protected
    function BaseFunc(const Theta: Real): Real; override;
  end;

  TTMSquareFunction = class(TTMPeriodicFunction)
  private
    FPulseWidth: Real;
  protected
    function BaseFunc(const Theta: Real): Real; override;
    function GetSpecificParam(Index: Integer): Real; override;
    procedure InitSpecificParam(Index: Integer; const Value: Real); override;
  public
    class function ApplicableParams: TTMFuncParamMask; override;
    class function SpecificParamInfo(Index: Integer): TTMFuncSpecificParamInfo; override;
    class function SpecificParamCount: Integer; override;
  end;

  TTMTriangleFunction = class(TTMPeriodicFunction)
  protected
    function BaseFunc(const Theta: Real): Real; override;
  end;

  TTMTableFunction = class(TTMPeriodicFunction)
  private
    FTable: TSingleDynArray;
  protected
    function BaseFunc(const Theta: Real): Real; override;
  public
    class function ApplicableParams: TTMFuncParamMask; override;
    constructor Create(const Params: TTMFuncParams); override;
    function EqualParams(const Params: TTMFuncParams): Boolean; override;
  end;

  TTMNoiseFunction = class(TTMWorkFunction)
  public
    class function ApplicableParams: TTMFuncParamMask; override;
  end;

  TTMWhiteNoiseFunction = class(TTMNoiseFunction)
  protected
    function BaseFunc(const Theta: Real = 0): Real; override;
  end;

  TTMPinkNoiseFunction = class(TTMNoiseFunction)
  protected
    function BaseFunc(const Theta: Real = 0): Real; override;
  end;

  TTMFuncRec = record
    FuncClass: TTMWorkFunctionClass;
    Params: TTMFuncParams;
  end;

  TFuncMorph = class
  private
    FFunc, FNewFunc: TTMWorkFunction;
    FMorph: Boolean;
  public
    function ThetaApplicable: Boolean;
    function AmpApplicable: Boolean;
    destructor Destroy; override;
    procedure UpdateFunc(const FuncRec: TTMFuncRec);
    function Func(const Theta, FuncSelection: Real): Real;
    property Morph: Boolean read FMorph;
  end;

  TTMWave = (tmwCarrier, tmwAM, tmwBM, tmwFM, tmwPDM);
  TTMCarrierChannel = 0..TMMaxChannels - 1;

  TTMModWave = Succ(tmwCarrier)..High(TTMWave);

  PTMWaveState = ^TTMWaveState;
  TTMWaveState = record
    Carrier: array[TTMCarrierChannel] of TWaveState;
    Mods: array[TTMModWave] of TWaveState;
  end;

  TTMFuncRecs = array[TTMWave] of TTMFuncRec;

  TTMValueType = (tmvReal, tmvBool, tmvID, tmvString, tmvFuncClass,
    tmvStructured, tmvUnknown);

  TTMSettingKind = (tmskMode, tmskWorkFunction, tmskFuncParams, tmskLevel,
    tmskFrequency, tmskPhase, tmskTime, tmskMisc, tmskSetup);

  TTMSettingInfo = record
    ValueType: TTMValueType;
    Kind: TTMSettingKind;
    Wave: TTMWave;
  end;

  TTMSetting = (tmsActive, tmsWorkFunction, tmsFuncParams, tmsLevel,
    tmsLevel_0, tmsLevel_1, tmsFrequency, tmsFrequencyDifference,
    tmsPhaseDifference, tmsPhaseOffset, tmsAMWorkFunction, tmsAMFuncParams,
    tmsAMLevel, tmsAMFrequency, tmsBMWorkFunction, tmsBMFuncParams, tmsBMLevel,
    tmsBMFrequency, tmsFMWorkFunction, tmsFMFuncParams, tmsFMLevel,
    tmsFMFrequency, tmsPDMWorkFunction, tmsPDMFuncParams, tmsPDMAmplitude,
    tmsPDMFrequency, tmsTransitionTime, tmsPassageTime, tmsProgram,
    tmsProgramReverse, tmsFadeIn, tmsFadeOut, tmsBufferTime, tmsPrebufferTime,
    tmsPCMFormat, tmsDevice, tmsOutputFile, tmsAux1, tmsAux2);

  TTMSettings = set of TTMSetting;

  TTMRealSettings = array[TTMSetting] of Real;

  TTMParamsEvent = procedure(Sender: TObject; Settings: TTMSettings) of
    object;

  TTMWaveSettings = record
    FuncRec: TTMFuncRec;
    Level: Real;
    Frequency: Real;
  end;

  TTMMasterSettingsRec = record
    ByWave: array[TTMWave] of TTMWaveSettings;
    Level_0: Real;
    Level_1: Real;
    FrequencyDifference: Real;
    PhaseDifference: Real;
    TransitionTime: Real;
    PassageTime: Real;
  end;

  TTMMasterSettings = class
  private
    FRec: TTMMasterSettingsRec;
    function GetByWave(Wave: TTMWave): TTMWaveSettings;
  public
    function Copy: TTMMasterSettings;
    destructor Destroy; override;
    property ByWave[Wave: TTMWave]: TTMWaveSettings read GetByWave;
    property Level_0: Real read FRec.Level_0;
    property Level_1: Real read FRec.Level_1;
    property FrequencyDifference: Real read FRec.FrequencyDifference;
    property PhaseDifference: Real read FRec.PhaseDifference;
    property TransitionTime: Real read FRec.TransitionTime;
    property PassageTime: Real read FRec.PassageTime;
  end;

  TTMProgram = class(TList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    function Copy: TTMProgram;
  end;

  TTM = class(TWaveOut)
  private
    FFuncRecs: TTMFuncRecs;
    FRealSettings: TTMRealSettings;
    FFadeOut, FFadeIn: Boolean;
    FOnSettingsChange: TTMParamsEvent;
    FWaveState: TTMWaveState;
    FSelection: Real;
    FFuncs: array[TTMWave] of TFuncMorph;
    FSelection_Chg: Real;
    FModActive: array[TTMModWave] of Boolean;

    FWaveStateChanging: array[TTMWave] of Boolean;
    FWaveChange: array[TTMCarrierChannel] of TWaveChange;
    FModWaveChanges: array[TTMModWave] of TWaveChange;
    FTransitionCount, FPassageCount: Int64;
    FFadingOut: Boolean;
    FStartCount: Integer;
    FProgram: TTMProgram;
    FProgramIndex: Integer;
    FProgramReverse: Boolean;
    function GetAccept(Setting: TTMSetting): Boolean;
    function GetCaptureFile: string;
    function GetDeviceID: Cardinal;
    function GetPCMFormat: TPCMFormat;
    function GetProgram: TTMProgram;
    function GetRealValue(Index: TTMSetting): Real;
    function GetWorkFunction(Index: TTMWave): TTMWorkFunctionClass;
    procedure SetCaptureFile(const Value: string);
    procedure SetDeviceID(const Value: Cardinal);
    procedure SetFadeOut(const Value: Boolean);
    procedure SetPCMFormat(const Value: TPCMFormat);
    procedure SetProgram(const Value: TTMProgram);
    procedure SetRealValue(Index: TTMSetting; const Value: Real);
    procedure SetWorkFunction(Index: TTMWave; Value: TTMWorkFunctionClass);
    function GetMasterSettings: TTMMasterSettings;
    procedure SetMasterSettings(const Value: TTMMasterSettings);
    procedure UpdateWaveParams(var WaveState: TTMWaveState);
    procedure ZeroChange;
    function GetFuncFarams(Index: TTMWave): TTMFuncParams;
    procedure SetFuncParams(Index: TTMWave; const Value: TTMFuncParams);
    function GetSettingsInfo: string;
    procedure SetFadeIn(const Value: Boolean);
  protected
    procedure BeginProcessingData; override;
    procedure EndProcessingData; override;
    function AvailRange(Index: TTMSetting;
      const Settings: TTMRealSettings): TRange;
    procedure ProcessData(var Data; SampleCount: Integer); override;
    procedure RestoreWaveState(const Source); override;
    procedure SaveWaveState(var Dest); override;
    procedure SetActive(const Value: Boolean); override;
    procedure SettingsChange(Settings: TTMSettings); dynamic;
    function WaveStateDataSize: Integer; override;
    procedure UpdateRealSetting(var Settings: TTMRealSettings; Index: TTMSetting;
      const Value: Real; var AffectedSettings: TTMSettings);

    procedure UpdateWorkFunction(var FuncRecs: TTMFuncRecs; Index: TTMWave;
      const Value: TTMWorkFunctionClass; var AffectedSettings: TTMSettings);

    procedure UpdateFuncParams(var FuncRecs: TTMFuncRecs; Index: TTMWave;
      const Value: TTMFuncParams; var AffectedSettings: TTMSettings);

    function SetValues(var FuncRecs: TTMFuncRecs;
      var RealSettings: TTMRealSettings;
      const MasterSettings: TTMMasterSettings): TTMSettings;

    procedure EnsureAvailRange(var Settings: TTMRealSettings;
      var AffectedSettings: TTMSettings);
    function ModActive(Wave: TTMModWave): Boolean;
    function Applicable(Setting: TTMSetting): Boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property Accept[Setting: TTMSetting]: Boolean read GetAccept;
    property AMFrequency: Real index tmsAMFrequency read GetRealValue write
      SetRealValue;
    property AMLevel: Real index tmsAMLevel read GetRealValue write SetRealValue;
    property AMWorkFunction: TTMWorkFunctionClass index tmwAM read
      GetWorkFunction write SetWorkFunction;
    property BMFrequency: Real index tmsBMFrequency read GetRealValue write
      SetRealValue;
    property BMLevel: Real index tmsBMLevel read GetRealValue write SetRealValue;
    property BMWorkFunction: TTMWorkFunctionClass index tmwBM read
      GetWorkFunction write SetWorkFunction;
    property BufferTime: Real index tmsBufferTime read GetRealValue write SetRealValue;
    property CaptureFile: string read GetCaptureFile write SetCaptureFile;
    property DeviceID: Cardinal read GetDeviceID write SetDeviceID;
    property FadeIn: Boolean read FFadeIn write SetFadeIn;
    property FadeOut: Boolean read FFadeOut write SetFadeOut;
    property FMFrequency: Real index tmsFMFrequency read GetRealValue write SetRealValue;
    property FMLevel: Real index tmsFMLevel read GetRealValue write SetRealValue;
    property FMWorkFunction: TTMWorkFunctionClass index tmwFM read
      GetWorkFunction write SetWorkFunction;
    property Frequency: Real index tmsFrequency read GetRealValue write SetRealValue;
    property FrequencyDifference: Real index tmsFrequencyDifference read GetRealValue write SetRealValue;
    property FuncParams: TTMFuncParams index tmwCarrier read GetFuncFarams write SetFuncParams;
    property FuncsParams[Index: TTMWave]: TTMFuncParams read GetFuncFarams write SetFuncParams;
    property Level: Real index tmsLevel read GetRealValue write SetRealValue;
    property Level_0: Real index tmsLevel_0 read GetRealValue write SetRealValue;
    property Level_1: Real index tmsLevel_1 read GetRealValue write SetRealValue;
    property MasterSettings: TTMMasterSettings read GetMasterSettings write SetMasterSettings;
    property PassageTime: Real index tmsPassageTime read GetRealValue write SetRealValue;
    property PCMFormat: TPCMFormat read GetPCMFormat write SetPCMFormat;
    property PDMAmplitude: Real index tmsPDMAmplitude read GetRealValue write SetRealValue;
    property PDMFrequency: Real index tmsPDMFrequency read GetRealValue write SetRealValue;
    property PDMWorkFunction: TTMWorkFunctionClass index tmwPDM
      read GetWorkFunction write SetWorkFunction;
    property PhaseDifference: Real index tmsPhaseDifference read GetRealValue
      write SetRealValue;
    property PhaseOffset: Real index tmsPhaseOffset read GetRealValue write SetRealValue;
    property PrebufferTime: Real index tmsPrebufferTime read GetRealValue write SetRealValue;
    property Prog: TTMProgram read GetProgram write SetProgram;
    property RealSettings[Index: TTMSetting]: Real read GetRealValue write SetRealValue;
    property SettingsInfo: string read GetSettingsInfo;
    property TransitionTime: Real index tmsTransitionTime read GetRealValue write SetRealValue;
    property WorkFunction: TTMWorkFunctionClass index tmwCarrier read
      GetWorkFunction write SetWorkFunction;
    property WorkFunctions[Index: TTMWave]: TTMWorkFunctionClass read
      GetWorkFunction write SetWorkFunction;
    property OnSettingsChange: TTMParamsEvent read FOnSettingsChange write FOnSettingsChange;
  end;

  EInvalidProgram = class(Exception);
  EInvalidTableFile = class(Exception);

const
  TMSettingsInfo: array[TTMSetting] of TTMSettingInfo = (
    (ValueType: tmvBool; Kind: tmskMode),
    (ValueType: tmvFuncClass; Kind: tmskWorkFunction),
    (ValueType: tmvStructured; Kind: tmskFuncParams),
    (Kind: tmskLevel),
    (Kind: tmskLevel),
    (Kind: tmskLevel),
    (Kind: tmskFrequency),
    (Kind: tmskFrequency),
    (Kind: tmskPhase),
    (Kind: tmskPhase),
    (ValueType: tmvFuncClass; Kind: tmskWorkFunction; Wave: tmwAM),
    (ValueType: tmvStructured; Kind: tmskFuncParams; Wave: tmwAM),
    (Kind: tmskLevel; Wave: tmwAM),
    (Kind: tmskFrequency; Wave: tmwAM),
    (ValueType: tmvFuncClass; Kind: tmskWorkFunction; Wave: tmwBM),
    (ValueType: tmvStructured; Kind: tmskFuncParams; Wave: tmwBM),
    (Kind: tmskLevel; Wave: tmwBM),
    (Kind: tmskFrequency; Wave: tmwBM),
    (ValueType: tmvFuncClass; Kind: tmskWorkFunction; Wave: tmwFM),
    (ValueType: tmvStructured; Kind: tmskFuncParams; Wave: tmwFM),
    (Kind: tmskLevel; Wave: tmwFM),
    (Kind: tmskFrequency; Wave: tmwFM),
    (ValueType: tmvFuncClass; Kind: tmskWorkFunction; Wave: tmwPDM),
    (ValueType: tmvStructured; Kind: tmskFuncParams; Wave: tmwPDM),
    (Kind: tmskLevel; Wave: tmwPDM),
    (Kind: tmskFrequency; Wave: tmwPDM),
    (Kind: tmskTime),
    (Kind: tmskTime),
    (ValueType: tmvStructured; Kind: tmskMisc),
    (ValueType: tmvBool; Kind: tmskMode),
    (ValueType: tmvBool; Kind: tmskSetup),
    (ValueType: tmvBool; Kind: tmskSetup),
    (Kind: tmskSetup),
    (Kind: tmskSetup),
    (ValueType: tmvStructured; Kind: tmskSetup),
    (ValueType: tmvID; Kind: tmskSetup),
    (ValueType: tmvString; Kind: tmskSetup),
    (ValueType: tmvUnknown; Kind: tmskMisc),
    (ValueType: tmvUnknown; Kind: tmskMisc)
  );

  tmsCarrierLevel = [tmsLevel..tmsLevel_1];
  tmsAny = [Low(TTMSetting)..High(TTMSetting)];
  TMWorkFuncSettings: array[TTMWave] of TTMSetting = (tmsWorkFunction,
    tmsAMWorkFunction, tmsBMWorkFunction, tmsFMWorkFunction,
    tmsPDMWorkFunction);
  TMFuncParamsSettings: array[TTMWave] of TTMSetting = (tmsFuncParams,
    tmsAMFuncParams, tmsBMFuncParams, tmsFMFuncParams, tmsPDMFuncParams);

  InitialTMFuncParams: TTMFuncParams = (Power: 1; TweakSym: True);

  tmcBase = High(TTMCarrierChannel) + 1;

  tmcAM   = tmcBase + 0;
  tmcBM   = tmcBase + 1;
  tmcFM   = tmcBase + 2;
  tmcPDM  = tmcBase + 3;

  tmcLast = tmcPDM;


var
  TMWorkFuncs: TStrings;

  _dbg_ModAct,
  _dbg_Change: Boolean;

type
  TTMChannel = 0..tmcLast;

threadvar
  Channel: TTMChannel;

function CopyFuncParams(const Source: TTMFuncParams): TTMFuncParams;

implementation

uses
  Math, Lite1;

resourcestring
  SSine        = 'Sine';
  SSquare      = 'Square';
  STriangle    = 'Triangle';
  SSawtooth    = 'Sawtooth';
  SSine3       = 'Sine^3';
  SInvSine2    = 'InvSine^2';
  STable       = 'Table';
  SWhiteNoise  = 'White noise';
  SPinkNoise   = 'Pink noise';
  SCustom      = 'Custom';

  SFrequencyStr   = '%.*f %sHz ';
  SLevelStr       = '%.1f dB ';
  SModulated      = 'modulated ';
  SProgramWorking = 'program working';

  SInvalidProgramDuration = 'Invalid program duration values';

  STableFileMoreThanOneChannel = 'Table file contain extra channels';

function CopyFuncParams(const Source: TTMFuncParams): TTMFuncParams;
begin
  Result := Source;
  with Result do
  begin
    Specific := Copy(Specific);
    if Custom <> nil then
      Custom := Custom.Copy;
  end;
end;

function EqualTMFuncParams(const P1, P2: TTMFuncParams): Boolean;
var
  I: Integer;
begin
  Result := False;
  if (P1.DCOffset = P2.DCOffset) and (P1.Inv = P2.Inv) and (P1.Abs = P2.Abs) and
    (P1.Power = P2.Power) and (P1.Tweak = P2.Tweak) and (P1.TweakSym =
    P2.TweakSym) and (P1.TweakCurved = P2.TweakCurved) and (Length(P1.Specific)
    = Length(P2.Specific)) and (P1.Custom = P2.Custom) then
  begin
    for I := 0 to High(P1.Specific) do
      if P1.Specific[I] <> P2.Specific[I] then
        Exit;
    Result := True;
  end;
end;

{ TTMWorkFunction }

class function TTMWorkFunction.ApplicableParams: TTMFuncParamMask;
begin
  Result := [tmfpDCOffset, tmfpInv, tmfpAbs, tmfpPower, tmfpTweak];
end;

constructor TTMWorkFunction.Create(const Params: TTMFuncParams);
var
  I: Integer;
  B: Boolean;
  AppParams: TTMFuncParamMask;
begin
  FPower := 1;
  AppParams := ApplicableParams;
  with Params do
  begin
    if (tmfpDCOffset in AppParams) and (DCOffset <> 0) then
    begin
      FDCOffset := EnsureRange(DCOffset, -1, 1);
      FDCOffsetOrig := FDCOffset / 2;
      FDCOffsetFac := 1 - System.Abs(FDCOffsetOrig);
      FDCOffsetValid := True;
    end;
    FInv := (tmfpInv in AppParams) and Inv;
    FAbs := (tmfpAbs in AppParams) and Abs;
    if (tmfpPower in AppParams) and (Power <> 1) then
    begin
      FPower := Power;
      FPowerValid := True;
    end;
    if (tmfpTweak in AppParams) and (Tweak <> 0) then
    begin
      FTweak := EnsureRange(Tweak, -1, 1);
      FTweakSym := not FAbs and TweakSym;
      FTweakCurved := TweakCurved;
      if FTweakCurved then
      begin
        FTweakExp := 1 - System.Abs(FTweak);
        FTweakPos := FTweak > 0;
      end
      else
        for B := False to True do
        begin
          FTweakFac[B] := SignFactor[B] * FTweak + 1;
          FTweakOrig[B] := FTweakFac[B] / 2;
        end;
      FTweakValid := True;
    end;
    for I := 0 to SpecificParamCount - 1 do
      InitSpecificParam(I, ParamValue(Params, I));
  end;
end;

class function TTMWorkFunction.CustomParamsClass: TTMCustomClass;
begin
  Result := nil;
end;

function TTMWorkFunction.EqualParams(const Params: TTMFuncParams): Boolean;
var
  I: Integer;
  AppParams: TTMFuncParamMask;
begin
  Result := False;
  AppParams := ApplicableParams;
  if (not (tmfpDCOffset in AppParams) or (Params.DCOffset = FDCOffset)) and (not
    (tmfpInv in AppParams) or (Params.Inv = FInv)) and (not (tmfpAbs in
    AppParams) or (Params.Abs = FAbs)) and (not (tmfpPower in AppParams) or
    (Params.Power = FPower)) and (not (tmfpTweak in AppParams) or (Params.Tweak
    = FTweak) and (Params.TweakSym = FTweakSym) and (Params.TweakCurved =
    FTweakCurved)) then
  begin
    for I := 0 to SpecificParamCount - 1 do
      if ParamValue(Params, I) <> GetSpecificParam(I) then
        Exit;
    Result := True;
  end;
end;

function TTMWorkFunction.Func(const Theta: Real): Real;
var
  TempTheta, T: Real;
  I: Integer;
  B: Boolean;
begin
  TempTheta := Theta;
  if FAbs then
    TempTheta := TempTheta / 2;
  if FTweakValid then
  begin
    T := TempTheta / Pi;
    I := Trunc(T);
    T := Frac(T);
    if T < 0 then
    begin
      Dec(I);
      T := T + 1;
    end;
    B := FTweakSym and (I and 1 <> 0);
    if FTweakCurved then
    begin
      B := FTweakPos xor B;
      if B then
        T := 1 - T;
      T := Power(T, FTweakExp);
      if B then
        T := 1 - T;
    end
    else
      if T < FTweakOrig[B] then
        T := T / FTweakFac[B]
      else
        T := 1 - (1 - T) / FTweakFac[not B];
    TempTheta := (T + I) * Pi;
  end;
  Result := BaseFunc(TempTheta);
  if FPowerValid then
  begin
    B := Result < 0;
    Result := Power(Abs(Result), FPower);
    if B then
      Result := -Result;
  end;
  if FAbs then
    Result := 2 * (Abs(Result) - 0.5);
  if FInv then
    Result := -Result;
  if FDCOffsetValid then
    Result := FDCOffsetFac * Result + FDCOffsetOrig;
end;

function TTMWorkFunction.GetSpecificParam(Index: Integer): Real;
begin
  Result := 0;
end;

procedure TTMWorkFunction.InitSpecificParam(Index: Integer; const Value: Real);
begin
end;

class function TTMWorkFunction.ParamValue(const Params: TTMFuncParams;
  Index: Integer): Real;
begin
  with SpecificParamInfo(Index) do
    if Index < Length(Params.Specific) then
      Result := EnsureRange(Params.Specific[Index], Range)
    else
      Result := DefaultValue;
end;

class function TTMWorkFunction.SpecificParamCount: Integer;
begin
  Result := 0;
end;

class function TTMWorkFunction.SpecificParamInfo(
  Index: Integer): TTMFuncSpecificParamInfo;
begin
end;

{ TTMSineFunction }

function TTMSineFunction.BaseFunc(const Theta: Real): Real;
begin
  Result := Sin(Theta);
end;

{ TTMSquareFunction }

resourcestring
  STMFPPulseWidth = 'Pulse width';

class function TTMSquareFunction.ApplicableParams: TTMFuncParamMask;
begin
  Result := [tmfpDCOffset, tmfpInv];
end;

function TTMSquareFunction.BaseFunc(const Theta: Real): Real;
begin
  if Cycle(Theta) < FPulseWidth then
    Result := 1
  else
    Result := -1;
end;

function TTMSquareFunction.GetSpecificParam(Index: Integer): Real;
begin
  if Index = 0 then
    Result := FPulseWidth
  else
    Result := inherited GetSpecificParam(Index);
end;

procedure TTMSquareFunction.InitSpecificParam(Index: Integer; const Value: Real);
begin
  if Index = 0 then
    FPulseWidth := Value;
end;

class function TTMSquareFunction.SpecificParamCount: Integer;
begin
  Result := 1;
end;

class function TTMSquareFunction.SpecificParamInfo(
  Index: Integer): TTMFuncSpecificParamInfo;
begin
  if Index = 0 then
    with Result do
    begin
      Name := 'PulseWidth';
      DispName := STMFPPulseWidth;
      Range.Min := 0;
      Range.Max := 1;
      DefaultValue := 0.5;
    end;
end;

{ TTMTriangleFunction }

function TTMTriangleFunction.BaseFunc(const Theta: Real): Real;
begin
  Result := Cycle(Theta + Pi / 2);
  if Result > 0.5 then
    Result := 1 - Result;
  Result := 4 * (Result - 0.25);
end;

{ TTMTableFunctionTable }

function TTMTableFunctionTable.Copy: TTMCustomFuncParams;
begin
  Result := TTMTableFunctionTable.Create;
  TTMTableFunctionTable(Result).FTable := System.Copy(FTable);
end;

constructor TTMTableFunctionTable.Create(const ATable: array of Single);
begin
  SetLength(FTable, Length(ATable));
  Move(ATable[0], FTable[0], Length(ATable) * SizeOf(Single));
end;

constructor TTMTableFunctionTable.Create(const SourceFileName: string);
var
  Stream: THandleStream;
  PCMFormat: TPCMFormat;
  SampleCount: Cardinal;
  BitDepth, BlockSize, Max, I, J, Count, Value: Integer;
  Buffer: array[0..$7FF] of Byte;
  Samples8: TPCMSamples8_1 absolute Buffer;
  Samples16: TPCMSamples16_1 absolute Buffer;
  Samples24: TPCMSamples24_1 absolute Buffer;
begin
  Stream := TFileStream.Create(SourceFileName, fmOpenRead + fmShareDenyWrite);
  try
    ReadRIFFWaveHeader(Stream, PCMFormat, SampleCount);
    if PCMFormat.ChannelCount <> 1 then
      raise EInvalidTableFile.CreateRes(@STableFileMoreThanOneChannel);
    BitDepth := PCMFormat.BitDepth;
    BlockSize := BitDepth div 8;
    Max := MaxIntVal(BitDepth) + 1;
    SetLength(FTable, SampleCount);
    I := 0;
    while SampleCount > 0 do
    begin
      Count := Min(SampleCount, SizeOf(Buffer) div BlockSize);
      Stream.ReadBuffer(Buffer, Count * BlockSize);
      for J := 0 to Count - 1 do
      begin
        Value := 0;
        case BitDepth of
          8: Value            := Samples8[J] - 128;
          16: Value           := Samples16[J];
          24: PInt24(@Value)^ := Samples24[J];
        end;
        FTable[I] := Value / Max;
        Inc(I);
      end;
      Dec(SampleCount, Count);
    end;
  finally
    Stream.Free;
  end;
end;

{ TTMTableFunction }

class function TTMTableFunction.ApplicableParams: TTMFuncParamMask;
begin
  Result := [tmfpDCOffset, tmfpInv];
end;

function TTMTableFunction.BaseFunc(const Theta: Real): Real;
begin
  Result := 0;
  if FTable <> nil then
    Result := FTable[Trunc(Cycle(Theta) * Length(FTable))];
end;

constructor TTMTableFunction.Create(const Params: TTMFuncParams);
begin
  inherited Create(Params);
  if Params.Custom is TTMTableFunctionTable then
    FTable := TTMTableFunctionTable(Params.Custom).FTable;
end;

function TTMTableFunction.EqualParams(const Params: TTMFuncParams): Boolean;
begin
  Result := inherited EqualParams(Params) and (TTMTableFunctionTable(
    Params.Custom).FTable = FTable);
end;

{ TTMNoiseFunction }

class function TTMNoiseFunction.ApplicableParams: TTMFuncParamMask;
begin
  Result := [tmfpDCOffset, tmfpInv, tmfpAbs, tmfpPower];
end;

{ TTMWhiteNoiseFunction }

function TTMWhiteNoiseFunction.BaseFunc(const Theta: Real): Real;
begin
  Result := SignedRandom;
end;

{ TTMPinkNoiseFunction }

const
  PinkCoefs: array[0..5] of
    record
      P, V: Single;
    end
    = (
    (P: 0.997; V: 0.011743),
    (P: 0.985; V: 0.012911),
    (P: 0.950; V: 0.019071),
    (P: 0.850; V: 0.035946),
    (P: 0.620; V: 0.043253),
    (P: 0.250; V: 0.101508)
  );

type
  TPinkBuf = array[0..High(PinkCoefs)] of Double;

threadvar
  PinkBufs: array[TTMChannel] of TPinkBuf;

function TTMPinkNoiseFunction.BaseFunc(const Theta: Real): Real;

  function MakePink(var Buf: TPinkBuf; const White: Real): Real;
  var
    I: Integer;
  begin
    for I := 0 to High(PinkCoefs) do
      with PinkCoefs[I] do
        Buf[I] := P * Buf[I] + V * White;
    Result := Sum(Buf);
  end;

begin
  Result := MakePink(PinkBufs[Channel], SignedRandom);
end;

{ TFuncMorph }

function TFuncMorph.AmpApplicable: Boolean;
begin
  Result := (FFunc <> nil) or (FNewFunc <> nil);
end;

destructor TFuncMorph.Destroy;
begin
  FFunc.Free;
  FNewFunc.Free;
end;

function TFuncMorph.Func(const Theta, FuncSelection: Real): Real;
var
  Result1: Real;
begin
  Result := 0;
  if FFunc <> nil then
    Result := FFunc.Func(Theta);
  if FMorph then
  begin
    Result1 := 0;
    if FNewFunc <> nil then
      Result1 := FNewFunc.Func(Theta);
    Result := (1 - FuncSelection) * Result + FuncSelection * Result1;
  end;
end;

function TFuncMorph.ThetaApplicable: Boolean;
begin
  Result := (FFunc <> nil) and (FFunc is TTMPeriodicFunction) or (FNewFunc <>
    nil) and (FNewFunc is TTMPeriodicFunction);
end;

procedure TFuncMorph.UpdateFunc(const FuncRec: TTMFuncRec);
begin
  if FMorph then
  begin
    FFunc.Free;
    FFunc := FNewFunc;
    FNewFunc := nil;
    FMorph := False;
  end;
  with FuncRec do
    if (FuncClass <> nil) and ((FFunc = nil) or (FFunc.ClassType <> FuncClass)
      or not FFunc.EqualParams(Params)) or (FuncClass = nil) and (FFunc <> nil)
      then
    begin
      if FuncClass <> nil then
        FNewFunc := FuncClass.Create(Params);
      FMorph := True;
    end;
end;

{ TTMMasterSettings }

function TTMMasterSettings.Copy: TTMMasterSettings;
var
  Wave: TTMWave;
begin
  Result := TTMMasterSettings.Create;
  Result.FRec := FRec;
  with Result.FRec do
    for Wave := Low(TTMWave) to High(TTMWave) do
      with ByWave[Wave].FuncRec do
        Params := CopyFuncParams(Params);
end;

destructor TTMMasterSettings.Destroy;
var
  Wave: TTMWave;
begin
  for Wave := Low(TTMWave) to High(TTMWave) do
    FRec.ByWave[Wave].FuncRec.Params.Custom.Free;
end;

function TTMMasterSettings.GetByWave(Wave: TTMWave): TTMWaveSettings;
begin
  Result := FRec.ByWave[Wave];
end;

{ TTMProgram }

function TTMProgram.Copy: TTMProgram;
begin
  Result := TTMProgram.Create;
  Result.Assign(Self);
end;

procedure TTMProgram.Notify(Ptr: Pointer; Action: TListNotification);
begin
  with TTMMasterSettings(Ptr) do
    case Action of
      lnAdded:
         try
           List[IndexOf(Ptr)] := Copy;
         except
           Remove(Ptr);
           raise;
         end;
      lnDeleted:
        Free;
    end;
end;

{ TTM }

threadvar
  Morphing: Boolean;
  SetByProgram: Boolean;

function TTM.Applicable(Setting: TTMSetting): Boolean;

  function Applicable2: Boolean;
  begin
    with TMSettingsInfo[Setting] do
      case Kind of
        tmskFuncParams, tmskLevel:
          if Morphing then
            Result := FFuncs[Wave].AmpApplicable
          else
            Result := FFuncRecs[Wave].FuncClass <> nil;
        tmskFrequency, tmskPhase:
          if Morphing then
            Result := FFuncs[Wave].ThetaApplicable
          else
            Result := (FFuncRecs[Wave].FuncClass <> nil) and
              FFuncRecs[Wave].FuncClass.InheritsFrom(TTMPeriodicFunction);
      else
        Result := True;
      end;
  end;

const
  TMModAffSettings: array[TTMWave] of TTMSetting = (tmsActive, tmsLevel,
    tmsLevel_1, tmsFrequency, tmsPhaseDifference);
begin
  with TMSettingsInfo[Setting] do
    Result := ((Wave = tmwCarrier) or Applicable(TMModAffSettings[Wave]))
      and Applicable2 and (Stereo or not (Setting in [tmsLevel_0, tmsLevel_1,
      tmsFrequencyDifference, tmsPhaseDifference]));
end;

function TTM.AvailRange(Index: TTMSetting;
  const Settings: TTMRealSettings): TRange;

  function MinAvailLevel: Real;
  begin
    Result := -AmpdB(MaxIntVal(PCMFormat.BitDepth));
  end;

  function MaxAvailModLevel: Real;
  begin
    Result := Min(-Max(Settings[tmsLevel_0], Settings[tmsLevel_1]),
      Min(Settings[tmsLevel_0], Settings[tmsLevel_1]) - MinAvailLevel);
  end;

  function MaxAvailFrequency: Real;
  begin
    Result := PCMFormat.SamplingRate / 2;
  end;

  function MaxAvailFreqRatio: Real;
  begin
    Result := AmpdB(MaxAvailFrequency / Settings[tmsFrequency]);
  end;

begin
  Result := DoubleRange;
  case Index of
    tmsLevel, tmsLevel_0, tmsLevel_1:
      Result.Min := MinAvailLevel;
    tmsFrequency:
      Result.Max := MaxAvailFrequency;
    tmsFrequencyDifference:
      begin
        Result.Max := MaxAvailFreqRatio * 2;
        Result.Min := -Result.Max;
      end;
    tmsAMLevel:
      Result.Max := MaxAvailModLevel;
    tmsBMLevel:
      Result.Max := (MaxAvailModLevel - Settings[tmsAMLevel]) * 2;
    {tmsAMFrequency, tmsBMFrequency, tmsFMFrequency, tmsPDMFrequency:
      // if work func is periodic
      Result.Max := Settings[tmsFrequency];}
    tmsFMLevel:
      Result.Max := MaxAvailFreqRatio;
  end;
end;

procedure TTM.BeginProcessingData;
var
  Wave: TTMWave;
  FadeIn: Boolean;
begin
  FillChar(FWaveState, SizeOf(FWaveState), 0);
  FadeIn := FFadeIn;
  if FProgram <> nil then
  begin
    if not FProgramReverse then
      FProgramIndex := 0
    else
      FProgramIndex := FProgram.Count - 1;
    FStartCount := 1 + Ord(FadeIn);
  end;
  FTransitionCount := 0;
  FPassageCount := 0;
  for Wave := Low(TTMWave) to High(TTMWave) do
    FFuncs[Wave] := TFuncMorph.Create;
  UpdateWaveParams(FWaveState);
  if FadeIn then
    with FWaveState do
    begin
      Carrier[0].Amp := 1;
      Carrier[1].Amp := 1;
    end
  else
  begin
    FSelection := 1;
    ZeroChange;
    if FProgram = nil then
      FTransitionCount := Round(BufferTime * PCMFormat.SamplingRate);
  end;
  Morphing := True;
  for Wave := Low(TTMModWave) to High(TTMModWave) do
    FModActive[Wave] := ModActive(Wave);
end;

constructor TTM.Create;
var
  //I: Integer;
  Wave: TTMWave;
begin
  inherited Create;

  for Wave := Low(TTMWave) to High(TTMWave) do
    with FFuncRecs[Wave] do
    begin
      FuncClass := TTMSineFunction;
      Params := InitialTMFuncParams;
    end;

  FRealSettings[tmsLevel_0] := -12;
  FRealSettings[tmsLevel_1] := -12;
  FRealSettings[tmsAMFrequency] := 10;
  FRealSettings[tmsBMFrequency] := 10;
  FRealSettings[tmsFrequency] := 1000;
  FRealSettings[tmsFMFrequency] := 10;
  FRealSettings[tmsPDMFrequency] := 10;

  {
  setlength(FProgram, 3);
  for I := 0 to High(FProgram) do
    with FProgram[I] do
    begin
      TransitionTime := 0.5;
      PassageTime := 1;
      ByWave[tmwCarrier].WorkFunction := TTMSineFunction;
      ByWave[tmwAM].WorkFunction := TTMSineFunction;
      ByWave[tmwBM].WorkFunction := TTMSineFunction;
      ByWave[tmwFM].WorkFunction := TTMSineFunction;
      ByWave[tmwPDM].WorkFunction := TTMSineFunction;
      ByWave[tmwAM].Frequency := 3;
      ByWave[tmwBM].Frequency := 3;
      ByWave[tmwFM].Frequency := 3;
      ByWave[tmwPDM].Frequency := 3;
      ByWave[tmwCarrier].Frequency := 440;
      Level_0 := -72;
      Level_1 := -72;
    end;

  with FProgram[0] do
  begin
    TransitionTime := 0.5;
    PassageTime := 1;
    ByWave[tmwCarrier].Frequency := 200;
    Level_0 := -40;
    Level_1 := -40;
    PhaseDifference := -Pi/2;
  end;
  with FProgram[1] do
  begin
    TransitionTime := 2;
    PassageTime := 0.5;
    ByWave[tmwCarrier].WorkFunction := TTMPinkNoiseFunction;
    ByWave[tmwCarrier].Frequency := 677;
    Level_0 := -40;
    Level_1 := -40;
    PhaseDifference := 0;
  end;
  with FProgram[2] do
  begin
    ByWave[tmwCarrier].WorkFunction := TTMSawtoothFunction;
    TransitionTime := 1;
    PassageTime := 0;
    ByWave[tmwCarrier].Frequency := 677;
    Level_0 := -30;
    Level_1 := -30;
    PhaseDifference := 0;
  end;
  {}
end;

destructor TTM.Destroy;
var
  Wave: TTMWave;
begin
  inherited Destroy;
  for Wave := Low(TTMWave) to High(TTMWave) do
    FreeAndNil(FFuncRecs[Wave].Params.Custom);
  FProgram.Free;
end;

procedure TTM.EndProcessingData;
var
  Wave: TTMWave;
begin
  Morphing := False;
  for Wave := Low(TTMWave) to High(TTMWave) do
    FreeAndNil(FFuncs[Wave]);
end;

procedure TTM.EnsureAvailRange(var Settings: TTMRealSettings;
  var AffectedSettings: TTMSettings);
var
  Setting: TTMSetting;
  Range: TRange;
begin
  for Setting := Low(TTMSetting) to High(TTMSetting) do
    if Accept[Setting] then
    begin
      Range := AvailRange(Setting, Settings);
      if not InRange(Settings[Setting], Range) then
      begin
        Settings[Setting] := EnsureRange(Settings[Setting], Range);
        Include(AffectedSettings, Setting);
      end;
    end;
end;

function TTM.GetAccept(Setting: TTMSetting): Boolean;
begin
  if Active then
    Result := SetByProgram or (FProgram = nil) and Applicable(Setting)
  else
    Result := Setting <> tmsPhaseOffset;
end;

function TTM.GetCaptureFile: string;
begin
  Result := inherited CaptureFile;
end;

function TTM.GetDeviceID: Cardinal;
begin
  Result := inherited DeviceID;
end;

function TTM.GetFuncFarams(Index: TTMWave): TTMFuncParams;
begin
  Result := CopyFuncParams(FFuncRecs[Index].Params);
end;

function TTM.GetMasterSettings: TTMMasterSettings;
var
  Setting: TTMSetting;
begin
  Result := TTMMasterSettings.Create;
  with Result.FRec do
  begin
    for Setting := Low(TTMSetting) to High(TTMSetting) do
      with TMSettingsInfo[Setting], ByWave[Wave] do
        case Kind of
          tmskWorkFunction:
            WorkFunction := GetWorkFunction(Wave);
          tmskFuncParams:
            FuncParams := GetFuncFarams(Wave);
          tmskLevel:
            Level := FRealSettings[Setting];
          tmskFrequency:
            Frequency := FRealSettings[Setting];
        end;
    Level_0 := FRealSettings[tmsLevel_0];
    Level_1 := FRealSettings[tmsLevel_1];
    PhaseDifference := FRealSettings[tmsPhaseDifference];
  end;
end;

function TTM.GetPCMFormat: TPCMFormat;
begin
  Result := inherited PCMFormat;
end;

function TTM.GetProgram: TTMProgram;
begin
  Result := nil;
  if FProgram <> nil then
    Result := FProgram.Copy;
end;

function TTM.GetRealValue(Index: TTMSetting): Real;
begin
  case Index of
    tmsBufferTime: Result := inherited BufferTime;
    tmsPrebufferTime: Result := inherited PrebufferTime;
  else
    if Index = tmsLevel then
      Result := AmpdBMean([Level_0, Level_1])
    else
      Result := FRealSettings[Index];
  end;
end;

function TTM.GetSettingsInfo: string;
var
  FrequencyStr, LevelStr, ModulationStr, WorkFunctionStr: string;
  L: Real;
  MPI, Prec, I: Integer;
  Wave: TTMModWave;
begin
  if Active and (FProgram <> nil) then
    Result := SProgramWorking
  else
  begin
    if Accept[tmsFrequency] then
    begin
      L := Log10(Frequency);
      MPI := DivRem(30 + Floor(L), 3, Prec) - 10;
      FrequencyStr := Format(SFrequencyStr, [(2 - Prec) mod 3, Power(10, L -
        MPI * 3), MetricPrefixes[MPI]]);
    end;
    if Accept[tmsLevel] then
      LevelStr := Format(SLevelStr, [Level]);
    for Wave := Low(TTMModWave) to High(TTMModWave) do
      if ModActive(Wave) then
      begin
        ModulationStr := SModulated;
        Break;
      end;
    if WorkFunction <> nil then
    begin
      I := TMWorkFuncs.IndexOfObject(TObject(WorkFunction));
      if I <> -1 then
        WorkFunctionStr := TMWorkFuncs[I];
    end;
    Result := FrequencyStr + LevelStr + ModulationStr + WorkFunctionStr;
  end;
end;

function TTM.GetWorkFunction(Index: TTMWave): TTMWorkFunctionClass;
begin
  Result := FFuncRecs[Index].FuncClass;
end;

function TTM.ModActive(Wave: TTMModWave): Boolean;
const
  LevelSettings: array[TTMModWave] of TTMSetting = (tmsAMLevel, tmsBMLevel,
    tmsFMLevel, tmsPDMAmplitude);
var
  LevelSetting: TTMSetting;
  Value: Real;
begin
  LevelSetting := LevelSettings[Wave];
  if Morphing then
    Value := FWaveState.Mods[Wave].Amp
  else
    Value := FRealSettings[LevelSetting];
  Result := Applicable(LevelSetting) and (Value > 0);
end;

procedure TTM.ProcessData(var Data; SampleCount: Integer);
var
  C: TTMCarrierChannel;
  I, J, Value: Integer;
  NewWaveParams: TTMWaveState;
  Chg, Change: Boolean;
  Wave: TTMWave;
  AMValue, SqrtBMValue, FMValue, HalfPDMValue: Real;
  AMvalues, PMValues, FMValues: array[TTMCarrierChannel] of Real;

  function ChangeRatio(const NewValue, OldValue: Real): Real;
  begin
    Result := Exp(Ln(NewValue / OldValue) / FTransitionCount);
  end;

  function NoVanishing(const X: Real): Boolean;
  begin
    Result := Abs(X) >= 1e-15;
  end;

  function LogNoVanishing(const X: Real): Boolean;
  begin
    Result := NoVanishing(X - 1);
  end;

  procedure IncTheta(var Theta: Real; const ThetaVel: Real);
  begin
    Theta := Theta + ThetaVel;
    if Theta > _2Pi then
      Theta := Theta - _2Pi;
  end;

  function NewModWaveValue(Wave: TTMModWave): Real;
  begin
    with FWaveState.Mods[Wave], FFuncs[Wave] do
    begin
      Result := Amp * Func(Theta, FSelection);
      IncTheta(Theta, ThetaVel);
    end;
  end;

begin                                 _dbg_ModAct := false; _dbg_Change:= false;
  with FWaveState, PCMFormat do
  begin
    if FFadingOut then
    begin
      ZeroChange;
      FTransitionCount := SampleCount;
      for C := 0 to ChannelCount - 1 do
        with FWaveChange[C] do
        begin
          Amp_Chg := ChangeRatio(1, Carrier[C].Amp);
          ThetaVel_Chg := 1;
          Phase_Chg := 0;
        end;
      FWaveStateChanging[tmwCarrier] := True;
      FPassageCount := High(Int64);
      FFadingOut := False;
    end;
    J := 0;
    for I := 0 to SampleCount - 1 do
    begin
      if FTransitionCount = 0 then
        if FPassageCount > 0 then
          Dec(FPassageCount)
        else
        begin
          FTransitionCount := SampleCount - I;
          UpdateWaveParams(NewWaveParams);
          FSelection_Chg := 1 / FTransitionCount;
          Chg := False;
          for C := 0 to ChannelCount - 1 do
            with FWaveChange[C], NewWaveParams.Carrier[C] do
            begin
              Amp_Chg := ChangeRatio(Amp, Carrier[C].Amp);
              ThetaVel_Chg := ChangeRatio(ThetaVel, Carrier[C].ThetaVel);
              Phase_Chg := (Phase - Carrier[C].Phase) / FTransitionCount;
              Chg := Chg or LogNoVanishing(Amp_Chg) or LogNoVanishing(
                ThetaVel_Chg) or NoVanishing(Phase_Chg);
              if not Chg then
              begin
                Carrier[C].Amp      := Amp;
                Carrier[C].ThetaVel := ThetaVel;
                Carrier[C].Phase    := Phase;
              end;
            end;
          FWaveStateChanging[tmwCarrier] := Chg;
          Change := FFuncs[tmwCarrier].Morph or Chg;
          for Wave := Low(TTMModWave) to High(TTMModWave) do
            with FModWaveChanges[Wave], NewWaveParams.Mods[Wave] do
            begin
              Amp_Chg := (Amp - Mods[Wave].Amp) / FTransitionCount;
              ThetaVel_Chg := ChangeRatio(ThetaVel, Mods[Wave].ThetaVel);
              Chg := NoVanishing(Amp_Chg) or LogNoVanishing(ThetaVel_Chg);
              FWaveStateChanging[Wave] := Chg;
              if not Chg then
              begin
                Mods[Wave].Amp      := Amp;
                Mods[Wave].ThetaVel := ThetaVel;
              end;
              Change := Change or FFuncs[Wave].Morph or Chg;
              FModActive[Wave] := Chg or ModActive(Wave);
            end;
          if not Change then
          begin
            Inc(FPassageCount, FTransitionCount - 1);
            FTransitionCount := 0;
          end;
        end;
      if FTransitionCount > 0 then
      begin
        FSelection := FSelection + FSelection_Chg;
        if FWaveStateChanging[tmwCarrier] then
          for C := 0 to ChannelCount - 1 do
            with Carrier[C], FWaveChange[C] do
            begin                                           _dbg_Change := true;
              Amp      := Amp      * Amp_Chg;
              ThetaVel := ThetaVel * ThetaVel_Chg;
              Phase    := Phase    + Phase_Chg;
            end;
        for Wave := Low(TTMModWave) to High(TTMModWave) do
          if FWaveStateChanging[Wave] then
            with Mods[Wave], FModWaveChanges[Wave] do
            begin                                           _dbg_Change := true;
              Amp      := Amp      + Amp_Chg;
              ThetaVel := ThetaVel * ThetaVel_Chg;
            end;
        Dec(FTransitionCount);
      end;
      if FModActive[tmwAM] then
      begin                                                 _dbg_ModAct := true;
        Channel := tmcAM;
        AMValue := Exp(NewModWaveValue(tmwAM));
        for C := 0 to ChannelCount - 1 do
          AMvalues[C] := AMValue;
      end
      else
        for C := 0 to ChannelCount - 1 do
          AMvalues[C] := 1;
      if Stereo and FModActive[tmwBM] then
      begin                                                 _dbg_ModAct := true;
        Channel := tmcBM;
        SqrtBMValue := Exp(NewModWaveValue(tmwBM));
        AMvalues[0] := AMvalues[0] / SqrtBMValue;
        AMvalues[1] := AMvalues[1] * SqrtBMValue;
      end;
      if FModActive[tmwFM] then
      begin                                                 _dbg_ModAct := true;
        Channel := tmcFM;
        FMValue := Exp(NewModWaveValue(tmwFM));
        for C := 0 to ChannelCount - 1 do
          FMValues[C] := FMValue;
      end
      else
        for C := 0 to ChannelCount - 1 do
          FMvalues[C] := 1;
      for C := 0 to ChannelCount - 1 do
        PMvalues[C] := 0;
      if Stereo and FModActive[tmwPDM] then
      begin                                                 _dbg_ModAct := true;
        Channel := tmcPDM;
        HalfPDMValue := NewModWaveValue(tmwPDM);
        PMvalues[0] := PMvalues[0] - HalfPDMValue;
        PMvalues[1] := PMvalues[1] + HalfPDMValue;
      end;
      for C := 0 to ChannelCount - 1 do
        with Carrier[C] do
        begin
          Value := Round(Amp * AMValues[C] * FFuncs[tmwCarrier].Func(Theta +
            Phase + PMValues[C], FSelection));
          IncTheta(Theta, FMValues[C] * ThetaVel);
          case BitDepth of
            8:  Bytes(Data)[J]     := $80 + Value;
            16: SmallInts(Data)[J] := Value;
            24: Ints24(Data)[J]    := PInt24(@Value)^;
            32: LongInts(Data)[J]  := Value;
          end;
          Inc(J);
        end;
    end;
  end;
end;

procedure TTM.RestoreWaveState(const Source);
begin
  FWaveState := TTMWaveState(Source);
end;

procedure TTM.SaveWaveState(var Dest);
begin
  TTMWaveState(Dest) := FWaveState;
end;

procedure TTM.SetActive(const Value: Boolean);
var
  AffectedSettings: TTMSettings;
  ProgramValid: Boolean;
  I, TC, PC: Integer;
begin
  if Value <> Active then
  begin
    AffectedSettings := [tmsActive];
    if Value then
    begin
      if FProgram <> nil then
      begin
        ProgramValid := False;
        for I := 0 to FProgram.Count - 1 do
          with TTMMasterSettings(FProgram[I]), PCMFormat do
          begin
            if (TransitionTime < 0) or (PassageTime < 0) then
              Break;
            TC := Round(TransitionTime * SamplingRate);
            PC := Round(PassageTime * SamplingRate);
            if (TC = 0) and (PC = 0) then
              Break;
          end;
        if not ProgramValid then
          raise EInvalidProgram.CreateRes(@SInvalidProgramDuration);
      end
      else
      begin
        if not Stereo and (Level_0 <> Level_1) then
          Level := RoundTo(Level, -2);
        EnsureAvailRange(FRealSettings, AffectedSettings);
      end;
    end
    else
      if FFadeOut then
      begin
        FFadingOut := True;
        UpdateStream;
        Sleep(Round(BufferTime * 3e3));
      end;
    inherited;
    if not Active then
      FRealSettings[tmsPhaseOffset] := 0;
    SettingsChange(AffectedSettings);
  end;
end;

procedure TTM.SetCaptureFile(const Value: string);
begin
  inherited CaptureFile := Value;
  SettingsChange([tmsOutputFile]);
end;

procedure TTM.SetDeviceID(const Value: Cardinal);
begin
  inherited DeviceID := Value;
  SettingsChange([tmsDevice]);
end;

procedure TTM.SetFadeIn(const Value: Boolean);
begin
  if Value <> FFadeIn then
  begin
    FFadeIn := Value;
    SettingsChange([tmsFadeIn]);
  end;
end;

procedure TTM.SetFadeOut(const Value: Boolean);
begin
  if Value <> FFadeOut then
  begin
    FFadeOut := Value;
    SettingsChange([tmsFadeOut]);
  end;
end;

procedure TTM.SetFuncParams(Index: TTMWave; const Value: TTMFuncParams);
var
  AffectedSettings: TTMSettings;
begin
  AffectedSettings := [];
  UpdateFuncParams(FFuncRecs, Index, Value, AffectedSettings);
  if AffectedSettings <> [] then
  begin
    UpdateStream;
    SettingsChange(AffectedSettings);
  end;
end;

procedure TTM.SetMasterSettings(const Value: TTMMasterSettings);
var
  AffectedSettings: TTMSettings;
begin
  AffectedSettings := SetValues(FFuncRecs, FRealSettings, Value);
  if AffectedSettings <> [] then
  begin
    UpdateStream;
    SettingsChange(AffectedSettings);
  end;
end;

procedure TTM.SetPCMFormat(const Value: TPCMFormat);
var
  SavedMaxPCMChannels: Integer;
begin
  SavedMaxPCMChannels := MaxPCMChannels;
  try
    MaxPCMChannels := TMMaxChannels;
    inherited PCMFormat := Value;
  finally
    MaxPCMChannels := SavedMaxPCMChannels;
  end;
  SettingsChange([tmsPCMFormat]);
end;

procedure TTM.SetProgram(const Value: TTMProgram);
begin
  if not Active then
  begin
    FreeAndNil(FProgram);
    if (Value <> nil) and (Value.Count > 0) then
      FProgram := Value.Copy;
    SettingsChange([tmsProgram]);
  end;
end;

procedure TTM.SetRealValue(Index: TTMSetting; const Value: Real);
var
  AffectedSettings: TTMSettings;
  OldBufferTime, OldPrebufferTime: Real;
begin
  AffectedSettings := [];
  case Index of
    tmsBufferTime, tmsPrebufferTime:
      begin
        OldBufferTime := inherited BufferTime;
        OldPrebufferTime := inherited PrebufferTime;
        case Index of
          tmsBufferTime:
            inherited BufferTime := Value;
          tmsPrebufferTime:
            inherited PrebufferTime := Value;
        end;
        if inherited BufferTime <> OldBufferTime then
          Include(AffectedSettings, tmsBufferTime);
        if inherited PrebufferTime <> OldPrebufferTime then
          Include(AffectedSettings, tmsPrebufferTime);
      end;
  else
    if (Index in [tmsLevel_0, tmsLevel_1]) and not Stereo then
      Index := tmsLevel;
    UpdateRealSetting(FRealSettings, Index, Value, AffectedSettings);
  end;
  if AffectedSettings <> [] then
  begin
    if not (Index in [tmsTransitionTime, tmsPassageTime, tmsBufferTime,
      tmsPrebufferTime]) then
    begin
      if Active then
        EnsureAvailRange(FRealSettings, AffectedSettings);
      UpdateStream;
    end;
    SettingsChange(AffectedSettings);
  end;
end;

procedure TTM.SettingsChange(Settings: TTMSettings);
begin
  if Assigned(FOnSettingsChange) then
    FOnSettingsChange(Self, Settings);
end;

function TTM.SetValues(var FuncRecs: TTMFuncRecs;
  var RealSettings: TTMRealSettings;
  const MasterSettings: TTMMasterSettings): TTMSettings;
var
  Setting: TTMSetting;
begin
  with MasterSettings.FRec do
  begin
    for Setting := Low(TTMSetting) to High(TTMSetting) do
      if not (Setting in tmsCarrierLevel + [tmsPhaseDifference]) then
        with TMSettingsInfo[Setting], ByWave[Wave] do
          case Kind of
            tmskWorkFunction:
              UpdateWorkFunction(FuncRecs, Wave, FuncRec.FuncClass, Result);
            tmskFuncParams:
              UpdateFuncParams(FuncRecs, Wave, FuncRec.Params, Result);
            tmskLevel:
              UpdateRealSetting(RealSettings, Setting, Level, Result);
            tmskFrequency:
              UpdateRealSetting(RealSettings, Setting, Frequency, Result);
          end;
    if Stereo then
    begin
      UpdateRealSetting(RealSettings, tmsLevel_0, Level_0, Result);
      UpdateRealSetting(RealSettings, tmsLevel_1, Level_1, Result);
    end
    else
      UpdateRealSetting(RealSettings, tmsLevel, AmpdBMean([Level_0,
        Level_1]), Result);
    UpdateRealSetting(RealSettings, tmsFrequencyDifference, FrequencyDifference,
      Result);
    UpdateRealSetting(RealSettings, tmsPhaseDifference, PhaseDifference,
      Result);
    UpdateRealSetting(RealSettings, tmsTransitionTime, TransitionTime, Result);
    UpdateRealSetting(RealSettings, tmsPassageTime, PassageTime, Result);
  end;
end;

procedure TTM.SetWorkFunction(Index: TTMWave; Value: TTMWorkFunctionClass);
var
  AffectedSettings: TTMSettings;
begin
  AffectedSettings := [];
  UpdateWorkFunction(FFuncRecs, Index, Value, AffectedSettings);
  if AffectedSettings <> [] then
  begin
    UpdateStream;
    SettingsChange(AffectedSettings);
  end;
end;

procedure TTM.UpdateFuncParams(var FuncRecs: TTMFuncRecs; Index: TTMWave;
  const Value: TTMFuncParams; var AffectedSettings: TTMSettings);
var
  Setting: TTMSetting;
begin
  Setting := TMFuncParamsSettings[Index];
  if Accept[Setting] and not EqualTMFuncParams(Value, FuncRecs[Index].Params)
    then
  begin
    with FuncRecs[Index] do
      if not SetByProgram then
        begin
          if (FuncClass = nil) or ((Value.Custom <> nil) and not
            (Value.Custom is FuncClass.CustomParamsClass)) then
            Exit;
          FreeAndNil(Params.Custom);
          Params := CopyFuncParams(Value);
        end
      else
        Params := Value;
    Include(AffectedSettings, Setting);
  end;
end;

procedure TTM.UpdateRealSetting(var Settings: TTMRealSettings;
  Index: TTMSetting; const Value: Real; var AffectedSettings: TTMSettings);
var
  ValidRange: TRange;
  NewValue: Real;
begin
  if Accept[Index] then
  begin
    case Index of
      tmsLevel, tmsLevel_0, tmsLevel_1:
        ValidRange := Range(-1e3, 0);
      tmsFrequency, tmsAMFrequency, tmsBMFrequency, tmsFMFrequency,
        tmsPDMFrequency:
        ValidRange := Range(1e-9, 1e9);
      tmsFrequencyDifference:
        ValidRange := Range(-1e3, 1e3);
      tmsPhaseDifference:
        ValidRange := TrigRange;
      tmsPhaseOffset:
        ValidRange := DoubleRange;
      tmsAMLevel, tmsBMLevel, tmsFMLevel:
        ValidRange := Range(0, 1e3);
      tmsPDMAmplitude:
        ValidRange := Range(0, Pi);
      tmsTransitionTime, tmsPassageTime:
        ValidRange := NonNegativeRange;
    else
      Exit;
    end;
    if Active then
      ValidRange := IntersectRange(ValidRange, AvailRange(Index, Settings));
    NewValue := EnsureRange(Value, ValidRange);
    if Index = tmsLevel then
    begin
      if (NewValue <> Settings[tmsLevel_0]) or (NewValue <> Settings[
        tmsLevel_1]) then
      begin
        Settings[tmsLevel_0] := NewValue;
        Settings[tmsLevel_1] := NewValue;
        AffectedSettings := AffectedSettings + tmsCarrierLevel;
      end;
    end
    else
      if NewValue <> Settings[Index] then
      begin
        Settings[Index] := NewValue;
        Include(AffectedSettings, Index);
        if Index in [tmsLevel_0, tmsLevel_1] then
          Include(AffectedSettings, tmsLevel);
      end;
  end;
end;

procedure TTM.UpdateWaveParams(var WaveState: TTMWaveState);

  procedure DoUpdate(var FuncRecs: TTMFuncRecs;
    const Settings: TTMRealSettings);
  const
    ModFrequencies: array[TTMModWave] of TTMSetting = (tmsAMFrequency,
      tmsBMFrequency, tmsFMFrequency, tmsPDMFrequency);
  var
    Wave: TTMWave;
    LevelValues, FrequencyValues, PhaseValues: array[TTMCarrierChannel] of
      Real;
    C: TTMCarrierChannel;
    X, OneHzThetaVel: Real;
    MaxPCMVal: Integer;
  begin
    for Wave := Low(TTMWave) to High(TTMWave) do
      FFuncs[Wave].UpdateFunc(FuncRecs[Wave]);
    FSelection := 0;
    with PCMFormat, WaveState do
    begin
      LevelValues[0] := Settings[tmsLevel_0];
      LevelValues[1] := Settings[tmsLevel_1];
      for C := 0 to ChannelCount - 1 do
      begin
        FrequencyValues[C] := Settings[tmsFrequency];
        PhaseValues[C] := 0;
      end;
      if Stereo then
      begin
        X := Exp(Settings[tmsFrequencyDifference] / PowerdBFactor / 2);
        FrequencyValues[0] := FrequencyValues[0] / X;
        FrequencyValues[1] := FrequencyValues[1] * X;
        X := Settings[tmsPhaseDifference] / 2;
        PhaseValues[0] := -X;
        PhaseValues[1] := X;
      end;
      MaxPCMVal := MaxIntVal(BitDepth);
      OneHzThetaVel := _2Pi / SamplingRate;
      for C := 0 to ChannelCount - 1 do
        with Carrier[C] do
        begin
          Amp := MaxPCMVal * AmpdBRatio(LevelValues[C]);
          ThetaVel := OneHzThetaVel * FrequencyValues[C];
          Phase := Settings[tmsPhaseOffset] + PhaseValues[C];
        end;
      Mods[tmwAM].Amp := Settings[tmsAMLevel] / AmpdBFactor;
      Mods[tmwBM].Amp := Settings[tmsBMLevel] / AmpdBFactor / 2;
      Mods[tmwFM].Amp := Settings[tmsFMLevel] / AmpdBFactor;
      Mods[tmwPDM].Amp := Settings[tmsPDMAmplitude] / 2;
      for Wave := Low(TTMModWave) to High(TTMModWave) do
        with Mods[Wave] do
          ThetaVel := OneHzThetaVel * Settings[ModFrequencies[Wave]];
    end;
  end;

  procedure UpdateByProgram;

    procedure Step;
    begin
      FProgramIndex := Wrap(FProgramIndex + SignFactor[FProgramReverse], 0,
        FProgram.Count - 1);
    end;

  var
    FuncRecs: TTMFuncRecs;
    Settings: TTMRealSettings;
    TransitionCount, PassageCount: Int64;
  begin
    TransitionCount := 0;
    PassageCount := 0;
    while True do
    begin
      with TTMMasterSettings(FProgram[FProgramIndex]), PCMFormat do
      begin
        TransitionCount := Round(TransitionTime * SamplingRate);
        PassageCount := Round(PassageTime * SamplingRate);
      end;
      if (TransitionCount > 0) or (PassageCount > 0) then
        Break;
      Step;
    end;
    FillChar(Settings, SizeOf(Settings), 0);
    SetByProgram := True;
    try
      SetValues(FuncRecs, Settings, FProgram[FProgramIndex]);
    finally
      SetByProgram := False;
    end;
    if FStartCount <= 1 then
    begin
      if (FStartCount = 0) or (TransitionCount < FTransitionCount) then
      begin
        FTransitionCount := TransitionCount;
        if FTransitionCount = 0 then
        begin
          FTransitionCount := 1;
          Dec(FPassageCount);
        end;
      end;
      FPassageCount := PassageCount;
      Step;
    end;
    if FStartCount > 0 then
      Dec(FStartCount);
    DoUpdate(FuncRecs, Settings);
  end;

begin
  if FProgram <> nil then
    UpdateByProgram
  else
    DoUpdate(FFuncRecs, FRealSettings);
end;

procedure TTM.UpdateWorkFunction(var FuncRecs: TTMFuncRecs; Index: TTMWave;
  const Value: TTMWorkFunctionClass; var AffectedSettings: TTMSettings);
var
  Setting: TTMSetting;
begin
  Setting := TMWorkFuncSettings[Index];
  if Accept[Setting] and (Value <> FuncRecs[Index].FuncClass) then
  begin
    if not SetByProgram then
      with FuncRecs[Index].Params do
      begin
        Specific := nil;
        FreeAndNil(Custom);
      end;
    FuncRecs[Index].FuncClass := Value;
    Include(AffectedSettings, Setting);
  end;
end;

function TTM.WaveStateDataSize: Integer;
begin
  Result := SizeOf(FWaveState);
end;

procedure TTM.ZeroChange;
begin
  FSelection_Chg := 0;
  FillChar(FWaveStateChanging, SizeOf(FWaveStateChanging), 0);
end;

initialization
  TMWorkFuncs := TStringList.Create;
  with TMWorkFuncs do
  begin
    AddObject(SSine, TObject(TTMSineFunction));
    AddObject(SSquare, TObject(TTMSquareFunction));
    AddObject(STriangle, TObject(TTMTriangleFunction));
//    AddObject(STable, TObject(TTMTableFunction));
    AddObject(SWhiteNoise, TObject(TTMWhiteNoiseFunction));
    AddObject(SPinkNoise, TObject(TTMPinkNoiseFunction));
  end;
  Randomize;

finalization
  TMWorkFuncs.Free;

end.
