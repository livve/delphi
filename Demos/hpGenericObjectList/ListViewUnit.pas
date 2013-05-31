unit ListViewUnit;

interface

uses
  Windows, ComCtrls, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, hpGenericObjectList, hpRoom;

type
  TListViewForm = class(TForm)
    RoomListView: TListView;
    PreviousButton: TButton;
    NextButton: TButton;
    PageLabel: TLabel;
    procedure NextButtonClick(Sender: TObject);
    procedure PreviousButtonClick(Sender: TObject);
  private
    FCurrentPage: Integer;
    FPageSize: Integer;
    FRooms: ThpGenericObjectList<ThpRoom>;
    FTotalPages: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  ListViewForm: TListViewForm;

implementation

{$R *.dfm}

uses
  Math;

{ TListViewForm }

constructor TListViewForm.Create(AOwner: TComponent);
begin
  inherited;

  FCurrentPage := 1;
  FPageSize := 4;
  FRooms := ThpGenericObjectList<ThpRoom>.Create;

  with FRooms.Add('Lobby') do
    Description := 'Welcome lobby';

  with FRooms.Add('Delphi') do
    Description := 'Delphi programming discussions';

  with FRooms.Add('PHP') do
    Description := 'PHP programming discussions';

  with FRooms.Add('Beginners') do
    Description := 'We will help you get started';

  FRooms.Add('Premium');

  with FRooms.Add('Trophy') do
    Description := 'Trophy winners can boast here';

  FRooms.Add('General');

  with FRooms.Add('Spades') do
    Description := 'Spades discussions';

  with FRooms.Add('Backgammon') do
    Description := 'Backgammon discussions';

  with FRooms.Add('Support') do
    Description := 'Trouble shooting room';

  with FRooms.Add('Private') do
    Description := 'By invitation only';

  FRooms.GetListItems(RoomListView.Items, 0, FPageSize);

  FTotalPages := Ceil(FRooms.Count / FPageSize);
  PageLabel.Caption := Format('%d / %d', [FCurrentPage, FTotalPages]);
end;

destructor TListViewForm.Destroy;
begin
  FRooms.Free;
  inherited;
end;

procedure TListViewForm.NextButtonClick(Sender: TObject);
begin
  if FCurrentPage < FTotalPages then begin
    Inc(FCurrentPage);
    FRooms.GetListItems(RoomListView.Items, (FCurrentPage - 1) * FPageSize,
      FPageSize);
    PageLabel.Caption := Format('%d / %d', [FCurrentPage, FTotalPages]);
  end;
end;

procedure TListViewForm.PreviousButtonClick(Sender: TObject);
begin
  if FCurrentPage > 1 then begin
    Dec(FCurrentPage);
    FRooms.GetListItems(RoomListView.Items, (FCurrentPage - 1) * FPageSize,
      FPageSize);
    PageLabel.Caption := Format('%d / %d', [FCurrentPage, FTotalPages]);
  end;
end;

end.

