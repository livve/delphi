unit hpTypes;

(**
 * @copyright Copyright (C) 2011-2014, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
 * @package   hpTypes
 * @version   1.00
 *)

(**
 * History
 *
 * V1.00 2011-05-19
 * - Initial release with ThpColor
 *)

interface

uses
  Graphics;

type
  (**
   * ThpColor allows easy conversion between a TColor and an HTML color code
   *)
  ThpColor = record
    Color: TColor;
    class operator Equal(ALeftOp, ARightOp: ThpColor): Boolean;
    class operator Implicit(AValue: string): ThpColor;
    class operator Implicit(AValue: TColor): ThpColor;
    class operator Implicit(AValue: ThpColor): string;
    class operator Implicit(AValue: ThpColor): TColor;
    class operator NotEqual(ALeftOp, ARightOp: ThpColor): Boolean;
  end;

implementation

uses
  Windows, SysUtils;

{ ThpColor }

(**
 * Compare two ThpColor types for equality
 *
 * @param ALeftOp  ThpColor The left operand
 * @param ARightOp ThpColor The right operand
 * @return         Boolean  True when equal, False otherwise
 *)
class operator ThpColor.Equal(ALeftOp, ARightOp: ThpColor): Boolean;
begin
  Result := ALeftOp.Color = ARightOp.Color;
end;

(**
 * Cast a string to a ThpColor
 *
 * @param AValue string   The value to cast (HTML color code)
 * @return       ThpColor The casted value
 *)
class operator ThpColor.Implicit(AValue: string): ThpColor;
var
  R, G, B: Byte;
begin
  if Pos('#', AValue) = 1 then
    Delete(AValue, 1, 1);

  R := StrToIntDef('$' + Copy(AValue, 1, 2), 0);
  G := StrToIntDef('$' + Copy(AValue, 3, 2), 0);
  B := StrToIntDef('$' + Copy(AValue, 5, 2), 0);

  Result.Color := RGB(R, G, B);
end;

(**
 * Cast a TColor to a ThpColor
 *
 * @param AValue TColor   The value to cast
 * @return       ThpColor The casted value
 *)
class operator ThpColor.Implicit(AValue: TColor): ThpColor;
begin
  Result.Color := AValue;
end;

(**
 * Cast a ThpColor to a string
 *
 * @param AValue ThpColor The value to cast
 * @return       string   The casted value (HTML color code)
 *)
class operator ThpColor.Implicit(AValue: ThpColor): string;
begin
  Result := Format('#%s%s%s', [
    IntToHex(GetRValue(AValue.Color), 2),
    IntToHex(GetGValue(AValue.Color), 2),
    IntToHex(GetBValue(AValue.Color), 2)]);
end;

(**
 * Cast a ThpColor to a TColor
 *
 * @param AValue ThpColor The value to cast
 * @return       TColor   The casted value
 *)
class operator ThpColor.Implicit(AValue: ThpColor): TColor;
begin
  Result := AValue.Color;
end;

(**
 * Compare two ThpColor types for inequality
 *
 * @param ALeftOp  ThpColor The left operand
 * @param ARightOp ThpColor The right operand
 * @return         Boolean  True when not equal, False otherwise
 *)
class operator ThpColor.NotEqual(ALeftOp, ARightOp: ThpColor): Boolean;
begin
  Result := ALeftOp.Color <> ARightOp.Color;
end;

end.
