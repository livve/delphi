unit hpRichEdit;

(**
 * @copyright Copyright (C) 2010-2013, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  VCL
 * @package   hpRichEdit
 * @version   1.04
 *)

(**
 * History
 *
 * 1.05       30/08/2010
 *            Added additional procedure to handle room adverts and settings.
 *
 * 1.04       2010-04-27
 *            Added system message font and function
 *
 * 1.03       2010-03-14
 *            Missing line feed
 *            Added comments
 *
 * 1.02       2010-03-12
 *            Added additional space around smiley
 *
 * 1.01       2010-03-06
 *            Added fail-safe to AddSmiley
 *            Moved AddNotice to public
 *            Replaced mid with Copy
 *            Copied InStr to remove the PubUnit dependency
 *            Some code cleaning
 *
 * 1.00       2010-03-04
 *            Initial implementation
 *)

interface

uses
  Windows, Messages, SysUtils, Classes, Dialogs, Graphics, Controls, JvRichEdit;

type
  (**
   * ThpRichEdit interface
   *)
  ThpRichEdit = class(TJvRichEdit)
  protected
    FEmoticons: TStringList;
    FSmileys: TImageList;
    FSystemFont: TFont;
    procedure SetEmoticons(const AValue: string);
    procedure AddSmiley(AIndex: Integer);
    procedure AddText(const AText: string; AUseCrLf: Boolean); overload;
  published
    (* reference to an existing ImageList *)
    property Smileys: TImageList read FSmileys write FSmileys;
    (* path and/or filename to the emotes.dat *)
    property Emoticons: string write SetEmoticons;
    (* font for system messages *)
    property SystemFont: TFont read FSystemFont write FSystemFont;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ResetAttributes;
    procedure AddText(const AText: string); overload;
    function GetCommand: string;
    procedure AddNotice(const AText: string);
    procedure AddRoomNotice(const AText: string);
    procedure AddHelpMenu(const AText: string);
    procedure AddRoomAd(const AText: string);
    procedure AddSystemMessage(const AText: string);
    procedure AddMsgHeader(const AText: string);
    procedure AddMsgLocation(const AText: string);
    procedure AddMsgInfo(const AText: string);
    procedure AddHeaderTime(const AText: string);
  end;

procedure Register;

implementation

(**
 * Moved here from PubUnit to remove the dependency
 *)
function InStr(AStart: integer; const AText: string; const AFind: string): Integer;
begin
  Result := Pos(AFind, Copy(AText, AStart));
  if Result <> 0 then
     Result := Result + (AStart - 1);
end;

(**
 * ThpRichEdit implementation
 *)

(**
 * Constructor
 *)
constructor ThpRichEdit.Create(AOwner: TComponent);
begin
  inherited;
  FEmoticons := TStringList.Create;
  FSystemFont := TFont.Create;
end;

(**
 * Destructor
 *)
destructor ThpRichEdit.Destroy;
begin
  FEmoticons.Clear;
  FEmoticons.Free;
  FSystemFont.Free;
  inherited;
end;

(**
 * Load the emoticons data file
 *
 * @param AValue string Set the emoticons filename and load the items
 *)
procedure ThpRichEdit.SetEmoticons(const AValue: string);
begin
  FEmoticons.Clear;
  if FileExists(AValue) then
    FEmoticons.LoadFromFile(AValue);
end;

(**
 * Add a smiley to the rich edit
 *
 * @param AIndex integer Index of the smiley to add
 *)
procedure ThpRichEdit.AddSmiley(AIndex: Integer);
var
  Bitmap: TBitmap;
begin
  if (FSmileys <> nil) and (FSmileys.Count > 0) and (AIndex < FSmileys.Count) then begin
    Bitmap := TBitmap.Create;
    try
     // AddText(' ', False);
      FSmileys.GetBitmap(AIndex, Bitmap);
      InsertGraphic(Bitmap, False);
      SetSelection(GetSelection.cpMin + 1, GetSelection.cpMin + 1, False);
     // AddText(' ', False);
    finally
      Bitmap.Free;
    end;
  end;
end;

(**
 * Parse the text and add it to the RichEdit
 *
 * @param AText    string  Text to add
 * @param AUseCrlf Boolean If true, add a line feed first
 *)
procedure ThpRichEdit.AddText(const AText: string; AUseCrLf: Boolean);
var
  startpos, endpos: Integer;
  subtext: string;
begin
  if AUseCrLf then
     Lines.Add('');

  SelStart := -1;
  startpos := 1;

  while startpos <= Length(AText) do begin
    subtext := Copy(AText, startpos, 1);
    if subtext = '<' then begin
      endpos := InStr(startpos + 1, AText, '>');
      if endpos <> 0 then begin
        subtext := LowerCase(Copy(AText, startpos + 1, endpos - (startpos + 1)));
        startpos := endpos;

        if Copy(subtext, 1, 4) = 'size' then
          SelAttributes.Size := StrToInt(Copy(subtext, 5))
        else if Copy(subtext, 1, 4) = 'font' then
          SelAttributes.Name := Copy(subtext, 6)
        else if Copy(subtext, 1, 5) = 'color' then
          SelAttributes.Color := StrToInt(Copy(subtext, 7));
      end;
    end
    else begin
      endpos := InStr(startpos, AText, '<');
      if endpos = 0 then begin
        subtext := Copy(AText, startpos);
        startpos := Length(AText);
      end
      else begin
        subtext := Copy(AText, startpos, endpos - startpos);
        startpos := endpos - 1;
      end;
      SelText := subtext;
      SelStart := -1;
    end;
    Inc(startpos);
  end;

  PostMessage(Handle, WM_VSCROLL, SB_BOTTOM, 0);
end;

(**
 * Add a notice message to the RichEdit, in red
 *
 * @param AText string Notice text to add
 *)
procedure ThpRichEdit.AddNotice(const AText: string);
begin
  ResetAttributes;
  SelAttributes.Color := clRed;
  SelAttributes.Size := 9;
  AddText(AText, False);
  Lines.Add('');
  ResetAttributes;
end;

(**
 * Add a notice message to the RichEdit, in red
 *
 * @param AText string Notice text to add
 *)
procedure ThpRichEdit.AddRoomNotice(const AText: string);
begin
  ResetAttributes;
  SelAttributes.Color := clRed;
  SelAttributes.Size := 8;
  AddText(AText, True);
  Lines.Add('');
  ResetAttributes;
end;

(**
 * Add a notice message to the RichEdit, in red
 *
 * @param AText string Notice text to add
 *)
procedure ThpRichEdit.AddHeaderTime(const AText: string);
begin
  ResetAttributes;
  SelAttributes.Style := SelAttributes.Style - [fsBold];
  SelAttributes.Color := clWhite;
  SelAttributes.Size := 9;
  AddText(AText, True);
  ResetAttributes;
end;

(**
 * Add a notice message to the RichEdit, in red
 *
 * @param AText string Notice text to add
 *)
procedure ThpRichEdit.AddMsgHeader(const AText: string);
begin
  ResetAttributes;
  SelAttributes.Style := SelAttributes.Style + [fsBold];
  SelAttributes.Color := clWhite;
  SelAttributes.Size := 17;
  AddText(AText, True);
  ResetAttributes;
end;

(**
 * Add a notice message to the RichEdit, in red
 *
 * @param AText string Notice text to add
 *)
procedure ThpRichEdit.AddMsgLocation(const AText: string);
begin
  ResetAttributes;
  SelAttributes.Style := SelAttributes.Style + [fsBold];
  SelAttributes.Color := clRed;
  SelAttributes.Size := 10;
  AddText(AText, True);
  ResetAttributes;
end;

(**
 * Add a notice message to the RichEdit, in red
 *
 * @param AText string Notice text to add
 *)
procedure ThpRichEdit.AddMsgInfo(const AText: string);
begin
  ResetAttributes;
  SelAttributes.Style := SelAttributes.Style - [fsBold];
  SelAttributes.Color := clWhite;
  SelAttributes.Size := 10;
  AddText(AText, True);
  Lines.Add('');
  ResetAttributes;
end;

(**
 * Add a notice message to the RichEdit, in red
 *
 * @param AText string Notice text to add
 *)
procedure ThpRichEdit.AddHelpMenu(const AText: string);
begin
  ResetAttributes;
  SelAttributes.Color := clWhite;
  SelAttributes.Size := 9;
  AddText(AText, True);
  Lines.Add('');
  ResetAttributes;
end;

(**
 * Add a notice message to the RichEdit, in red
 *
 * @param AText string Notice text to add
 *)
procedure ThpRichEdit.AddRoomAd(const AText: string);
begin
  ResetAttributes;
  SelAttributes.Color := clYellow;
  SelAttributes.Size := 9;
  AddText(AText, True);
  Lines.Add('');
  Lines.Add('');
  ResetAttributes;
end;

(**
 * Add a notice message to the RichEdit, in red
 *
 * @param AText string Notice text to add
 *)
procedure ThpRichEdit.AddSystemMessage(const AText: string);
begin
  ResetAttributes;
  Lines.Add('');
  SelAttributes.Name := FSystemFont.Name;
  SelAttributes.Color := FSystemFont.Color;
  SelAttributes.Size := FSystemFont.Size;
  AddText(AText, False);
  Lines.Add('');
  ResetAttributes;
end;

(**
 * Reset the font, color and size attributes to default
 *)
procedure ThpRichEdit.ResetAttributes;
begin
  SelAttributes.Name := 'Tahoma';
  SelAttributes.Size := 8;
  SelAttributes.Color := clwhite;
  SelAttributes.Style := SelAttributes.Style - [fsBold, fsItalic, fsStrikeout, fsUnderline];
end;

(**
 * Add text to the rich edit, parse for smiley codes
 *
 * @param AText string Unparsed text to add 
 *)
procedure ThpRichEdit.AddText(const AText: string);
var
  p: Integer;
  text, handleText, emote: string;
  index: Integer;
begin
  text := AText;
  p := Pos('|', text);
  if (FEmoticons.Count > 0) and (p > 0) then begin
    while p > 0 do begin
      handleText := Copy(text, 1, p - 1);
      text := Copy(text, p, Length(text));

      AddText(handleText, True);

      emote := Copy(text, 1, 3);
      text := Copy(text, 4, Length(text));

      if FEmoticons.IndexOf(emote) > -1 then begin
        index := StrToIntDef(Copy(emote, 2, 2), -1);
        if index > -1 then
          AddSmiley(index);
      end;

      p := Pos('|', text);
      if p = 0 then
        AddText(text, True);
    end;
  end
  else
    AddText(AText, True);
end;

(**
 * Convert the text to a command
 *
 * @return string Command text
 *)
function ThpRichEdit.GetCommand: string;
var
  n: Integer;
  iColor, iSize: Integer;
  sFont: string;
begin
if Length(text) > 0 then begin
    sFont := 'Tahoma';
    iColor := 0;
    iSize := 0;

   // for n := 1 to Length(Text) do begin
    for n := 1 to Length(Text) - 1 do begin
      SelStart := n;

      if iSize <> SelAttributes.Size then begin
        iSize := SelAttributes.Size;
        Result := Result + '<size ' + IntToStr(iSize) + '>';
      end;

      if iColor <> SelAttributes.Color then begin
        iColor := SelAttributes.Color;
        Result := Result + '<color ' + IntToStr(iColor) + '>';
      end;

      if sFont <> SelAttributes.Name then begin
        sFont := SelAttributes.Name;
        Result := Result + '<font ' + sFont + '>';
      end;

      Result := Result + Copy(Text, n, 1);
    end;
  end
  else
    Result := '';
end;

(**
 * Register into the component palette
 *)
procedure Register;
begin
  RegisterComponents('hpVCL', [ThpRichEdit]);
end;

end.
