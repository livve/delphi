unit hpChatListBox;

(**
 * @copyright Copyright (C) 2008-2014, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
 * @package   ThpChatListBox
 * @version   1.29
 *)

(**
 * History
 *
 * V1.29 (2014-12-16)
 * - Name check in AddItem
 *
 * V1.28
 * - Changes by Simon
 *
 * V1.27
 * - Changed sort, moved co-moderator between moderator and voice
 *
 * V1.26
 * - Moved Ok icon to first column (in pmTwoIcons mode)
 *
 * V1.25
 * - Added Delete function
 * - Added bounds check for CustomIconIndex
 * - Fixed FocusRect size
 *
 * V1.24
 * - Removed community leader debug code
 * - Added public property IsAfkSeparator
 * - Added space between items
 * - Added CustomImageList to listbox
 * - Added CustomIconIndex to items
 * - Fixed selected background color
 *
 * V1.23
 * - Added IsCommunityLeader
 *
 * V1.22
 * - Added IsBlocked property and icon
 *
 * V1.21
 * - Changed the way the AFK separator is added
 * - Added user item paint mode: legacy (all icons) and two icons
 *
 * V1.20
 * - Added margins (left, right)
 * - Added icon size and (right) margin
 * - Restored IsOverName
 * - Fixed highlight background
 * - Custom colour change
 *
 * V1.19
 * - Changed sort order
 *
 * V1.18
 * - Changed IsOverName
 *
 * V1.17
 * - New sort
 *
 * V1.16
 * - ItemIndex is restored after sort
 * - Spacing between icon and username
 * - Increased ItemHeight
 *
 * V1.15
 * - Added two new account levels 16, 17 and updated user key to show them.
 *
 * V1.14
 * - Bugfix for redraw problem when running multiple instances on a single
 *   computer
 *
 * V1.13
 * - Bugfix for ChatSort
 *
 * V1.12
 * - Added Afk separator
 *
 * V1.11
 * - ChatSort now puts Voice user on top of the list
 *
 * V1.10
 * - Added ComponentState csDestroying checks
 *
 * V1.09
 * - Added custom user colors
 * - ImageList now optional
 *
 * V1.08
 * - Replaced userlevel icon with trophy, if any
 * - Fixed positioning bug for trophy icon
 * - Changed ChatSort to include FOk
 *
 * V1.07
 * - Added IsOverName check function
 *
 * V1.06
 * - Added co moderator
 *
 * V1.05
 * - Auto refresh list on item content change
 *
 * V1.04
 * - Added moderator on top to sort
 *
 * V1.03
 * - Added member sort
 *
 * V1.02
 * - Added voice property
 *
 * V1.01
 * - Added video property
 * - Changed drawing colors
 *
 * V1.00 2008-09-30 Initial release
 * - Customized chat members list, containing multiple icons, custom colors
 *   and borders and custom sorting of the items
 *)

interface

uses
  Windows, Classes, Controls, StdCtrls, Messages, Graphics, Contnrs;

type
  ThpChatListBox = class;

  (**
   * ThpChatListItem
   *)
  ThpChatListItem = class(TComponent)
  private
    FParent: ThpChatListBox;
    FName: string;
    FUserLevel: Integer;
    FCommunityLeader: Boolean;
    FModerator: Boolean;
    FCoModerator: Boolean;
    FAfk: Boolean;
    FUnlimited: Boolean;
    FDownload: Boolean;
    FVideo: Boolean;
    FVoice: Boolean;
    FOk: Boolean;
    FRanked: Boolean;
    FGaming: Boolean;
    FGoodlatency: Boolean;
    FHighlatency: Boolean;
    FMeasuring: Boolean;
    FTrophy: Boolean;
    FTextColor: TColor;
    FBorderColor: TColor;
    FCustomColor: Boolean;
    FIsAfkSeparator: Boolean;
    FIsBlocked: Boolean;
    FCustomIconIndex: Integer;
    FCustomBIconIndex: Integer;
    FTavlaWinIndex: Integer;
    FBatakWinIndex: Integer;
    FPlaying: Boolean;
    procedure SetPlaying(const Value: Boolean);
  protected
    procedure UpdateParent; virtual;
    procedure SetUserLevel(AValue: Integer); virtual;
    procedure SetCommunityLeader(AValue: Boolean); virtual;
    procedure SetAfk(AValue: Boolean); virtual;
    procedure SetModerator(AValue: Boolean); virtual;
    procedure SetCoModerator(AValue: Boolean); virtual;
    procedure SetUnlimited(AValue: Boolean); virtual;
    procedure SetDownload(AValue: Boolean); virtual;
    procedure SetOk(AValue: Boolean); virtual;
    procedure SetGaming(AValue: Boolean); virtual;
    procedure SetRanked(AValue: Boolean); virtual;
    procedure SetGoodlatency(AValue: Boolean); virtual;
    procedure SetHighlatency(AValue: Boolean); virtual;
    procedure SetMeasuring(AValue: Boolean); virtual;
    procedure SetVideo(AValue: Boolean); virtual;
    procedure SetVoice(AValue: Boolean); virtual;
    procedure SetTrophy(AValue: Boolean); virtual;
    procedure SetTextColor(AValue: TColor); virtual;
    procedure SetBorderColor(AValue: TColor); virtual;
    procedure SetCustomColor(AValue: Boolean); virtual;
    procedure SetIsBlocked(AValue: Boolean); virtual;
    procedure SetCustomIconIndex(AValue: Integer); virtual;
    procedure SetCustomBIconIndex(AValue: Integer); virtual;
    procedure SetTavlaWinIndex(AValue: Integer); virtual;
    procedure SetBatakWinIndex(AValue: Integer); virtual;
  public
    function IsOverName(X: Integer): Boolean; virtual;
  published
    property Name: string read FName;
    property UserLevel: Integer read FUserLevel write SetUserLevel;
    property Afk: Boolean read FAfk write SetAfk;
    property CommunityLeader: Boolean read FCommunityLeader write SetCommunityLeader;
    property Moderator: Boolean read FModerator write SetModerator;
    property CoModerator: Boolean read FCoModerator write SetCoModerator;
    property Unlimited: Boolean read FUnlimited write SetUnlimited;
    property Download: Boolean read FDownload write SetDownload;
    property Trophy: Boolean read FTrophy write SetTrophy;
    property Ok: Boolean read FOk write SetOk;
    property Gaming: Boolean read FGaming write SetGaming;
    property Ranked: Boolean read FRanked write SetRanked;
    property Goodlatency: Boolean read FGoodlatency write SetGoodlatency;
    property Highlatency: Boolean read FHighlatency write SetHighlatency;
    property Measuring: Boolean read FMeasuring write SetMeasuring;
    property Video: Boolean read FVideo write SetVideo;
    property Voice: Boolean read FVoice write SetVoice;
    property TextColor: TColor read FTextColor write SetTextColor;
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property CustomColor: Boolean read FCustomColor write SetCustomColor;
    property IsAfkSeparator: Boolean read FIsAfkSeparator;
    property IsBlocked: Boolean read FIsBlocked write SetIsBlocked;
    property CustomIconIndex: Integer read FCustomIconIndex write SetCustomIconIndex;
    property CustomBIconIndex: Integer read FCustomBIconIndex write SetCustomBIconIndex;
    property TavlaWinIndex: Integer read FTavlaWinIndex write SetTavlaWinIndex;
    property BatakWinIndex: Integer read FBatakWinIndex write SetBatakWinIndex;
  end;

  (**
   * TChatListBoxPaintMode
   *)
  TChatListBoxPaintMode = (pmLegacy, pmTwoIcons);

  (**
   * ThpChatListBox
   *)
  ThpChatListBox = class(TCustomListBox)
  private
    FSorted: Boolean;
    FImageList: TImageList;
    FCustomImageList: TImageList;
    FCustomBImageList: TImageList;
    FTavlaWinIndex: TImageList;
    FBatakWinIndex: TImageList;
    FMarginLeft: Integer;
    FMarginRight: Integer;
    FIconWidth: Integer;
    FIconHeight: Integer;
    FIconMargin: Integer;
    FHasAfkSeparator: Boolean;
    FPaintMode: TChatListBoxPaintMode;
  public
    constructor Create(AOwner: TComponent); override;
    function AddItem(const AName: string): ThpChatListItem; reintroduce; overload; virtual;
    function AddItem(const AName: string; ATextColor, ABorderColor: TColor): ThpChatListItem; reintroduce; overload; virtual;
    procedure DeleteItem(const AName: string);
  protected
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    function GetItem(AIndex: Integer): ThpChatListItem;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure SetMarginLeft(AValue: Integer);
    procedure SetMarginRight(AValue: Integer);
    procedure SetIconWidth(AValue: Integer);
    procedure SetIconHeight(AValue: Integer);
    procedure SetIconMargin(AValue: Integer);
  public
    property ListItems[Index: Integer]: ThpChatListItem read GetItem;
    procedure Sort; virtual;
    procedure Clear; override;
    property Count: Integer read GetCount;
    function GetCount: Integer; override;
  published
    property ImageList: TImageList read FImageList write FImageList;
    property CustomImageList: TImageList read FCustomImageList write FCustomImageList;
    property CustomBImageList: TImageList read FCustomBImageList write FCustomBImageList;
    property TavlaWinIndex: TImageList read FTavlaWinIndex write FTavlaWinIndex;
    property BatakWinIndex: TImageList read FBatakWinIndex write FBatakWinIndex;
    property MarginLeft: Integer read FMarginLeft write SetMarginLeft;
    property MarginRight: Integer read FMarginRight write SetMarginRight;
    property IconWidth: Integer read FIconWidth write SetIconWidth;
    property IconHeight: Integer read FIconHeight write SetIconHeight;
    property IconMargin: Integer read FIconMargin write SetIconMargin;
    property Align;
    property Columns;
    property DragMode;
    property DragKind;
    property Anchors;
    property BorderStyle;
    property ItemHeight;
    property MultiSelect;
    property Color;
    property Ctl3D;
    property Font;
    property Constraints;
    property OnMouseMove;
    property OnClick;
    property OnMouseUp;
    property OnMouseLeave;
  end;

procedure Register;

implementation

uses
  SysUtils, Math;

type
  (**
   * ThpItemColors
   *)
  ThpItemColors = record
    Border: TColor;
    Background: TColor;
    Font: TColor;
  end;

const
  (**
   * Default color definition
   *)
  SIZE = 21;
  TROPHY_COLOR: TColor = clYellow;

  COLOR_NORMAL: array [0 .. SIZE] of ThpItemColors = (
    (Border: clBlack;   Background: clBlack; Font: $0074D17B),        // Free
    (Border: clBlack;   Background: clBlack; Font: clYellow),         // Plus
    (Border: clYellow;  Background: clYellow; Font: clBlack),         // Celebrity
    (Border: clBlack;   Background: clBlack; Font: $00FFFF),          // Team Mplayer
    (Border: $C0C0C0;   Background: clBlack; Font: clRed),            // Mplayer Representative
    (Border: clBlack;   Background: clBlack; Font: $00F1CAA6),        // Mplayer Employee
    (Border: clBlack;   Background: clBlack; Font: $FF00FF),          // One star sage
    (Border: clBlack;   Background: clBlack; Font: $FF00FF),          // Two star sage
    (Border: clBlack;   Background: clBlack; Font: $FF00FF),          // Three star sage
    (Border: clBlack;   Background: clBlack; Font: $C0C0C0),          // EBT captain
    (Border: $FFFF00;   Background: clBlack; Font: $00FFFF),          // HearMe Volunteer
    (Border: clBlack;   Background: clBlack; Font: $FEFCFF),          // Community Leader
    (Border: clBlack;   Background: clBlack; Font: $9FD9E5),          // Wizard
    (Border: clBlack;   Background: clBlack; Font: $FF00FF),          // Sage
    (Border: clBlack;   Background: clBlack; Font: $9FD9E5),          // One Star wizard
    (Border: clBlack;   Background: clBlack; Font: $9FD9E5),          // Two Star wizard
    (Border: clBlack;   Background: clBlack; Font: $9FD9E5),          // Three Star wizard
    (Border: $8F8F8F;   Background: clBlack; Font: $FF00FF),          // Mplayer Tech
    (Border: $E2EC47;   Background: clBlack; Font: clRed),            // Mplayer GameGod
    (Border: clBlack;   Background: clBlack; Font: clWhite),          // Even Host
    (Border: $00FFF9F3; Background: clBlack; Font: clWhite),          // Even Host Coordinator
    (Border: clBlack;   Background: clBlack; Font: clInactiveBorder)  // Developer
  );

  COLOR_SELECTED: array [0 .. SIZE] of ThpItemColors = (
    (Border: clBlack;   Background: clNavy;  Font: $0074D17B),        // Free
    (Border: clBlack;   Background: clNavy;  Font: clYellow),         // Plus
    (Border: clBlack;   Background: clYellow;  Font: clBlack),        // Celebrity
    (Border: clBlack;   Background: clNavy;  Font: $00FFFF),          // Team Mplayer
    (Border: $C0C0C0;   Background: clNavy;  Font: clRed),            // Mplayer Representative
    (Border: clWhite;   Background: clNavy;  Font: $00F1CAA6),        // Mplayer Employee
    (Border: clBlack;   Background: clNavy;  Font: $FF00FF),          // One star sage
    (Border: clBlack;   Background: clNavy;  Font: $FF00FF),          // Two star sage
    (Border: clBlack;   Background: clNavy;  Font: $FF00FF),          // Three star sage
    (Border: clBlack;   Background: clNavy;  Font: $C0C0C0),          // EBT captain
    (Border: $FFFF00;   Background: clNavy;  Font: $00FFFF),          // HearMe Volunteer
    (Border: clBlack;   Background: clNavy;  Font: $FEFCFF),          // Community Leader
    (Border: clBlack;   Background: clNavy;  Font: $9FD9E5),          // Wizard
    (Border: clBlack;   Background: clNavy;  Font: $FF00FF),          // Sage
    (Border: clBlack;   Background: clNavy;  Font: $9FD9E5),          // One Star wizard
    (Border: clBlack;   Background: clNavy;  Font: $9FD9E5),          // Two Star wizard
    (Border: clBlack;   Background: clNavy;  Font: $9FD9E5),          // Three Star wizard
    (Border: $8F8F8F;   Background: clNavy;  Font: $FF00FF),          // Mplayer Tech
    (Border: $E2EC47;   Background: clNavy;  Font: clRed),            // Mplayer GameGod
    (Border: clBlack;   Background: clNavy;  Font: clWhite),          // Even Host
    (Border: $00FFF9F3; Background: clNavy;  Font: clWhite),          // Even Host Coordinator
    (Border: clBlack;   Background: clNavy;  Font: clInactiveBorder)  // Developer
  );

(**
 * Register into the component palette
 *)
procedure Register;
begin
  RegisterComponents('hpVCL', [ThpChatListBox]);
end;

(**
 * ChatSort custom sorts the stringlist containing the member items
 *)

(**
  My Sort order for names as follows

  Volunteer staff members
  Sages/wizard
  5 three star
  6 two star
  7 one star
**)

function ChatSort(AList: TStringList; AIndex1, AIndex2: Integer): Integer;
const
  USERLEVEL_TO_ORDER: array [0 .. SIZE] of Integer = (
    20,  //  0 Free *20
    10,  //  1 Plus *12
     9,  //  2 Celebrity *8
     9,  //  3 Team Mplayer *10
     1,  //  4 Mplayer Representative *6
     0,  //  5 Mplayer Employee *6
     6,  //  6 One Star Sage *6
     5,  //  7 Two Star Sage *6
     4,  //  8 Three Star Sage *5
     9,  //  9 EBT Captain *5
     3,  // 10 HearMe Volunteer *5
     9,  // 11 Community Leader *5
     7,  // 12 Wizard * 12
     7,  // 13 Sage *12
     6,  // 14 One Star Wizard *6
     5,  // 15 Two Star Wizard *4
     4,  // 16 Three Star Wizard *3
     2,  // 17 Mplayer Tech *2
     4,  // 18 Mplayer GameGod *1
     8,  // 19 Even Host *7
     2,  // 20 Even Host Coordinator *0
    20); // 21 Developer *11
var
  uli1, uli2: ThpChatListItem;
begin
  Result := 0;
  if AIndex1 <> AIndex2 then begin
    uli1 := ThpChatListItem(AList.Objects[AIndex1]);
    uli2 := ThpChatListItem(AList.Objects[AIndex2]);

    { Check AFK separator and AFK }
    {if uli1.Afk and uli2.FIsAfkSeparator then
      Result := 1
    else if uli2.Afk and uli1.FIsAfkSeparator then
      Result := -1
    else if (not uli1.Afk) and uli2.FIsAfkSeparator then
      Result := -1
    else if (not uli2.Afk) and uli1.FIsAfkSeparator then
      Result := 1
    else if uli1.Afk and not uli2.Afk then
      Result := 1
    else if uli2.Afk and not uli1.Afk then
      Result := -1
    { Check community leader
    else } if uli1.FCommunityLeader and not uli2.FCommunityLeader then
      Result := -1
    else if uli2.FCommunityLeader and not uli1.FCommunityLeader then
      Result := 1
    { Check moderator }
    else if uli1.FModerator and not uli2.FModerator then
      Result := -1
    else if uli2.FModerator and not uli1.FModerator then
      Result := 1
    { Check co moderator }
    else if uli1.FCoModerator and not uli2.FCoModerator then
      Result := -1
    else if uli2.FCoModerator and not uli1.FCoModerator then
      Result := 1
    { Check voice }
    else if uli1.FVoice and not uli2.FVoice then
      Result := -1
    else if uli2.FVoice and not uli1.FVoice then
      Result := 1;

    { Compare userlevel order }
    if Result = 0 then begin
      if USERLEVEL_TO_ORDER[uli1.FUserLevel] < USERLEVEL_TO_ORDER[uli2.FUserLevel] then
        Result := -1
      else if USERLEVEL_TO_ORDER[uli1.FUserLevel] > USERLEVEL_TO_ORDER[uli2.FUserLevel] then
        Result := 1;
    end;

    { Compare username }
    if Result = 0 then
      Result := AnsiCompareText(AList[AIndex1], AList[AIndex2]);
  end;
end;

{ ThpChatListItem }

procedure ThpChatListItem.UpdateParent;
begin
  if FParent <> nil then begin
    FParent.FSorted := False;
    FParent.Invalidate;
  end;
end;

procedure ThpChatListItem.SetUserLevel(AValue: Integer);
begin
  if AValue <> FUserLevel then begin
    FUserLevel := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetCommunityLeader(AValue: Boolean);
begin
  if AValue <> FCommunityLeader then begin
    FCommunityLeader := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetAfk(AValue: Boolean);
begin
  if AValue <> FAfk then begin
    FAfk := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetModerator(AValue: Boolean);
begin
  if AValue <> FModerator then begin
    FModerator := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetCoModerator(AValue: Boolean);
begin
  if AValue <> FCoModerator then begin
    FCoModerator := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetUnlimited(AValue: Boolean);
begin
  if AValue <> FUnlimited then begin
    FUnlimited := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetDownload(AValue: Boolean);
begin
  if AValue <> FDownload then begin
    FDownload := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetOk(AValue: Boolean);
begin
  if AValue <> FOk then begin
    FOk := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetGaming(AValue: Boolean);
begin
  if AValue <> FGaming then begin
    FGaming := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetRanked(AValue: Boolean);
begin
  if AValue <> FRanked then begin
    FRanked := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetGoodlatency(AValue: Boolean);
begin
  if AValue <> FGoodlatency then begin
    FGoodlatency := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetHighlatency(AValue: Boolean);
begin
  if AValue <> FHighlatency then begin
    FHighlatency := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetMeasuring(AValue: Boolean);
begin
  if AValue <> FMeasuring then begin
    FMeasuring := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetPlaying(const Value: Boolean);
begin
  FPlaying := Value;
end;

procedure ThpChatListItem.SetTrophy(AValue: Boolean);
begin
  if AValue <> FTrophy then begin
    FTrophy := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetVideo(AValue: Boolean);
begin
  if AValue <> FVideo then begin
    FVideo := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetVoice(AValue: Boolean);
begin
  if AValue <> FVoice then begin
    FVoice := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetTextColor(AValue: TColor);
begin
  if AValue <> FTextColor then begin
    FTextColor := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetBorderColor(AValue: TColor);
begin
  if AValue <> FBorderColor then begin
    FBorderColor := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetCustomColor(AValue: Boolean);
begin
  if AValue <> FCustomColor then begin
    FCustomColor := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetIsBlocked(AValue: Boolean);
begin
  if AValue <> FIsBlocked then begin
    FIsBlocked := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetCustomIconIndex(AValue: Integer);
begin
  if AValue <> FCustomIconIndex then begin
    FCustomIconIndex := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetCustomBIconIndex(AValue: Integer);
begin
  if AValue <> FCustomBIconIndex then begin
    FCustomBIconIndex := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetTavlaWinIndex(AValue: Integer);
begin
  if AValue <> FTavlaWinIndex then begin
    FTavlaWinIndex := AValue;
    UpdateParent;
  end;
end;

procedure ThpChatListItem.SetBatakWinIndex(AValue: Integer);
begin
  if AValue <> FBatakWinIndex then begin
    FBatakWinIndex := AValue;
    UpdateParent;
  end;
end;

function ThpChatListItem.IsOverName(X: Integer): Boolean;
var
  left, right: Integer;
  width, nameWidth: Integer;
begin
  Result := False;
  if (csDestroying in ComponentState) or FIsAfkSeparator then
    Exit;

  left := FParent.FMarginLeft + FParent.FIconMargin;
  width := FParent.FIconWidth + FParent.FIconMargin;

  if FParent.FPaintMode = pmLegacy then begin
    if FAfk or FOk then
      Inc(left, width);

    if FVoice then
      Inc(left, width);

    if FVideo then
      Inc(left, width);

    if FModerator then
      Inc(left, width);

    if FCoModerator then
      Inc(left, width);

    if FUnlimited then
      Inc(left, width);

    if FGoodlatency then
      Inc(left, width);

    if FGaming then
      Inc(left, width);

    if FRanked then
      Inc(left, width);

    if FHighlatency then
      Inc(left, width);

    if FMeasuring then
      Inc(left, width);

    if FCommunityLeader then
      Inc(left, width);

    if FTrophy or ((FUserLevel > 0) and (FParent.FImageList <> nil)) then
      Inc(left, width);

    if FDownload then
      Inc(left, width);
  end
  else if FParent.FPaintMode = pmTwoIcons then begin
    Inc(left, 2 * width);
  end;

  nameWidth := FParent.Canvas.TextWidth(FName);
  if  (FTrophy) or ((COLOR_NORMAL[FUserLevel].Border <> COLOR_NORMAL[FUserLevel].Background) or (FUserLevel = 2) and not FCustomColor) or
      ((FBorderColor <> COLOR_NORMAL[FUserLevel].Background) and FCustomColor) then begin
    right := FParent.ClientWidth - FParent.FMarginRight - FParent.FIconMargin;
    Inc(left, (right - left - nameWidth) div 2);
  end;

  right := left + nameWidth;
  Result := (X >= left) and (X <= right);
end;

(* ThpChatListBox *)

(**
 * constructor
 *)
constructor ThpChatListBox.Create(AOwner: TComponent);
begin
  inherited;
  Style := lbOwnerDrawFixed;
  ItemHeight := 24;
  FSorted := True;
  FMarginLeft := 5;
  FMarginRight := 35;
  FIconWidth := 16;
  FIconHeight := 16;
  FIconMargin := 2;
  FHasAfkSeparator := False;
  FPaintMode := pmTwoIcons;
end;

(**
 * GetItem returns the item at position AIndex
 *
 * @param  AIndex Integer  Item position
 * @return ThpChatListItem Item at position AIndex, or nil
 *)
function ThpChatListBox.GetItem(AIndex: Integer): ThpChatListItem;
begin
  if (AIndex > -1) and (AIndex < Items.Count) then
    Result := ThpChatListItem(Items.Objects[AIndex])
  else
    Result := nil;
end;

(**
 * CNDrawItem (overridden) draws the item and it's selected color and border
 *
 * @param Message TWMDrawItem
 *)
procedure ThpChatListBox.CNDrawItem(var Message: TWMDrawItem);
var
  State: TOwnerDrawState;
  idx: Integer;
  li: ThpChatListItem;
begin
  if csDestroying in ComponentState then
    Exit;

  with Message.DrawItemStruct^ do begin
    li := ListItems[itemID];
    if (li <> nil) and li.FIsAfkSeparator then
      Exit;

    Inc(rcItem.Left, FMarginLeft);
    Dec(rcItem.Right, FMarginRight);

    if li <> nil then
      idx := Min(SIZE, Max(0, li.FUserLevel))
    else
      idx := 0;

    State := TOwnerDrawState(LongRec(itemState).Lo);
    Canvas.Handle := hDC;
    Canvas.Font := Font;
    Canvas.Brush := Brush;

    Canvas.Brush.Color := COLOR_NORMAL[idx].Background;
    Canvas.Font.Color := COLOR_NORMAL[idx].Font;

    if (Integer(itemID) >= 0) and (odSelected in State) then
    begin
      Canvas.Pen.Color := COLOR_SELECTED[idx].Background;
      Canvas.Font.Color := COLOR_SELECTED[idx].Font;
    end;

    if (li <> nil) and li.FCustomColor then
      Canvas.Font.Color := li.FTextColor;

    if Integer(itemID) >= 0 then
      DrawItem(itemID, rcItem, State)
    else
      Canvas.FillRect(rcItem);

    Canvas.Handle := 0;
  end;
end;

(**
 * GetCount returns the number of items in the list
 *)
function ThpChatListBox.GetCount: Integer;
begin
  Result := inherited GetCount;
  if FHasAfkSeparator then
    Result := Result - 1;
end;

(**
 * AddItem adds a new item to the list and returns the reference
 *
 * @param  AName string    Name of the new item
 * @return ThpChatListItem Reference to the newly created item
 *)
function ThpChatListBox.AddItem(const AName: string): ThpChatListItem;
var
  obj: ThpChatListItem;
begin
  obj := GetItem(Items.IndexOf(AName));
  if obj = nil then begin
    obj := ThpChatListItem.Create(Self);
    obj.FParent := Self;
    obj.FName := AName;
    obj.FCustomColor := False;
    obj.CustomIconIndex := -1;
    Items.AddObject(AName, obj);
    obj.UpdateParent;
  end;
  Result := obj;
end;

(**
 * AddItem (overloaded) adds a new item with custom colors to the list and returns the reference
 *
 * @param  AName        string    Name of the new item
 * @param  ATextColor   TColor    Custom text color
 * @param  ABorderColor TColor    Custom border color
 * @return ThpChatListItem        Reference to the newly created item
 *)
function ThpChatListBox.AddItem(const AName: string; ATextColor, ABorderColor: TColor): ThpChatListItem;
var
  obj: ThpChatListItem;
begin
  obj := AddItem(AName);
  obj.FTextColor := ATextColor;
  obj.FBorderColor := ABorderColor;
  obj.FCustomColor := True;
  obj.UpdateParent;
  Result := obj;
end;

(**
 * DeleteItem deletes an item from the list
 *
 * @param  AName string  Name of the item
 *)
procedure ThpChatListBox.DeleteItem(const AName: string);
var
  i: Integer;
begin
  i := Items.IndexOf(AName);
  if i > -1 then begin
    Items.Objects[i].Free;
    Items.Delete(i);
  end;
end;

(**
 * DrawItem (overridden) draws item at position Index and draw state State
 * within Rect. The paint mode determines how the items are drawn.
 *
 * @param Index Integer         Item position
 * @param Rect  TRect           Draw area
 * @param State TOwnerDrawState Draw state
 *)
procedure ThpChatListBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  bmp: TBitmap;
  width, top: Integer;
  prev: TColor;
  mode: Longint;
  textRect, borderRect: TRect;
begin
  if (csDestroying in ComponentState) {or ListItems[Index].FIsAfkSeparator} then
    Exit;

  if FImageList <> nil then begin
    prev := FImageList.BkColor;
    FImageList.BkColor := Color;
  end
  else
    prev := clBlack;

  width := FIconWidth + FIconMargin;
  top := Rect.Top + (ItemHeight - FIconHeight) div 2;
  if Index < Items.Count then begin
    if FImageList <> nil then begin
      bmp := TBitmap.Create;
      try
        if FPaintMode = pmLegacy then begin
          if ThpChatListItem(Items.Objects[Index]).FAfk then begin
            FImageList.GetBitmap(24, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end
          else if ThpChatListItem(Items.Objects[Index]).FOk then begin
            FImageList.GetBitmap(28, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end;

          if ThpChatListItem(Items.Objects[Index]).FCommunityLeader then begin
            FImageList.GetBitmap(11, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end;

          if ThpChatListItem(Items.Objects[Index]).FModerator then begin
            FImageList.GetBitmap(29, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end;

          if ThpChatListItem(Items.Objects[Index]).FCoModerator then begin
            FImageList.GetBitmap(42, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end;

          if ThpChatListItem(Items.Objects[Index]).FVideo then begin
            FImageList.GetBitmap(40, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end;

          if ThpChatListItem(Items.Objects[Index]).FUnlimited then begin
            FImageList.GetBitmap(26, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end;

          if ThpChatListItem(Items.Objects[Index]).FDownload then begin
            FImageList.GetBitmap(25, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end;

          if ThpChatListItem(Items.Objects[Index]).FGoodlatency then begin
            FImageList.GetBitmap(27, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end;

          if ThpChatListItem(Items.Objects[Index]).FHighlatency then begin
            FImageList.GetBitmap(31, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end;

          if ThpChatListItem(Items.Objects[Index]).FMeasuring then begin
            FImageList.GetBitmap(36, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end;

          if ThpChatListItem(Items.Objects[Index]).FGaming then begin
            FImageList.GetBitmap(30, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end;

          if ThpChatListItem(Items.Objects[Index]).FRanked then begin
            FImageList.GetBitmap(21, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end;

          if ThpChatListItem(Items.Objects[Index]).FTrophy then begin
            FImageList.GetBitmap(40, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end
          else if ThpChatListItem(Items.Objects[Index]).FUserLevel > 0 then begin
            FImageList.GetBitmap(ThpChatListItem(Items.Objects[Index]).FUserLevel, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
            Inc(Rect.Left, width);
          end;
        end
        else if FPaintMode = pmTwoIcons then begin

          { Moderator icon in column 1 }
          {if ThpChatListItem(Items.Objects[Index]).FCommunityLeader then begin
            FImageList.GetBitmap(11, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else}if ThpChatListItem(Items.Objects[Index]).FModerator then begin
            FImageList.GetBitmap(29, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if ThpChatListItem(Items.Objects[Index]).FCoModerator then begin
            FImageList.GetBitmap(42, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          {else if ThpChatListItem(Items.Objects[Index]).FDownload then begin
            FImageList.GetBitmap(25, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end}
          else if ThpChatListItem(Items.Objects[Index]).FOk then begin
            FImageList.GetBitmap(28, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if ThpChatListItem(Items.Objects[Index]).FGaming then begin
            FImageList.GetBitmap(30, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if ThpChatListItem(Items.Objects[Index]).FRanked then begin
            FImageList.GetBitmap(21, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if ThpChatListItem(Items.Objects[Index]).FGoodlatency then begin
            FImageList.GetBitmap(31, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if ThpChatListItem(Items.Objects[Index]).FHighlatency then begin
            FImageList.GetBitmap(27, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if ThpChatListItem(Items.Objects[Index]).FMeasuring then begin
            FImageList.GetBitmap(36, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if ThpChatListItem(Items.Objects[Index]).FVideo then begin
            FImageList.GetBitmap(40, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end;
          Inc(Rect.Left, width);

          { User information icons in column 2 }

          if ThpChatListItem(Items.Objects[Index]).FCommunityLeader then begin
            FImageList.GetBitmap(11, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if ThpChatListItem(Items.Objects[Index]).FAfk then begin
            FImageList.GetBitmap(24, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if ThpChatListItem(Items.Objects[Index]).FVoice then begin
            FImageList.GetBitmap(26, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if ThpChatListItem(Items.Objects[Index]).FDownload then begin
            FImageList.GetBitmap(25, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if ThpChatListItem(Items.Objects[Index]).FIsBlocked then begin
            FImageList.GetBitmap(41, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if ThpChatListItem(Items.Objects[Index]).FTrophy then begin
            FImageList.GetBitmap(40, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if ThpChatListItem(Items.Objects[Index]).FUnlimited then begin
            FImageList.GetBitmap(26, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if (ThpChatListItem(Items.Objects[Index]).FCustomIconIndex > -1) and
              (FCustomImageList <> nil) and
              (ThpChatListItem(Items.Objects[Index]).FCustomIconIndex < FCustomImageList.Count) then begin
            FCustomImageList.GetBitmap(ThpChatListItem(Items.Objects[Index]).FCustomIconIndex, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end
          else if ThpChatListItem(Items.Objects[Index]).FUserLevel > 0 then begin
            FImageList.GetBitmap(ThpChatListItem(Items.Objects[Index]).FUserLevel, bmp);
            Canvas.Draw(Rect.Left, top, bmp);
          end;
          Inc(Rect.Left, width);
        end;
      finally
        bmp.Free;
      end;
    end;

    borderRect := Rect;
    Inc(borderRect.Top);
    Dec(borderRect.Bottom);

    mode := DT_LEFT;
    with ThpChatListItem(Items.Objects[Index]) do begin
      if odFocused in State then begin
        Canvas.Brush.Color := COLOR_SELECTED[FUserLevel].Background;
        Canvas.Brush.Style := bsSolid;
      end;
      Canvas.FillRect(Rect);

      if FCustomColor then begin
        Canvas.Pen.Color := FBorderColor;
        Canvas.Brush.Style := bsClear;
        Canvas.Rectangle(borderRect);
        if FBorderColor <> COLOR_NORMAL[FUserLevel].Background then
          mode := DT_CENTER;
      end
      else if FTrophy then begin
        Canvas.Brush.Color := clYellow;
        Canvas.Pen.Color := TROPHY_COLOR;
        Canvas.Font.Color := clBlack;
        Canvas.Brush.Style := bsSolid;
        Canvas.Rectangle(borderRect);
        mode := DT_CENTER;
      end
      else if (COLOR_NORMAL[FUserLevel].Background = clYellow) then
      begin
        Canvas.Pen.Color := COLOR_NORMAL[FUserLevel].Border;
        Canvas.Brush.Style := bsClear;
        Canvas.Rectangle(borderRect);
        mode := DT_CENTER;
      end
      else if COLOR_NORMAL[FUserLevel].Border <> COLOR_NORMAL[FUserLevel].Background then begin
        Canvas.Pen.Color := COLOR_NORMAL[FUserLevel].Border;
        Canvas.Brush.Style := bsClear;
        Canvas.Rectangle(borderRect);
        mode := DT_CENTER;
      end;
    end;

    textRect := Rect;
    Inc(textRect.Left, FIconMargin);
    Dec(textRect.Right, FIconMargin);
    DrawText(Canvas.Handle, PChar(Items[Index]), Length(Items[Index]), textRect,
      DT_SINGLELINE or DT_VCENTER or mode);

    if odFocused in State then
      DrawFocusRect(Canvas.Handle, borderRect);
  end;

  if FImageList <> nil then
    FImageList.BkColor := prev;
end;

(**
 * Sort custom sorts all user items
 *)
procedure ThpChatListBox.Sort;
var
  sl: TStringList;
  user: string;
begin
  // REMOVED DUE TO MPLAYER NOT NEEDING IT BUT MAY BE REENABLED FOR OTHER PROJECTS.
  {if not FHasAfkSeparator then begin
    with AddItem('') do
      FIsAfkSeparator := True;

    FHasAfkSeparator := True;
  end;}

  if ItemIndex > -1 then
    user := Items[ItemIndex]
  else
    user := '';

  sl := TStringList.Create;
  try
    sl.Assign(Items);
    sl.CustomSort(ChatSort);
    Items.Assign(sl);
  finally
    sl.Free;
  end;

  if user > '' then
    ItemIndex := Items.IndexOf(user);
end;

(**
 * Clear clears the list of it's items
 *)
procedure ThpChatListBox.Clear;
begin
  inherited Clear;
  FHasAfkSeparator := False;
end;

(**
 * WMPaint checks the sort before painting
 *
 * @param  Message  TWMPaint  The message contents
 *)
procedure ThpChatListBox.WMPaint(var Message: TWMPaint);
begin
  if csDestroying in ComponentState then
    Exit;

  if not FSorted then begin
    FSorted := True;
    Sort;
  end;

  inherited;
end;

(**
 * SetMarginLeft sets the left margin of the items
 *
 * @param  AValue  Integer  Left margin in pixels
 *)
procedure ThpChatListBox.SetMarginLeft(AValue: Integer);
begin
  if FMarginLeft <> AValue then begin
    FMarginLeft := AValue;
    Invalidate;
  end;
end;

(**
 * SetMarginRight sets the right margin of the items
 *
 * @param  AValue  Integer  Right margin in pixels
 *)
procedure ThpChatListBox.SetMarginRight(AValue: Integer);
begin
  if FMarginRight <> AValue then begin
    FMarginRight := AValue;
    Invalidate;
  end;
end;

(**
 * SetIconHeight sets the height of the icons
 *
 * @param  AValue  Integer  Icon height in pixels
 *)
procedure ThpChatListBox.SetIconHeight(AValue: Integer);
begin
  if FIconHeight <> AValue then begin
    IconHeight := AValue;
    Invalidate;
  end;
end;

(**
 * SetIconMargin sets the spacing between the icons
 *
 * @param  AValue  Integer  Icon margin in pixels
 *)
procedure ThpChatListBox.SetIconMargin(AValue: Integer);
begin
  if FIconMargin <> AValue then begin
    FIconMargin := AValue;
    Invalidate;
  end;
end;

(**
 * SetIconWidth set the width of the icons
 *
 * @param  AValue  Integer  Icon width in pixels
 *)
procedure ThpChatListBox.SetIconWidth(AValue: Integer);
begin
  if FIconWidth <> AValue then begin
    FIconWidth := AValue;
    Invalidate;
  end;
end;

end.
