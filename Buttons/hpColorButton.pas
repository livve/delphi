unit hpColorButton;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Buttons
 * @package   hpColorButton
 * @version   1.03
 *)

(**
 * History
 *
 * V1.03 2015-06-09
 * - Added MouseDown property
 *
 * V1.02 2015-05-20
 * - Added MouseDownColor
 *
 * V1.01 2015-05-17
 * - Introduced custom base class
 *
 * V1.00 2015-01-04
 * - Copy of ThpImageButton
 * - Initial release
 *)

interface

uses
  Classes, Controls, ExtCtrls, Graphics, Messages,
  hpCustomButton;

type
  (**
   * ThpColorButton interface
   *)
  ThpColorButton = class(ThpCustomButton)
  private
    FBackgroundColor: TColor;
    FBorderColorDark: TColor;
    FBorderColorLight: TColor;
    FHighlightColor: TColor;
    FMouseDown: Boolean;
    FMouseDownColor: TColor;
    FNormalColor: TColor;
    FShadowColor: TColor;
    FUseShadowText: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
  protected
    procedure AdjustSize; override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure Paint; override;
    procedure SetMouseDown(AValue: Boolean);
    procedure SetUseShadowText(AValue: Boolean);
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
  public
    property MouseDown: Boolean read FMouseDown write SetMouseDown;
  published
    property BackgroundColor: TColor read FBackgroundColor write FBackgroundColor;
    property BorderColorDark: TColor read FBorderColorDark write FBorderColorDark;
    property BorderColorLight: TColor read FBorderColorLight write FBorderColorLight;
    property HighlightColor: TColor read FHighlightColor write FHighlightColor;
    property MouseDownColor: TColor read FMouseDownColor write FMouseDownColor;
    property ShadowColor: TColor read FShadowColor write FShadowColor;
    property UseShadowText: Boolean read FUseShadowText write SetUseShadowText;
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
  RegisterComponents('hpVCL', [ThpColorButton]);
end;

(**
 * ThpColorButton implementation
 *)

constructor ThpColorButton.Create(AOwner: TComponent);
begin
  inherited;
  Canvas.CopyMode := cmSrcCopy;
  FMouseDown := False;
  FShadowColor := RGB(80, 80, 80);
  FUseShadowText := True;

  Height := 25;
  Width := 75;
end;

procedure ThpColorButton.SetMouseDown(AValue: Boolean);
begin
  if FMouseDown <> AValue then begin
    FMouseDown := AValue;
    Invalidate;
  end;
end;

procedure ThpColorButton.SetUseShadowText(AValue: Boolean);
begin
  if FUseShadowText <> AValue then begin
    FUseShadowText := AValue;
    Invalidate;
  end;
end;

procedure ThpColorButton.AdjustSize;
var
  textSize: TSize;
begin
  if not (csLoading in ComponentState) and AutoSize then begin
    textSize := Canvas.TextExtent(Caption);
    Width := textSize.cx;
  end;
  inherited;
end;

procedure ThpColorButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Caption > '' then begin
    FNormalColor := Font.Color;
    Font.Color := FHighlightColor;
  end;
end;

procedure ThpColorButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Caption > '' then
    Font.Color := FNormalColor;
end;

procedure ThpColorButton.Paint;
var
  dstText: TRect;
  shadowRect: TRect;
  oldBrushColor, oldFontColor, oldPenColor: TColor;
begin
  if csDestroying in ComponentState then
    Exit;

  oldBrushColor := Canvas.Brush.Color;
  oldPenColor := Canvas.Pen.Color;

  Canvas.Brush.Style := bsSolid;
  if FMouseDown then
    Canvas.Brush.Color := FMouseDownColor
  else
    Canvas.Brush.Color := FBackgroundColor;
    
  Canvas.Pen.Color := FBackgroundColor;
  Canvas.Rectangle(0, 0, Width, Height);

  if FMouseDown then
    Canvas.Pen.Color := FBorderColorDark
  else
    Canvas.Pen.Color := FBorderColorLight;

  Canvas.MoveTo(0, Height - 1);
  Canvas.LineTo(0, 0);
  Canvas.LineTo(Width - 1, 0);

  if FMouseDown then
    Canvas.Pen.Color := FBorderColorLight
  else
    Canvas.Pen.Color := FBorderColorDark;

  Canvas.MoveTo(Width - 1, 1);
  Canvas.LineTo(Width - 1, Height - 1);
  Canvas.LineTo(1, Height - 1);

  if Caption > '' then begin
    dstText := Rect(0, 0, Width, Height);
    Canvas.Brush.Style := bsClear;
    Canvas.Font.Assign(Font);

    if FUseShadowText then begin
      oldFontColor := Canvas.Font.Color;

      shadowRect := dstText;
      OffsetRect(shadowRect, 1, 1);
      Canvas.Font.Color := FShadowColor;
      DrawText(Canvas.Handle, PChar(Caption), Length(Caption), shadowRect,
        DT_SINGLELINE or DT_VCENTER or DT_CENTER);

      Canvas.Font.Color := oldFontColor;
    end;

    DrawText(Canvas.Handle, PChar(Caption), Length(Caption), dstText,
      DT_SINGLELINE or DT_VCENTER or DT_CENTER);
  end;

  Canvas.Brush.Color := oldBrushColor;
  Canvas.Pen.Color := oldPenColor;
end;

procedure ThpColorButton.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  FMouseDown := True;
  Invalidate;
end;

procedure ThpColorButton.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  FMouseDown := False;
  Invalidate;
end;

end.
