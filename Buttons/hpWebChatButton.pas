unit hpWebChatButton;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Buttons
 * @package   hpWebChatButton
 * @version   1.02
 *)

(**
 * History
 *
 * V1.02 2015-05-17
 * - Introduced custom base class
 *
 * V1.01 2015-05-14
 * - Seperated into two buttons.
 * - Added JPEG support.
 * - Added OnButtonChanged event.
 *
 * V1.00 2015-01-03
 * - Copy of ThpImageToggleButton
 * - Initial release
 *)

interface

uses
  Classes, Controls, ExtCtrls, Graphics, Messages,
  hpCustomButton;

type
  ThpWebChatState = (wcsWeb, wcsChat);

  (**
   * ThpWebChatButton interface
   *)
  ThpWebChatButton = class(ThpCustomButton)
  private
    FGlyph: TPicture;
    FNotify: Boolean;
    FNumGlyphs: Integer;
    FWebChatState: ThpWebChatState;
    FOnButtonChanged: TNotifyEvent;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromFile(const AFileName: string);
    procedure LoadFromJpegFile(const AFileName: string);
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
    property OnButtonChanged: TNotifyEvent read FOnButtonChanged write FOnButtonChanged;
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
  RegisterComponents('hpVCL', [ThpWebChatButton]);
end;

(**
 * ThpWebChatButton implementation
 *)

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

procedure ThpWebChatButton.LoadFromJpegFile(const AFileName: string);
var
  jpeg: TJpegImage;
begin
  jpeg := TJpegImage.Create();
  jpeg.LoadFromFile(AFileName);

  FGlyph.Bitmap.Assign(jpeg);
  Invalidate;

  jpeg.Free;
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
var
  halfWidth: Integer;
  mousePos: TPoint;
begin
  inherited;

  if not Enabled then
    Exit;

  halfWidth := Width div 2;
  mousePos := ScreenToClient(Mouse.CursorPos);

  if (mousePos.X < 0) or (mousePos.Y < 0) or
     (mousePos.X > Width) or (mousePos.Y > Height) then
    Exit;

  if ((FWebChatState = wcsChat) and (mousePos.X >= halfWidth)) or
     ((FWebChatState = wcsWeb) and (mousePos.X < halfWidth)) then
    Exit;

  if FWebChatState = wcsWeb then
    FWebChatState := wcsChat
  else
    FWebChatState := wcsWeb;

  FNotify := False;
  Invalidate;

  if Assigned(FOnButtonChanged) then
    FOnButtonChanged(Self);
end;

end.
