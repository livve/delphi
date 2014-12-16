unit hpScaleDraw;

(**
 * @copyright Copyright (C) 2012-2014, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
 * @package   hpScaleDraw
 * @version   1.04
 *)

(**
 * History
 *
 * 1.04       2012-05-01
 *            Added draw mode rectangle and ellipse, outline and filled
 *            Added draw mode to callback function
 *            Added draw mode to draw function
 *
 * 1.03       2012-04-30
 *            Fixed saving of Pen color and width
 *            Added DrawMode for pen and line
 *
 * 1.02       2012-04-23
 *            Added SaveToFile
 *
 * 1.01       2012-04-22
 *            Added Clear
 *
 * 1.00       2012-04-21
 *            Initial implementation
 *)

interface

uses
  Classes, Types, Contnrs, Controls, ExtCtrls, Graphics;

type
  ThpDrawMode = (dmPen, dmLine, dmRectangle, dmFilledRectangle, dmEllipse,
    dmFilledEllipse);

  ThpOnAfterDrawNotify = procedure (AMode: ThpDrawMode; AFrom, ATo: TPoint;
    AColor: TColor; AWidth: Integer) of object;

  ThpScaleDraw = class(TPaintBox)
  private
    FDrawItems: TInterfaceList;
    FDrawMode: ThpDrawMode;
    FIsMouseDown: Boolean;
    FOnAfterDraw: ThpOnAfterDrawNotify;
    FOrigin: TPoint;
    FPrecision: Integer;
    FPrevious: TPoint;
    procedure CanvasMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CanvasMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure CanvasMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  protected
    procedure DrawXor(AMode: ThpDrawMode; AFrom, ATo: TPoint);
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure Draw(AMode: ThpDrawMode; AFrom, ATo: TPoint;
      AColor: TColor; AWidth: Integer);
    procedure SaveToFile(const AFilename: string);
  published
    property DrawMode: ThpDrawMode read FDrawMode write FDrawMode;
    property Precision: Integer read FPrecision write FPrecision;
    property OnAfterDraw: ThpOnAfterDrawNotify read FOnAfterDraw
      write FOnAfterDraw;
  end;

procedure Register;

implementation

type
  IhpDraw = interface
    procedure Draw(ACanvas: TCanvas; AWidth, AHeight, APrecision: Integer);
  end;

  ThpDraw = class(TInterfacedObject, IhpDraw)
  private
    FColor: TColor;
    FFrom: TPoint;
    FMode: ThpDrawMode;
    FTo: TPoint;
    FWidth: Integer;
  public
    constructor Create(AMode: ThpDrawMode; AFrom, ATo: TPoint; AColor: TColor;
      AWidth: Integer);
    procedure Draw(ACanvas: TCanvas; AWidth, AHeight, APrecision: Integer);
  end;

{ ThpDraw }

constructor ThpDraw.Create(AMode: ThpDrawMode; AFrom, ATo: TPoint;
  AColor: TColor; AWidth: Integer);
begin
  inherited Create;
  FColor := AColor;
  FFrom := AFrom;
  FMode := AMode;
  FTo := ATo;
  FWidth := AWidth;
end;

procedure ThpDraw.Draw(ACanvas: TCanvas; AWidth, AHeight, APrecision: Integer);
var
  oldBrushColor: TColor;
  oldBrushStyle: TBrushStyle;
  oldColor: TColor;
  oldWidth: Integer;
begin
  oldBrushColor := ACanvas.Brush.Color;
  oldBrushStyle := ACanvas.Brush.Style;
  oldColor := ACanvas.Pen.Color;
  oldWidth := ACanvas.Pen.Width;

  ACanvas.Pen.Color := FColor;
  ACanvas.Pen.Width := FWidth;

  case FMode of
    dmPen,
    dmLine: begin
      ACanvas.MoveTo(
        FFrom.X * AWidth div APrecision,
        FFrom.Y * AHeight div APrecision);
      ACanvas.LineTo(
        FTo.X * AWidth div APrecision,
        FTo.Y * AHeight div APrecision);
    end;

    dmRectangle: begin
      ACanvas.Brush.Style := bsClear;
      ACanvas.Rectangle(
        FFrom.X * AWidth div APrecision,
        FFrom.Y * AHeight div APrecision,
        FTo.X * AWidth div APrecision,
        FTo.Y * AHeight div APrecision);
    end;

    dmFilledRectangle: begin
      ACanvas.Brush.Color := FColor;
      ACanvas.Rectangle(
        FFrom.X * AWidth div APrecision,
        FFrom.Y * AHeight div APrecision,
        FTo.X * AWidth div APrecision,
        FTo.Y * AHeight div APrecision);
    end;

    dmEllipse: begin
      ACanvas.Brush.Style := bsClear;
      ACanvas.Ellipse(
        FFrom.X * AWidth div APrecision,
        FFrom.Y * AHeight div APrecision,
        FTo.X * AWidth div APrecision,
        FTo.Y * AHeight div APrecision);
    end;

    dmFilledEllipse: begin
      ACanvas.Brush.Color := FColor;
      ACanvas.Ellipse(
        FFrom.X * AWidth div APrecision,
        FFrom.Y * AHeight div APrecision,
        FTo.X * AWidth div APrecision,
        FTo.Y * AHeight div APrecision);
    end;
  end;

  ACanvas.Brush.Color := oldBrushColor;
  ACanvas.Brush.Style := oldBrushStyle;
  ACanvas.Pen.Color := oldColor;
  ACanvas.Pen.Width := oldWidth;
end;

{ ThpScaleDraw }

constructor ThpScaleDraw.Create(AOwner: TComponent);
begin
  inherited;
  FDrawItems := TInterfaceList.Create;
  FDrawMode := dmPen;
  FIsMouseDown := False;
  FPrecision := 1000;
  OnMouseDown := CanvasMouseDown;
  OnMouseUp := CanvasMouseUp;
  OnMouseMove := CanvasMouseMove;
end;

destructor ThpScaleDraw.Destroy;
begin
  FDrawItems.Clear;
  FDrawItems.Free;
  inherited;
end;

procedure ThpScaleDraw.Clear;
begin
  FDrawItems.Clear;
  Invalidate;
end;

procedure ThpScaleDraw.Draw(AMode: ThpDrawMode; AFrom, ATo: TPoint;
  AColor: TColor; AWidth: Integer);
var
  intf: IhpDraw;
begin
  intf := ThpDraw.Create(AMode, AFrom, ATo, AColor, AWidth);
  FDrawItems.Add(intf);
  intf.Draw(Canvas, Width, Height, FPrecision);
end;

procedure ThpScaleDraw.SaveToFile(const AFilename: string);
var
  bitmap: TBitmap;
  r: TRect;
begin
  bitmap := TBitmap.Create;
  try
    bitmap.Width := Width;
    bitmap.Height := Height;
    bitmap.PixelFormat := pf32bit;
    r := Rect(0, 0, Width, Height);
    bitmap.Canvas.CopyRect(r, Canvas, r);
    bitmap.SaveToFile(AFilename);
  finally
    bitmap.Free;
  end;
end;

{ protected }

procedure ThpScaleDraw.DrawXor(AMode: ThpDrawMode; AFrom, ATo: TPoint);
var
  oldMode: TPenMode;
  intf: IhpDraw;
begin
  intf := ThpDraw.Create(AMode, AFrom, ATo, Canvas.Pen.Color,
    Canvas.Pen.Width);

  oldMode := Canvas.Pen.Mode;
  Canvas.Pen.Mode := pmXor;
  intf.Draw(Canvas, Width, Height, FPrecision);
  Canvas.Pen.Mode := oldMode;
end;

procedure ThpScaleDraw.Paint;
var
  i: Integer;
begin
  for i := 0 to FDrawItems.Count - 1 do
    IhpDraw(FDrawItems[i]).Draw(Canvas, Width, Height, FPrecision);
end;

{ private }

procedure ThpScaleDraw.CanvasMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  FIsMouseDown := True;
  FOrigin.X := FPrecision * X div Width;
  FOrigin.Y := FPrecision * Y div Height;
  FPrevious := FOrigin;
end;

procedure ThpScaleDraw.CanvasMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  current: TPoint;
begin
  if FIsMouseDown then begin
    current.X := FPrecision * X div Width;
    current.Y := FPrecision * Y div Height;

    case FDrawMode of
      dmPen: begin
        Draw(FDrawMode, FPrevious, current, Canvas.Pen.Color, Canvas.Pen.Width);

        if Assigned(FOnAfterDraw) then
          FOnAfterDraw(FDrawMode, FPrevious, current, Canvas.Pen.Color,
            Canvas.Pen.Width);
      end;

      dmLine,
      dmRectangle,
      dmFilledRectangle,
      dmEllipse,
      dmFilledEllipse: begin
        DrawXor(FDrawMode, FOrigin, FPrevious);
        DrawXor(FDrawMode, FOrigin, current);
      end;
    end;
    FPrevious := current;
  end;
end;

procedure ThpScaleDraw.CanvasMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  current: TPoint;
begin
  FIsMouseDown := False;
  current.X := FPrecision * X div Width;
  current.Y := FPrecision * Y div Height;

  case FDrawMode of
    dmLine,
    dmrectangle,
    dmFilledRectangle,
    dmEllipse,
    dmFilledEllipse: begin
      DrawXor(FDrawMode, FOrigin, FPrevious);

      Draw(FDrawMode, FOrigin, current, Canvas.Pen.Color, Canvas.Pen.Width);
      if Assigned(FOnAfterDraw) then
        FOnAfterDraw(FDrawMode, FOrigin, current, Canvas.Pen.Color,
          Canvas.Pen.Width);

      Invalidate;
    end;
  end;
end;

(**
 * Register into the component palette
 *)
procedure Register;
begin
  RegisterComponents('hpVCL', [ThpScaleDraw]);
end;

end.
