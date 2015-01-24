unit hpDelTimer;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Timers
 * @package   hpDelTimer
 * @version   1.00
 *)

(**
 * History
 *
 * 1.00       21/10/2011
 *            Initial implementation (untested)
 *)

interface

uses
  Classes, Controls, ExtCtrls, Contnrs;

type
  (*
   * ThpDelTimer interface
   *)

  ThpDelTimer = class(TTimer)
  protected
    FDelItems: TObjectList;
    FDeleteDuration: Integer;
    procedure TimerInterval(Sender: TObject); virtual;
  published
    // Duration of a delete in minutes, defaults to 5
    property DeleteDuration: Integer read FDeleteDuration write FDeleteDuration default 5;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Add(const ARoom: string = '');
    function IsPendingDeletion(const ARoom: string): Boolean;
    procedure ClearRoom(const ARoom: string);
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
  (*
   * ThpDelTimerItem interface
   *)

  ThpDelTimerItem = class(TPersistent)
  protected
    FRoom: string;
    FDate: TDateTime;
  public
    constructor Create(const ARoom: string); virtual;
    procedure ReadData(AReader: TReader); dynamic;
    procedure WriteData(AWriter: TWriter); dynamic;
  published 
    property Room: string read FRoom write FRoom;
    property Date: TDateTime read FDate write FDate;
  end;

(*
 * ThpDelItem implementation
 *)

constructor ThpDelTimerItem.Create(const ARoom: string);
begin
  inherited Create;
  FRoom := ARoom;
  FDate := Now;
end;

procedure ThpDelTimerItem.ReadData(AReader: TReader);
begin
  with AReader do begin
    Room := ReadString;
    Date := ReadDate;
  end;
end;

procedure ThpDelTimerItem.WriteData(AWriter: TWriter);
begin
  with AWriter do begin
    WriteString(Room);
    WriteDate(Date);
  end;
end;

(*
 * ThpDelTimer implementation
 *)

constructor ThpDelTimer.Create(AOwner: TComponent);
begin
  inherited;
  FDelItems := TObjectList.Create(true);
  OnTimer := TimerInterval;
  // check the list every minute
  FDeleteDuration := 120;
  Interval := 60000;
  Enabled := False;
end;

destructor ThpDelTimer.Destroy;
begin
  FDelItems.Clear;
  FDelItems.Free;
  inherited;
end;

procedure ThpDelTimer.TimerInterval(Sender: TObject);
var
  i: Integer;
  timediff: Int64;
begin
  // stop the timer while processing
  Enabled := False;

  i := FDelItems.Count - 1;
  while i > -1 do begin
    timediff := Round((Now - ThpDelTimerItem(FDelItems[i]).FDate) * 1440);
    if timediff > FDeleteDuration then
      FDelItems.Delete(i);

    Dec(i);
  end;

  // enable the timer only if there are items in the list
  if FDelItems.Count > 0 then
    Enabled := True;
end;

procedure ThpDelTimer.Add(const ARoom: string = '');
begin
  FDelItems.Add(ThpDelTimerItem.Create(ARoom));
  if not Enabled then
    Enabled := True;
end;

function ThpDelTimer.IsPendingDeletion(const ARoom: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to FDelItems.Count - 1 do
    if ThpDelTimerItem(FDelItems[i]).FRoom = ARoom then begin
      Result := True;
      Break;
    end;
end;

procedure ThpDelTimer.ClearRoom(const ARoom: string);
var
  i: Integer;
begin
  for i := FDelItems.Count - 1 downto 0 do
    if (ThpDelTimerItem(FDelItems[i]).FRoom = ARoom) then
      FDelItems.Delete(i);
end;

procedure ThpDelTimer.LoadFromFile(const AFileName: string);
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

procedure ThpDelTimer.SaveToFile(const AFileName: string);
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

procedure ThpDelTimer.LoadFromStream(AStream: TStream);
var
  reader: TReader;
  obj: TPersistent;
  ctype: TPersistentClass;
  cname: string;
begin
  FDelItems.Clear;
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
            if obj is ThpDelTimerItem then
              ThpDelTimerItem(obj).ReadData(reader);
          except
            obj.Free;
            raise;
          end;
          FDelItems.Add(obj);
        end;
      end;
      ReadListEnd;
    end;
  finally
    reader.Free;
  end;
end;

procedure ThpDelTimer.SaveToStream(AStream: TStream);
var
  writer: TWriter;
  i: Integer;
begin
  writer := TWriter.Create(AStream, $FF);
  try
    with writer do begin
      WriteSignature;
      WriteListBegin;
      for i := 0 to FDelItems.Count - 1 do begin
        if TObject(FDelItems[i]) is ThpDelTimerItem then begin
          WriteString(TPersistent(FDelItems[i]).ClassName);
          ThpDelTimerItem(FDelItems[i]).WriteData(writer);
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
  RegisterComponents('hpVCL', [ThpDelTimer]);
end;

initialization

  RegisterClass(ThpDelTimer);
  
finalization
  
  UnRegisterClass(ThpDelTimer);

end.
