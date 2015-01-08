unit hpWebChatButton;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Buttons
 * @package   hpWebChatButton
 * @version   1.00
 *)

(**
 * History
 *
 * V1.00 2015-01-03
 * - Copy of ThpImageToggleButton
 * - Initial release
 *)

interface

uses
  Classes, Controls, ExtCtrls, Graphics, Messages;

type
  ThpWebChatState = (wcsWeb, wcsChat);

  ThpWebChatButton = class(TGraphicControl)
  private
    FGlyph: TPicture;
    FNotify: Boolean;
    FNumGlyphs: Integer;
    FWebChatState: ThpWebChatState;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromFile(const AFileName: string);
  protected
    procedure Paint; override;
    procedure SetEnabled(Value: Boolean); override;
    procedure SetGlyph(AValue: TPicture);
    procedure SetNotify(AValue: Boolean);
    procedure SetToggleState(AValue: ThpWebChatState);
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
  published
    property Glyph: TPicture read FGlyph write SetGlyph;
    property Notify: Boolean read FNotify write SetNotify;
    property ToggleState: ThpWebChatState read FWebChatState write SetToggleState;
    property Anchors;
    property AutoSize;
    property Caption;
    property Cursor;
    property Enabled;
    property Hint;
    property ParentShowHint;
    property ShowHint;
    property OnClick;
    property Visible;
  end;

procedure Register;

implementation

uses
  Dialogs, Math, Types, Windows;

(**
 * Register into the component palette
 *)
procedure Register;
begin
  RegisterComponents('hpVCL', [ThpWebChatButton]);
end;

(* ThpWebChatButton *)

constructor ThpWebChatButton.Create(AOwner: TComponent);
begin
  inherited;

  Canvas.CopyMode := cmSrcCopy;
  FGlyph := TPicture.Create;
  FNumGlyphs := 3;
  FWebChatState := wcsWeb;

  Height := 34;
  Width := 36;
end;

destructor ThpWebChatButton.Destroy;
begin
  FGlyph.Free;
  inherited;
end;

procedure ThpWebChatButton.LoadFromFile(const AFileName: string);
begin
  FGlyph.LoadFromFile(AFileName);
  Invalidate;
end;

procedure ThpWebChatButton.Paint;
var
  srcImg, dstImg: TRect;
  imgWidth, imgHeight: Integer;
begin
  if (csDestroying in ComponentState) then
    Exit;

  if FGlyph.Graphic <> nil then begin
    imgWidth := FGlyph.Width div FNumGlyphs;
    imgHeight := FGlyph.Height;

    dstImg := Rect(0, 0, imgWidth, imgHeight);

    if not Enabled then
      // show second image (web)
      srcImg := Rect(imgWidth, 0, 2 * imgWidth, imgHeight)
    else
      if FWebChatState = wcsWeb then begin
        if FNotify then
          // show third image (web + notify)
          srcImg := Rect(2 * imgWidth, 0, 3 * imgWidth, imgHeight)
        else
          // show second image (web)
          srcImg := Rect(imgWidth, 0, 2 * imgWidth, imgHeight)
      end
      else
        // show first image (chat)
        srcImg := Rect(0, 0, imgWidth, imgHeight);

    Canvas.CopyRect(dstImg, FGlyph.Bitmap.Canvas, srcImg);
  end;
end;

procedure ThpWebChatButton.SetEnabled(Value: Boolean);
begin
  FWebChatState := wcsWeb;
  inherited;
end;

procedure ThpWebChatButton.SetGlyph(AValue: TPicture);
begin
  FGlyph.Assign(AValue);
  Invalidate;
end;

procedure ThpWebChatButton.SetNotify(AValue: Boolean);
begin
  if AValue <> FNotify then begin
    FNotify := AValue;
    Invalidate;
  end;
end;

procedure ThpWebChatButton.SetToggleState(AValue: ThpWebChatState);
begin
  if AValue <> FWebChatState then begin
    FWebChatState := AValue;
    Invalidate;
  end;
end;

procedure ThpWebChatButton.WMLButtonUp(var Message: TWMLButtonUp);
begin
  if not Enabled then
    Exit;

  inherited;

  if FWebChatState = wcsWeb then begin
    FWebChatState := wcsChat;
  end
  else
    FWebChatState := wcsWeb;

  FNotify := False;
  Invalidate;
end;

end.
