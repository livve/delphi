unit hpUser;

interface

uses
  Classes, ComCtrls,
  hpGenericObjectList;

type
  ///	<summary>User class for use with the ThpGenericObjectList</summary>
  ThpUser = class(ThpGenericObject)
  private
    FEmail: string;
  protected
    procedure AssignTo(ADestination: TPersistent); override;
    procedure DefineProperties(AFiler: TFiler); override;
    procedure ReadData(AReader: TReader); override;
    procedure WriteData(AWriter: TWriter); override;
  public
    procedure GetSubItems(AListItem: TListItem); override;

    ///	<summary>Alias for the Identifier property</summary>
    ///	<value>Item identifier</value>
    property User: string read FIdentifier;
    property FullName: string read FDescription write FDescription;
    property Email: string read FEmail write FEmail;
  end;

implementation

{ ThpUser }


///	<summary>Add additional properties to a list item</summary>
///	<param name="AListItem">List item to add to</param>
procedure ThpUser.GetSubItems(AListItem: TListItem);
begin
  inherited;
  AListItem.SubItems.Add(FEmail);
end;

///	<summary>Assign this object's properties to another instance</summary>
///	<param name="ADestination">The object to copy to</param>
procedure ThpUser.AssignTo(ADestination: TPersistent);
begin
  inherited;
  if ADestination is ThpUser then
    ThpUser(ADestination).FEmail := FEmail;
end;

///	<summary>Define the object's properties using a filer object</summary>
///	<param name="AFiler">The filer to use</param>
procedure ThpUser.DefineProperties(AFiler: TFiler);
begin
  inherited;
  AFiler.DefineProperty('User', ReadData, WriteData, True);
end;

///	<summary>Read the object's properties from a reader object</summary>
///	<param name="AReader">The reader to read from</param>
procedure ThpUser.ReadData(AReader: TReader);
begin
  inherited;
  FEmail := AReader.ReadString;
end;

///	<summary>Write the object's properties to a writer object</summary>
///	<param name="AWriter">The writer to write to</param>
procedure ThpUser.WriteData(AWriter: TWriter);
begin
  inherited;
  AWriter.WriteString(FEmail);
end;

end.

