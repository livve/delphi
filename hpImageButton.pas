unit hpImageButton;

(**
 * @copyright Copyright (C) 2011-2014, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
 * @package   hpImageButton
 * @version   1.04
 *)

(**
 * History
 *
 * V1.04
 * - Added TransparentGlyph
 * - Added ShadowColor
 *
 * V1.03
 * - Added painting of mouse down image
 * - Removed painting of disabled image
 * - Fixed image/caption centering
 * - Fixed AutoSize handling
 *
 * V1.02
 * - Exposed Caption
 * - Exposed Font
 * - Exposed ParentFont
 * - Exposed Hint
 * - Exposed ParentShowHint
 * - Exposed ShowHint
 * - Added HighlightColor property
 * - Added color change on MouseEnter
 *
 * V1.01 2011-12-06
 * - Changed Glyph to TPicture, to allow design-time loading of the image
 * - Added LoadFromFile
 * - Exposed AutoSize
 * - Exposed Enabled
 * - Added Anchors
 * - Added Cursor
 *
 * V1.00 2011-12-06
 * - Initial release
 *)

interface

uses
  Classes, Controls, ExtCtrls, Graphics, Messages;

type
  ThpImageButton = class(TGraphicControl)
  private
    FGlyph: TPicture;
    FHighlightColor: TColor;
    FMouseDown: Boolean;
    FNormalColor: TColor;
    FShadowColor: TColor;
    FNumGlyphs: Integer;
    FTransparentGlyph: Boolean;
    procedure SetTransparentGlyph(Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromFile(const AFileName: string);
  protected
    procedure AdjustSize; override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure Paint; override;
    procedure SetGlyph(AValue: TPicture);
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
  published
    property Glyph: TPicture read FGlyph write SetGlyph;
    property HighlightColor: TColor read FHighlightColor write FHighlightColor;
    property Anchors;
    property AutoSize;
    property Caption;
	property Cursor;
    property TransparentGlyph: Boolean read FTransparentGlyph write SetTransparentGlyph;
    property Enabled;
    property Font;
    property Hint;
    property ShadowColor: TColor read FShadowColor write FShadowColor;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property OnClick;
    property OnMouseUp;
    property OnMouseDown;
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
  RegisterComponents('hpVCL', [ThpImageButton]);
end;

(* ThpImageButton *)

constructor ThpImageButton.Create(AOwner: TComponent);
begin
  inherited;
  Canvas.CopyMode := cmSrcCopy;
  FGlyph := TPicture.Create;
  FMouseDown := False;
  TransparentGlyph := True;
  FNumGlyphs := 2;
  FShadowColor := RGB(80, 80, 80);
end;

destructor ThpImageButton.Destroy;
begin
  FGlyph.Free;
  inherited;
end;

procedure ThpImageButton.SetTransparentGlyph(Value: Boolean);
begin
  FTransparentGlyph:= Value;
  Invalidate;
end;

procedure ThpImageButton.LoadFromFile(const AFileName: string);
begin
  FGlyph.LoadFromFile(AFileName);
  Invalidate;
end;

procedure ThpImageButton.AdjustSize;
var
  textSize: TSize;
begin
  if not (csLoading in ComponentState) and AutoSize then begin
    textSize := Canvas.TextExtent(Caption);
    Width := textSize.cx;
    if FGlyph.Graphic <> nil then begin
      Width := Max(Width, FGlyph.Width div FNumGlyphs);
      Height := FGlyph.Height;
    end;
  end;
  inherited;
end;

procedure ThpImageButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Caption > '' then begin
    FNormalColor := Font.Color;
    Font.Color := FHighlightColor;
  end;
end;

procedure ThpImageButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Caption > '' then
    Font.Color := FNormalColor;
end;

procedure ThpImageButton.Paint;
var
  srcImg, dstImg, dstText: TRect;
  imgWidth, imgHeight, offsetX, offsetY: Integer;
  shadowRect: TRect;
  oldColor: TColor;
begin
  if (csDestroying in ComponentState) then
    Exit;

  if FGlyph.Graphic <> nil then begin
    imgWidth := FGlyph.Width div 2;
    imgHeight := FGlyph.Height;
    offsetX := (Width - imgWidth) div 2;
    offsetY := (Height - imgHeight) div 2;

    dstImg := Rect(0, 0, imgWidth, imgHeight);
    OffsetRect(dstImg, offsetX, offsetY);

    srcImg := Rect(0, 0, imgWidth, imgHeight);
    if FMouseDown then
      srcImg := Rect(imgWidth, 0, 2 * imgWidth, imgHeight);

    FGlyph.Bitmap.TransparentColor := FGlyph.Bitmap.Canvas.Pixels[0, 0];
    FGlyph.Bitmap.Transparent := FTransparentGlyph;

    Canvas.CopyRect(dstImg, FGlyph.Bitmap.Canvas, srcImg);
  end;

  if Caption > '' then begin
    dstText := Rect(0, 0, Width, Height);
    Canvas.Brush.Style := bsClear;
    Canvas.Font.Assign(Font);

    oldColor := Canvas.Font.Color;

    shadowRect := dstText;
    OffsetRect(shadowRect, 1, 1);
    Canvas.Font.Color := FShadowColor;
    DrawText(Canvas.Handle, PChar(Caption), Length(Caption), shadowRect,
      DT_SINGLELINE or DT_VCENTER or DT_CENTER);

    Canvas.Font.Color := oldColor;
    DrawText(Canvas.Handle, PChar(Caption), Length(Caption), dstText,
      DT_SINGLELINE or DT_VCENTER or DT_CENTER);
  end;
end;

procedure ThpImageButton.SetGlyph(AValue: TPicture);
begin
  FGlyph.Assign(AValue);
  Invalidate;
end;

procedure ThpImageButton.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  FMouseDown := True;
  Invalidate;
end;

procedure ThpImageButton.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  FMouseDown := False;
  Invalidate;
end;

end.
