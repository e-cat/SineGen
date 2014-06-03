unit Lite2;

interface

uses
  Messages, Classes, Types, ShellAPI;

function RandPermut(n: Integer; r: Integer = -1): TIntegerDynArray;

procedure SetStrings(Strings: TStrings; Buffer: PChar);
function ObjectByString(Strings: TStrings; const S: string): TObject;
function StringByObject(Strings: TStrings; AObject: TObject): string;

type
  TObjList = class(TList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  end;

  TDropFiles = class(TStrings)
  private
    Handle: HDROP;
  protected
    function Get(Index: Integer): string; override;
    function GetCount: Integer; override;
    function GetPoint: TPoint;
  public
    constructor Create(Message: TWMDropFiles);
    destructor Destroy; override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
    property Point: TPoint read GetPoint;
  end;

resourcestring
  SModifyingStaticObject = 'Modifying static object';

var
  CompanyName, ProductName: string;

function RegKey: string;

implementation

uses
  SysUtils, Registry;
  

function RandPermut(n: Integer; r: Integer = -1): TIntegerDynArray;
var
  I, J, SubIndex, Number: Integer;
begin
  if (r < 0) or (r > n) then
    r := n;
  with TBits.Create do
    try
      Size := n;
      SetLength(Result, r);
      for I := 0 to r - 1 do
      begin
        SubIndex := Random(n - I);
        J := 0;
        Number := 0;
        while True do
        begin
          while Bits[Number] do
            Inc(Number);
          if J = SubIndex then
            Break;
          Inc(Number);
          Inc(J);
        end;
        Result[I] := Number;
        Bits[Number] := True;
      end;
    finally
      Free;
    end;
end;


procedure SetStrings(Strings: TStrings; Buffer: PChar);
var
  S: string;
begin
  Strings.Clear;
  while Buffer^ <> #0 do
  begin
    S := Buffer;
    Strings.Add(S);
    Inc(Buffer, Length(S) + 1);
  end;
end;

function ObjectByString(Strings: TStrings; const S: string): TObject;
var
  I: Integer;
begin
  Result := nil;
  I := Strings.IndexOf(S);
  if I <> -1 then
    Result := Strings.Objects[I];
end;

function StringByObject(Strings: TStrings; AObject: TObject): string;
var
  I: Integer;
begin
  I := Strings.IndexOfObject(AObject);
  if I <> -1 then
    Result := Strings[I];
end;

{ TObjList }

procedure TObjList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if Action = lnDeleted then
    TObject(Ptr).Free;
end;

{ TDropFiles }

procedure DropFilesInvalidOperation;
begin
  raise EInvalidOperation.CreateRes(@SModifyingStaticObject);
end;

procedure TDropFiles.Clear;
begin
  DropFilesInvalidOperation;
end;

constructor TDropFiles.Create(Message: TWMDropFiles);
begin
  Handle := Message.Drop;
end;

procedure TDropFiles.Delete(Index: Integer);
begin
  DropFilesInvalidOperation;
end;

destructor TDropFiles.Destroy;
begin
  DragFinish(Handle);
  inherited Destroy;
end;

function TDropFiles.Get(Index: Integer): string;
begin
  SetLength(Result, DragQueryFile(Handle, Index, nil, 0));
  DragQueryFile(Handle, Index, Pointer(Result), Length(Result) + 1);
end;

function TDropFiles.GetCount: Integer;
begin
  Result := DragQueryFile(Handle, $FFFFFFFF, nil, 0);
end;

function TDropFiles.GetPoint: TPoint;
begin
  DragQueryPoint(Handle, Result);
end;

procedure TDropFiles.Insert(Index: Integer; const S: string);
begin
  DropFilesInvalidOperation;
end;


function RegKey: string;
begin
  Result := '\Software\' + CompanyName + '\' + ProductName;
end;

initialization
  CompanyName := 'eCat';
  ProductName := ChangeFileExt(ExtractFileName(ParamStr(0)), '');

end.
