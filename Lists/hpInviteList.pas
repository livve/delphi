unit hpInviteList;

(**
 * @copyright Copyright (C) 2012-2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Lists
 * @package   hpInviteList
 * @version   1.00
 *)

(**
 * History
 *
 * 1.00       2012-05-02
 *            Initial implementation
 *)

interface

uses
  Classes, Generics.Defaults, Generics.Collections;

type
  ThpInviteItem = record
    Room, User: string;
  end;

  ThpInviteList = class(TPersistent)
  private
    FItems: TList<ThpInviteItem>;
    FCompare: IComparer<ThpInviteItem>;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Add(const ARoom, AUser: string);
    procedure Clear;
    procedure Delete(const ARoom, AUser: string);
    procedure DeleteRoom(const ARoom: string);
    procedure DeleteUser(const AUser: string);
    function Exists(const ARoom, AUser: string): Boolean;
  end;

implementation

uses
  SysUtils;

function hpInviteItemCompare(const ALeft, ARight: ThpInviteItem): Integer;
begin
  Result := CompareStr(ALeft.Room, ARight.Room);
  if Result = 0 then
    Result := CompareStr(ALeft.User, ARight.User);
end;

{ ThpInviteList }

constructor ThpInviteList.Create;
begin
  FItems := TList<ThpInviteItem>.Create();
  FCompare := TComparer<ThpInviteItem>.Construct(hpInviteItemCompare);
end;

destructor ThpInviteList.Destroy;
begin
  FItems.Clear;
  FItems.Free;
  FCompare := nil;
  inherited;
end;

procedure ThpInviteList.Add(const ARoom, AUser: string);
var
  item: ThpInviteItem;
  i: integer;
begin
  item.Room := ARoom;
  item.User := AUser;
  if not FItems.BinarySearch(item, i, FCompare) then begin
    FItems.Add(item);
    FItems.Sort(FCompare);
  end;
end;

procedure ThpInviteList.Clear;
begin
  FItems.Clear;
end;

procedure ThpInviteList.Delete(const ARoom, AUser: string);
var
  item: ThpInviteItem;
  i: integer;
begin
  item.Room := ARoom;
  item.User := AUser;
  if FItems.BinarySearch(item, i, FCompare) then
    FItems.Delete(i);
end;

procedure ThpInviteList.DeleteRoom(const ARoom: string);
var
  i: Integer;
begin
  for i := FItems.Count - 1 downto 0 do
    if CompareStr(ARoom, FItems[i].Room) = 0 then
      FItems.Delete(i);
end;

procedure ThpInviteList.DeleteUser(const AUser: string);
var
  i: Integer;
begin
  for i := FItems.Count - 1 downto 0 do
    if CompareStr(AUser, FItems[i].User) = 0 then
      FItems.Delete(i);
end;

function ThpInviteList.Exists(const ARoom, AUser: string): Boolean;
var
  item: ThpInviteItem;
  i: integer;
begin
  item.Room := ARoom;
  item.User := AUser;
  Result := FItems.BinarySearch(item, i, FCompare);
end;

end.
