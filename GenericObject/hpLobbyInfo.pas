unit hpLobbyInfo;

(**
 * @copyright Copyright (C) 2012-2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  GenericObject
 * @package   hpLobbyInfo
 * @version   1.00
 *)

(**
 * History
 *
 * V1.00
 * - Initial release
 *)

interface

uses
  Classes, ComCtrls,
  hpGenericObjectList;

type
  ///	<summary>LobbyInfo class for use with the ThpGenericObjectList</summary>
  ThpLobbyInfo = class(ThpGenericObject)
  private
    FPopulation, FRoomCount, FGroupIndex, FImageIndex, FStateIndex, FLID: String;
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

    ///	<summary>Population of the Lobby</summary>
    property Population: String read FPopulation write FPopulation;

    ///	<summary>Rooms in this Lobby</summary>
    property RoomCount: String read FRoomCount write FRoomCount;

    ///	<summary>ImageIndex of the Lobby</summary>
    property ImageIndex: String read FImageIndex write FImageIndex;

    ///	<summary>ImageIndex of the Lobby</summary>
    property StateIndex: String read FStateIndex write FStateIndex;

    ///	<summary>LID of the Lobby</summary>
    property LID: String read FLID write FLID;

    ///	<summary>GroupIndex of the Lobby</summary>
    property GroupIndex: String read FGroupIndex write FGroupIndex;
  end;
  

implementation

uses
  SysUtils;

{ ThpLobbyInfo }

///	<summary>Initializes an instance of ThpLobbyInfo</summary>
constructor ThpLobbyInfo.Create;
begin
  inherited;
  FRoomCount := '0';
  FPopulation := '0';
  FImageIndex := '0';
  FStateIndex := '0';
  FGroupIndex := '0';
end;

///	<summary>Add additional properties to a list item</summary>
///	<param name="AListItem">List item to add to</param>
procedure ThpLobbyInfo.GetSubItems(AListItem: TListItem);
begin
  AListItem.ImageIndex := StrToInt(FImageIndex);
  AListItem.StateIndex := StrToInt(FStateIndex);
  AListItem.GroupID := StrToInt(FGroupIndex);
  AListItem.SubItems.Add(FPopulation);
  AListItem.SubItems.Add(FRoomCount);
  AListItem.SubItems.Add(FLID);
end;

///	<summary>Assign this object's properties to another instance</summary>
///	<param name="ADestination">The object to copy to</param>
procedure ThpLobbyInfo.AssignTo(ADestination: TPersistent);
begin
  inherited;
  if ADestination is ThpLobbyInfo then begin
    ThpLobbyInfo(ADestination).FGroupIndex := FGroupIndex;
    ThpLobbyInfo(ADestination).FImageIndex := FImageIndex;
    ThpLobbyInfo(ADestination).FStateIndex := FStateIndex;
    ThpLobbyInfo(ADestination).FPopulation := FPopulation;
    ThpLobbyInfo(ADestination).FRoomCount := FRoomCount;
    ThpLobbyInfo(ADestination).FLID := FLID;
  end;
end;

///	<summary>Define the object's properties using a filer object</summary>
///	<param name="AFiler">The filer to use</param>
procedure ThpLobbyInfo.DefineProperties(AFiler: TFiler);
begin
  inherited;
  AFiler.DefineProperty('LobbyInfo', ReadData, WriteData, True);
end;

///	<summary>Read the object's properties from a reader object</summary>
///	<param name="AReader">The reader to read from</param>
procedure ThpLobbyInfo.ReadData(AReader: TReader);
begin
  inherited;
  FLID := AReader.ReadString;
  FRoomCount := AReader.ReadString;
  FPopulation := AReader.ReadString;
  FGroupIndex := AReader.ReadString;
  FImageIndex := AReader.ReadString;
  FStateIndex := AReader.ReadString;
end;

///	<summary>Write the object's properties to a writer object</summary>
///	<param name="AWriter">The writer to write to</param>
procedure ThpLobbyInfo.WriteData(AWriter: TWriter);
begin
  inherited;
  AWriter.WriteStr(FLID);
  AWriter.WriteStr(FRoomCount);
  AWriter.WriteStr(FPopulation);
  AWriter.WriteStr(FGroupIndex);
  AWriter.WriteStr(FImageIndex);
  AWriter.WriteStr(FStateIndex);
end;

end.

