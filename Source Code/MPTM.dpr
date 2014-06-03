program MPTM;

uses
  Forms,
  TMKernel in 'TMKernel.pas',
  TMConst in 'TMConst.pas',
  TMMain in 'TMMain.pas' {fmMain},
  TMPower in 'TMPower.pas' {fmPower},
  TMFunction in 'TMFunction.pas' {fmFunction},
  TMFuncParams in 'TMFuncParams.pas' {fmFuncParams},
  TMLevel in 'TMLevel.pas' {fmLevel},
  TMFrequency in 'TMFrequency.pas' {fmFrequency},
  TMPhase in 'TMPhase.pas' {fmPhase},
  TMModulation in 'TMModulation.pas' {fmModulation},
  TMDuration in 'TMDuration.pas' {fmDuration},
  TMMaster in 'TMMaster.pas' {fmMaster},
  TMOutput in 'TMOutput.pas' {fmOutput},
  TMTimer in 'TMTimer.pas' {fmTimer},
  TMOutputSetup in 'TMOutputSetup.pas' {fmOutputSetup},
  TMAbout in 'TMAbout.pas' {fmAbout};

{$R *.res}

begin
  Application.CreateForm(TfmMain, fmMain);
  Application.CreateForm(TfmTimer, fmTimer);
  Application.CreateForm(TfmOutput, fmOutput);
  Application.CreateForm(TfmMaster, fmMaster);
  Application.CreateForm(TfmDuration, fmDuration);
  Application.CreateForm(TfmModulation, fmModulation);
  Application.CreateForm(TfmPhase, fmPhase);
  Application.CreateForm(TfmFrequency, fmFrequency);
  Application.CreateForm(TfmLevel, fmLevel);
  Application.CreateForm(TfmFuncParams, fmFuncParams);
  Application.CreateForm(TfmFunction, fmFunction);
  Application.CreateForm(TfmPower, fmPower);
  Initialize;
  Application.Run;
end.
