unit hpBanTimer;

(**
 * @copyright Copyright (C) 2012-2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Timers
 * @package   hpBanTimer
 * @version   1.00
 *)

(**
 * History
 *
 * 1.00       2010-03-02
 *            Initial implementation (copy of ThpKickTimer)
 *)

interface

uses
  Classes, Controls, ExtCtrls, Contnrs;

type
  ThpBanTimer = class(TTimer)
  protected
    FBanItems: TObjectList;
    procedure TimerInterval(Sender: TObject); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Add(const AItem: string; ADate: TDateTime);
    function IsBanned(const AItem: string): Boolean;
    procedure ClearItem(const AItem: string);
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToFile(const AFileName: string);
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream: TStream);
  end;

procedure Register;

implementation

uses
  SysUtils;

type
  ThpBanItem = class(TPersistent)
  protected
    FItem: string;
    FDate: TDateTime;
  public
    constructor Create(const AItem: string; ADate: TDateTime); virtual;
    procedure ReadData(AReader: TReader); dynamic;
    procedure WriteData(AWriter: TWriter); dynamic;
  published
    property Item: string read FItem write FItem;
    property Date: TDateTime read FDate write FDate;
  end;

constructor ThpBanItem.Create(const AItem: string; ADate: TDateTime);
begin
  inherited Create;
  FItem := AItem;
  FDate := ADate;
end;

procedure ThpBanItem.ReadData(AReader: TReader);
begin
  with AReader do begin
    Item := ReadString;
    Date := ReadDate;
  end;
end;

procedure ThpBanItem.WriteData(AWriter: TWriter);
begin
  with AWriter do begin
    WriteString(Item);
    WriteDate(Date);
  end;
end;

constructor ThpBanTimer.Create(AOwner: TComponent);
begin
  inherited;
  FBanItems := TObjectList.Create(true);
  OnTimer := TimerInterval;
  // check the list every minute
  Interval := 60000;
  Enabled := False;
end;

destructor ThpBanTimer.Destroy;
begin
  FBanItems.Clear;
  FBanItems.Free;
  inherited;
end;

(*
 * Check for expired bans and remove them from the list
 *)
procedure ThpBanTimer.TimerInterval(Sender: TObject);
var
  i: Integer;
begin
  // stop the timer while processing
  Enabled := False;

  i := FBanItems.Count - 1;
  while i > -1 do begin
    if Now > ThpBanItem(FBanItems[i]).Date then
      FBanItems.Delete(i);

    Dec(i);
  end;

  // enable the timer only if there are items in the list
  if FBanItems.Count > 0 then
    Enabled := True;
end;

(*
 * Add a banned item/date combination to the list
 * Additionally start the timer if it is not already active
 *)
procedure ThpBanTimer.Add(const AItem: string; ADate: TDateTime);
begin
  FBanItems.Add(ThpBanItem.Create(AItem, ADate));
  if not Enabled then
    Enabled := True;
end;

(*
 * Check if an item/date combination has been banned
 * Returns true if the combination is found, false otherwise
 *)
function ThpBanTimer.IsBanned(const AItem: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to FBanItems.Count - 1 do
    if ThpBanItem(FBanItems[i]).FItem = AItem then begin
      Result := True;
      Break;
    end;
end;

procedure ThpBanTimer.ClearItem(const AItem: string);
var
  i: Integer;
begin
  for i := FBanItems.Count - 1 downto 0 do
    if (ThpBanItem(FBanItems[i]).FItem = AItem) then
      FBanItems.Delete(i);
end;

procedure ThpBanTimer.LoadFromFile(const AFileName: string);
var
  stream: TFileStream;
begin
  stream := TFileStream.Create(AFileName, fmOpenRead);
  try
    LoadFromStream(stream);
  finally
    stream.Free;
  end;
end;

procedure ThpBanTimer.SaveToFile(const AFileName: string);
var
  stream: TFileStream;
begin
  stream := TFileStream.Create(AFileName, fmCreate or fmOpenWrite);
  try
    SaveToStream(stream);
  finally
    stream.Free;
  end;
end;

procedure ThpBanTimer.LoadFromStream(AStream: TStream);
var
  reader: TReader;
  obj: TPersistent;
  ctype: TPersistentClass;
  cname: string;
begin
  FBanItems.Clear;
  reader := TReader.Create(AStream, $FF);
  try
    with reader do begin
      ReadSignature;
      ReadListBegin;
      while not EndOfList do begin
        cname := ReadString;
        ctype := GetClass(cname);
        if Assigned(ctype) then begin
          obj := ctype.Create;
          try
            if obj is ThpBanItem then
              ThpBanItem(obj).ReadData(reader);
          except
            obj.Free;
            raise;
          end;
          FBanItems.Add(obj);
        end;
      end;
      ReadListEnd;
    end;
  finally
    reader.Free;
  end;
end;

procedure ThpBanTimer.SaveToStream(AStream: TStream);
var
  writer: TWriter;
  i: Integer;
begin
  writer := TWriter.Create(AStream, $FF);
  try
    with writer do begin
      WriteSignature;
      WriteListBegin;
      for i := 0 to FBanItems.Count - 1 do begin
        if TObject(FBanItems[i]) is ThpBanItem then begin
          WriteString(TPersistent(FBanItems[i]).ClassName);
          ThpBanItem(FBanItems[i]).WriteData(writer);
        end;
      end;
      WriteListEnd;
    end;
  finally
    writer.Free;
  end;
end;

(**
 * Register into the component palette
 *)
procedure Register;
begin
  RegisterComponents('hpVCL', [ThpBanTimer]);
end;

initialization

  RegisterClass(ThpBanItem);

finalization

  UnRegisterClass(ThpBanItem);

end.
