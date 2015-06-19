unit hpHistoryList;

(**
 * @copyright Copyright (C) 2012-2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Lists
 * @package   hpHistoryList
 * @version   1.01
 *)

(**
 * History
 *
 * 1.01       2015-06-18
 *            Memory leak.
 *
 * 1.00       2012-04-24
 *            Initial implementation.
 *)

 interface

uses
  Classes;

type
  ThpHistoryList = class(TPersistent)
  private
    FItems: TStringList;
    FMaxLines: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Add(const AIdentifier, ALine: string);
    procedure Clear(const AIdentifier: string);
    function Get(const AIdentifier: string): string;
  published
    property MaxLines: Integer read FMaxLines write FMaxLines;
  end;

implementation

{ ThpHistoryList }

constructor ThpHistoryList.Create;
begin
  inherited;
  FItems := TStringList.Create;
  FItems.Duplicates := dupIgnore;
  FItems.Sorted := True;
  FMaxLines := 1000;
end;

destructor ThpHistoryList.Destroy;
var
  i: Integer;
begin
  for i := FItems.Count - 1 downto 0 do begin
    TStringList(FItems.Objects[i]).Clear;
    TStringList(FItems.Objects[i]).Free;
    FItems.Delete(i);
  end;
  
  FItems.Free;
  inherited;
end;

procedure ThpHistoryList.Add(const AIdentifier, ALine: string);
var
  i: Integer;
  sl: TStringList;
begin
  i := FItems.IndexOf(AIdentifier);
  if i = -1 then begin
    sl := TStringList.Create;
    i := FItems.AddObject(AIdentifier, sl);
  end;
  TStringList(FItems.Objects[i]).Add(ALine);
  if TStringList(FItems.Objects[i]).Count > FMaxLines then
    TStringList(FItems.Objects[i]).Delete(0);
end;

procedure ThpHistoryList.Clear(const AIdentifier: string);
var
  i: Integer;
begin
  i := FItems.IndexOf(AIdentifier);
  if i > -1 then
    TStringList(FItems.Objects[i]).Clear;
end;

function ThpHistoryList.Get(const AIdentifier: string): string;
var
  i: Integer;
begin
  i := FItems.IndexOf(AIdentifier);
  if i > -1 then
    Result := TStringList(FItems.Objects[i]).Text;
end;

end.
