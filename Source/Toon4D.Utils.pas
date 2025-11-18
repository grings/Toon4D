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
unit Toon4D.Utils;

interface

uses
  System.SysUtils,
  System.JSON,
  System.RegularExpressions;

function NeedsQuoting(const Value: string; Delimiter: Char): Boolean;
function EscapeString(const Value: string): string;
function NormalizeNumber(JsonNumber: TJSONNumber): string;
function IsValidIdentifier(const KeyName: string): Boolean;
function LooksLikeNumber(const Value: string): Boolean;
function IsReservedWord(const Value: string): Boolean;

implementation

uses
  System.Math;

function LooksLikeNumber(const Value: string): Boolean;
begin
  Result := TRegEx.IsMatch(Value, '^-?\d+(\.\d+)?([eE][+-]?\d+)?$');
end;

function IsReservedWord(const Value: string): Boolean;
begin
  Result := Value.Equals('true') or Value.Equals('false') or Value.Equals('null');
end;

function NeedsQuoting(const Value: string; Delimiter: Char): Boolean;
begin
  Result := False;

  if Value = '' then
  begin
    Result := True;
    Exit;
  end;

  if (Value[1] = ' ') or (Value[Length(Value)] = ' ') then
  begin
    Result := True;
    Exit;
  end;

  if IsReservedWord(Value) then
  begin
    Result := True;
    Exit;
  end;

  if (Value = '-') or Value.StartsWith('- ') then
  begin
    Result := True;
    Exit;
  end;

  if LooksLikeNumber(Value) then
  begin
    Result := True;
    Exit;
  end;

  for var Character in Value do
  begin
    if CharInSet(Character, [':', '"', '\', '[', ']', '{', '}']) then
    begin
      Result := True;
      Exit;
    end;
    if Ord(Character) < 32 then
    begin
      Result := True;
      Exit;
    end;
    if Character = Delimiter then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function EscapeString(const Value: string): string;
begin
  var Builder := TStringBuilder.Create(Length(Value) * 2);
  try
    for var Character in Value do
    begin
      case Character of
        '\': Builder.Append('\\');
        '"': Builder.Append('\"');
        #10: Builder.Append('\n');
        #13: Builder.Append('\r');
        #9:  Builder.Append('\t');
      else
        Builder.Append(Character);
      end;
    end;
    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

function NormalizeNumber(JsonNumber: TJSONNumber): string;
begin
  var DoubleValue := JsonNumber.AsDouble;

  if IsNan(DoubleValue) or IsInfinite(DoubleValue) then
  begin
    Result := 'null';
    Exit;
  end;

  if SameValue(DoubleValue, -0.0) then
    DoubleValue := 0.0;

  if Frac(DoubleValue) = 0 then
  begin
    if (DoubleValue >= Low(Int64)) and (DoubleValue <= High(Int64)) then
    begin
      var IntValue := Trunc(DoubleValue);
      Result := IntValue.ToString;
      Exit;
    end
    else
    begin
      Result := Format('%.0f', [DoubleValue]);
      Result := StringReplace(Result, ',', '.', [rfReplaceAll]);
      Exit;
    end;
  end;

  var StringValue := FloatToStr(DoubleValue);
  StringValue := StringReplace(StringValue, ',', '.', [rfReplaceAll]);

  if StringValue.Contains('E') or StringValue.Contains('e') then
  begin
    StringValue := FloatToStrF(DoubleValue, ffFixed, 18, 18);
    StringValue := StringReplace(StringValue, ',', '.', [rfReplaceAll]);
  end;

  if StringValue.Contains('.') then
  begin
    while StringValue.EndsWith('0') and not StringValue.EndsWith('.0') do
      StringValue := StringValue.Substring(0, StringValue.Length - 1);
  end;

  Result := StringValue;
end;

function IsValidIdentifier(const KeyName: string): Boolean;
begin
  if KeyName = '' then
  begin
    Result := False;
    Exit;
  end;

  if IsReservedWord(KeyName) then
  begin
    Result := False;
    Exit;
  end;

  if LooksLikeNumber(KeyName) then
  begin
    Result := False;
    Exit;
  end;

  var Pattern := '^[A-Za-z_][A-Za-z0-9_.]*$';
  Result := TRegEx.IsMatch(KeyName, Pattern);
end;

end.
