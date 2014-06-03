unit TMOutput;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfmOutput = class(TForm)
    gbDevice: TGroupBox;
    gbOutputFile: TGroupBox;
    comboDevice: TComboBox;
    editOutputFile: TEdit;
    btnBrowseOutputFile: TButton;
    dlgOutputFileName: TSaveDialog;
    btnOutputSetup: TButton;
    Bevel1: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure comboDeviceSelect(Sender: TObject);
    procedure editOutputFileChange(Sender: TObject);
    procedure btnBrowseOutputFileClick(Sender: TObject);
    procedure btnOutputSetupClick(Sender: TObject);
  end;

var
  fmOutput: TfmOutput;

implementation

uses
  MMSystem, CtlUtils, WaveInOut, TMMain, TMOutputSetup;

{$R *.dfm}

procedure TfmOutput.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  Constraints.MinWidth := (Width - ClientWidth) + PhysPixels(200);
  Constraints.MinHeight := (Height - ClientHeight) +
    btnOutputSetup.BoundsRect.Bottom;
  Constraints.MaxHeight := Constraints.MinHeight;
  with TWaveOut.Create do
    try
      for I := -1 to waveOutGetNumDevs - 1 do
      begin
        DeviceID := I;
        comboDevice.Items.Add(DeviceName);
      end;
    finally
      Free;
    end;
  FormResize(nil);
end;

procedure TfmOutput.FormResize(Sender: TObject);
var
  Margin: Integer;
begin
  Margin := comboDevice.Left;
  comboDevice.Width := gbDevice.ClientWidth - Margin * 2;
  editOutputFile.Width := gbOutputFile.Width - Margin * 2 -
    btnBrowseOutputFile.Width - 1;
  btnBrowseOutputFile.Left := gbOutputFile.Width - Margin -
    btnBrowseOutputFile.Width;
end;

procedure TfmOutput.comboDeviceSelect(Sender: TObject);
begin
  if RespondControlEvent(Sender) then
    try
      TM.DeviceID := comboDevice.ItemIndex - 1;
    finally
      CurrentControl := nil;
    end;
end;

procedure TfmOutput.editOutputFileChange(Sender: TObject);
begin
  if RespondControlEvent(Sender) then
    try
      TM.CaptureFile := editOutputFile.Text;
    finally
      CurrentControl := nil;
    end;
end;

procedure TfmOutput.btnBrowseOutputFileClick(Sender: TObject);
begin                                               
  if (TM <> nil) and not TM.Active then
    with dlgOutputFileName do
    begin
      FileName := TM.CaptureFile;
      if Execute then
        TM.CaptureFile := FileName;
    end;
end;

procedure TfmOutput.btnOutputSetupClick(Sender: TObject);
begin
  if (TM <> nil) and not TM.Active then
    TfmOutputSetup.Execute;
end;

end.
