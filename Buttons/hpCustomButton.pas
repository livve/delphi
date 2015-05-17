unit hpCustomButton;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Buttons
 * @package   hpCustomButton
 * @version   1.00
 *)

(**
 * History
 *
 * V1.00 2015-05-16
 * - Initial release
 *)

interface

uses
  Controls;

type
  (**
   * ThpCustomButton interface
   *)
  ThpCustomButton = class(TGraphicControl)
  published
    property Anchors;
    property AutoSize;
    property Caption;
    property Cursor;
    property Enabled;
    property Font;
    property Hint;
    property OnClick;
    property OnMouseUp;
    property OnMouseDown;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property Visible;
  end;

implementation

end.
