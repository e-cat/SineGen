unit TMDuration;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfmDuration = class(TForm)
    Label1: TLabel;
    editTransitionTime: TEdit;
    Label2: TLabel;
    editPassageTime: TEdit;
    procedure ControlExit(Sender: TObject);
    procedure editTimeChange(Sender: TObject);
  end;

var
  fmDuration: TfmDuration;

implementation

{$R *.dfm}

uses
  TMKernel, TMMain;

const
  Settings: array[1..2] of TTMSetting = (tmsTransitionTime, tmsPassageTime);

procedure TfmDuration.ControlExit(Sender: TObject);
var
  ExitSettings: TTMSettings;
begin
  if Sender = Self then
    ExitSettings := [tmsTransitionTime, tmsPassageTime]
  else
    ExitSettings := [Settings[(Sender as TComponent).Tag]];
  ExitControls(ExitSettings);
end;

procedure TfmDuration.editTimeChange(Sender: TObject);
begin
  SetRealValueByControl(Settings[(Sender as TComponent).Tag], Sender);
end;

end.
