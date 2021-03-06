unit hpPortraitList;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Lists
 * @package   hpPortraitList
 * @version   1.01
 *)

(**
 * History
 *
 * V1.01 2015-01-19
 * - Updated to simplify sub-classing.
 *
 * V1.00 2015-01-05
 * - Initial release
 *)

interface

uses
  Classes;

type
  ThpPortrait = class(TObject)
  protected
    FPortrait: string;
  public
    constructor Create(const APortrait: string); virtual;
    property Portrait: string read FPortrait write FPortrait;
  end;

  ThpPortraitList = class(TObject)
  protected
    FItems: TStringList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Add(const AUser, APortrait: string); virtual;
    function AsHtml: string; virtual;
    procedure Clear; virtual;
    procedure Delete(const AUser: string); virtual;
    function Find(const AUser: string): ThpPortrait; virtual;
  end;

implementation

uses
  SysUtils;

const
  HtmlPrefix = '<html><head><style>div.portrait { float: left; width: 128px; margin: 5px; } div.portrait p { text-align: center; }</style></head><body>';
  HtmlPostfix = '</body></html>';
  PortraitDivFormat = '<div class="portrait"><img src="%s" /><p>%s</p></div>';

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
  hpPortrait: ThpPortrait;
  i: Integer;
begin
  hpPortrait := Find(AUser);
  if hpPortrait <> nil then
    hpPortrait.Portrait := APortrait
  else begin
    i := FItems.Add(AUser);
    FItems.Objects[i] := ThpPortrait.Create(APortrait);
  end;
end;

function ThpPortraitList.AsHtml: string;
var
  i: Integer;
begin
  Result := HtmlPrefix;

  for i := 0 to FItems.Count - 1 do
    Result := Result + Format(PortraitDivFormat,
      [ThpPortrait(FItems.Objects[i]).Portrait, FItems[i]]);

  Result := Result + HtmlPostfix;
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

function ThpPortraitList.Find(const AUser: string): ThpPortrait;
var
  i: Integer;
begin
  Result := nil;
  i := FItems.IndexOf(AUser);
  if i > -1 then
    Result := ThpPortrait(FItems.Objects[i]);
end;

end.
