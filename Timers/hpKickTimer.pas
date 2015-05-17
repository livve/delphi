unit hpKickTimer;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Timers
 * @package   hpKickTimer
 * @version   1.05
 *)

(**
 * History
 *
 * V1.05 2015-05-17
 * - Introduced custom base class
 *
 * V1.04 2011-07-08
 * - Added IsKickedUser
 *
 * V1.03 2011-07-08
 * - Added ClearUser
 *
 * V1.02 2011-06-06
 * - LoadFromFile/SaveToFile
 *
 * V1.01 2011-03-09
 * - Room delete
 *
 * V1.00 2010-03-02
 * - Initial release (untested)
 *)

interface

uses
  Classes, Controls, ExtCtrls, Contnrs,
  hpCustomTimer;

type
  (**
   * ThpKickTimer interface
   *)
  ThpKickTimer = class(ThpCustomTimer)
  protected
    FKickDuration: Integer;
    procedure TimerInterval(Sender: TObject); override;
  published
    // Duration of a kick in minutes, defaults to 5
    property KickDuration: Integer read FKickDuration write FKickDuration default 5;
  public
    constructor Create(AOwner: TComponent); override;
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
  (**
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
  FKickDuration := 120;
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

  i := FItems.Count - 1;
  while i > -1 do begin
    timediff := Round((Now - ThpKickItem(FItems[i]).FDate) * 1440);
    if timediff > FKickDuration then
      FItems.Delete(i);

    Dec(i);
  end;

  // enable the timer only if there are items in the list
  if FItems.Count > 0 then
    Enabled := True;
end;

(*
 * Add a kicked user/room combination to the list
 * Additionally start the timer if it is not already active
 *)
procedure ThpKickTimer.Add(const AUser: string; const ARoom: string = '');
begin
  FItems.Add(ThpKickItem.Create(AUser, ARoom));
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
  for i := 0 to FItems.Count - 1 do
    if (ThpKickItem(FItems[i]).FUser = AUser) and (ThpKickItem(FItems[i]).FRoom = ARoom) then begin
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
  for i := 0 to FItems.Count - 1 do
    if ThpKickItem(FItems[i]).FUser = AUser then begin
      Result := True;
      Break;
    end;
end;

procedure ThpKickTimer.ClearRoom(const ARoom: string);
var
  i: Integer;
begin
  for i := FItems.Count - 1 downto 0 do
    if (ThpKickItem(FItems[i]).FRoom = ARoom) then
      FItems.Delete(i);
end;

procedure ThpKickTimer.ClearUser(const AUser: string);
var
  i: Integer;
begin
  for i := FItems.Count - 1 downto 0 do
    if (ThpKickItem(FItems[i]).FUser = AUser) then
      FItems.Delete(i);
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
  FItems.Clear;
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
          FItems.Add(obj);
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
      for i := 0 to FItems.Count - 1 do begin
        if TObject(FItems[i]) is ThpKickItem then begin
          WriteString(TPersistent(FItems[i]).ClassName);
          ThpKickItem(FItems[i]).WriteData(writer);
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
