unit hpImageListHelper;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Helpers
 * @package   hpImageListHelper
 * @version   1.00
 *)

(**
 * History
 *
 * V1.00 2015-01-08
 * - Initial release
 *)

interface

uses
  Controls;

type
  ThpImageListHelper = class
  public
    procedure AddBitmap(const AFileName: string; AImageList: TImageList); virtual;
  end;

implementation

uses
  Classes, Graphics;

(* ThpImageListHelper *)

procedure ThpImageListHelper.AddBitmap(const AFileName: string;
  AImageList: TImageList);
var
  thumbnail, copy: TBitmap;
  left: Integer;
begin
  copy := TBitmap.Create;
  copy.Height := AImageList.Height;
  copy.Width := AImageList.Width;

  thumbnail := TBitmap.Create;
  thumbnail.LoadFromFile(AFileName);

  left := 0;
  while left < thumbnail.Width do begin
    copy.Canvas.CopyRect(Rect(0, 0, AImageList.Width - 1, AImageList.Height - 1),
      thumbnail.Canvas, Rect(left, 0, left + AImageList.Width - 1, AImageList.Height - 1));

    AImageList.Add(copy, nil);
    Inc(left, AImageList.Width);
  end;

  copy.Free;
  thumbnail.free;
end;

end.
