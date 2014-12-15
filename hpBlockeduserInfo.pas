unit hpBlockeduserInfo;

interface

uses
  Classes, ComCtrls,
  hpGenericObjectList;

type
  ///	<summary>RoomInfo class for use with the ThpGenericObjectList</summary>
  ThpBlockeduserInfo = class(ThpGenericObject)
  private
    FImageIndex: String;
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

    ///	<summary>ImageIndex of the icon</summary>
    property ImageIndex: String read FImageIndex write FImageIndex;

  end;

implementation

uses
  SysUtils;

{ ThpBlockeduserInfo }

///	<summary>Initializes an instance of ThpBlockeduserInfo</summary>
constructor ThpBlockeduserInfo.Create;
begin
  inherited;
  FImageIndex := '0';
end;

///	<summary>Add additional properties to a list item</summary>
///	<param name="AListItem">List item to add to</param>
procedure ThpBlockeduserInfo.GetSubItems(AListItem: TListItem);
begin
  AListItem.ImageIndex := StrToInt(FImageIndex);
end;

///	<summary>Assign this object's properties to another instance</summary>
///	<param name="ADestination">The object to copy to</param>
procedure ThpBlockeduserInfo.AssignTo(ADestination: TPersistent);
begin
  inherited;
  if ADestination is ThpBlockeduserInfo then begin
    ThpBlockeduserInfo(ADestination).FImageIndex := FImageIndex;
  end;
end;

///	<summary>Define the object's properties using a filer object</summary>
///	<param name="AFiler">The filer to use</param>
procedure ThpBlockeduserInfo.DefineProperties(AFiler: TFiler);
begin
  inherited;
  AFiler.DefineProperty('BlockeduserInfo', ReadData, WriteData, True);
end;

///	<summary>Read the object's properties from a reader object</summary>
///	<param name="AReader">The reader to read from</param>
procedure ThpBlockeduserInfo.ReadData(AReader: TReader);
begin
  inherited;
  FImageIndex := AReader.ReadString;
end;

///	<summary>Write the object's properties to a writer object</summary>
///	<param name="AWriter">The writer to write to</param>
procedure ThpBlockeduserInfo.WriteData(AWriter: TWriter);
begin
  inherited;
  AWriter.WriteStr(FImageIndex);
end;

end.

