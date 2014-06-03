{-------------------|
| TWaveInOut v1.0.8 |
| (c) eCat          |
|-------------------}

unit WaveInOut;

interface

uses
  Windows, MMSystem, SysUtils, Classes, WaveFmt, Lite;

var
  DefPCMFormat: TPCMFormat = (
    BitDepth: 16;
    SamplingRate: 48000;
    ChannelCount: 2;
  );

const
  BufferTimeRange: TRange = (Min: 1e-3; Max: 0.5);
  PrebufferTimeRange: TRange = (Min: 0.1; Max: 5);

type
  EWaveError = class(Exception);
  
  TWaveInOut = class;
  TWaveStream = class;

  TWaveBuffer = class
  private
    FHeader: TWaveHdr;
    FNext: TWaveBuffer;
    FOwner: TWaveStream;
    FReturned: Boolean;
    procedure Process;
    procedure Return;
  protected
    procedure AfterProcessingData; virtual;
    procedure BeforeProcessingData; virtual;
    function DataLength: Integer; virtual; abstract;
    function DataProcessing: Boolean; virtual; abstract;
    procedure ProcessData;
    procedure Send; virtual; abstract;
  public
    constructor Create(AOwner: TWaveStream); virtual;
    destructor Destroy; override;
    procedure SaveToStream(Stream: TStream);
    function WaveInOut: TWaveInOut;
    property Returned: Boolean read FReturned;
  end;

  TWaveBufferClass = class of TWaveBuffer;

  TWaveStream = class(TList)
  private
    FHead, FTail, FUnprocessed: TWaveBuffer;
    FTerminated: Boolean;
    FReleasedCount: Integer;
    FOwner: TWaveInOut;
    FEvent, FThread: THandle;
    FCapture: TStream;
    procedure Process;
    procedure SetHead(Value: TWaveBuffer);
  protected
    procedure Accept(Buffer: TWaveBuffer);
    function BufferClass: TWaveBufferClass; virtual; abstract;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    procedure Reset; virtual; abstract;
  public
    constructor Create(AOwner: TWaveInOut); virtual;
    destructor Destroy; override;
  end;

  TWaveStreamClass = class of TWaveStream;

  TWaveInOut = class
  private
    FActive: Boolean;
    FDeviceID: Cardinal;
    FPCMFormat: TPCMFormat;
    FStream: TWaveStream;
    FCaps: TWaveOutCaps;
    FPrebufferTime: Real;
    FBufferTime: Real;
    FHandle: Integer;
    FFormat: TWaveFormatEx;
    FCaptureFile: string;
    FPaused: Boolean;
    function GetDeviceFormats: TPCMFormatMask;
    function GetDeviceName: string;
    function GetStereo: Boolean;
    procedure SetCaptureFile(const Value: string);
    procedure SetDeviceID(const Value: Cardinal);
    procedure SetBufferTime(const Value: Real);
    procedure SetPaused(const Value: Boolean);
    procedure SetPCMFormat(const Value: TPCMFormat);
    procedure SetPrebufferTime(const Value: Real);
  protected
    procedure BeginProcessingData; dynamic;
    procedure CheckError(ErrorCode: Cardinal);
    procedure Close; dynamic; abstract;
    function CreateCapture: TStream; dynamic;
    procedure DoOpen(PFormatEx: PWaveFormatEx); dynamic; abstract;
    procedure EndProcessingData; dynamic;
    procedure GetCaps; virtual; abstract;
    procedure GetErrorText(ErrorCode: Cardinal; var Buffer;
      BufSize: Cardinal); dynamic; abstract;
    procedure Open; dynamic;
    procedure Pause; dynamic; abstract;
    procedure ProcessData(var Data; SampleCount: Integer); virtual; abstract;
    procedure SetActive(const Value: Boolean); virtual;
    function StreamClass: TWaveStreamClass; dynamic; abstract;
    procedure Unpause; dynamic; abstract;
    property Handle: Integer read FHandle;
  public
    constructor Create;
    destructor Destroy; override;
    property Active: Boolean read FActive write SetActive;
    property CaptureFile: string read FCaptureFile write SetCaptureFile;
    property DeviceFormats: TPCMFormatMask read GetDeviceFormats;
    property DeviceID: Cardinal read FDeviceID write SetDeviceID;
    property DeviceName: string read GetDeviceName;
    property BufferTime: Real read FBufferTime write SetBufferTime;
    property Paused: Boolean read FPaused write SetPaused;
    property PCMFormat: TPCMFormat read FPCMFormat write SetPCMFormat;
    property PrebufferTime: Real read FPrebufferTime write SetPrebufferTime;
    property Stereo: Boolean read GetStereo;
  end;

  TWaveCaptureClass = class of TCustomWaveFileWriter;

  TWaveOutBuffer = class(TWaveBuffer)
  private
    FWaveEndState: Pointer;
  protected
    procedure AfterProcessingData; override;
    procedure BeforeProcessingData; override;
    function DataLength: Integer; override;
    function DataProcessing: Boolean; override;
    procedure Send; override;
  public
    constructor Create(AOwner: TWaveStream); override;
    destructor Destroy; override;
  end;

  TWaveOutStream = class(TWaveStream)
  private
    FNeedUpdate: Boolean;
    procedure CheckUpdate;
  protected
    function BufferClass: TWaveBufferClass; override;
    procedure Reset; override;
  end;

  TWaveOut = class(TWaveInOut)
  protected
    procedure Close; override;
    procedure DoOpen(PFormatEx: PWaveFormatEx); override;
    procedure GetCaps; override;
    procedure GetErrorText(ErrorCode: Cardinal; var Buffer;
      BufSize: Cardinal); override;
    procedure Pause; override;
    procedure RestoreWaveState(const Source); virtual;
    procedure SaveWaveState(var Dest); virtual;
    function StreamClass: TWaveStreamClass; override;
    procedure Unpause; override;
    function WaveStateDataSize: Integer; virtual;
  public
    procedure UpdateStream;
  end;

  TWaveInBuffer = class(TWaveBuffer)
  protected
    function DataLength: Integer; override;
    function DataProcessing: Boolean; override;
    procedure Send; override;
  public
    constructor Create(AOwner: TWaveStream); override;
    destructor Destroy; override;
  end;

  TWaveInStream = class(TWaveStream)
  protected
    function BufferClass: TWaveBufferClass; override;
    procedure Reset; override;
  public
    constructor Create(AOwner: TWaveInOut); override;
  end;

  TWaveIn = class(TWaveInOut)
  protected
    procedure Close; override;
    procedure DoOpen(PFormatEx: PWaveFormatEx); override;
    procedure GetCaps; override;
    procedure GetErrorText(ErrorCode: Cardinal; var Buffer;
      BufSize: Cardinal); override;
    procedure Pause; override;
    function StreamClass: TWaveStreamClass; override;
    procedure Unpause; override;
  end;

var
  WaveCaptureClass: TWaveCaptureClass = TBasicWaveFileWriter;

implementation

uses
  Math, Lite1;

{ TWaveBuffer }

procedure TWaveBuffer.AfterProcessingData;
begin
end;

procedure TWaveBuffer.BeforeProcessingData;
begin
end;

constructor TWaveBuffer.Create(AOwner: TWaveStream);
begin
  FOwner := AOwner;
  with FHeader, WaveInOut, FFormat do
  begin
    dwBufferLength := Round(FBufferTime * nSamplesPerSec) * nBlockAlign;
    GetMem(lpData, dwBufferLength);
    dwUser := Cardinal(Self);
  end;
end;

destructor TWaveBuffer.Destroy;
begin
  with FHeader do
    if lpData <> nil then
      FreeMem(lpData, dwBufferLength);
  inherited;
end;

procedure TWaveBuffer.Process;
begin
  if DataProcessing then
    ProcessData;
  if not FOwner.FTerminated then
    Send;
end;

procedure TWaveBuffer.ProcessData;
begin
  BeforeProcessingData;
  with FHeader, WaveInOut do
    ProcessData(lpData^, DataLength div FFormat.nBlockAlign);
  AfterProcessingData;
end;

procedure TWaveBuffer.Return;
begin
  FReturned := True;
  FOwner.Accept(Self);
end;

procedure TWaveBuffer.SaveToStream(Stream: TStream);
begin
  if FReturned then
    Stream.WriteBuffer(FHeader.lpData^, DataLength);
end;

function TWaveBuffer.WaveInOut: TWaveInOut;
begin
  Result := FOwner.FOwner;
end;

{ TWaveStream }

procedure ProcessWaveStream(Instance: TWaveStream);
begin
  try
    Instance.Process;
  except
    ShowException(ExceptObject, ExceptAddr);
  end;
end;

procedure TWaveStream.Accept(Buffer: TWaveBuffer);
begin
  FTail := Buffer.FNext;
  Buffer.FNext := nil;
  SetHead(Buffer);
  if FUnprocessed = nil then
  begin
    FUnprocessed := Buffer;
    SetEvent(FEvent);
  end;
end;

constructor TWaveStream.Create(AOwner: TWaveInOut);
var
  I: Integer;
  ThreadID: Cardinal;
begin
  FOwner := AOwner;
  with FOwner do
    Capacity := Max(Round(FPrebufferTime / FBufferTime), 2);
  for I := 1 to Capacity do
    Add(BufferClass.Create(Self));
  FCapture := FOwner.CreateCapture;
  FEvent := CreateEvent(nil, False, False, nil);
  FThread := BeginThread(nil, 0, @ProcessWaveStream, Self, 0, ThreadID);
  SetThreadPriority(FThread, THREAD_PRIORITY_TIME_CRITICAL);
  FUnprocessed := First;
  SetEvent(FEvent);
end;

destructor TWaveStream.Destroy;
begin
  FTerminated := True;
  Reset;
  WaitForSingleObject(FThread, INFINITE);
  CloseHandle(FThread);
  CloseHandle(FEvent);
  FCapture.Free;
  inherited Destroy;
end;

procedure TWaveStream.Notify(Ptr: Pointer; Action: TListNotification);
begin
  case Action of
    lnAdded: SetHead(Ptr);
    lnDeleted: TObject(Ptr).Free;
  end;
end;

procedure TWaveStream.Process;
begin
  FOwner.BeginProcessingData;
  try
    while WaitForSingleObject(FEvent, INFINITE) = WAIT_OBJECT_0 do
      while FUnprocessed <> nil do
      begin
        if FCapture <> nil then
          FUnprocessed.SaveToStream(FCapture);
        FUnprocessed.Process;
        if FTerminated then
        begin
          Inc(FReleasedCount);
          if FReleasedCount = Count then
            Exit;
        end;
        FUnprocessed := FUnprocessed.FNext;
      end;
    RaiseLastOSError;
  finally
    FOwner.EndProcessingData;
  end;
end;

procedure TWaveStream.SetHead(Value: TWaveBuffer);
begin
  if FHead <> nil then
    FHead.FNext := Value;
  FHead := Value;
end;

{ TWaveInOut }

procedure waveProc(Handle: Integer; Msg: Cardinal; Instance: TWaveInOut;
  Header: PWaveHdr; UnusedParam: Cardinal); stdcall;
begin
  if (Msg = WIM_DATA) or (Msg = WOM_DONE) then
    TWaveBuffer(Header^.dwUser).Return;
end;

procedure TWaveInOut.BeginProcessingData;
begin
end;

procedure TWaveInOut.CheckError(ErrorCode: Cardinal);
var
  Buf: array[0..MAXERRORLENGTH - 1] of Char;
begin
  if ErrorCode <> MMSYSERR_NOERROR then
  begin
    GetErrorText(ErrorCode, Buf, SizeOf(Buf));
    raise EWaveError.Create(Buf);
  end;
end;

constructor TWaveInOut.Create;
begin
  FBufferTime := 0.05;
  FPrebufferTime := 0.2;
  FPCMFormat := DefPCMFormat;
  SetDeviceID(WAVE_MAPPER);
end;

function TWaveInOut.CreateCapture: TStream;
begin
  Result := nil;
  if FCaptureFile <> '' then
    Result := WaveCaptureClass.Create(FCaptureFile, FPCMFormat);
end;

destructor TWaveInOut.Destroy;
begin
  SetActive(False);
  inherited;
end;

procedure TWaveInOut.EndProcessingData;
begin
end;

function TWaveInOut.GetDeviceFormats: TPCMFormatMask;
begin
  Result := TPCMFormatMask(FCaps.dwFormats);
end;

function TWaveInOut.GetDeviceName: string;
begin
  Result := FCaps.szPname;
end;

function TWaveInOut.GetStereo: Boolean;
begin
  Result := FPCMFormat.ChannelCount = 2;
end;

procedure TWaveInOut.Open;
var
  wfe: TWaveFormatExtensible;
begin
  SetPCMFormatInfo(wfe, FPCMFormat);
  DoOpen(@wfe.Format);
  FFormat := wfe.Format;
end;

procedure TWaveInOut.SetActive(const Value: Boolean);
begin
  if Value <> FActive then
  begin
    if Value then
    begin        
      Open;
      try
        FStream := StreamClass.Create(Self);
      except
        Close;
        raise;
      end;
    end
    else
    begin
      FStream.Free;
      Close;
      FPaused := False;
    end;
    FActive := Value;
  end;
end;

procedure TWaveInOut.SetBufferTime(const Value: Real);
begin
  FBufferTime := EnsureRange(Value, BufferTimeRange);
  FPrebufferTime := Max(FPrebufferTime, FBufferTime * 2);
end;

procedure TWaveInOut.SetCaptureFile(const Value: string);
begin
  if not FActive then
    FCaptureFile := Value;
end;

procedure TWaveInOut.SetDeviceID(const Value: Cardinal);
begin
  if not FActive then
  begin
    FDeviceID := Value;
    FillChar(FCaps, SizeOf(TWaveOutCaps), 0);
    GetCaps;
  end;
end;

procedure TWaveInOut.SetPrebufferTime(const Value: Real);
begin
  FPrebufferTime := Max(EnsureRange(Value, PrebufferTimeRange),
    FBufferTime * 2);
end;

procedure TWaveInOut.SetPaused(const Value: Boolean);
begin
  if FActive and (Value <> FPaused) then
  begin
    if Value then
      Pause
    else
      Unpause;
    FPaused := Value;
  end;
end;

procedure TWaveInOut.SetPCMFormat(const Value: TPCMFormat);
begin
  if not FActive then
    FPCMFormat := ValidPCMFormat(Value);
end;

{ TWaveOutBuffer }

procedure TWaveOutBuffer.AfterProcessingData;
begin
  TWaveOut(WaveInOut).SaveWaveState(FWaveEndState^);
end;

procedure TWaveOutBuffer.BeforeProcessingData;
begin
  TWaveOutStream(FOwner).CheckUpdate;
end;

constructor TWaveOutBuffer.Create(AOwner: TWaveStream);
begin
  inherited Create(AOwner);
  WaveInOut.CheckError(waveOutPrepareHeader(WaveInOut.FHandle, @FHeader,
    SizeOf(TWaveHdr)));
  GetMem(FWaveEndState, TWaveOut(WaveInOut).WaveStateDataSize);
end;

function TWaveOutBuffer.DataLength: Integer;
begin
  Result := FHeader.dwBufferLength - FHeader.dwBufferLength mod
    WaveInOut.FFormat.nBlockAlign;
end;

function TWaveOutBuffer.DataProcessing: Boolean;
begin
  Result := not FOwner.FTerminated;
end;

destructor TWaveOutBuffer.Destroy;
begin
  if FWaveEndState <> nil then
    FreeMem(FWaveEndState);
  waveOutUnprepareHeader(WaveInOut.FHandle, @FHeader, SizeOf(TWaveHdr));
  inherited Destroy;
end;

procedure TWaveOutBuffer.Send;
begin
  waveOutWrite(WaveInOut.FHandle, @FHeader, SizeOf(TWaveHdr));
end;

{ TWaveOutStream }

function TWaveOutStream.BufferClass: TWaveBufferClass;
begin
  Result := TWaveOutBuffer;
end;

procedure TWaveOutStream.CheckUpdate;
var
  Buf: TWaveBuffer;
begin
  if FNeedUpdate then
  begin
    FNeedUpdate := False;
    Buf := FTail;
    if Buf <> nil then
    begin
      TWaveOut(FOwner).RestoreWaveState(TWaveOutBuffer(Buf).FWaveEndState^);
      while True do
      begin
        Buf := Buf.FNext;
        if Buf = FUnprocessed then
          Break;
        Buf.ProcessData;
      end;
    end;
  end;
end;

procedure TWaveOutStream.Reset;
begin
  waveOutReset(FOwner.FHandle);
end;

{ TWaveOut }

procedure TWaveOut.Close;
begin
  waveOutClose(FHandle);
end;

procedure TWaveOut.DoOpen(PFormatEx: PWaveFormatEx);
begin
  CheckError(waveOutOpen(@FHandle, FDeviceID, PFormatEx, Cardinal(@waveProc),
    Cardinal(Self), WAVE_FORMAT_DIRECT * Ord(Win32MajorVersion >= 5) or
    CALLBACK_FUNCTION));
end;

procedure TWaveOut.GetCaps;
begin
  waveOutGetDevCaps(FDeviceID, @FCaps, SizeOf(TWaveOutCaps));
end;

procedure TWaveOut.GetErrorText(ErrorCode: Cardinal; var Buffer;
  BufSize: Cardinal);
begin
  waveOutGetErrorText(ErrorCode, @Buffer, BufSize);
end;

procedure TWaveOut.Pause;
begin
  waveOutPause(FHandle);
end;

procedure TWaveOut.RestoreWaveState(const Source);
begin
end;

procedure TWaveOut.SaveWaveState(var Dest);
begin
end;

function TWaveOut.StreamClass: TWaveStreamClass;
begin
  Result := TWaveOutStream;
end;

procedure TWaveOut.Unpause;
begin
  waveOutRestart(FHandle);
end;

procedure TWaveOut.UpdateStream;
begin
  if FActive then
    TWaveOutStream(FStream).FNeedUpdate := True;
end;

function TWaveOut.WaveStateDataSize: Integer;
begin
  Result := 0;
end;

{ TWaveInBuffer }

constructor TWaveInBuffer.Create(AOwner: TWaveStream);
begin
  inherited Create(AOwner);
  WaveInOut.CheckError(waveInPrepareHeader(WaveInOut.FHandle, @FHeader,
    SizeOf(TWaveHdr)));
end;

function TWaveInBuffer.DataLength: Integer;
begin
  Result := FHeader.dwBytesRecorded;
end;

function TWaveInBuffer.DataProcessing: Boolean;
begin
  Result := FReturned and (DataLength <> 0);
end;

destructor TWaveInBuffer.Destroy;
begin
  waveOutUnprepareHeader(WaveInOut.FHandle, @FHeader, SizeOf(TWaveHdr));
  inherited Destroy;
end;

procedure TWaveInBuffer.Send;
begin
  waveInAddBuffer(WaveInOut.FHandle, @FHeader, SizeOf(TWaveHdr));
end;

{ TWaveInStream }

function TWaveInStream.BufferClass: TWaveBufferClass;
begin
  Result := TWaveInBuffer;
end;

constructor TWaveInStream.Create(AOwner: TWaveInOut);
begin
  inherited Create(AOwner);
  waveInStart(FOwner.FHandle);
end;

procedure TWaveInStream.Reset;
begin
  waveInReset(FOwner.FHandle);
end;

{ TWaveIn }

procedure TWaveIn.Close;
begin
  waveInClose(FHandle);
end;

procedure TWaveIn.DoOpen(PFormatEx: PWaveFormatEx);
begin
  CheckError(waveInOpen(@FHandle, FDeviceID, PFormatEx, Cardinal(@waveProc),
    Cardinal(Self), WAVE_FORMAT_DIRECT * Ord(Win32MajorVersion >= 5) or
    CALLBACK_FUNCTION));
end;

procedure TWaveIn.GetCaps;
begin
  waveInGetDevCaps(FDeviceID, @FCaps, SizeOf(TWaveInCaps));
end;

procedure TWaveIn.GetErrorText(ErrorCode: Cardinal; var Buffer;
  BufSize: Cardinal);
begin
  waveInGetErrorText(ErrorCode, @Buffer, BufSize);
end;

procedure TWaveIn.Pause;
begin
  waveInStop(FHandle);
end;

function TWaveIn.StreamClass: TWaveStreamClass;
begin
  Result := TWaveInStream;
end;

procedure TWaveIn.Unpause;
begin
  waveInStart(FHandle);
end;

end.
