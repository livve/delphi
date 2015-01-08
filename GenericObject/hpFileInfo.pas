unit hpFileInfo;

(**
 * @copyright Copyright (C) 2012-2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  GenericObject
 * @package   hpFileInfo
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
  ///	<summary>RoomInfo class for use with the ThpGenericObjectList</summary>
  ThpFileInfo = class(ThpGenericObject)
  private
    FProgress, FFileSize, FFileTo: String;
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
    property Progress: String read FProgress write FProgress;

    ///	<summary>Latency of the room</summary>
    property FileSize: String read FFileSize write FFileSize;

    ///	<summary>Comment of the room</summary>
    property FileTo: String read FFileTo write FFileTo;
  end;

implementation

uses
  SysUtils;

{ ThpFileInfo }

///	<summary>Initializes an instance of ThpFileInfo</summary>
constructor ThpFileInfo.Create;
begin
  inherited;
  FProgress := '';
  FFileSize := '';
  FFileTo := '';
end;

///	<summary>Add additional properties to a list item</summary>
///	<param name="AListItem">List item to add to</param>
procedure ThpFileInfo.GetSubItems(AListItem: TListItem);
begin
  AListItem.SubItems.Add(FProgress);
  AListItem.SubItems.Add(FFileSize);
  AListItem.SubItems.Add(FFileTo);
end;

///	<summary>Assign this object's properties to another instance</summary>
///	<param name="ADestination">The object to copy to</param>
procedure ThpFileInfo.AssignTo(ADestination: TPersistent);
begin
  inherited;
  if ADestination is ThpFileInfo then begin
    ThpFileInfo(ADestination).FProgress := FProgress;
    ThpFileInfo(ADestination).FFileSize := FFileSize;
    ThpFileInfo(ADestination).FFileTo := FFileTo;
  end;
end;

///	<summary>Define the object's properties using a filer object</summary>
///	<param name="AFiler">The filer to use</param>
procedure ThpFileInfo.DefineProperties(AFiler: TFiler);
begin
  inherited;
  AFiler.DefineProperty('FileInfo', ReadData, WriteData, True);
end;

///	<summary>Read the object's properties from a reader object</summary>
///	<param name="AReader">The reader to read from</param>
procedure ThpFileInfo.ReadData(AReader: TReader);
begin
  inherited;
  FProgress := AReader.ReadString;
  FFileSize := AReader.ReadString;
  FFileTo := AReader.ReadString;
end;

///	<summary>Write the object's properties to a writer object</summary>
///	<param name="AWriter">The writer to write to</param>
procedure ThpFileInfo.WriteData(AWriter: TWriter);
begin
  inherited;
  AWriter.WriteStr(FProgress);
  AWriter.WriteStr(FFileSize);
  AWriter.WriteStr(FFileTo);
end;

end.

