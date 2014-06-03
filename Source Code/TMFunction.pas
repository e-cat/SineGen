unit TMFunction;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfmFunction = class(TForm)
    cmbWorkFunction: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure cmbWorkFunctionSelect(Sender: TObject);
    procedure FormResize(Sender: TObject);
  public
    procedure CalcHeight;
  end;

var
  fmFunction: TfmFunction;

implementation

uses
  Lite, TMKernel, TMMain;

{$R *.dfm}

procedure TfmFunction.FormCreate(Sender: TObject);
begin
  CalcHeight;
  FormResize(nil);
  cmbWorkFunction.Items := TMWorkFuncs;
end;

procedure TfmFunction.cmbWorkFunctionSelect(Sender: TObject);
begin
  SetWorkFunctionByControl(Sender);
end;

procedure TfmFunction.FormResize(Sender: TObject);
begin
  cmbWorkFunction.Width := ClientWidth;
end;

procedure TfmFunction.CalcHeight;
begin
  Constraints.MinHeight := (Height - ClientHeight) + cmbWorkFunction.Height;
  Constraints.MaxHeight := Constraints.MinHeight;
end;

end.
