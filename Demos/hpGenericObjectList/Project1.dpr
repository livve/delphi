program Project1;

uses
  Forms,
  TestUnit in 'TestUnit.pas' {TestForm},
  hpGenericObjectList in 'hpGenericObjectList.pas',
  hpUser in 'hpUser.pas',
  hpRoom in 'hpRoom.pas',
  ListViewUnit in 'ListViewUnit.pas' {ListViewForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTestForm, TestForm);
  Application.CreateForm(TListViewForm, ListViewForm);
  Application.Run;
end.
