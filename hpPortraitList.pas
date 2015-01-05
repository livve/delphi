unit hpPortraitList;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
 * @package   hpPortraitList
 * @version   1.00
 *)

(**
 * History
 *
 * V1.00 2015-01-05
 * - Initial release
 *)

interface

uses
  Classes;

type
  ThpPortraitList = class(TObject)
  private
    FItems: TStringList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Add(const AUser, APortrait: string); virtual;
    function AsHtml: string; virtual;
    procedure Clear; virtual;
    procedure Delete(const AUser: string); virtual;
  end;

implementation

uses
  SysUtils;

const
  PortraitDivFormat = '<div class="portrait"><img src="%s" /><span>%s</span></div>';

type
  ThpPortrait = class(TObject)
  private
    FPortrait: string;
  public
    constructor Create(const APortrait: string); virtual;
    property Portrait: string read FPortrait write FPortrait;
  end;

(* ThpPortrait *)

constructor ThpPortrait.Create(const APortrait: string);
begin
  FPortrait := APortrait;
end;

(* ThpPortraitList *)

constructor ThpPortraitList.Create;
begin
  inherited;
  FItems := TStringList.Create;
  FItems.Duplicates := dupIgnore;
  FItems.Sorted := True;
end;

destructor ThpPortraitList.Destroy;
var
  i: Integer;
begin
  for i := 0 to FItems.Count - 1 do
    FItems.Objects[i].Free;

  FItems.Clear;
  FItems.Free;
  inherited;
end;

procedure ThpPortraitList.Add(const AUser, APortrait: string);
var
  i: Integer;
begin
  i := FItems.IndexOf(AUser);
  if i > -1 then
    ThpPortrait(FItems.Objects[i]).Portrait := APortrait
  else begin
    i := FItems.Add(AUser);
    FItems.Objects[i] := ThpPortrait.Create(APortrait);
  end;
end;

function ThpPortraitList.AsHtml: string;
var
  i: Integer;
begin
  for i := 0 to FItems.Count - 1 do
    Result := Result + Format(PortraitDivFormat,
      [ThpPortrait(FItems.Objects[i]).Portrait, FItems[i]]);
end;

procedure ThpPortraitList.Clear;
var
  i: Integer;
begin
  for i := 0 to FItems.Count - 1 do
    FItems.Objects[i].Free;

  FItems.Clear;
end;

procedure ThpPortraitList.Delete(const AUser: string);
var
  i: Integer;
begin
  i := FItems.IndexOf(AUser);
  if i > -1 then begin
    FItems.Objects[i].Free;
    FItems.Delete(i);
  end;
end;

end.
