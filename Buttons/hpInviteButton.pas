unit hpInviteButton;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Buttons
 * @package   hpInviteButton
 * @version   1.00
 *)

(**
 * History
 *
 * V1.00 2015-10-10
 * - Initial release
 *)

interface

uses
  Classes, Controls, StdCtrls;

type
  ThpJoinNotifyEvent = procedure(Sender: TObject; const AFrom, ALobby, ARoom: string) of object;
  
  ThpInviteButton = class(TButton)
  private
    FCurrentUser: string;
    FInviteList: TStringList;
    FOnJoin: ThpJoinNotifyEvent;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddInvite(const AFrom, ALobby, ARoom: string);
    procedure Click; override;
    procedure SetCurrentUser(const AUser: string);
  published
    property OnJoin: ThpJoinNotifyEvent read FOnJoin write FOnJoin;
  end;

implementation

type
  { ThpLobbyRoom }
  
  ThpLobbyRoom = class
  public
    FLobby: string;
    FRoom: string;
  end;

(**
 * Register into the component palette
 *)
procedure Register;
begin
  RegisterComponents('hpVCL', [ThpInviteButton]);
end;

{ ThpInviteButton }

procedure ThpInviteButton.Click;
var
  i: Integer;
  lobbyRoom: ThpLobbyRoom;
begin
  inherited;
  i := FInviteList.IndexOf(FCurrentUser);
  if (i > -1) and Assigned(FOnJoin) then begin
    lobbyRoom := ThpLobbyRoom(FInviteList.Objects[i]);
    FOnJoin(Self, FCurrentUser, lobbyRoom.FLobby, lobbyRoom.FRoom);
  end;
end;

constructor ThpInviteButton.Create(AOwner: TComponent);
begin
  inherited;
  FInviteList := TStringList.Create;
  FInviteList.Sorted := True;
  FInviteList.Duplicates := dupIgnore;
end;

destructor ThpInviteButton.Destroy;
var
  i: Integer;
begin
  for i := FInviteList.Count - 1 downto 0 do
    FInviteList.Objects[i].Free;

  FInviteList.Clear;
  FInviteList.Free;

  inherited;
end;

procedure ThpInviteButton.AddInvite(const AFrom, ALobby, ARoom: string);
var
  i: Integer;
  lobbyRoom: ThpLobbyRoom;
begin
  i := FInviteList.IndexOf(AFrom);
  if i = -1 then begin
    lobbyRoom := ThpLobbyRoom.Create;
    lobbyRoom.FLobby := ALobby;
    lobbyRoom.FRoom := ARoom;
    FInviteList.AddObject(AFrom, lobbyRoom);
  end
  else begin
    lobbyRoom := ThpLobbyRoom(FInviteList.Objects[i]);
    lobbyRoom.FLobby := ALobby;
    lobbyRoom.FRoom := ARoom;
  end;
end;

procedure ThpInviteButton.SetCurrentUser(const AUser: string);
begin
  FCurrentUser := AUser;
  Enabled := FInviteList.IndexOf(FCurrentUser) > -1;
end;

end.
