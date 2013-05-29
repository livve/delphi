unit hpHtmlChatWindow;

(**
 * @copyright Copyright (C) 2010-2013, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
 * @package   hpHtmlChatWindow
 * @version   1.03
 *)

(**
 * History
 *
 * V1.03 2011-05-19
 * - Used custom color type ThpColor in ThpFontSettings. It allows easy
 *   conversion to/from an HTML color code
 *
 * V1.02 2011-05-05
 * - Added option to convert newlines
 *
 * V1.01
 * - Added border to the system message
 *
 * V1.00 2010-11-25
 * - Initial release
 *)

interface

uses
  Classes, Graphics, Htmlview, hpTypes;

type
  (**
   * ThpFontSettings
   *)
  ThpFontSettings = record
    Name: string;
    Color: ThpColor;
    Size: Integer;
    Style: TFontStyles;
  end;

  (**
   * ThpHtmlChatWindow
   *)
  ThpHtmlChatWindow = class(THTMLViewer)
  private
    FContent: TStringList;
    FContentMax: Integer;
    FUsernameColor: TColor;
    FBackgroundColor: TColor;
    FDefaultFont: ThpFontSettings;
    FSystemFont: ThpFontSettings;
    FConvertNewlines: Boolean;
  protected
    function GetFontStyle(AFont: ThpFontSettings; ASystemFont: Boolean = False): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize;
    procedure Clear; override;
    procedure Add(const AHtml: string); overload;
    procedure Add(const AUsername, AMessage: string); overload;
    procedure Add(const AMessage: string; AMsgFont: ThpFontSettings); overload;
    procedure Add(const AUsername, AMessage: string; AMsgFont: ThpFontSettings); overload;
    procedure Add(const AUsername, AMessage: string; AUsrFont, AMsgFont: ThpFontSettings); overload;
    procedure AddSystemMessage(const AMessage: string); overload;
  published
    property ContentMax: Integer read FContentMax write FContentMax;
    property UsernameColor: TColor read FUsernameColor write FUsernameColor;
    property BackgroundColor: TColor read FBackgroundColor write FBackgroundColor;
    property DefaultFont: ThpFontSettings read FDefaultFont write FDefaultFont;
    property SystemFont: ThpFontSettings read FSystemFont write FSystemFont;
    property ConvertNewlines: Boolean read FConvertNewlines write FConvertNewlines;
    property OnClick;
  end;

procedure Register;

implementation

uses
  Windows, Controls, Dialogs, SysUtils;

const
  HTML_BR = '<br/>';
  HTML_STYLE_FONT = 'font-family:%s;font-size:%dpt;color:%s;';
  HTML_STYLE_BOLD = 'font-weight:bold;';
  HTML_STYLE_ITALIC = 'font-style:italic;';
  HTML_STYLE_STRIKEOUT = 'text-decoration:line-through;';
  HTML_STYLE_UNDERLINE = 'border-bottom:1px solid %s;';
  HTML_SYSTEM_BORDER = 'border:1px solid red;margin:2px;padding:2px;';

(**
 * Register into the component palette
 *)
procedure Register;
begin
  RegisterComponents('hpVCL', [ThpHtmlChatWindow]);
end;

(* ThpHtmlChatWindow *)

constructor ThpHtmlChatWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FContent := TStringList.Create;
  FContentMax := 256;

  FUsernameColor := clWhite;
  FBackgroundColor := clBlack;

  FDefaultFont.Name := 'Tahoma';
  FDefaultFont.Color := clWhite;
  FDefaultFont.Size := 8;

  FSystemFont := FDefaultFont;
  FSystemFont.Color := clRed;
  FSystemFont.Style := [fsBold];

  FConvertNewlines := False;
end;

destructor ThpHtmlChatWindow.Destroy;
begin
  FContent.Clear;
  FContent.Free;
  inherited Destroy;
end;

function ThpHtmlChatWindow.GetFontStyle(AFont: ThpFontSettings; ASystemFont: Boolean = False): string;
begin
  Result := Format(HTML_STYLE_FONT, [AFont.Name, AFont.Size, string(AFont.Color)]);

  if fsBold in AFont.Style then
    Result := Result + HTML_STYLE_BOLD;

  if fsItalic in AFont.Style then
    Result := Result + HTML_STYLE_ITALIC;

  if fsStrikeout in AFont.Style then
    Result := Result + HTML_STYLE_STRIKEOUT;

  if fsUnderline in AFont.Style then
    Result := Result + Format(HTML_STYLE_UNDERLINE, [string(AFont.Color)]);

  {if ASystemFont then
    Result := Result + HTML_SYSTEM_BORDER;}

  Result := Format('style="%s"', [Result]);
end;

procedure ThpHtmlChatWindow.Initialize;
var
  style: string;
begin
  style := GetFontStyle(FDefaultFont);
  style := Copy(style, 1, Length(style) - 1);
  style := Format('%sbackground-color:%s;"', [style, string(FBackgroundColor)]);

  FContent.Add(Format('<html><body %s>', [style]));
  LoadFromString(FContent.Text);
end;

procedure ThpHtmlChatWindow.Clear;
begin
  inherited Clear;
  FContent.Clear;
  Initialize;
end;

procedure ThpHtmlChatWindow.Add(const AHtml: string);
var
  i, count: Integer;
begin
  if FConvertNewlines then
    FContent.Add(StringReplace(AHtml, #13, HTML_BR, [rfReplaceAll]) + HTML_BR)
  else
    FContent.Add(AHtml + HTML_BR);

  count := FContent.Count - 1 - FContentMax;
  for i := 0 to count do
    FContent.Delete(1);

  LoadFromString(FContent.Text);
  ScrollTo(VScrollBar.Max);
end;

procedure ThpHtmlChatWindow.Add(const AUsername, AMessage: string);
begin
  Add(AUsername, AMessage, FDefaultFont);
end;

procedure ThpHtmlChatWindow.Add(const AMessage: string; AMsgFont: ThpFontSettings);
begin
  Add(Format('<span %s>%s</span>', [GetFontStyle(AMsgFont), AMessage]));
end;

procedure ThpHtmlChatWindow.Add(const AUsername, AMessage: string; AMsgFont: ThpFontSettings);
begin
  Add(Format('%s: <span %s>%s</span>', [AUsername, GetFontStyle(AMsgFont), AMessage]));
end;

procedure ThpHtmlChatWindow.Add(const AUsername, AMessage: string; AUsrFont, AMsgFont: ThpFontSettings);
begin
  Add(Format('<span %s>%s:</span> <span %s>%s</span>',
    [GetFontStyle(AUsrFont), AUsername, GetFontStyle(AMsgFont), AMessage]));
end;

procedure ThpHtmlChatWindow.AddSystemMessage(const AMessage: string);
begin
  { Changed div to span }
  Add(Format('<span %s>%s</span>', [GetFontStyle(FSystemFont, True), AMessage]));
end;

end.
