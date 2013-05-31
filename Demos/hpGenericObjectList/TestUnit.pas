unit TestUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Contnrs,
  hpGenericObjectList, hpRoom, hpUser, ComCtrls;

type
  TTestForm = class(TForm)
    FillButton: TButton;
    CaseSensitiveCheckBox: TCheckBox;
    AscendingCheckBox: TCheckBox;
    DuplicatesCheckBox: TCheckBox;
    SortedCheckBox: TCheckBox;
    UserListBox: TListBox;
    LoadButton: TButton;
    SaveButton: TButton;
    RoomListBox: TListBox;
    CaseSensitiveCheckBox2: TCheckBox;
    AscendingCheckBox2: TCheckBox;
    DuplicatesCheckBox2: TCheckBox;
    SortedCheckBox2: TCheckBox;
    ClearButton: TButton;
    FindEdit: TEdit;
    FindButton: TButton;
    UserListView: TListView;
    FormButton: TButton;
    procedure FillButtonClick(Sender: TObject);
    procedure LoadButtonClick(Sender: TObject);
    procedure SaveButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
    procedure FindButtonClick(Sender: TObject);
    procedure FormButtonClick(Sender: TObject);
  private
    FUsers: ThpGenericObjectList<ThpUser>;
    FRooms: ThpGenericObjectList<ThpRoom>;
    procedure GetSettings;
    procedure SetSettings;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  TestForm: TTestForm;

implementation

uses
  ListViewUnit;

{$R *.dfm}

const
  FILENAME_ROOMS = 'rooms.bin';
  FILENAME_USERS = 'users.bin';

{ TTestForm }

procedure TTestForm.ClearButtonClick(Sender: TObject);
begin
  FUsers.Clear;
  FRooms.Clear;
  UserListView.Clear;
  UserListBox.Clear;
  RoomListBox.Clear;
end;

constructor TTestForm.Create(AOwner: TComponent);
begin
  inherited;
  FUsers := ThpGenericObjectList<ThpUser>.Create;
  FRooms := ThpGenericObjectList<ThpRoom>.Create;
end;

destructor TTestForm.Destroy;
begin
  FUsers.Free;
  FRooms.Free;
  inherited;
end;

procedure TTestForm.LoadButtonClick(Sender: TObject);
begin
  if FileExists(FILENAME_USERS) then
    FUsers.LoadFromFile(FILENAME_USERS);

  if FileExists(FILENAME_ROOMS) then
    FRooms.LoadFromFile(FILENAME_ROOMS);

  SetSettings;
end;

procedure TTestForm.SaveButtonClick(Sender: TObject);
begin
  GetSettings;
  FUsers.SaveToFile(FILENAME_USERS);
  FRooms.SaveToFile(FILENAME_ROOMS);
end;

procedure TTestForm.SetSettings;
begin
  FUsers.GetListItems(UserListView.Items);
  FUsers.GetStrings(UserListBox.Items);
  AscendingCheckBox.Checked := FUsers.Ascending;
  CaseSensitiveCheckBox.Checked := FUsers.CaseSensitive;
  DuplicatesCheckBox.Checked := FUsers.Duplicates;
  SortedCheckBox.Checked := FUsers.Sorted;

  FRooms.GetStrings(RoomListBox.Items);
  AscendingCheckBox2.Checked := FRooms.Ascending;
  CaseSensitiveCheckBox2.Checked := FRooms.CaseSensitive;
  DuplicatesCheckBox2.Checked := FRooms.Duplicates;
  SortedCheckBox2.Checked := FRooms.Sorted;
end;

procedure TTestForm.FillButtonClick(Sender: TObject);
begin
  with FUsers.Add('pritaeas') do begin
    Email := 'pritaeas@gmail.com';
    FullName := 'Hans';
  end;

  with FUsers.Add('Simon') do
    Email := 'simon@psd-designs.com';

  with FUsers.Add('Ron') do
    Email := 'ron@myleagues4u.com';

  with FUsers.Add('simon') do
    Email := 'simon@myleagues4u.com';

  with FUsers.Add('Andreas') do
    Email := 'andreas@example.com';

  FUsers.GetListItems(UserListView.Items);
  FUsers.GetStrings(UserListBox.Items);

  FRooms.Add('Lobby');
  FRooms.Add('Delphi');
  FRooms.Add('Beginners');
  FRooms.Add('Premium');
  FRooms.GetStrings(RoomListBox.Items);
end;

procedure TTestForm.FindButtonClick(Sender: TObject);
var
  idx: Integer;
begin
  idx := FUsers.Find(FindEdit.Text);
  if idx > -1 then
    ShowMessage(Format('User %s (%s) on index %d', [FUsers[idx].User,
      FUsers[idx].Email, idx]));

  idx := FRooms.Find(FindEdit.Text);
  if idx > -1 then
    ShowMessage(Format('Room %s (%s) on index %d', [FRooms[idx].Room,
      FRooms[idx].Description, idx]));
end;

procedure TTestForm.FormButtonClick(Sender: TObject);
begin
  ListViewForm.Show;
end;

procedure TTestForm.GetSettings;
begin
  FUsers.Ascending := AscendingCheckBox.Checked;
  FUsers.CaseSensitive := CaseSensitiveCheckBox.Checked;
  FUsers.Duplicates := DuplicatesCheckBox.Checked;
  FUsers.Sorted := SortedCheckBox.Checked;

  FRooms.Ascending := AscendingCheckBox2.Checked;
  FRooms.CaseSensitive := CaseSensitiveCheckBox2.Checked;
  FRooms.Duplicates := DuplicatesCheckBox2.Checked;
  FRooms.Sorted := SortedCheckBox2.Checked;
end;

end.
