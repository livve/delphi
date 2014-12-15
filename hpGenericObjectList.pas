///	<summary>Defines a generic object list capable of sorting, searching,
///	loading and saving custom classes</summary>
unit hpGenericObjectList;

(**
 * @copyright Copyright (C) 2011, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  hpClasses
 * @package   ThpGenericObjectList
 * @version   1.03
 *
 * @todo Introduce ThpCustomObjectList
 * @todo Rename to ThpObjectList (descend from ThpCustomObjectList)
 * @todo Introduce ThpCustomObjectListItem
 * @todo Rename to ThpObjectListItem
 * @todo Add FSubItems (TStrings) to ThpCustomObjectListItem
 *
 * V1.03 2011-08-13
 * - Added overloaded Delete function (by identifier)
 * - Changed Delete to function
 * - Added BeginUpdate/EndUpdate
 *
 * V1.02 2011-08-06
 * - Added Description property
 * - Added GetStrings function
 * - Added Clear function
 * - Added GetListItems/GetSubItems functions
 * - Added overloaded GetListItems function to get a subset (for paging)
 *
 * V1.01 2011-08-03
 * - Added Ascending property (default True)
 * - Added CaseSensitive property (default False)
 * - Added Duplicates property (default False)
 * - Added Sorted property (default True)
 * - Updated Find with binary search (when sorted)
 * - Replaced JavaDoc comments with XML comments (except the header)
 * - Moved ThpGenericObject to seperate unit
 * - Added LoadFromFile/SaveToFile functions
 * - Added LoadFromStream/SaveToStream functions
 *
 * V1.00 2011-07-29
 * - Initial release
 *)

interface

uses
  Classes, ComCtrls, Contnrs;

type
  ///	<summary>ThpCustomObjectListItem is the base class for use with the ThpCustomObjectList</summary>
  ThpCustomObjectListItem = class(TPersistent)
  end;

  ///	<summary>ThpGenericObject is the base class for use with the generic
  ///	object list</summary>
  ThpGenericObject = class(ThpCustomObjectListItem)
  protected
    FIdentifier: string;
    FDescription: string;
    procedure AssignTo(ADestination: TPersistent); override;
    procedure DefineProperties(AFiler: TFiler); override;
    procedure ReadData(AReader: TReader); virtual;
    procedure WriteData(AWriter: TWriter); virtual;
  public
    function Compare(AObject: ThpGenericObject;
      ACaseSensitive: Boolean): Integer; virtual;
    procedure GetSubItems(AListItem: TListItem); virtual;

    ///	<value>Read-only identifying string for this instance</value>
    property Identifier: string read FIdentifier;

    ///	<value>Read-only descriptive string for this instance</value>
    property Description: string read FDescription write FDescription;
  end;

  ThpCustomObjectList<T: constructor, ThpGenericObject> = class
  end;

  ///	<summary>ThpGenericObjectList is a sorted object list of type T. T must
  ///	be a descendant class of ThpGenericObject</summary>
  ///	<typeparam name="T">Descendant class of ThpGenericObject</typeparam>
  ThpGenericObjectList<T: constructor, ThpGenericObject> = class(ThpCustomObjectList<T>)
  private
    FAscending: Boolean;
    FCaseSensitive: Boolean;
    FDuplicates: Boolean;
    FItems: TObjectList;
    FSorted: Boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Add(const AIdentifier: string): T; virtual;
    procedure Clear; virtual;
    function Delete(AIndex: Integer): Boolean; overload; virtual;
    function Delete(const AIdentifier: string): Boolean; overload; virtual;
    function Find(const AIdentifier: string): Integer; virtual;
    procedure GetListItems(AListItems: TListItems); overload; virtual;
    procedure GetListItems(AListItems: TListItems;
      AStart, ALimit: Integer); overload; virtual;
    procedure GetStrings(AStrings: TStrings); virtual;
    procedure LoadFromFile(const AFileName: string); virtual;
    procedure SaveToFile(const AFileName: string); virtual;
  protected
    function GetCount: Integer; virtual;
    function GetItem(AIndex: Integer): T; virtual;
    procedure IdentifierSort; virtual;
    procedure LoadFromStream(AStream: TStream); virtual;
    procedure SaveToStream(AStream: TStream); virtual;
    procedure SetAscending(AValue: Boolean); virtual;
    procedure SetCaseSensitive(AValue: Boolean); virtual;
    procedure SetDuplicates(AValue: Boolean); virtual;
    procedure SetSorted(AValue: Boolean); virtual;
  public
    ///	<value>Returns the number of items in the list</value>
    property Count: Integer read GetCount;

    ///	<value>True (default) indicates ascending sort, False indicates
    ///	descending sort</value>
    property Ascending: Boolean read FAscending write SetAscending;

    ///	<value>True finds and compares case sensitive, default False</value>
    property CaseSensitive: Boolean read FCaseSensitive
      write SetCaseSensitive;

    ///	<value>True allows duplicate items to be added, default False</value>
    property Duplicates: Boolean read FDuplicates write SetDuplicates;

    ///	<summary>Items array</summary>
    ///	<param name="AIndex">Index of the item to access</param>
    ///	<value>Returned item, or nil if the index is out-of-bounds</value>
    property Items[AIndex: Integer]: T read GetItem; default;

    ///	<value>True (default) sorts the list</value>
    property Sorted: Boolean read FSorted write SetSorted;
  end;

implementation

uses
  Math, SysUtils;

{ ThpGenericObject }

///	<summary>Compares the instance with the provided instance. The compare
///	depends on parameter ACaseSensitive</summary>
///	<param name="AObject">Instance to compare to</param>
///	<param name="ACaseSensitive">Compare case sensitive when True</param>
///	<returns>Negative when non nil and smaller, positive when non nil and
///	larger, 0 otherwise</returns>
function ThpGenericObject.Compare(AObject: ThpGenericObject;
  ACaseSensitive: Boolean): Integer;
begin
  Result := 0;
  if AObject <> nil then begin
    if ACaseSensitive then
      Result := AnsiCompareStr(FIdentifier, AObject.FIdentifier)
    else
      Result := AnsiCompareText(FIdentifier, AObject.FIdentifier)
  end;
end;

///	<summary>Fill the sub-items with additional properties</summary>
///	<param name="AListItem">The list item to add to</param>
procedure ThpGenericObject.GetSubItems(AListItem: TListItem);
begin
  AListItem.SubItems.Add(FDescription);
end;

///	<summary>Assign this object's properties to another instance</summary>
///	<param name="ADestination">The object to copy to</param>
procedure ThpGenericObject.AssignTo(ADestination: TPersistent);
begin
  if ADestination is ThpGenericObject then
    ThpGenericObject(ADestination).FIdentifier := FIdentifier
  else
    inherited;
end;

///	<summary>Define the object's properties using a filer object</summary>
///	<param name="AFiler">The filer to use</param>
procedure ThpGenericObject.DefineProperties(AFiler: TFiler);
begin
  AFiler.DefineProperty('Generic', ReadData, WriteData, True);
end;

///	<summary>Read the object's properties from a reader object</summary>
///	<param name="AReader">The reader to read from</param>
procedure ThpGenericObject.ReadData(AReader: TReader);
begin
  FIdentifier := AReader.ReadString;
  FDescription := AReader.ReadString;
end;

///	<summary>Write the object's properties to a writer object</summary>
///	<param name="AWriter">The writer to write to</param>
procedure ThpGenericObject.WriteData(AWriter: TWriter);
begin
  AWriter.WriteString(FIdentifier);
  AWriter.WriteString(FDescription);
end;

{ ThpGenericObjectList }

///	<summary>Creates an instance of ThpGenericObjectList</summary>
constructor ThpGenericObjectList<T>.Create;
begin
  FAscending := True;
  FCaseSensitive := False;
  FDuplicates := False;
  FItems := TObjectList.Create;
  FItems.OwnsObjects := True;
  FSorted := True;

  { Register the class for streaming }
  RegisterClass(T);
end;

///	<summary>Frees an instance of ThpGenericObjectList</summary>
destructor ThpGenericObjectList<T>.Destroy;
begin
  FItems.Free;
  inherited;
end;

///	<summary>Creates a new item and adds it to the list if a matching item is
///	not found already. Otherwise the matching item will be returned</summary>
///	<param name="AIdentifier">Identifier for the new item</param>
///	<returns>New or existing item</returns>
function ThpGenericObjectList<T>.Add(const AIdentifier: string): T;
var
  idx: Integer;
begin
  Result := nil;
  if AIdentifier > '' then begin
    idx := Find(AIdentifier);
    if (idx > -1) and not FDuplicates then
      Result := Items[idx]
    else begin
      Result := T.Create;
      Result.FIdentifier := AIdentifier;
      FItems.Add(Result);
      IdentifierSort;
    end;
  end;
end;

///	<summary>Clear the list</summary>
procedure ThpGenericObjectList<T>.Clear;
begin
  FItems.Clear;
end;

///	<summary>Deletes the item from the list specified by the AIndex</summary>
///	<param name="AIndex">Index of the item to delete</param>
///	<remarks>Prevents a list index error by doing an out-of-bounds
///	check</remarks>
function ThpGenericObjectList<T>.Delete(AIndex: Integer): Boolean;
begin
  Result := (AIndex >= 0) and (AIndex < FItems.Count);
  if Result then
    FItems.Delete(AIndex);
end;

///	<summary>Deletes the item from the list specified by the AIdentifier</summary>
///	<param name="AIdentifier">Identifier of the item to delete</param>
function ThpGenericObjectList<T>.Delete(const AIdentifier: string): Boolean;
begin
  Result := Delete(Find(AIdentifier));
end;

///	<summary>Finds the index of an item in the list that matches
///	AIdentifier</summary>
///	<param name="AIdentifier">Identifier to find</param>
///	<returns>Index of the matching item, or -1 if no match is found</returns>
function ThpGenericObjectList<T>.Find(const AIdentifier: string): Integer;
var
  first, last, current, compare: Integer;
  found: Boolean;
  obj: T;
begin
  Result := -1;

  // Create a comparison object
  obj := T.Create;
  obj.FIdentifier := AIdentifier;

  if (FSorted and not FDuplicates) then begin // Do a binary search
    first := 0;
    last := FItems.Count - 1;
    found := False;
    while (first <= last) and (not found) do begin
      current := (first + last) div 2;

      compare := T(FItems[current]).Compare(obj, FCaseSensitive);
      if not FAscending then
        compare := - compare;

      if compare = 0 then begin
        found := True;
        Result := current;
      end
      else if compare > 0 then
        last := current - 1
      else
        first := current + 1;
    end;
  end
  else // Do a linear search
    for current := 0 to FItems.Count - 1 do
      if T(FItems[current]).Compare(obj, FCaseSensitive) = 0 then begin
        Result := current;
        Break;
      end;

  obj.Free;
end;

///	<summary>Stores all identifiers from the list into a TListItems
///	object</summary>
///	<param name="AListItems">ListItems object to use</param>
///	<remarks>ListItems parameter will be cleared</remarks>
procedure ThpGenericObjectList<T>.GetListItems(AListItems: TListItems);
begin
  GetListItems(AlistItems, 0, FItems.Count);
end;

///	<summary>Stores all identifiers from the list into a TListItems object,
///	starting at AStart, returning ALimit items</summary>
///	<param name="AListItems">ListItems object to use</param>
///	<param name="AStart">Index to start at</param>
///	<param name="ALimit">Number of items to return</param>
///	<remarks>ListItems parameter will be cleared</remarks>
procedure ThpGenericObjectList<T>.GetListItems(AListItems: TListItems;
  AStart, ALimit: Integer);
var
  idx: Integer;
  item: TListItem;
begin
  AListItems.BeginUpdate;
  AListItems.Clear;
  for idx := Max(AStart, 0) to Min(AStart + ALimit - 1, FItems.Count - 1) do begin
    item := AListItems.Add;
    item.Data := FItems[idx];
    item.Caption := T(FItems[idx]).FIdentifier;
    T(FItems[idx]).GetSubItems(item);
  end;
  AListItems.EndUpdate;
end;

///	<summary>Stores all identifiers from the list into a TStrings
///	object</summary>
///	<param name="AStrings">Strings object to use</param>
///	<remarks>Strings parameter will be cleared</remarks>
procedure ThpGenericObjectList<T>.GetStrings(AStrings: TStrings);
var
  idx: Integer;
begin
  AStrings.BeginUpdate;
  AStrings.Clear;
  for idx := 0 to FItems.Count - 1 do
    AStrings.AddObject(T(FItems[idx]).FIdentifier, FItems[idx]);

  AStrings.EndUpdate;
end;

///	<summary>Load an object list from a file</summary>
///	<param name="AFileName">File name to load from</param>
///	<exception cref="EFOpenError">When the file cannot be opened</exception>
procedure ThpGenericObjectList<T>.LoadFromFile(const AFileName: string);
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

///	<summary>Save an object list to a file</summary>
///	<param name="AFileName">File name to save to</param>
///	<exception cref="EFCreateError">When the file cannot be created</exception>
procedure ThpGenericObjectList<T>.SaveToFile(const AFileName: string);
var
  stream: TFileStream;
begin
  stream := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(stream);
  finally
    stream.Free;
  end;
end;

///	<summary>Gets the number of items in the list</summary>
///	<returns>Number of items in the list</returns>
function ThpGenericObjectList<T>.GetCount: Integer;
begin
  Result := FItems.Count;
end;

///	<summary>Gets the item in the list specified by the AIndex</summary>
///	<param name="AIndex">Index of the item to return</param>
///	<returns>Item specified by AIndex, or nil if AIndex is out of
///	bounds</returns>
function ThpGenericObjectList<T>.GetItem(AIndex: Integer): T;
begin
  if (AIndex >= 0) and (AIndex < FItems.Count) then
    Result := T(FItems[AIndex])
  else
    Result := nil;
end;

///	<summary>Sorts the list by calling Compare on the items</summary>
procedure ThpGenericObjectList<T>.IdentifierSort;
begin
  if FSorted and (FItems.Count > 1) then
    FItems.SortList(
      function (L, R: Pointer): Integer
      begin
        Result := ThpGenericObject(L).Compare(R, FCaseSensitive);
        if not FAscending then
          Result := - Result;
      end
    );
end;

///	<summary>Load an object list from a stream</summary>
///	<param name="AStream">Stream to load from</param>
procedure ThpGenericObjectList<T>.LoadFromStream(AStream: TStream);
var
  idx, count: Integer;
  reader: TReader;
  obj: T;
begin
  reader := TReader.Create(AStream, $FF);
  try
    reader.ReadSignature;
    FAscending := reader.ReadBoolean;
    FCaseSensitive := reader.ReadBoolean;
    FDuplicates := reader.ReadBoolean;
    FSorted := reader.ReadBoolean;

    count := reader.ReadInteger;
    if count > 0 then begin
      reader.ReadListBegin;
      for idx := 0 to count - 1 do begin
        obj := T.Create;
        obj.ReadData(reader);
        FItems.Add(obj);
      end;
      reader.ReadListEnd;
    end;
  finally
    reader.Free;
  end;
end;

///	<summary>Save an object list to a stream</summary>
///	<param name="AStream">Stream to save to</param>
procedure ThpGenericObjectList<T>.SaveToStream(AStream: TStream);
var
  idx: Integer;
  writer: TWriter;
  stream: TFileStream;
begin
  writer := TWriter.Create(AStream, $FF);
  try
    writer.WriteSignature;
    writer.WriteBoolean(FAscending);
    writer.WriteBoolean(FCaseSensitive);
    writer.WriteBoolean(FDuplicates);
    writer.WriteBoolean(FSorted);

    writer.WriteInteger(FItems.Count);
    if FItems.Count > 0 then begin
      writer.WriteListBegin;
      for idx := 0 to FItems.Count - 1 do begin
        T(FItems[idx]).WriteData(writer);
      end;
      writer.WriteListEnd;
    end;
  finally
    writer.Free;
  end;
end;

///	<summary>Sets the Ascending property</summary>
///	<param name="AValue">New value for the Ascending property</param>
procedure ThpGenericObjectList<T>.SetAscending(AValue: Boolean);
begin
  if AValue <> FAscending then begin
    FAscending := AValue;
    IdentifierSort;
  end;
end;

///	<summary>Sets the CaseSensitive property</summary>
///	<param name="AValue">New value for the CaseSensitive property</param>
procedure ThpGenericObjectList<T>.SetCaseSensitive(AValue: Boolean);
begin
  if AValue <> FCaseSensitive then begin
    FCaseSensitive := AValue;
    IdentifierSort;
  end;
end;

///	<summary>Sets the Duplicates property</summary>
///	<param name="AValue">New value for the Duplicates property</param>
procedure ThpGenericObjectList<T>.SetDuplicates(AValue: Boolean);
begin
  if AValue <> FDuplicates then
    FDuplicates := AValue;
end;

///	<summary>Sets the Sorted property</summary>
///	<param name="AValue">New value for the Sorted property</param>
procedure ThpGenericObjectList<T>.SetSorted(AValue: Boolean);
begin
  if AValue <> FSorted then begin
    FSorted := AValue;
    IdentifierSort;
  end;
end;

end.
