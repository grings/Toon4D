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
    class function EncodeObject(JsonObject: TJSONObject; Options: TToonOptions; IndentLevel: Integer = 0; RootObject: TJSONObject = nil; const PathPrefix: string = ''): string; static;
    class function EncodePrimitive(JsonValue: TJSONValue; Options: TToonOptions): string; static;
    class function GetIndent(Options: TToonOptions; Level: Integer): string; static;
    class function GetArrayContentLevel(IndentLevel: Integer): Integer; static;
    class function GetNestedLevel(IndentLevel: Integer): Integer; static;
    class function HasKeyFoldingCollision(RootObject: TJSONObject; const PathPrefix: string; const StartKey: string; NestedObject: TJSONObject): Boolean; static;
    class function TryFoldKey(RootObject: TJSONObject; const PathPrefix: string; const Key: string; Value: TJSONObject; Options: TToonOptions; IndentLevel: Integer; out FoldedOutput: string): Boolean; static;
    class function EncodeArray(JsonArray: TJSONArray; Options: TToonOptions; IndentLevel: Integer; IsRootContext: Boolean = False): string; static;
    class function EncodeArrayInline(JsonArray: TJSONArray; Options: TToonOptions; const LengthPrefix: string): string; static;
    class function EncodeArrayTabular(JsonArray: TJSONArray; Options: TToonOptions; IndentLevel: Integer; const LengthPrefix: string): string; static;
    class function EncodeArrayList(JsonArray: TJSONArray; Options: TToonOptions; IndentLevel: Integer; const LengthPrefix: string; IsRootContext: Boolean = False): string; static;
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

class function TToon.GetArrayContentLevel(IndentLevel: Integer): Integer;
begin
  Result := IndentLevel;
  if Result = 0 then
    Result := 1;
end;

class function TToon.GetNestedLevel(IndentLevel: Integer): Integer;
begin
  Result := IndentLevel + 1;
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
  if FirstObj.Count = 0 then
    Exit;

  FieldNames := TList<string>.Create;

  for var Pair in FirstObj do
  begin
    FieldNames.Add(Pair.JsonString.Value);
    if (Pair.JsonValue is TJSONObject) or (Pair.JsonValue is TJSONArray) then
      Exit;
  end;

  for var Index := 1 to JsonArray.Count - 1 do
  begin
    var Obj := JsonArray.Items[Index] as TJSONObject;
    if Obj.Count <> FieldNames.Count then
      Exit;

    for var FieldName in FieldNames do
    begin
      var FieldValue := Obj.GetValue(FieldName);
      if FieldValue = nil then
        Exit;
      if (FieldValue is TJSONObject) or (FieldValue is TJSONArray) then
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
    for var Index := 0 to JsonArray.Count - 1 do
    begin
      if Index > 0 then
        Builder.Append(Delimiter);
      var PrimitiveValue := EncodePrimitive(JsonArray.Items[Index], Options);
      Builder.Append(PrimitiveValue);
    end;
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

class function TToon.EncodeArrayTabular(JsonArray: TJSONArray; Options: TToonOptions; IndentLevel: Integer; const LengthPrefix: string): string;
begin
  var FieldNames: TList<string> := nil;
  if not IsUniformObjectArray(JsonArray, FieldNames) then
  begin
    if FieldNames <> nil then
      FieldNames.Free;
    Result := '';
    Exit;
  end;

  try
    var Delimiter := GetDelimiter(Options);
    var Builder := TStringBuilder.Create;
    try
      Builder.Append(LengthPrefix).Append('{');
      for var FieldIndex := 0 to FieldNames.Count - 1 do
      begin
        if FieldIndex > 0 then
          Builder.Append(Delimiter);
        var FieldName := FieldNames[FieldIndex];
        if not IsValidIdentifier(FieldName) then
          Builder.Append('"').Append(EscapeString(FieldName)).Append('"')
        else
          Builder.Append(FieldName);
      end;
      Builder.Append('}:');

      var Indent := GetIndent(Options, GetArrayContentLevel(IndentLevel));
      for var RowIndex := 0 to JsonArray.Count - 1 do
      begin
        Builder.Append(ToonLineBreak);
        Builder.Append(Indent);
        var Obj := JsonArray.Items[RowIndex] as TJSONObject;
        for var ColIndex := 0 to FieldNames.Count - 1 do
        begin
          if ColIndex > 0 then
            Builder.Append(Delimiter);
          var FieldValue := Obj.GetValue(FieldNames[ColIndex]);
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

class function TToon.EncodeArrayList(JsonArray: TJSONArray; Options: TToonOptions; IndentLevel: Integer; const LengthPrefix: string; IsRootContext: Boolean): string;
begin
  var Builder := TStringBuilder.Create;
  try
    Builder.Append(LengthPrefix).Append(':');
    var ContentLevel := IndentLevel;
    if IsRootContext then
      ContentLevel := 1;
    var Indent := GetIndent(Options, ContentLevel);

    for var ItemIndex := 0 to JsonArray.Count - 1 do
    begin
      Builder.Append(ToonLineBreak);
      Builder.Append(Indent).Append('- ');
      var Item := JsonArray.Items[ItemIndex];

      if Item is TJSONObject then
      begin
        var ObjContent := EncodeObject(Item as TJSONObject, Options, 0);
        var Lines := ObjContent.Split([ToonLineBreak]);
        var NestedIndent := GetIndent(Options, 1);
        for var Index := 0 to High(Lines) do
        begin
          if Index = 0 then
            Builder.Append(Lines[Index])
          else
          begin
            Builder.Append(ToonLineBreak);
            var Line := Lines[Index];
            var TrimmedLine := Line.TrimLeft;
            var LeadingSpaces := Length(Line) - Length(TrimmedLine);
            var NestedIndentLen := Length(NestedIndent);
            if Line.StartsWith(NestedIndent) then
            begin
              var IsArrayContent := TrimmedLine.StartsWith('- ') or (not TrimmedLine.Contains(': '));
              if IsArrayContent or (LeadingSpaces > NestedIndentLen) then
                Line := Line.Substring(NestedIndentLen);
            end;
            Builder.Append(Indent).Append('  ').Append(Line);
          end;
        end;
      end
      else if Item is TJSONArray then
      begin
        var ArrayContent := EncodeArray(Item as TJSONArray, Options, 0);
        var Lines := ArrayContent.Split([ToonLineBreak]);
        for var Index := 0 to High(Lines) do
        begin
          if Index = 0 then
            Builder.Append(Lines[Index])
          else
          begin
            Builder.Append(ToonLineBreak);
            Builder.Append(Indent).Append('  ').Append(Lines[Index]);
          end;
        end;
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

class function TToon.EncodeArray(JsonArray: TJSONArray; Options: TToonOptions; IndentLevel: Integer; IsRootContext: Boolean): string;
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
  for var Index := 0 to ArrayLength - 1 do
  begin
    var Item := JsonArray.Items[Index];
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
  for var Index := 0 to ArrayLength - 1 do
  begin
    if not (JsonArray.Items[Index] is TJSONObject) then
    begin
      AllObjects := False;
      Break;
    end;
  end;

  if AllObjects then
  begin
    var TabularResult := EncodeArrayTabular(JsonArray, Options, IndentLevel, LengthPrefix);
    if TabularResult <> '' then
    begin
      Result := TabularResult;
      Exit;
    end;
  end;

  Result := EncodeArrayList(JsonArray, Options, IndentLevel, LengthPrefix, IsRootContext);
end;

class function TToon.HasKeyFoldingCollision(RootObject: TJSONObject; const PathPrefix: string; const StartKey: string; NestedObject: TJSONObject): Boolean;
var
  FoldedPath: string;
  FullPath: string;
  CurrentObj: TJSONObject;
  Pair: TJSONPair;
begin
  Result := False;
  if RootObject = nil then
    Exit;

  FoldedPath := StartKey;
  CurrentObj := NestedObject;

  while (CurrentObj <> nil) and (CurrentObj.Count = 1) do
  begin
    FoldedPath := FoldedPath + '.' + CurrentObj.Pairs[0].JsonString.Value;

    if PathPrefix <> '' then
      FullPath := PathPrefix + '.' + FoldedPath
    else
      FullPath := FoldedPath;

    for Pair in RootObject do
    begin
      if Pair.JsonString.Value = FullPath then
      begin
        Result := True;
        Exit;
      end;
    end;

    if CurrentObj.Pairs[0].JsonValue is TJSONObject then
      CurrentObj := CurrentObj.Pairs[0].JsonValue as TJSONObject
    else
      Break;
  end;
end;

class function TToon.TryFoldKey(RootObject: TJSONObject; const PathPrefix: string; const Key: string; Value: TJSONObject; Options: TToonOptions; IndentLevel: Integer; out FoldedOutput: string): Boolean;
var
  MaxDepth: Integer;
  CurrentDepth: Integer;
begin
  Result := False;

  if not ((TToonOption.KeyFoldingSafe in Options) or (TToonOption.KeyFoldingAggressive in Options)) then
    Exit;

  if not IsValidIdentifier(Key) then
    Exit;

  if Value.Count <> 1 then
    Exit;

  if HasKeyFoldingCollision(RootObject, PathPrefix, Key, Value) then
    Exit;

  if TToonOption.KeyFoldingDepth1 in Options then
    Exit;

  if TToonOption.KeyFoldingDepth2 in Options then
    MaxDepth := 2
  else
    MaxDepth := MaxInt;

  var FoldedKey := Key;
  var CurrentObj := Value;
  var Indent := GetIndent(Options, IndentLevel);
  CurrentDepth := 1;

  while CurrentObj.Count = 1 do
  begin
    var ChildPair := CurrentObj.Pairs[0];
    var ChildKey := ChildPair.JsonString.Value;
    var ChildValue := ChildPair.JsonValue;

    if not IsValidIdentifier(ChildKey) then
      Exit;

    if CurrentDepth >= MaxDepth then
    begin
      var NoFoldOptions := Options - [TToonOption.KeyFoldingSafe, TToonOption.KeyFoldingAggressive, TToonOption.KeyFoldingDepth2];
      var NestedContent := EncodeObject(CurrentObj, NoFoldOptions, IndentLevel + 1, RootObject, PathPrefix + FoldedKey + '.');
      FoldedOutput := Indent + FoldedKey + ':' + ToonLineBreak + NestedContent;
      Result := True;
      Exit;
    end;

    FoldedKey := FoldedKey + '.' + ChildKey;
    Inc(CurrentDepth);

    if ChildValue is TJSONArray then
    begin
      var ArrayOutput := EncodeArray(ChildValue as TJSONArray, Options, GetNestedLevel(IndentLevel));
      FoldedOutput := Indent + FoldedKey + ArrayOutput;
      Result := True;
      Exit;
    end;

    if not (ChildValue is TJSONObject) then
    begin
      var PrimitiveValue := EncodePrimitive(ChildValue, Options);
      FoldedOutput := Indent + FoldedKey + ': ' + PrimitiveValue;
      Result := True;
      Exit;
    end;

    CurrentObj := ChildValue as TJSONObject;
  end;

  if CurrentObj.Count = 0 then
  begin
    FoldedOutput := Indent + FoldedKey + ':';
    Result := True;
    Exit;
  end;

  Result := False;
end;

class function TToon.EncodeObject(JsonObject: TJSONObject; Options: TToonOptions; IndentLevel: Integer; RootObject: TJSONObject; const PathPrefix: string): string;
begin
  if JsonObject.Count = 0 then
  begin
    Result := '';
    Exit;
  end;

  var ActualRoot := RootObject;
  if ActualRoot = nil then
    ActualRoot := JsonObject;

  var Builder := TStringBuilder.Create;
  try
    var IsFirst := True;
    for var Pair in JsonObject do
    begin
      var Key := Pair.JsonString.Value;
      var Value := Pair.JsonValue;
      var Indent := GetIndent(Options, IndentLevel);

      var NewPathPrefix: string;
      if PathPrefix <> '' then
        NewPathPrefix := PathPrefix + '.' + Key
      else
        NewPathPrefix := Key;

      if Value is TJSONObject then
      begin
        var NestedObject := Value as TJSONObject;

        var FoldedResult: string;
        if TryFoldKey(ActualRoot, PathPrefix, Key, NestedObject, Options, IndentLevel, FoldedResult) then
        begin
          if not IsFirst then
            Builder.Append(ToonLineBreak);
          Builder.Append(FoldedResult);
          IsFirst := False;
        end
        else
        begin
          var QuotedKey := Key;
          if not IsValidIdentifier(Key) then
            QuotedKey := '"' + EscapeString(Key) + '"';

          if not IsFirst then
            Builder.Append(ToonLineBreak);
          Builder.Append(Indent).Append(QuotedKey).Append(':');

          var NestedObj := EncodeObject(NestedObject, Options, IndentLevel + 1, ActualRoot, NewPathPrefix);
          if NestedObj <> '' then
          begin
            Builder.Append(ToonLineBreak);
            Builder.Append(NestedObj);
          end;

          IsFirst := False;
        end;
      end
      else if Value is TJSONArray then
      begin
        if not IsFirst then
          Builder.Append(ToonLineBreak);

        var QuotedKey := Key;
        if not IsValidIdentifier(Key) then
          QuotedKey := '"' + EscapeString(Key) + '"';

        var ArrayOutput := EncodeArray(Value as TJSONArray, Options, GetNestedLevel(IndentLevel));
        Builder.Append(Indent).Append(QuotedKey).Append(ArrayOutput);
        IsFirst := False;
      end
      else
      begin
        if not IsFirst then
          Builder.Append(ToonLineBreak);

        var QuotedKey := Key;
        if not IsValidIdentifier(Key) then
          QuotedKey := '"' + EscapeString(Key) + '"';

        var PrimitiveValue := EncodePrimitive(Value, Options);
        Builder.Append(Indent).Append(QuotedKey).Append(': ').Append(PrimitiveValue);
        IsFirst := False;
      end;
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
    Result := Result.TrimRight;
    Exit;
  end;

  if JsonValue is TJSONArray then
  begin
    Result := EncodeArray(JsonValue as TJSONArray, ActualOptions, 0, True);
    Result := Result.TrimRight;
    Exit;
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
