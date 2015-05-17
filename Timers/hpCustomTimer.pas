unit hpCustomTimer;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Timers
 * @package   hpCustomTimer
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
  Classes, Contnrs, ExtCtrls;

type
  (**
   * ThpCustomTimer interface
   *)
  ThpCustomTimer = class(TTimer)
  protected
    FItems: TObjectList;
    procedure TimerInterval(Sender: TObject); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

(**
 * ThpCustomTimer implementation
 *)

constructor ThpCustomTimer.Create(AOwner: TComponent);
begin
  inherited;
  Enabled := False;
  FItems := TObjectList.Create(true);
  Interval := 60000;
  OnTimer := TimerInterval;
end;

destructor ThpCustomTimer.Destroy;
begin
  FItems.Clear;
  FItems.Free;
  inherited;
end;

procedure ThpCustomTimer.TimerInterval(Sender: TObject);
begin
  (**
   * Override in base class
   *)
end;

end.
