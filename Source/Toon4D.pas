{*******************************************************}
{                                                       }
{         Toon4D Library - LLM Data Optimization        }
{                                                       }
{     Copyright(c) 2025 Marco Geuze - GDK Software      }
{              All rights reserved                      }
{                                                       }
{              Licensed under MIT License               }
{                                                       }
{*******************************************************}
unit Toon4D;

interface

uses
  System.SysUtils,
  System.JSON,
  Toon4D.Types;

type
  TToon = class sealed
  private
    class function GetDefaultOptions: TToonOptions; static;
  public
    class function JsonToToon(
      JsonValue: TJSONValue;
      Options: TToonOptions = []
    ): string; overload; static;

    class function JsonToToon(
      const JsonString: string;
      Options: TToonOptions = []
    ): string; overload; static;

    class function Validate(
      const ToonString: string;
      out ErrorMessage: string
    ): Boolean; static;

    class function GetLibraryVersion: string; static;
  end;

implementation

uses
  Toon4D.Utils,
  Toon4D.Consts;

class function TToon.GetDefaultOptions: TToonOptions;
begin
  Result := [
    TToonOption.Indent2Spaces,
    TToonOption.DelimiterComma,
    TToonOption.KeyFoldingSafe,
    TToonOption.PreferTabular
  ];
end;

class function TToon.JsonToToon(
  JsonValue: TJSONValue;
  Options: TToonOptions
): string;
begin
  if JsonValue = nil then
    raise EToonInvalidJsonException.Create(ErrorNilJsonValue);

  var ActualOptions := Options;
  if ActualOptions = [] then
    ActualOptions := GetDefaultOptions;

  if JsonValue is TJSONNumber then
  begin
    Result := NormalizeNumber(JsonValue as TJSONNumber);
    Exit;
  end;

  if JsonValue is TJSONString then
  begin
    var StringValue := (JsonValue as TJSONString).Value;
    var Delimiter := ',';

    if NeedsQuoting(StringValue, Delimiter) then
      Result := '"' + EscapeString(StringValue) + '"'
    else
      Result := StringValue;
    Exit;
  end;

  if JsonValue is TJSONBool then
  begin
    if (JsonValue as TJSONBool).AsBoolean then
      Result := 'true'
    else
      Result := 'false';
    Exit;
  end;

  if JsonValue is TJSONNull then
  begin
    Result := 'null';
    Exit;
  end;

  raise EToonEncodingException.Create('Not implemented yet');
end;

class function TToon.JsonToToon(
  const JsonString: string;
  Options: TToonOptions
): string;
begin
  var JsonValue := TJSONObject.ParseJSONValue(JsonString);
  if JsonValue = nil then
    raise EToonInvalidJsonException.CreateFmt(ErrorInvalidJson, [JsonString]);

  try
    Result := JsonToToon(JsonValue, Options);
  finally
    JsonValue.Free;
  end;
end;

class function TToon.Validate(
  const ToonString: string;
  out ErrorMessage: string
): Boolean;
begin
  Result := False;
  ErrorMessage := 'Not implemented yet';
end;

class function TToon.GetLibraryVersion: string;
begin
  Result := '1.0.0';
end;

end.
