unit hpHintWindow;

(**
 * @copyright Copyright (C) 2008-2014, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
 * @package   ThpHintWindow
 * @version   1.05
 *)

(**
 * History
 *
 * V1.05
 * - Added TextLine3
 *
 * V1.04 30/08/2010
 * - BUGFIX  Hint resize room user count text now also resizes hint.
 *
 * V1.03 2009-02-03
 * - BUGFIX  Hint size not calculated correctly if FItems.Count = 0
 *
 * V1.02 2009-02-01
 * - FEATURE New properties for large icon and two lines of text next to it.Set
 *           HintType to hwtLargeIcon, set LargeImageList, LargeIconId,
 *           TextLine1 and TextLine2
 *
 * V1.01 2008-09-03 Bugfixes and basic features
 * - FEATURE Added IconSize and Margin property
 * - BUGFIX  Line height now calculated from font and icon size
 * - FEATURE Added icon background brush
 * - FEATURE Accept imagelist as property to be used with Add(Index)
 * - BUGFIX  TStringList oddity. When Sorted Add does nothing on dupIgnore (in
 *           contrary to the help. So object was created, but never inserted
 *           (and thus not freed). Added IndexOf checks before all inserts
 *
 * V1.00 2008-08-31 Initial release
 * - Customized hint window that shows multiple lines containing icons and/or
 *   texts
 *)

interface

uses
  Windows, Controls, Classes, Graphics;

type
  (**
   * ThpHintWindowType
   *)
  ThpHintWindowType = (hwtStandard, hwtLargeIcon);

  (**
   * ThpHintWindow
   *)
  ThpHintWindow = class(THintWindow)
  private
    FHintType: ThpHintWindowType;
    FItems: TStringList;
    FIconSize: Integer;
    FIconBkBrush: TBrush;
    FMargin: Integer;
    FImageList: TImageList;
    FLargeIconId: Integer;
    FLargeIconSize: Integer;
    FLargeImageList: TImageList;
    FTextLine1: string;
    FTextLine2: string;
    FTextLine3: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Add(const AId, AText: string); overload;
    procedure Add(const AId, AText: string; AIcon: TPicture); overload;
    procedure Add(const AId, AText: string; AIcon: TBitmap); overload;
    procedure Add(const AId, AText: string; AIndex: Integer); overload;
    procedure Delete(const AId: string);
    procedure Clear;
    procedure ActivateHint(APoint: TPoint); reintroduce;
  protected
    procedure Paint; override;
  published
    property HintType: ThpHintWindowType read FHintType write FHintType;
    property IconSize: Integer read FIconSize write FIconSize;
    property IconBkBrush: TBrush read FIconBkBrush write FIconBkBrush;
    property Margin: Integer read FMargin write FMargin;
    property ImageList: TImageList write FImageList;
    property LargeIconId: Integer read FLargeIconId write FLargeIconId;
    property LargeIconSize: Integer read FLargeIconSize write FLargeIconSize;
    property LargeImageList: TImageList write FLargeImageList;
    property TextLine1: string read FTextLine1 write FTextLine1;
    property TextLine2: string read FTextLine2 write FTextLine2;
    property TextLine3: string read FTextLine3 write FTextLine3;
  end;

implementation

uses
  Math;

type
  (**
   * ThpHintItem
   * Contains the text and icon to be displayed by ThpHintWIndow
   *)
  ThpHintItem = class(TObject)
  private
    FText: string;
    FIcon: TPicture;
    FFreeIcon: Boolean;
  public
    constructor Create(const AText: string; AIcon: TPicture); reintroduce; virtual;
    destructor Destroy; override;
  end;

(* ThpHintItem *)

(**
 * constructor
 * @param AText string
 * @param AIcon TPicture
 *)
constructor ThpHintItem.Create(const AText: string; AIcon: TPicture);
begin
  FText := AText;
  FIcon := nil;
  FFreeIcon := False;

  if AIcon <> nil then begin
    FIcon := TPicture.Create;
    FIcon.Assign(AIcon);
    FFreeIcon := True;
  end;
end;

(**
 * destructor
 *)
destructor ThpHintItem.Destroy;
begin
  if FFreeIcon then
    FIcon.Free;
  inherited Destroy;
end;

(* ThpHintWindow *)

(**
 * constructor
 * @param AOwner TComponent
 *)
constructor ThpHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHintType := hwtStandard;
  FItems := TStringList.Create;
  FItems.Sorted := True;
  FIconSize := 16;
  FIconBkBrush := TBrush.Create;
  FIconBkBrush.Color := clBlack;
  FIconBkBrush.Style := bsSolid;
  FMargin := 4;
  FImageList := nil;
  FLargeIconId := -1;
  FLargeIconSize := 48;
  FLargeImageList := nil;
end;

(**
 * destructor
 *)
destructor ThpHintWindow.Destroy;
begin
  Clear;
  FItems.Free;
  if FIconBkBrush <> nil then
    FIconBkBrush.Free;
  inherited Destroy;
end;

(**
 * Add, overloaded
 * Adds a hint text without an icon to the list
 *
 * @param AId   string Hint identifier
 * @param AText string Hint text
 *)
procedure ThpHintWindow.Add(const AId, AText: string);
begin
  if FItems.IndexOf(AId) = -1 then
    FItems.AddObject(AId, ThpHintItem.Create(AText, nil));
end;

(**
 * Add, overloaded
 * Adds a hint text and a picture reference to the list
 *
 * @param AId   string   Hint identifier
 * @param AText string   Hint text
 * @param AIcon TPicture Hint picture
 *)
procedure ThpHintWindow.Add(const AId, AText: string; AIcon: TPicture);
begin
  if FItems.IndexOf(AId) = -1 then
    FItems.AddObject(AId, ThpHintItem.Create(AText, AIcon));
end;

(**
 * Add, overloaded
 * Adds a hint text and a bitmap to the list
 *
 * @param AId   string  Hint identifier
 * @param AText string  Hint text
 * @param AIcon TBitmap Hint bitmap
 *)
procedure ThpHintWindow.Add(const AId, AText: string; AIcon: TBitmap);
var
  obj: ThpHintItem;
begin
  if FItems.IndexOf(AId) = -1 then begin
    obj := ThpHintItem.Create(AText, nil);
    obj.FIcon := TPicture.Create;
    obj.FIcon.Assign(AIcon);
    obj.FFreeIcon := True;

    FItems.AddObject(AId, obj);
  end;
end;

(**
 * Add, overloaded
 * Adds a hint text and a bitmap to the list
 *
 * @param AId    string  Hint identifier
 * @param AText  string  Hint text
 * @param AIndex Integer Hint image index in image list
 *)
procedure ThpHintWindow.Add(const AId, AText: string; AIndex: Integer);
var
  bmp: TBitmap;
begin
  if FItems.IndexOf(AId) = -1 then begin
    if FImageList <> nil then begin
      bmp := TBitmap.Create;
      try
        FImageList.GetBitmap(AIndex, bmp);
        Add(AId, AText, bmp);
      finally
        bmp.Free;
      end;
    end
    else
      FItems.AddObject(AId, ThpHintItem.Create(AText, nil));
  end;
end;

(**
 * Delete
 * Delete the item identified by AId from the list
 *
 * @param AId string Hint identifier
 *)
procedure ThpHintWindow.Delete(const AId: string);
var
  i: Integer;
begin
  i := FItems.IndexOf(AId);
  if i > -1 then begin
    FItems.Objects[i].Free;
    FItems.Delete(i);
  end;
end;

(**
 * Clear
 * Removes all items from the list
 *)
procedure ThpHintWindow.Clear;
var
  i: Integer;
begin
  for i := 0 to FItems.Count - 1 do
    FItems.Objects[i].Free;
  FItems.Clear;
end;

(**
 * ActivateHint
 * Enables the hint after calculating it's size. If the item list is empty, the
 * hint window won't show
 *
 * @param APoint TPoint Top-left position of the hint window
 *)
procedure ThpHintWindow.ActivateHint(APoint: TPoint);
var
  i, w, h, lh: Integer;
begin
  lh := Max(FIconSize, Canvas.TextHeight('yY')); // line height
  w := 0;
  h := FMargin;

  with APoint do begin
    if FItems.Count > 0 then begin

      (* Calculate width *)
      w := 0;
      for i := 0 to FItems.Count - 1 do
        w := Max(w, Canvas.TextWidth(ThpHintItem(FItems.Objects[i]).FText));

      (* Calculate height *)
      Inc(h, (lh * FItems.Count) + (FMargin * FItems.Count));
    end;

    if FHintType = hwtLargeIcon then begin
      w := Max(w, FLargeIconSize + FMargin +
        Max(Canvas.TextWidth(FTextLine1), Canvas.TextWidth(FTextLine1)));
      w := Max(w, FLargeIconSize + FMargin +
        Max(Canvas.TextWidth(FTextLine2), Canvas.TextWidth(FTextLine2)));
      w := Max(w, FLargeIconSize + FMargin +
        Max(Canvas.TextWidth(FTextLine3), Canvas.TextWidth(FTextLine3)));
      Inc(h, FMargin + FLargeIconSize);
    end;

    inherited ActivateHint(Rect(x, y, x + (3 * FMargin) + FIconSize + w,
      y + h), '');
  end;
end;

(**
 * Paint
 * Draws the actual content of the hint window
 *)
procedure ThpHintWindow.Paint;
var
  i, hd, th, lh: Integer;
  r, br: TRect;
  oldBrush: TBrush;
  hi: ThpHintItem;
begin
  th := Canvas.TextHeight('yY'); // text height
  hd := (FIconSize - th) div 2;  // height div (between icon and text)
  lh := Max(FIconSize, th);      // line height

  r := ClientRect;

  if FHintType = hwtLargeIcon then
    try
      if (FLargeImageList <> nil) and
         (FLargeIconId < FLargeImageList.Count) then
        FLargeImageList.Draw(Canvas, FMargin, FMargin, FLargeIconId);

      SetRect(br, r.Left + FLargeIconSize + 2 * FMargin, r.Top + FMargin,
        r.Right, r.Bottom);
      DrawText(Canvas.Handle, PChar(FTextLine1), -1, br, DT_LEFT or DT_NOPREFIX);
	  
      SetRect(br, r.Left + FLargeIconSize + 2 * FMargin,
        r.Top + 2 * FMargin + lh, r.Right, r.Bottom);
      DrawText(Canvas.Handle, PChar(FTextLine2), -1, br, DT_LEFT or DT_NOPREFIX);
	  
      SetRect(br, r.Left + FLargeIconSize + 2 * FMargin,
        r.Top + 5 * FMargin + lh, r.Right, r.Bottom);
      DrawText(Canvas.Handle, PChar(FTextLine3), -1, br, DT_LEFT or DT_NOPREFIX);
    except
    end;

  for i := 0 to FItems.Count - 1 do begin
    r.Top := i * lh + (i + 1) * FMargin;
    if FHintType = hwtLargeIcon then
      Inc(r.Top, FMargin + FLargeIconSize);

    r.Left := FMargin;

    hi := ThpHintItem(FItems.Objects[i]);

    if hi.FIcon <> nil then begin

      (* Draw background rectangle *)
      if FIconBkBrush <> nil then begin
        oldBrush := TBrush.Create;
        try
          oldBrush.Assign(Canvas.Brush);
          Canvas.Brush.Assign(FIconBkBrush);

          SetRect(br, r.Left, r.Top, r.Left + FIconSize, r.Top + FIconSize);
          Canvas.Rectangle(br);

          Canvas.Brush.Assign(oldBrush);
        finally
          oldBrush.Free;
        end;
      end;

      (* Draw image *)
      try
        Canvas.Draw(r.Left, r.Top, hi.FIcon.Graphic);
      except
      end;

      (* Adjust text offset*)
      Inc(r.Left, FIconSize + FMargin);
    end;

    (* Draw text *)
    r.Top := r.Top + hd;
    try
      DrawText(Canvas.Handle, PChar(hi.FText), -1, r, DT_LEFT or DT_NOPREFIX);
    except
    end;
  end;
end;

end.
