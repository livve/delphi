unit hpEmbeddedWbChatWindow;

(**
 * @copyright Copyright (C) 2013, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
 * @package   hpEmbeddedWbChatWindow
 * @version   1.00
 *)

(**
 * History
 *
 * V1.00 2013-05-31
 * - Initial release (copy of THtmlChatWindow)
 *)

interface

uses
  Classes, Graphics, Messages, hpTypes, EmbeddedWB;

const
  WM_SCROLL_TO_BOTTOM = WM_USER + 1;

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
   * ThpEmbeddedWbChatWindow
   *)
  ThpEmbeddedWbChatWindow = class(TEmbeddedWB)
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
    procedure WMScrollToBottom(var Msg: TMessage); message WM_SCROLL_TO_BOTTOM;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Initialize;
    procedure Clear;
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
  RegisterComponents('hpVCL', [ThpEmbeddedWbChatWindow]);
end;

(* ThpEmbeddedWbChatWindow *)

constructor ThpEmbeddedWbChatWindow.Create(AOwner: TComponent);
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

destructor ThpEmbeddedWbChatWindow.Destroy;
begin
  FContent.Clear;
  FContent.Free;
  inherited Destroy;
end;

function ThpEmbeddedWbChatWindow.GetFontStyle(AFont: ThpFontSettings; ASystemFont: Boolean = False): string;
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

  Result := Format('style="%s"', [Result]);
end;

procedure ThpEmbeddedWbChatWindow.WMScrollToBottom(var Msg: TMessage);
begin
  ScrollToBottom;
end;

procedure ThpEmbeddedWbChatWindow.Initialize;
var
  style: string;
begin
  style := GetFontStyle(FDefaultFont);
  style := System.Copy(style, 1, Length(style) - 1);
  style := Format('%sbackground-color:#000000;"', [style]); // set to black

  FContent.Add(Format('<html><body %s>', [style]));
  LoadFromStrings(FContent);
end;

procedure ThpEmbeddedWbChatWindow.Clear;
begin
  FContent.Clear;
  Initialize;
end;

procedure ThpEmbeddedWbChatWindow.Add(const AHtml: string);
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

  LoadFromStrings(FContent);
  
  //ScrollToBottom; // doesn't work here, jumps back to top
  PostMessage(Self.Handle, WM_SCROLL_TO_BOTTOM, 0, 0);
end;

procedure ThpEmbeddedWbChatWindow.Add(const AUsername, AMessage: string);
begin
  Add(AUsername, AMessage, FDefaultFont);
end;

procedure ThpEmbeddedWbChatWindow.Add(const AMessage: string; AMsgFont: ThpFontSettings);
begin
  Add(Format('<span %s>%s</span>', [GetFontStyle(AMsgFont), AMessage]));
end;

procedure ThpEmbeddedWbChatWindow.Add(const AUsername, AMessage: string; AMsgFont: ThpFontSettings);
begin
  Add(Format('%s: <span %s>%s</span>', [AUsername, GetFontStyle(AMsgFont), AMessage]));
end;

procedure ThpEmbeddedWbChatWindow.Add(const AUsername, AMessage: string; AUsrFont, AMsgFont: ThpFontSettings);
begin
  Add(Format('<span %s>%s:</span> <span %s>%s</span>',
    [GetFontStyle(AUsrFont), AUsername, GetFontStyle(AMsgFont), AMessage]));
end;

procedure ThpEmbeddedWbChatWindow.AddSystemMessage(const AMessage: string);
begin
  Add(Format('<span %s>%s</span>', [GetFontStyle(FSystemFont, True), AMessage]));
end;

end.
