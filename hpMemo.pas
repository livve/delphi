unit hpMemo;

(**
 * @copyright Copyright (C) 2011-2014, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
 * @package   hpMemo
 * @version   1.02
 *)

(**
 * History
 *
 * V1.02 2011-06-28
 * - Added ToTop and ToBottom procedures
 *
 * V1.01 2011-06-25
 * - Added OnTop event and testing after KeyUp
 *
 * V1.00 2011-06-24
 * - Initial release
 *)

interface

uses
  Classes, Messages, StdCtrls;

type
  (**
   * ThpMemo
   *)
  ThpMemo = class(TMemo)
  private
    FOnBottom: TNotifyEvent;
    FOnEndScroll: TNotifyEvent;
    FOnTop: TNotifyEvent;
  protected
    function GetIsAtBottom: Boolean;
    function GetIsAtTop: Boolean;
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
  public
    procedure ToBottom;
    procedure ToTop;
  published
    property IsAtBottom: Boolean read GetIsAtBottom;
    property IsAtTop: Boolean read GetIsAtTop;
    property OnBottom: TNotifyEvent read FOnBottom write FOnBottom;
    property OnEndScroll: TNotifyEvent read FOnEndScroll write FOnEndScroll;
    property OnTop: TNotifyEvent read FOnTop write FOnTop;
  end;

procedure Register;

implementation

uses
  Types, Windows;

(**
 * Register into the component palette
 *)
procedure Register;
begin
  RegisterComponents('hpVCL', [ThpMemo]);
end;

{ ThpMemo }

(**
 * GetIsAtBottom determines whether the scrollbar is at the bottom position
 *
 * @return  Boolean  True when at bottom position, False otherwise
 *)
function ThpMemo.GetIsAtBottom: Boolean;
var
  scrollInfo: TScrollInfo;
begin
  { Fill the ScrollInfo record }
  with scrollInfo do begin
    cbSize := SizeOf(TScrollInfo);
    fMask := SIF_PAGE or SIF_POS or SIF_RANGE or SIF_TRACKPOS;
  end;

  { Get the vertical scrollbar information }
  GetScrollInfo(Handle, SB_VERT, scrollInfo);

  { Compare current position against maximum position minus page size }
  Result := scrollInfo.nPos > scrollInfo.nMax - Integer(scrollInfo.nPage);end;

(**
 * GetIsAtTop determines whether the scrollbar is at the top position
 *
 * @return  Boolean  True when at top position, False otherwise
 *)
function ThpMemo.GetIsAtTop: Boolean;
var
  scrollInfo: TScrollInfo;
begin
  { Fill the ScrollInfo record }
  with scrollInfo do begin
    cbSize := SizeOf(TScrollInfo);
    fMask := SIF_PAGE or SIF_POS or SIF_RANGE or SIF_TRACKPOS;
  end;

  { Get the scrollbar information }
  GetScrollInfo(Handle, SB_VERT, scrollInfo);

  { Compare current position against top position }
  Result := scrollInfo.nPos = 0;end;

(**
 * WMKeyUp is triggered when releasing a key
 *
 * @param  Message  TWMKeyUp
 *)
procedure ThpMemo.WMKeyUp(var Message: TWMKeyUp);
begin
  inherited;

  { Trigger OnBottom when scrolling stops at the bottom position }
  if Assigned(FOnBottom) and GetIsAtBottom then begin
    FOnBottom(Self);
  end;

  { Trigger OnTop when scrolling stops at the top position }
  if Assigned(FOnTop) and GetIsAtTop then begin
    FOnTop(Self);
  end;
end;

(**
 * WMVScroll is triggered when the vertical scrollbar moves
 *
 * @param  Message  TWMVScroll
 *)
procedure ThpMemo.WMVScroll(var Message: TWMVScroll);
begin
  inherited;

  { Trigger OnEndScroll when scrolling stops }
  if Assigned(FOnEndScroll) and
     (Message.ScrollCode = Smallint(scEndScroll)) then begin

    FOnEndScroll(Self);
  end;

  { Trigger OnBottom when scrolling stops at the bottom position }
  if Assigned(FOnBottom) and (Message.ScrollCode = Smallint(scEndScroll)) and
     GetIsAtBottom then begin

    FOnBottom(Self);
  end;

  { Trigger OnTop when scrolling stops at the top position }
  if Assigned(FOnTop) and (Message.ScrollCode = Smallint(scEndScroll)) and
     GetIsAtTop then begin

    FOnTop(Self);
  end;
end;

(**
 * Scroll the memo to the bottom
 *)
procedure ThpMemo.ToBottom;
begin
  { Set the start of the selection to the maximum integer value }
  SelStart := MaxInt;

  { Tell the memo to scroll to the cursor }
  SendMessage(Handle, EM_SCROLLCARET, 0, 0);

  { Trigger OnBottom }
  if Assigned(FOnBottom) then begin
    FOnBottom(Self);
  end;
end;

(**
 * Scroll the memo to the top
 *)
procedure ThpMemo.ToTop;
begin
  { Set the start of the selection to zero }
  SelStart := 0;

  { Tell the memo to scroll to the cursor }
  SendMessage(Handle, EM_SCROLLCARET, 0, 0);

  { Trigger OnTop }
  if Assigned(FOnTop) then begin
    FOnTop(Self);
  end;
end;

end.
