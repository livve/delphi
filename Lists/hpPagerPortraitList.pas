unit hpPagerPortraitList;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Lists
 * @package   hpPagerPortraitList
 * @version   1.00
 *)

(**
 * History
 *
 * V1.00 2015-01-19
 * - Extension of hpPortraitList
 * - Initial release
 *)

interface

uses
  Classes, hpPortraitList;

type
  ThpPagerPortrait = class(ThpPortrait)
  private
    FMessage: string;
    FNotification: Boolean;
    FPortrait: string;
  public
    constructor Create(const APortrait, AMessage: string; ANotification: Boolean); reintroduce;
    property Message: string read FMessage write FMessage;
    property Notification: Boolean read FNotification write FNotification;
    property Portrait: string read FPortrait write FPortrait;
  end;

  ThpPagerPortraitList = class(ThpPortraitList)
  public
    procedure Add(const AUser, APortrait, AMessage: string; ANotification: Boolean); reintroduce;
    function Find(const AUser: string): ThpPagerPortrait; reintroduce;
  end;

implementation

uses
  SysUtils;

(* ThpPagerPortrait *)

constructor ThpPagerPortrait.Create(const APortrait, AMessage: string; ANotification: Boolean);
begin
  inherited Create(APortrait);
  FMessage := AMessage;
  FNotification := ANotification;
end;

(* ThpPagerPortraitList *)

procedure ThpPagerPortraitList.Add(const AUser, APortrait, AMessage: string; ANotification: Boolean);
var
  hpPagerPortrait: ThpPagerPortrait;
  i: Integer;
begin
  hpPagerPortrait := Find(AUser);
  if hpPagerPortrait <> nil then begin
    hpPagerPortrait.Message := AMessage;
    hpPagerPortrait.Notification := ANotification;
    hpPagerPortrait.Portrait := APortrait;
  end
  else begin
    i := FItems.Add(AUser);
    FItems.Objects[i] := ThpPagerPortrait.Create(APortrait, AMessage, ANotification);
  end;
end;

function ThpPagerPortraitList.Find(const AUser: string): ThpPagerPortrait;
begin
  Result := inherited Find(AUser) as ThpPagerPortrait;
end;

end.
