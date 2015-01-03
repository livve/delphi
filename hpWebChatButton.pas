unit hpWebChatButton;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
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
  ThpWebChatState = (tsWeb, tsChat);

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
  FNumGlyphs := 4;
  FWebChatState := tsChat;

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
  imgWidth, imgHeight, offsetX, offsetY: Integer;
begin
  if (csDestroying in ComponentState) then
    Exit;

  if FGlyph.Graphic <> nil then begin
    imgWidth := FGlyph.Width div FNumGlyphs;
    imgHeight := FGlyph.Height;
    offsetX := (Width - imgWidth) div 2;
    offsetY := (Height - imgHeight) div 2;

    dstImg := Rect(0, 0, imgWidth, imgHeight);

    if not Enabled then
      srcImg := Rect(3 * imgWidth, 0, 4 * imgWidth, imgHeight)
    else
      if FWebChatState = tsWeb then begin
        if FNotify then
          srcImg := Rect(2 * imgWidth, 0, 3 * imgWidth, imgHeight)
        else
          srcImg := Rect(imgWidth, 0, 2 * imgWidth, imgHeight)
      end
      else
        srcImg := Rect(0, 0, imgWidth, imgHeight);

    Canvas.CopyRect(dstImg, FGlyph.Bitmap.Canvas, srcImg);
  end;
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

  if FWebChatState = tsWeb then begin
    FWebChatState := tsChat;
  end
  else
    FWebChatState := tsWeb;

  FNotify := False;
  Invalidate;
end;

end.
