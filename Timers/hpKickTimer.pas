unit hpKickTimer;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Timers
 * @package   hpKickTimer
 * @version   1.04
 *)

(**
 * History
 *
 * 1.04       2011-07-08
 *            Added IsKickedUser
 *
 * 1.03       2011-07-08
 *            Added ClearUser
 *
 * 1.02	      2011-06-06
 *            LoadFromFile/SaveToFile
 *
 * 1.01       2011-03-09
 *            Room delete
 *
 * 1.00       2010-03-02
 *            Initial implementation (untested)
 *)

interface

uses
  Classes, Controls, ExtCtrls, Contnrs;

type
  (*
   * ThpKickTimer interface
   *)
  ThpKickTimer = class(TTimer)
  protected
    FKickItems: TObjectList;
    FKickDuration: Integer;
    procedure TimerInterval(Sender: TObject); virtual;
  published
    // Duration of a kick in minutes, defaults to 5
    property KickDuration: Integer read FKickDuration write FKickDuration default 5;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Add(const AUser: string; const ARoom: string = '');
    function IsKicked(const AUser, ARoom: string): Boolean;
    function IsKickedUser(const AUser: string): Boolean;
    procedure ClearRoom(const ARoom: string);
    procedure ClearUser(const AUser: string);
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
   * ThpKickItem interface
   *)
  ThpKickItem = class(TPersistent)
  protected
    FUser: string;
    FRoom: string;
    FDate: TDateTime;
  public
    constructor Create(const AUser, ARoom: string); virtual;
    procedure ReadData(AReader: TReader); dynamic;
    procedure WriteData(AWriter: TWriter); dynamic;
  published 
    property User: string read FUser write FUser;
    property Room: string read FRoom write FRoom;
    property Date: TDateTime read FDate write FDate;
  end;

(*
 * ThpKickItem implementation
 *)

constructor ThpKickItem.Create(const AUser, ARoom: string);
begin
  inherited Create;
  FUser := AUser;
  FRoom := ARoom;
  FDate := Now;
end;

procedure ThpKickItem.ReadData(AReader: TReader);
begin
  with AReader do begin
    User := ReadString;
    Room := ReadString;
    Date := ReadDate;
  end;
end;

procedure ThpKickItem.WriteData(AWriter: TWriter);
begin
  with AWriter do begin
    WriteString(User);
    WriteString(Room);
    WriteDate(Date);
  end;
end;

(*
 * ThpKickTimer implementation
 *)

constructor ThpKickTimer.Create(AOwner: TComponent);
begin
  inherited;
  FKickItems := TObjectList.Create(true);
  OnTimer := TimerInterval;
  // check the list every minute
  FKickDuration := 120;
  Interval := 60000;
  Enabled := False;
end;

destructor ThpKickTimer.Destroy;
begin
  FKickItems.Clear;
  FKickItems.Free;
  inherited;
end;

(*
 * Check for expired kicks and remove them from the list
 *)
procedure ThpKickTimer.TimerInterval(Sender: TObject);
var
  i: Integer;
  timediff: Int64;
begin
  // stop the timer while processing
  Enabled := False;

  i := FKickItems.Count - 1;
  while i > -1 do begin
    timediff := Round((Now - ThpKickItem(FKickItems[i]).FDate) * 1440);
    if timediff > FKickDuration then
      FKickItems.Delete(i);

    Dec(i);
  end;

  // enable the timer only if there are items in the list
  if FKickItems.Count > 0 then
    Enabled := True;
end;

(*
 * Add a kicked user/room combination to the list
 * Additionally start the timer if it is not already active
 *)
procedure ThpKickTimer.Add(const AUser: string; const ARoom: string = '');
begin
  FKickItems.Add(ThpKickItem.Create(AUser, ARoom));
  if not Enabled then
    Enabled := True;
end;

(*
 * Check if a user/room combination has been kicked
 * Returns true if the combination is found, false otherwise
 *)
function ThpKickTimer.IsKicked(const AUser, ARoom: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to FKickItems.Count - 1 do
    if (ThpKickItem(FKickItems[i]).FUser = AUser) and (ThpKickItem(FKickItems[i]).FRoom = ARoom) then begin
      Result := True;
      Break;
    end;
end;

(*
 * Check if a user has been kicked
 * Returns true if the user is found, false otherwise
 *)
function ThpKickTimer.IsKickedUser(const AUser: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to FKickItems.Count - 1 do
    if ThpKickItem(FKickItems[i]).FUser = AUser then begin
      Result := True;
      Break;
    end;
end;

procedure ThpKickTimer.ClearRoom(const ARoom: string);
var
  i: Integer;
begin
  for i := FKickItems.Count - 1 downto 0 do
    if (ThpKickItem(FKickItems[i]).FRoom = ARoom) then
      FKickItems.Delete(i);
end;

procedure ThpKickTimer.ClearUser(const AUser: string);
var
  i: Integer;
begin
  for i := FKickItems.Count - 1 downto 0 do
    if (ThpKickItem(FKickItems[i]).FUser = AUser) then
      FKickItems.Delete(i);
end;

procedure ThpKickTimer.LoadFromFile(const AFileName: string);
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

procedure ThpKickTimer.SaveToFile(const AFileName: string);
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

procedure ThpKickTimer.LoadFromStream(AStream: TStream);
var
  reader: TReader;
  obj: TPersistent;
  ctype: TPersistentClass;
  cname: string;
begin
  FKickItems.Clear;
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
            if obj is ThpKickItem then
              ThpKickItem(obj).ReadData(reader);
          except
            obj.Free;
            raise;
          end;
          FKickItems.Add(obj);
        end;
      end;
      ReadListEnd;
    end;
  finally
    reader.Free;
  end;
end;

procedure ThpKickTimer.SaveToStream(AStream: TStream);
var
  writer: TWriter;
  i: Integer;
begin
  writer := TWriter.Create(AStream, $FF);
  try
    with writer do begin
      WriteSignature;
      WriteListBegin;
      for i := 0 to FKickItems.Count - 1 do begin
        if TObject(FKickItems[i]) is ThpKickItem then begin
          WriteString(TPersistent(FKickItems[i]).ClassName);
          ThpKickItem(FKickItems[i]).WriteData(writer);
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
  RegisterComponents('hpVCL', [ThpKickTimer]);
end;

initialization

  RegisterClass(ThpKickItem);

finalization

  UnRegisterClass(ThpKickItem);

end.
