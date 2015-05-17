unit hpImageToggleButton;

(**
 * @copyright Copyright (C) 2012-2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Buttons
 * @package   hpImageToggleButton
 * @version   1.02
 *)

(**
 * History
 *
 * V1.02 2015-05-17
 * - Introduced custom base class
 *
 * V1.01 2015-05-14
 * - Added JPEG support.
 *
 * V1.00 2012-03-21
 * - Copy of ThpImageButton
 * - Added ToggleState
 * - Initial release
 *)

interface

uses
  Classes, Controls, ExtCtrls, Graphics, Messages,
  hpCustomButton;

type
  ThpToggleState = (tsFirst, tsSecond);

  (**
   * ThpImageToggleButton interface
   *)
  ThpImageToggleButton = class(ThpCustomButton)
  private
    FGlyph: TPicture;
    FHighlightColor: TColor;
    FMouseDown: Boolean;
    FNormalColor: TColor;
    FNumGlyphs: Integer;
    FToggleState: ThpToggleState;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromFile(const AFileName: string);
    procedure LoadFromJpegFile(const AFileName: string);
  protected
    procedure AdjustSize; override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure Paint; override;
    procedure SetGlyph(AValue: TPicture);
    procedure SetToggleState(AValue: ThpToggleState);
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
  published
    property Glyph: TPicture read FGlyph write SetGlyph;
    property HighlightColor: TColor read FHighlightColor write FHighlightColor;
    property ToggleState: ThpToggleState read FToggleState write SetToggleState;
  end;

procedure Register;

implementation

uses
  Dialogs, Jpeg, Math, Types, Windows;

(**
 * Register into the component palette
 *)
procedure Register;
begin
  RegisterComponents('hpVCL', [ThpImageToggleButton]);
end;

(**
 * ThpImageToggleButton implementation
 *)

constructor ThpImageToggleButton.Create(AOwner: TComponent);
begin
  inherited;
  Canvas.CopyMode := cmSrcCopy;
  FGlyph := TPicture.Create;
  FMouseDown := False;
  FNumGlyphs := 3;
end;

destructor ThpImageToggleButton.Destroy;
begin
  FGlyph.Free;
  inherited;
end;

procedure ThpImageToggleButton.LoadFromFile(const AFileName: string);
begin
  FGlyph.LoadFromFile(AFileName);
  Invalidate;
end;

procedure ThpImageToggleButton.LoadFromJpegFile(const AFileName: string);
var
  jpeg: TJpegImage;
begin
  jpeg := TJpegImage.Create();
  jpeg.LoadFromFile(AFileName);

  FGlyph.Bitmap.Assign(jpeg);
  Invalidate;

  jpeg.Free;
end;

procedure ThpImageToggleButton.AdjustSize;
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

procedure ThpImageToggleButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Caption > '' then begin
    FNormalColor := Font.Color;
    Font.Color := FHighlightColor;
  end;
end;

procedure ThpImageToggleButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Caption > '' then
    Font.Color := FNormalColor;
end;

procedure ThpImageToggleButton.Paint;
var
  srcImg, dstImg, dstText: TRect;
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
    OffsetRect(dstImg, offsetX, offsetY);

    if FMouseDown then
      srcImg := Rect(2 * imgWidth, 0, 3 * imgWidth, imgHeight)
    else
      if FToggleState = tsFirst then
        srcImg := Rect(0, 0, imgWidth, imgHeight)
      else
        srcImg := Rect(imgWidth, 0, 2 * imgWidth, imgHeight);

    Canvas.CopyRect(dstImg, FGlyph.Bitmap.Canvas, srcImg);
  end;

  if Caption > '' then begin
    dstText := Rect(0, 0, Width, Height);
    Canvas.Font.Assign(Font);
    Canvas.Brush.Style := bsClear;
    DrawText(Canvas.Handle, PChar(Caption), Length(Caption), dstText,
      DT_SINGLELINE or DT_VCENTER or DT_CENTER);
  end;
end;

procedure ThpImageToggleButton.SetGlyph(AValue: TPicture);
begin
  FGlyph.Assign(AValue);
  Invalidate;
end;

procedure ThpImageToggleButton.SetToggleState(AValue: ThpToggleState);
begin
  if AValue <> FToggleState then begin
    FToggleState := AValue;
    Invalidate;
  end;
end;

procedure ThpImageToggleButton.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  FMouseDown := True;
  Invalidate;
end;

procedure ThpImageToggleButton.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  FMouseDown := False;
  if FToggleState = tsFirst then
    FToggleState := tsSecond
  else
    FToggleState := tsFirst;

  Invalidate;
end;

end.
