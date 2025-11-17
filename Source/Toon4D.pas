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
  System.Generics.Collections,
  Toon4D.Types;

type
  TToon = class sealed
  private
    class function GetDefaultOptions: TToonOptions; static;
    class function EncodeObject(JsonObject: TJSONObject; Options: TToonOptions; IndentLevel: Integer): string; static;
    class function EncodePrimitive(JsonValue: TJSONValue; Options: TToonOptions): string; static;
    class function GetIndent(Options: TToonOptions; Level: Integer): string; static;
    class function TryFoldKey(const Key: string; Value: TJSONObject; Options: TToonOptions; IndentLevel: Integer; out FoldedOutput: string): Boolean; static;
    class function EncodeArray(JsonArray: TJSONArray; Options: TToonOptions; IndentLevel: Integer): string; static;
    class function EncodeArrayInline(JsonArray: TJSONArray; Options: TToonOptions; const LengthPrefix: string): string; static;
    class function EncodeArrayTabular(JsonArray: TJSONArray; Options: TToonOptions; IndentLevel: Integer; const LengthPrefix: string): string; static;
    class function EncodeArrayList(JsonArray: TJSONArray; Options: TToonOptions; IndentLevel: Integer; const LengthPrefix: string): string; static;
    class function IsUniformObjectArray(JsonArray: TJSONArray; out FieldNames: TList<string>): Boolean; static;
    class function GetDelimiter(Options: TToonOptions): Char; static;
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
    var Delimiter := GetDelimiter(Options);
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

class function TToon.GetDelimiter(Options: TToonOptions): Char;
begin
  if TToonOption.DelimiterTab in Options then
  begin
    Result := #9;
    Exit;
  end;

  if TToonOption.DelimiterPipe in Options then
  begin
    Result := '|';
    Exit;
  end;

  Result := ',';
end;

class function TToon.IsUniformObjectArray(JsonArray: TJSONArray; out FieldNames: TList<string>): Boolean;
begin
  Result := False;

  if JsonArray.Count = 0 then
    Exit;

  var FirstObj := JsonArray.Items[0] as TJSONObject;
  FieldNames := TList<string>.Create;

  for var Pair in FirstObj do
    FieldNames.Add(Pair.JsonString.Value);

  for var I := 1 to JsonArray.Count - 1 do
  begin
    var Obj := JsonArray.Items[I] as TJSONObject;
    if Obj.Count <> FieldNames.Count then
      Exit;

    for var FieldName in FieldNames do
    begin
      if Obj.GetValue(FieldName) = nil then
        Exit;
    end;
  end;

  Result := True;
end;

class function TToon.EncodeArrayInline(JsonArray: TJSONArray; Options: TToonOptions; const LengthPrefix: string): string;
begin
  var Delimiter := GetDelimiter(Options);
  var Builder := TStringBuilder.Create;
  try
    Builder.Append(LengthPrefix).Append(': ');
    for var I := 0 to JsonArray.Count - 1 do
    begin
      if I > 0 then
        Builder.Append(Delimiter);
      var PrimitiveValue := EncodePrimitive(JsonArray.Items[I], Options);
      Builder.Append(PrimitiveValue);
    end;
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

class function TToon.EncodeArrayTabular(JsonArray: TJSONArray; Options: TToonOptions; IndentLevel: Integer; const LengthPrefix: string): string;
begin
  var FieldNames: TList<string>;
  if not IsUniformObjectArray(JsonArray, FieldNames) then
  begin
    FieldNames.Free;
    Result := '';
    Exit;
  end;

  try
    var Delimiter := GetDelimiter(Options);
    var Builder := TStringBuilder.Create;
    try
      Builder.Append(LengthPrefix).Append('{');
      for var I := 0 to FieldNames.Count - 1 do
      begin
        if I > 0 then
          Builder.Append(',');
        Builder.Append(FieldNames[I]);
      end;
      Builder.Append('}:');

      var Indent := GetIndent(Options, IndentLevel);
      for var I := 0 to JsonArray.Count - 1 do
      begin
        Builder.AppendLine;
        Builder.Append(Indent);
        var Obj := JsonArray.Items[I] as TJSONObject;
        for var J := 0 to FieldNames.Count - 1 do
        begin
          if J > 0 then
            Builder.Append(Delimiter);
          var FieldValue := Obj.GetValue(FieldNames[J]);
          var PrimitiveValue := EncodePrimitive(FieldValue, Options);
          Builder.Append(PrimitiveValue);
        end;
      end;

      Result := Builder.ToString;
    finally
      Builder.Free;
    end;
  finally
    FieldNames.Free;
  end;
end;

class function TToon.EncodeArrayList(JsonArray: TJSONArray; Options: TToonOptions; IndentLevel: Integer; const LengthPrefix: string): string;
begin
  var Builder := TStringBuilder.Create;
  try
    Builder.Append(LengthPrefix).Append(':');
    var Indent := GetIndent(Options, IndentLevel);

    for var I := 0 to JsonArray.Count - 1 do
    begin
      Builder.AppendLine;
      Builder.Append(Indent).Append('- ');
      var Item := JsonArray.Items[I];

      if Item is TJSONObject then
      begin
        var ObjContent := EncodeObject(Item as TJSONObject, Options, IndentLevel + 1);
        var Lines := ObjContent.Split([#13#10]);
        for var J := 0 to High(Lines) do
        begin
          if J = 0 then
            Builder.Append(Lines[J])
          else
          begin
            Builder.AppendLine;
            Builder.Append(Indent).Append('  ').Append(Lines[J]);
          end;
        end;
      end
      else if Item is TJSONArray then
      begin
        var ArrayContent := EncodeArray(Item as TJSONArray, Options, IndentLevel + 1);
        Builder.Append(ArrayContent);
      end
      else
      begin
        var PrimitiveValue := EncodePrimitive(Item, Options);
        Builder.Append(PrimitiveValue);
      end;
    end;

    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

class function TToon.EncodeArray(JsonArray: TJSONArray; Options: TToonOptions; IndentLevel: Integer): string;
begin
  var ArrayLength := JsonArray.Count;
  var Delimiter := GetDelimiter(Options);
  var LengthPrefix := '[' + ArrayLength.ToString;

  if TToonOption.DelimiterTab in Options then
    LengthPrefix := LengthPrefix + Delimiter;

  if TToonOption.DelimiterPipe in Options then
    LengthPrefix := LengthPrefix + Delimiter;

  LengthPrefix := LengthPrefix + ']';

  if ArrayLength = 0 then
  begin
    Result := LengthPrefix + ':';
    Exit;
  end;

  var AllPrimitives := True;
  for var I := 0 to ArrayLength - 1 do
  begin
    var Item := JsonArray.Items[I];
    if (Item is TJSONObject) or (Item is TJSONArray) then
    begin
      AllPrimitives := False;
      Break;
    end;
  end;

  if AllPrimitives then
  begin
    Result := EncodeArrayInline(JsonArray, Options, LengthPrefix);
    Exit;
  end;

  var AllObjects := True;
  for var I := 0 to ArrayLength - 1 do
  begin
    if not (JsonArray.Items[I] is TJSONObject) then
    begin
      AllObjects := False;
      Break;
    end;
  end;

  if AllObjects and (TToonOption.PreferTabular in Options) then
  begin
    var TabularResult := EncodeArrayTabular(JsonArray, Options, IndentLevel, LengthPrefix);
    if TabularResult <> '' then
    begin
      Result := TabularResult;
      Exit;
    end;
  end;

  Result := EncodeArrayList(JsonArray, Options, IndentLevel, LengthPrefix);
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
        var QuotedKey := Key;
        if not IsValidIdentifier(Key) then
          QuotedKey := '"' + EscapeString(Key) + '"';

        var ArrayOutput := EncodeArray(Value as TJSONArray, Options, IndentLevel + 1);
        Builder.Append(Indent).Append(QuotedKey).Append(ArrayOutput);
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
