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
    class function EncodeObject(JsonObject: TJSONObject; Options: TToonOptions; IndentLevel: Integer): string; static;
    class function EncodePrimitive(JsonValue: TJSONValue; Options: TToonOptions): string; static;
    class function GetIndent(Options: TToonOptions; Level: Integer): string; static;
    class function TryFoldKey(const Key: string; Value: TJSONObject; Options: TToonOptions; IndentLevel: Integer; out FoldedOutput: string): Boolean; static;
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
    TToonOption.PreferTabular
  ];
end;

class function TToon.EncodePrimitive(JsonValue: TJSONValue; Options: TToonOptions): string;
begin
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

  Result := '';
end;

class function TToon.GetIndent(Options: TToonOptions; Level: Integer): string;
begin
  if Level = 0 then
  begin
    Result := '';
    Exit;
  end;

  var SpaceCount := 2;
  if TToonOption.Indent4Spaces in Options then
    SpaceCount := 4;

  Result := StringOfChar(' ', SpaceCount * Level);
end;

class function TToon.TryFoldKey(const Key: string; Value: TJSONObject; Options: TToonOptions; IndentLevel: Integer; out FoldedOutput: string): Boolean;
begin
  Result := False;

  if not ((TToonOption.KeyFoldingSafe in Options) or (TToonOption.KeyFoldingAggressive in Options)) then
    Exit;

  if not IsValidIdentifier(Key) then
    Exit;

  if Value.Count <> 1 then
    Exit;

  var FoldedKey := Key;
  var CurrentObj := Value;
  var Indent := GetIndent(Options, IndentLevel);

  while CurrentObj.Count = 1 do
  begin
    var ChildPair := CurrentObj.Pairs[0];
    var ChildKey := ChildPair.JsonString.Value;
    var ChildValue := ChildPair.JsonValue;

    if not IsValidIdentifier(ChildKey) then
      Exit;

    FoldedKey := FoldedKey + '.' + ChildKey;

    if not (ChildValue is TJSONObject) then
    begin
      var PrimitiveValue := EncodePrimitive(ChildValue, Options);
      FoldedOutput := Indent + FoldedKey + ': ' + PrimitiveValue;
      Result := True;
      Exit;
    end;

    CurrentObj := ChildValue as TJSONObject;
  end;

  var NestedObj := EncodeObject(CurrentObj, Options, IndentLevel + 1);
  FoldedOutput := Indent + FoldedKey + ':';
  if NestedObj <> '' then
    FoldedOutput := FoldedOutput + #13#10 + NestedObj;
  Result := True;
end;

class function TToon.EncodeObject(JsonObject: TJSONObject; Options: TToonOptions; IndentLevel: Integer): string;
begin
  if JsonObject.Count = 0 then
  begin
    Result := '';
    Exit;
  end;

  var Builder := TStringBuilder.Create;
  try
    var IsFirst := True;
    for var Pair in JsonObject do
    begin
      if not IsFirst then
        Builder.AppendLine;

      var Key := Pair.JsonString.Value;
      var Value := Pair.JsonValue;
      var Indent := GetIndent(Options, IndentLevel);

      if Value is TJSONObject then
      begin
        var FoldedResult: string;
        if TryFoldKey(Key, Value as TJSONObject, Options, IndentLevel, FoldedResult) then
        begin
          Builder.Append(FoldedResult);
        end
        else
        begin
          var QuotedKey := Key;
          if not IsValidIdentifier(Key) then
            QuotedKey := '"' + EscapeString(Key) + '"';

          Builder.Append(Indent).Append(QuotedKey).Append(':');
          var NestedObj := EncodeObject(Value as TJSONObject, Options, IndentLevel + 1);
          if NestedObj <> '' then
          begin
            Builder.AppendLine;
            Builder.Append(NestedObj);
          end;
        end;
      end
      else if Value is TJSONArray then
      begin
        raise EToonEncodingException.Create('Array encoding not implemented yet');
      end
      else
      begin
        var QuotedKey := Key;
        if not IsValidIdentifier(Key) then
          QuotedKey := '"' + EscapeString(Key) + '"';

        var PrimitiveValue := EncodePrimitive(Value, Options);
        Builder.Append(Indent).Append(QuotedKey).Append(': ').Append(PrimitiveValue);
      end;

      IsFirst := False;
    end;

    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

class function TToon.JsonToToon(JsonValue: TJSONValue; Options: TToonOptions): string;
begin
  if JsonValue = nil then
    raise EToonInvalidJsonException.Create(ErrorNilJsonValue);

  var ActualOptions := Options;
  if ActualOptions = [] then
    ActualOptions := GetDefaultOptions;

  if JsonValue is TJSONObject then
  begin
    Result := EncodeObject(JsonValue as TJSONObject, ActualOptions, 0);
    Exit;
  end;

  if JsonValue is TJSONArray then
  begin
    raise EToonEncodingException.Create('Array encoding not implemented yet');
  end;

  Result := EncodePrimitive(JsonValue, ActualOptions);
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
