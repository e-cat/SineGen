unit TMPower;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TfmPower = class(TForm)
    timerActive: TTimer;
    btnOnOff: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure OnOff(Sender: TObject);
    procedure timerActiveTimer(Sender: TObject);
  end;

var
  fmPower: TfmPower;

implementation

uses
  Lite1, TMMain, TMConst;

{$R *.dfm}

procedure TfmPower.FormCreate(Sender: TObject);
begin
  Constraints.MinHeight := (Height - ClientHeight) + btnOnOff.Height;
  Constraints.MaxHeight := Constraints.MinHeight;
end;

procedure TfmPower.FormResize(Sender: TObject);
begin
  btnOnOff.Width := ClientWidth;
end;

procedure TfmPower.OnOff(Sender: TObject);
begin
  Toggle;
end;

procedure TfmPower.timerActiveTimer(Sender: TObject);
begin
  Caption := Format(SPowerCaptionOn, [TimeToStrEx(ActiveTime)]);
end;

end.
