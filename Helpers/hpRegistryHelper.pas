unit hpRegistryHelper;

(**
 * @copyright Copyright (C) 2015, Hans Pollaerts
 * @author    Hans Pollaerts <pritaeas@gmail.com>
 * @category  Helpers
 * @package   hpRegistryHelper
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
  Classes;

type
  ThpRegistryHelper = class
  private
    FData: TStringList;
    FRootKey: string;
  public
    constructor Create(const ARootKey: string); virtual;
    destructor Destroy; override;
    procedure Add(const AKey, AValue: string); virtual;
    procedure Delete(const AKey: string); virtual;
    procedure GetKeys(AStrings: TStrings); virtual;
    function GetValue(const AKey: string): string; virtual;
  end;

implementation

uses
  Registry, SysUtils, Windows;

const
  KeyValueFormat = '%s%s%s';

(* ThpRegistryHelper *)

constructor ThpRegistryHelper.Create(const ARootKey: string);
var
  i: Integer;
  registry: TRegistry;
  sl: TStringList;
begin
  FData := TStringList.Create;
  FData.NameValueSeparator := '=';
  FRootKey := ARootKey;

  registry := TRegistry.Create(KEY_READ);
  registry.RootKey := HKEY_CURRENT_USER;

  sl := TStringList.Create;

  if registry.OpenKey(FRootKey, False) then begin
    registry.GetValueNames(sl);

    for i := 0 to sl.Count - 1 do
      FData.Add(Format(KeyValueFormat, [sl[i], FData.NameValueSeparator,
        registry.ReadString(sl[i])]));

    registry.CloseKey;
  end;

  registry.Free;
end;

destructor ThpRegistryHelper.Destroy;
begin
  FData.Clear;
  FData.Free;
  inherited;
end;

procedure ThpRegistryHelper.Add(const AKey, AValue: string);
var
  registry: TRegistry;
begin
  registry := TRegistry.Create(KEY_READ or KEY_WRITE);
  registry.RootKey := HKEY_CURRENT_USER;

  if registry.OpenKey(FRootKey, True) then begin
    registry.WriteString(AKey, AValue);
    registry.CloseKey;
  end;

  registry.Free;
  FData.Add(Format(KeyValueFormat, [AKey, FData.NameValueSeparator, AValue]));
end;

procedure ThpRegistryHelper.Delete(const AKey: string);
var
  i: Integer;
  registry: TRegistry;
begin
  registry := TRegistry.Create(KEY_READ or KEY_WRITE);
  registry.RootKey := HKEY_CURRENT_USER;

  if registry.OpenKey(FRootKey, False) then begin
    registry.DeleteValue(AKey);
    registry.CloseKey;
  end;

  registry.Free;
  for i := FData.Count - 1 downto 0 do
    if Pos(FData[i], Format(KeyValueFormat, [AKey, FData.NameValueSeparator, ''])) = 0 then
      FData.Delete(i);
end;

procedure ThpRegistryHelper.GetKeys(AStrings: TStrings);
var
  i: Integer;
begin
  for i := 0 to FData.Count - 1 do
    AStrings.Add(FData.Names[i]);
end;

function ThpRegistryHelper.GetValue(const AKey: string): string;
begin
  Result := FData.Values[AKey];
end;

end.
