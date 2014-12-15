unit hpRoomInfo;

interface

uses
  Classes, ComCtrls,
  hpGenericObjectList;

type
  ///	<summary>Status for a room</summary>
  ThpRoomStatus = (rsUnlocked, rsLocked);

  ///	<summary>RoomInfo class for use with the ThpGenericObjectList</summary>
  ThpRoomInfo = class(ThpGenericObject)
  private
    FPopulation, FGroupIndex, FImageIndex, FStateIndex, FSortOrder, FLatency, FComment, FRoom: String;
    FStatus: ThpRoomStatus;
  protected
    procedure AssignTo(ADestination: TPersistent); override;
    procedure DefineProperties(AFiler: TFiler); override;
    procedure ReadData(AReader: TReader); override;
    procedure WriteData(AWriter: TWriter); override;
  public
    constructor Create; virtual;
    procedure GetSubItems(AListItem: TListItem); override;

    ///	<summary>Alias for the Identifier property</summary>
    ///	<value>Item identifier</value>
    property Name: string read FIdentifier;

    ///	<summary>Population of the room</summary>
    property Population: String read FPopulation write FPopulation;

    ///	<summary>ImageIndex of the room</summary>
    property ImageIndex: String read FImageIndex write FImageIndex;

    ///	<summary>ImageIndex of the room</summary>
    property StateIndex: String read FStateIndex write FStateIndex;

    ///	<summary>GroupIndex of the room</summary>
    property GroupIndex: String read FGroupIndex write FGroupIndex;

    ///	<summary>Latency of the room</summary>
    property Latency: String read FLatency write FLatency;

    ///	<summary>Comment of the room</summary>
    property Comment: String read FComment write FComment;

    ///	<summary>Room of the room</summary>
    property Room: String read FRoom write FRoom;

    ///	<summary>GroupIndex of the room</summary>
    property SortOrder: String read FSortOrder write FSortOrder;

    ///	<summary>Status of the room, default unlocked</summary>
    property Status: ThpRoomStatus read FStatus write FStatus;
  end;
  
const
  ThpRoomStatusDescription: array [ThpRoomStatus] of string = ('Unlocked', 'Locked');

implementation

uses
  SysUtils;

{ ThpRoomInfo }

///	<summary>Initializes an instance of ThpRoomInfo</summary>
constructor ThpRoomInfo.Create;
begin
  inherited;
  FPopulation := '0';
  FImageIndex := '0';
  FStateIndex := '0';
  FGroupIndex := '0';
  FSortOrder := '0';
  FLatency := '';
  FComment := '';
  FRoom := '000';
  FStatus := rsUnlocked;
end;

///	<summary>Add additional properties to a list item</summary>
///	<param name="AListItem">List item to add to</param>
procedure ThpRoomInfo.GetSubItems(AListItem: TListItem);
begin
  AListItem.ImageIndex := StrToInt(FImageIndex);
  AListItem.StateIndex := StrToInt(FStateIndex);
  AListItem.GroupID := StrToInt(FGroupIndex);
  AListItem.SubItems.Add(FPopulation);
  AListItem.SubItems.Add(FLatency);
  AListItem.SubItems.Add(FComment);
  AListItem.SubItems.Add(FRoom);
  AListItem.SubItems.Add(ThpRoomStatusDescription[FStatus]);
end;

///	<summary>Assign this object's properties to another instance</summary>
///	<param name="ADestination">The object to copy to</param>
procedure ThpRoomInfo.AssignTo(ADestination: TPersistent);
begin
  inherited;
  if ADestination is ThpRoomInfo then begin
    ThpRoomInfo(ADestination).FGroupIndex := FGroupIndex;
    ThpRoomInfo(ADestination).FImageIndex := FImageIndex;
    ThpRoomInfo(ADestination).FStateIndex := FStateIndex;
    ThpRoomInfo(ADestination).FSortOrder := FSortOrder;
    ThpRoomInfo(ADestination).FPopulation := FPopulation;
    ThpRoomInfo(ADestination).FLatency := FLatency;
    ThpRoomInfo(ADestination).FComment := FComment;
    ThpRoomInfo(ADestination).FRoom := FRoom;
    ThpRoomInfo(ADestination).FStatus := FStatus;
  end;
end;

///	<summary>Define the object's properties using a filer object</summary>
///	<param name="AFiler">The filer to use</param>
procedure ThpRoomInfo.DefineProperties(AFiler: TFiler);
begin
  inherited;
  AFiler.DefineProperty('RoomInfo', ReadData, WriteData, True);
end;

///	<summary>Read the object's properties from a reader object</summary>
///	<param name="AReader">The reader to read from</param>
procedure ThpRoomInfo.ReadData(AReader: TReader);
begin
  inherited;
  FPopulation := AReader.ReadString;
  FGroupIndex := AReader.ReadString;
  FImageIndex := AReader.ReadString;
  FStateIndex := AReader.ReadString;
  FSortOrder := AReader.ReadString;
  FLatency := AReader.ReadString;
  FComment := AReader.ReadString;
  FRoom := AReader.ReadString;
  FStatus := ThpRoomStatus(AReader.ReadInteger);
end;

///	<summary>Write the object's properties to a writer object</summary>
///	<param name="AWriter">The writer to write to</param>
procedure ThpRoomInfo.WriteData(AWriter: TWriter);
begin
  inherited;
  AWriter.WriteStr(FPopulation);
  AWriter.WriteStr(FGroupIndex);
  AWriter.WriteStr(FImageIndex);
  AWriter.WriteStr(FStateIndex);
  AWriter.WriteStr(FSortOrder);
  AWriter.WriteStr(FLatency);
  AWriter.WriteStr(FComment);
  AWriter.WriteStr(FRoom);
  AWriter.WriteInteger(Ord(FStatus));
end;

end.

