unit hpServiceInfo;

(**
 * @copyright Copyright (C) 2012-2014, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
 * @package   hpServiceInfo
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
  ///<summary>LobbyInfo class for use with the ThpGenericObjectList</summary>
  ThpServiceInfo = class(ThpGenericObject)
  private
    FPopulation, FMaxAllowUsers, FActiveRooms, FInactiveRooms: String;
  protected
    procedure AssignTo(ADestination: TPersistent); override;
    procedure DefineProperties(AFiler: TFiler); override;
    procedure ReadData(AReader: TReader); override;
    procedure WriteData(AWriter: TWriter); override;
  public
    constructor Create; virtual;
    procedure GetSubItems(AListItem: TListItem); override;
    ///	<summary>Population of the room</summary>
    property Population: String read FPopulation write FPopulation;
    ///	<summary>MaxAllow of the Lobby</summary>
    property MaxAllowUsers: String read FMaxAllowUsers write FMaxAllowUsers;
    ///	<summary>Population of the Lobby</summary>
    property ActiveRooms: String read FActiveRooms write FActiveRooms;
    ///	<summary>InactiveRooms of the Lobby</summary>
    property InactiveRooms: String read FInactiveRooms write FInactiveRooms;
  end;

implementation

uses
  SysUtils;

{ ThpServiceInfo }

///	<summary>Initializes an instance of ThpServiceInfo</summary>
constructor ThpServiceInfo.Create;
begin
  inherited;
  FPopulation := '0';
  FMaxAllowUsers := '0';
  FActiveRooms := '0';
  FInactiveRooms := '0';
end;

///	<summary>Add additional properties to a list item</summary>
///	<param name="AListItem">List item to add to</param>
procedure ThpServiceInfo.GetSubItems(AListItem: TListItem);
begin
  AListItem.SubItems.Add(FPopulation);
  AListItem.SubItems.Add(FMaxAllowUsers);
  AListItem.SubItems.Add(FActiveRooms);
  AListItem.SubItems.Add(FInactiveRooms);
end;

///	<summary>Assign this object's properties to another instance</summary>
///	<param name="ADestination">The object to copy to</param>
procedure ThpServiceInfo.AssignTo(ADestination: TPersistent);
begin
  inherited;
  if ADestination is ThpServiceInfo then begin
    ThpServiceInfo(ADestination).FPopulation := FPopulation;
    ThpServiceInfo(ADestination).FMaxAllowUsers := FMaxAllowUsers;
    ThpServiceInfo(ADestination).FActiveRooms := FActiveRooms;
    ThpServiceInfo(ADestination).FInactiveRooms := FInactiveRooms;
  end;
end;

///	<summary>Define the object's properties using a filer object</summary>
///	<param name="AFiler">The filer to use</param>
procedure ThpServiceInfo.DefineProperties(AFiler: TFiler);
begin
  inherited;
  AFiler.DefineProperty('ServiceInfo', ReadData, WriteData, True);
end;

///	<summary>Read the object's properties from a reader object</summary>
///	<param name="AReader">The reader to read from</param>
procedure ThpServiceInfo.ReadData(AReader: TReader);
begin
  inherited;
  FPopulation := AReader.ReadString;
  FMaxAllowUsers := AReader.ReadString;
  FActiveRooms := AReader.ReadString;
  FInactiveRooms := AReader.ReadString;
end;

///	<summary>Write the object's properties to a writer object</summary>
///	<param name="AWriter">The writer to write to</param>
procedure ThpServiceInfo.WriteData(AWriter: TWriter);
begin
  inherited;
  AWriter.WriteStr(FPopulation);
  AWriter.WriteStr(FMaxAllowUsers);
  AWriter.WriteStr(FActiveRooms);
  AWriter.WriteStr(FInactiveRooms);
end;

end.

