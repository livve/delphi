unit hpUserCommentList;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Lists
 * @package   hpUserCommentList
 * @version   1.00
 *)

(**
 * History
 *
 * V1.00 2015-08-05
 * - Initial release
 *)

interface

uses
  Classes;

type
  ThpComment = class(TObject)
  protected
    FComment: string;
  public
    constructor Create(const AComment: string); virtual;
    property Comment: string read FComment write FComment;
  end;

  ThpUserCommentList = class(TObject)
  protected
    FItems: TStringList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure AddOrUpdate(const AUser, AComment: string); virtual;
    procedure Clear; virtual;
    procedure Delete(const AUser: string); virtual;
    function Find(const AUser: string): ThpComment; virtual;
    function GetComment(const AUser: string): string; virtual;
  end;

implementation

uses
  SysUtils;

const
  HtmlPrefix = '<html><head><style>div.portrait { float: left; width: 128px; margin: 5px; } div.portrait p { text-align: center; }</style></head><body>';
  HtmlPostfix = '</body></html>';
  PortraitDivFormat = '<div class="portrait"><img src="%s" /><p>%s</p></div>';

(* ThpComment *)

constructor ThpComment.Create(const AComment: string);
begin
  FComment := AComment;
end;

(* ThpUserCommentList *)

constructor ThpUserCommentList.Create;
begin
  inherited;
  
  FItems := TStringList.Create;
  FItems.Duplicates := dupIgnore;
  FItems.Sorted := True;
end;

destructor ThpUserCommentList.Destroy;
var
  i: Integer;
begin
  for i := 0 to FItems.Count - 1 do
    FItems.Objects[i].Free;

  FItems.Clear;
  FItems.Free;
  
  inherited;
end;

procedure ThpUserCommentList.AddOrUpdate(const AUser, AComment: string);
var
  item: ThpComment;
  i: Integer;
begin
  item := Find(AUser);
  if item <> nil then
    item.Comment := AComment
  else begin
    i := FItems.Add(AUser);
    FItems.Objects[i] := ThpComment.Create(AComment);
  end;
end;

procedure ThpUserCommentList.Clear;
var
  i: Integer;
begin
  for i := 0 to FItems.Count - 1 do
    FItems.Objects[i].Free;

  FItems.Clear;
end;

procedure ThpUserCommentList.Delete(const AUser: string);
var
  i: Integer;
begin
  i := FItems.IndexOf(AUser);
  if i > -1 then begin
    FItems.Objects[i].Free;
    FItems.Delete(i);
  end;
end;

function ThpUserCommentList.Find(const AUser: string): ThpComment;
var
  i: Integer;
begin
  Result := nil;
  i := FItems.IndexOf(AUser);
  if i > -1 then
    Result := ThpComment(FItems.Objects[i]);
end;

function ThpUserCommentList.GetComment(const AUser: string): string;
var
  item: ThpComment;
begin
  item := Find(AUser);
  if item <> nil then
    Result := item.Comment;
end;

end.
