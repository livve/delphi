unit hpTabStrip;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
 * @package   hpTabStrip
 * @version   1.01
 *)

(**
 * History
 *
 * V1.01 2015-05-14
 * - Added JPEG support.
 *
 * V1.00 2015-01-07
 * - Initial release
 *)

interface

uses
  Classes, Controls, ExtCtrls, Graphics, Messages;

type
  ThpTabStrip = class;

  ThpTabStripButtonState = (tbsUnselected, tbsSelected);

  ThpTabStripButton = class(TGraphicControl)
  private
    FTitle: string;
    FGlyph: TPicture;
    FHighlightColor: TColor;
    FNormalColor: TColor;
    FNumGlyphs: Integer;
    FTabStripButtonState: ThpTabStripButtonState;
    FTabStrip: ThpTabStrip;
  public
    constructor Create(AOwner: TComponent); override;
  protected
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure Paint; override;
    procedure SetTitle(const AValue: string); virtual;
    procedure SetTabButtonState(AValue: ThpTabStripButtonState);
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
  published
    property Title: string read FTitle write SetTitle;
    property HighlightColor: TColor read FHighlightColor write FHighlightColor;
    property TabStripButtonState: ThpTabStripButtonState read FTabStripButtonState write SetTabButtonState;
    property Font;
    property Hint;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
  end;

  ThpTabChangedEvent = procedure(AIndex: Integer; const ATitle: string) of object;

  ThpTabStrip = class(TCustomPanel)
  private
    FGlyph: TPicture;
    FHighlightColor: TColor;
    FNumGlyphs: Integer;
    FOnTabChanged: ThpTabChangedEvent;
  protected
    procedure SetGlyph(AValue: TPicture); virtual;
    procedure SetHighlightColor(AValue: TColor); virtual;
    procedure UpdateTabPositions(AGlyph: TPicture);
    procedure UpdateTabs(Sender: ThpTabStripButton);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddTab(const ATitle, AHint: string); virtual;
    procedure DeleteTab(AIndex: Integer); virtual;
    procedure LoadFromFile(const AFileName: string); virtual;
    procedure LoadFromJpegFile(const AFileName: string); virtual;
    procedure RenameTab(AIndex: Integer; const ATitle: string); virtual;
  published
    property Glyph: TPicture read FGlyph write SetGlyph;
    property HighlightColor: TColor read FHighlightColor write SetHighlightColor;
    property OnTabChanged: ThpTabChangedEvent read FOnTabChanged write FOnTabChanged;
    property Anchors;
    property Font;
    property ParentFont;
    property Visible;
  end;

procedure Register;

implementation

uses
  Dialogs, Jpeg, Math, Types, Windows, StdCtrls, Forms;

(**
 * Register into the component palette
 *)
procedure Register;
begin
  RegisterComponents('hpVCL', [ThpTabStrip]);
end;

(* ThpTabStripButton *)

constructor ThpTabStripButton.Create(AOwner: TComponent);
begin
  inherited;
  Canvas.CopyMode := cmSrcCopy;
  FNumGlyphs := 2;
  Width := 71;
  Height := 19;

  if AOwner is ThpTabStrip then
    FTabStrip := AOwner as ThpTabStrip;
end;

procedure ThpTabStripButton.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if FTitle > '' then begin
    FNormalColor := Font.Color;
    Font.Color := FHighlightColor;
  end;
end;

procedure ThpTabStripButton.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FTitle > '' then
    Font.Color := FNormalColor;
end;

procedure ThpTabStripButton.Paint;
var
  srcImg, dstImg, dstText: TRect;
  imgWidth, imgHeight: Integer;
begin
  if (csDestroying in ComponentState) then
    Exit;

  if FGlyph.Graphic <> nil then begin
    imgWidth := FGlyph.Width div FNumGlyphs;
    imgHeight := FGlyph.Height;

    dstImg := Rect(0, 0, imgWidth, imgHeight);

    if FTabStripButtonState = tbsSelected then
      srcImg := Rect(imgWidth, 0, 2 * imgWidth, imgHeight)
    else
      srcImg := Rect(0, 0, imgWidth, imgHeight);

    Canvas.CopyRect(dstImg, FGlyph.Bitmap.Canvas, srcImg);
  end;

  if FTitle > '' then begin
    dstText := Rect(0, 0, Width, Height);
    Canvas.Font.Assign(Font);
    Canvas.Brush.Style := bsClear;
    DrawText(Canvas.Handle, PChar(FTitle), Length(FTitle), dstText,
      DT_SINGLELINE or DT_VCENTER or DT_CENTER);
  end;
end;

procedure ThpTabStripButton.SetTitle(const AValue: string);
begin
  if AValue <> FTitle then begin
    FTitle := AValue;
    Invalidate;
  end;
end;

procedure ThpTabStripButton.SetTabButtonState(AValue: ThpTabStripButtonState);
begin
  if AValue <> FTabStripButtonState then begin
    FTabStripButtonState := AValue;
    Invalidate;
  end;
end;

procedure ThpTabStripButton.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  if FTabStripButtonState = tbsSelected then
    Exit;

  FTabStripButtonState := tbsSelected;
  Invalidate;

  FTabStrip.UpdateTabs(Self);
end;

(* ThpTabStrip *)

constructor ThpTabStrip.Create(AOwner: TComponent);
begin
  inherited;
  FGlyph := TPicture.Create;
  FNumGlyphs := 2;
  BorderStyle := bsNone;
  BevelInner := bvNone;
  BevelOuter := bvNone;
  Height := 19;
  Width := 142;
end;

destructor ThpTabStrip.Destroy;
begin
  FGlyph.Free;
  inherited;
end;

procedure ThpTabStrip.AddTab(const ATitle, AHint: string);
var
  tab: ThpTabStripButton;
begin
  tab := ThpTabStripButton.Create(Self);
  if ControlCount = 0 then
    tab.FTabStripButtonState := tbsSelected;


  tab.HighlightColor := FHighlightColor;
  tab.Hint := AHint;
  tab.Parent := Self;
  tab.Title := ATitle;
  tab.ShowHint := AHint > '';

  if FGlyph <> nil then begin
    tab.Left := (ControlCount - 1) * (FGlyph.Width div 2);
    tab.FGlyph := FGlyph;
  end;
end;

procedure ThpTabStrip.DeleteTab(AIndex: Integer);
begin
  if (AIndex >= 0) and (AIndex < ControlCount) then
    if Controls[AIndex] is ThpTabStripButton then begin
      RemoveControl(Controls[AIndex]);
      UpdateTabPositions(nil);
    end;
end;

procedure ThpTabStrip.LoadFromFile(const AFileName: string);
begin
  FGlyph.LoadFromFile(AFileName);
  UpdateTabPositions(nil);
end;

procedure ThpTabStrip.LoadFromJpegFile(const AFileName: string);
var
  jpeg: TJpegImage;
begin
  jpeg := TJpegImage.Create();
  jpeg.LoadFromFile(AFileName);

  FGlyph.Bitmap.Assign(jpeg);
  Invalidate;

  jpeg.Free;
end;

procedure ThpTabStrip.RenameTab(AIndex: Integer; const ATitle: string);
begin
  if (AIndex >= 0) and (AIndex < ControlCount) then
    if Controls[AIndex] is ThpTabStripButton then
      (Controls[AIndex] as ThpTabStripButton).Title := ATitle;
end;

procedure ThpTabStrip.SetGlyph(AValue: TPicture);
begin
  UpdateTabPositions(AValue);
end;

procedure ThpTabStrip.SetHighlightColor(AValue: TColor);
var
  i: Integer;
begin
  if FHighlightColor <> AValue then begin
    FHighlightColor := AValue;
    for i := 0 to ControlCount - 1 do
      if Controls[i] is ThpTabStripButton then
        (Controls[i] as ThpTabStripButton).HighlightColor := AValue;
  end;
end;

procedure ThpTabStrip.UpdateTabPositions(AGlyph: TPicture);
var
  i: Integer;
  tab: ThpTabStripButton;
begin
  if AGlyph <> nil then
    FGlyph := AGlyph;

  if FGlyph = nil then
    Exit;

  for i := 0 to ControlCount - 1 do
    if Controls[i] is ThpTabStripButton then begin
      tab := Controls[i] as ThpTabStripButton;
      tab.FGlyph := FGlyph;
      tab.Height := FGlyph.Height;
      tab.Left := i * (FGlyph.Width div 2);
      tab.Width := FGlyph.Width div 2;
    end;
end;

procedure ThpTabStrip.UpdateTabs(Sender: ThpTabStripButton);
var
  i, idx: Integer;
  title: string;
begin
  idx := -1;
  for i := 0 to ControlCount - 1 do
    if Controls[i] = Sender then begin
      idx := i;
      title := Sender.Title;
    end
    else if Controls[i] is ThpTabStripButton then
      (Controls[i] as ThpTabStripButton).TabStripButtonState := tbsUnselected;

  if (idx > -1) and Assigned(FOnTabChanged) then
    FOnTabChanged(idx, title);
end;

end.
