unit hpLibrary;

(**
 * @copyright Copyright (C) 2012-2013, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Functions
 * @package   hpLibrary
 * @version   1.01
 *)

(**
 * History
 *
 * 1.01       2012-06-08
 *            Added ReplaceStrings
 *
 * 1.00       2012-04-21
 *            Initial implementation
 *)

interface

{$REGION 'Documentation'}
///	<summary>
///	  Remove all patterns from the subject.
///	</summary>
///	<param name="ASubject">
///	  String to be modified.
///	</param>
///	<param name="APatterns">
///	  Sub-strings to be removed.
///	</param>
///	<example>
///	  // remove all CR and LF from newString <br />newString :=
///	  RemoveStrings(oldString, [#13, #10]);
///	</example>
{$ENDREGION}
function RemoveStrings(const ASubject: string;
  const APatterns: array of string): string;

{$REGION 'Documentation'}
///	<summary>
///	  Replace all patterns in the subject.
///	</summary>
///	<param name="ASubject">
///	  String to be modified.
///	</param>
///	<param name="APatterns">
///	  Sub-strings to be replaced.
///	</param>
///	<param name="AReplacement">
///	  Replacement string.
///	</param>
///	<example>
///	  // replace all CRLF in newString with &lt;br/&gt;<br />newString :=
///	  ReplaceStrings(oldString, [#13#10], '&lt;br/&gt;');
///	</example>
{$ENDREGION}
function ReplaceStrings(const ASubject: string;
  const APatterns: array of string; const AReplacement: string): string;

implementation

uses
  System.SysUtils;

function RemoveStrings(const ASubject: string;
  const APatterns: array of string): string;
begin
  Result := ReplaceStrings(ASubject, APatterns, '');
end;

function ReplaceStrings(const ASubject: string;
  const APatterns: array of string; const AReplacement: string): string;
var
  i: Integer;
begin
  Result := ASubject;
  for i := Low(APatterns) to High(APatterns) do
    Result := StringReplace(Result, APatterns[i], AReplacement,
      [rfIgnoreCase, rfReplaceAll]);
end;

end.
