unit TMOutputSetup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, WaveFmt;

type
  TfmOutputSetup = class(TForm)
    GroupBox1: TGroupBox;
    gbBufferTime: TGroupBox;
    slBufferTime: TTrackBar;
    gbPrebufferTime: TGroupBox;
    slPrebufferTime: TTrackBar;
    GroupBox2: TGroupBox;
    editFormats: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    btnReset: TButton;
    labelBufferTime: TLabel;
    labelPrebufferTime: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    procedure FormCreate(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure slBufferTimeChange(Sender: TObject);
    procedure slPrebufferTimeChange(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
  public
    class procedure Execute;
  end;

var
  fmOutputSetup: TfmOutputSetup;

implementation

uses
  CommCtrl, Lite, TMKernel, TMConst, TMMain;

{$R *.dfm}

procedure TfmOutputSetup.FormCreate(Sender: TObject);
begin
  ChangeWindowStyle(slBufferTime.Handle, 0, TBS_ENABLESELRANGE);
  ChangeWindowStyle(slPrebufferTime.Handle, 0, TBS_ENABLESELRANGE);
  slBufferTimeChange(nil);
  slPrebufferTimeChange(nil);    
end;

procedure TfmOutputSetup.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  if Msg.CharCode = VK_ESCAPE then
  begin
    Close;
    Handled := True;
  end;
end;

class procedure TfmOutputSetup.Execute;
begin                        
  with Create(Application) do
    try
      slBufferTime.Position := Round(TM.BufferTime * 1e3);
      slPrebufferTime.Position := Round(TM.PrebufferTime * 1e3);
      editFormats.Text := PCMFormatsToStr(PCMFormats);
      if (ShowModal = mrOk) and (TM <> nil) then
      begin
        TM.BufferTime := slBufferTime.Position / 1e3;
        TM.PrebufferTime := slPrebufferTime.Position / 1e3;
        PCMFormats := StrToPCMFormats(editFormats.Text);
        fmMain.UpdateControls(TM, [tmsAux1]);
      end;
    finally
      Free;
    end;
end;

procedure TfmOutputSetup.slBufferTimeChange(Sender: TObject);
begin
  labelBufferTime.Caption := Format(STimeInMS, [slBufferTime.Position]);
end;

procedure TfmOutputSetup.slPrebufferTimeChange(Sender: TObject);
begin
  labelPrebufferTime.Caption := Format(STimeInMS, [slPrebufferTime.Position]);
end;

procedure TfmOutputSetup.btnResetClick(Sender: TObject);
begin
  slBufferTime.Position := DefBufferTime;
  slPrebufferTime.Position := DefPreufferTime;
  editFormats.Text := PCMFormatsToStr(DefPCMFormats);
end;

end.
