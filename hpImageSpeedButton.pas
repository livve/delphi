unit hpImageSpeedButton;

(**
 * @copyright Copyright (C) 2011-2014, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
 * @package   hpImageSpeedButton
 * @version   1.00
 *)

(**
 * History
 *
 * V1.00 13/12/2011
 * - Initial release
 *)

interface

uses
  SysUtils, Dialogs, Math, Types, Classes, Controls, Windows, ExtCtrls, Graphics, Messages;


type
  TCMButtonPressed = record
    Msg: Cardinal;
    Index: Integer;
    {$IFDEF COMPILER16_UP}
	WParamFiller: TDWordFiller;
    {$ENDIF COMPILER16_UP}
    Control: TControl;
    Result: LRESULT;
  end;

type
  ThpImageBtnButtonState = (rbsUp, rbsDown, rbsExclusive);
  ThpImageSpeedButton = class(TGraphicControl)
  private
    FGlyph: TPicture;
    FHighlightColor: TColor;
    FMouseDown: Boolean;
    FNormalColor: TColor;
    FNumGlyphs: Integer;
    FGroupIndex: Integer;
    FAllowAllUp: Boolean;
    FDown: Boolean;
    procedure DoMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure CMButtonPressed(var Msg: TCMButtonPressed); message CM_BUTTONPRESSED;
    procedure UpdateExclusive;
    procedure SetGroupIndex(Value: Integer);
    procedure SetAllowAllUp(Value: Boolean);
    procedure SetDown(Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromFile(const AFileName: string);
    procedure ButtonClick;
  protected
    FState: ThpImageBtnButtonState;
    procedure AdjustSize; override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure Paint; override;
    procedure SetGlyph(AValue: TPicture);
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  published
    property Glyph: TPicture read FGlyph write SetGlyph;
    property HighlightColor: TColor read FHighlightColor write FHighlightColor;
    property Anchors;
    property AutoSize;
    property Caption;
   	property Cursor;
    property Enabled;
    property Font;
    property Hint;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property OnClick;
    property OnMouseUp;
    property OnMouseDown;
    property Visible;
    property GroupIndex: Integer read FGroupIndex write SetGroupIndex default 0;
    property AllowAllUp: Boolean read FAllowAllUp write SetAllowAllUp default False;
    property Down: Boolean read FDown write SetDown default False;
  end;

procedure Register;

implementation

(**
 * Register into the component palette
 *)
procedure Register;
begin
  RegisterComponents('hpVCL', [ThpImageSpeedButton]);
end;

(* ThpImageSpeedButton *)

constructor ThpImageSpeedButton.Create(AOwner: TComponent);
begin
  inherited;
  Canvas.CopyMode := cmSrcCopy;
  FGlyph := TPicture.Create;
  FMouseDown := False;
  FNumGlyphs := 3;
end;

destructor ThpImageSpeedButton.Destroy;
begin
  FGlyph.Free;
  inherited;
end;

procedure ThpImageSpeedButton.LoadFromFile(const AFileName: string);
begin
  FGlyph.LoadFromFile(AFileName);
  Invalidate;
end;

procedure ThpImageSpeedButton.AdjustSize;
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

procedure ThpImageSpeedButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Caption > '' then begin
    FNormalColor := Font.Color;
    Font.Color := FHighlightColor;
  end;
end;

procedure ThpImageSpeedButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Caption > '' then
    Font.Color := FNormalColor;
end;

procedure ThpImageSpeedButton.Paint;
var
  srcImg, dstImg, dstText: TRect;
  imgWidth, imgHeight, offsetX, offsetY: Integer;
  Offset: TPoint;
begin
  if (csDestroying in ComponentState) then
    Exit;

  if FGlyph.Graphic <> nil then begin
    imgWidth := FGlyph.Width div 3;
    imgHeight := FGlyph.Height;

    offsetX := (Width - imgWidth) div 3;
    offsetY := (Height - imgHeight) div 3;

    dstImg := Rect(0, 0, imgWidth, imgHeight);
    OffsetRect(dstImg, offsetX, offsetY);
    srcImg := Rect(0, 0, imgWidth, imgHeight);

    if FMouseDown then srcImg := Rect(imgWidth, 0, 2 * imgWidth, imgHeight);

    Canvas.CopyRect(dstImg, FGlyph.Bitmap.Canvas, srcImg);
  end;

  if FDown and (GroupIndex <> 0) then
      FState := rbsExclusive
    else
      FState := rbsUp;

  if FState in [rbsDown, rbsExclusive] then
      Offset := Point(1, 2)
    else
      Offset := Point(0, 1);

  if Caption > '' then begin
    dstText := Rect(0, 0, Width, Height);
    Canvas.Font.Assign(Font);
    Canvas.Brush.Style := bsClear;
    DrawText(Canvas.Handle, PChar(Caption), Length(Caption), dstText,
      DT_SINGLELINE or DT_VCENTER or DT_CENTER);
  end;
end;

procedure ThpImageSpeedButton.SetGlyph(AValue: TPicture);
begin
  FGlyph.Assign(AValue);
  Invalidate;
end;

procedure ThpImageSpeedButton.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  FMouseDown := True;
  Invalidate;
end;

procedure ThpImageSpeedButton.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  FMouseDown := False;
  Invalidate;
end;

procedure ThpImageSpeedButton.ButtonClick;
begin
  if not FDown then
  begin
    FState := rbsDown;
    Repaint;
  end;
  try
    Sleep(20); // (ahuser) why?
    if FGroupIndex = 0 then
      Click;
  finally
    FState := rbsUp;
    if FGroupIndex = 0 then
      Repaint
    else
    begin
      SetDown(not FDown);
      Click;
    end;
  end;
end;

procedure ThpImageSpeedButton.SetGroupIndex(Value: Integer);
begin
  if FGroupIndex <> Value then
  begin
    FGroupIndex := Value;
    UpdateExclusive;
  end;
end;

procedure ThpImageSpeedButton.SetAllowAllUp(Value: Boolean);
begin
  if FAllowAllUp <> Value then
  begin
    FAllowAllUp := Value;
    UpdateExclusive;
  end;
end;

procedure ThpImageSpeedButton.SetDown(Value: Boolean);
begin
  if FGroupIndex = 0 then
    Value := False;
  if Value <> FDown then
  begin
    if FDown and not FAllowAllUp then
      Exit;
    FDown := Value;
    if Value then
    begin
      if FState = rbsUp then
        Invalidate;
      FState := rbsExclusive;
    end
    else
    begin
      FState := rbsUp;
    end;
    Repaint;
    if Value then
      UpdateExclusive;
    Invalidate;
  end;
end;

procedure ThpImageSpeedButton.UpdateExclusive;
var
  Msg: TCMButtonPressed;
begin
  if (FGroupIndex <> 0) and (Parent <> nil) then
  begin
    Msg.Msg := CM_BUTTONPRESSED;
    Msg.Index := FGroupIndex;
    Msg.Control := Self;
    Msg.Result := 0;
    Parent.Broadcast(Msg);
  end;
end;

procedure ThpImageSpeedButton.CMButtonPressed(var Msg: TCMButtonPressed);
var
  Sender: TControl;
begin
  if (Msg.Index = FGroupIndex) and Parent.HandleAllocated then
  begin
    Sender := Msg.Control;
    if (Sender <> nil) and (Sender is ThpImageSpeedButton) then
      if Sender <> Self then
      begin
        if ThpImageSpeedButton(Sender).Down and FDown then
        begin
          FDown := False;
          FState := rbsUp;
          Repaint;
        end;
        FAllowAllUp := ThpImageSpeedButton(Sender).AllowAllUp;
      end;
   end;
end;

procedure ThpImageSpeedButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and Enabled {and not (ssDouble in Shift)} then
  begin
    if not FDown then begin
       FState := rbsDown;
       Invalidate {Repaint};
     end;
    DoMouseUp(Button, Shift, X, Y);
  end;
end;

procedure ThpImageSpeedButton.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewState: ThpImageBtnButtonState;
begin
  inherited MouseMove(Shift, X, Y);
  if not FDown then
      NewState := rbsUp
    else
      NewState := rbsExclusive;
    if (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight) then
      if FDown then
        NewState := rbsExclusive
      else
        NewState := rbsDown;
    if NewState <> FState then
    begin
      FState := NewState;
      Repaint;
   end;
end;

procedure ThpImageSpeedButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  DoMouseUp(Button, Shift, X, Y);
end;

procedure ThpImageSpeedButton.DoMouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  DoClick: Boolean;
begin
if DoClick then
    begin
      SetDown(not FDown);
      if FDown then
        Repaint;
    end
    else
    begin
      if FDown then
        FState := rbsExclusive;
      Repaint;
    end;
    if DoClick then
    begin
      Click;
   end;
end;

end.
