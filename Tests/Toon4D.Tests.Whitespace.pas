{*******************************************************}
{                                                       }
{         Toon4D Library - LLM Data Optimization        }
{                                                       }
{     Copyright(c) 2025 [Organization/Author Name]      }
{              All rights reserved                      }
{                                                       }
{              Licensed under MIT License               }
{                                                       }
{*******************************************************}
unit Toon4D.Tests.Whitespace;

/// <summary>
/// Tests for whitespace validation in TOON output
/// Based on official TOON spec fixtures: whitespace.json
/// </summary>

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  Toon4D,
  Toon4D.Types;

type
  [TestFixture]
  TWhitespaceTests = class
  public
    [Test]
    procedure NoTrailingNewline_EndOfOutput;
    [Test]
    procedure NoTrailingSpaces_OnAnyLine;
  end;

implementation

uses
  System.SysUtils;

{ TWhitespaceTests }

procedure TWhitespaceTests.NoTrailingNewline_EndOfOutput;
var
  JsonObject: TJSONObject;
  Result: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('name', 'test');
    JsonObject.AddPair('value', TJSONNumber.Create(42));

    Result := TToon.JsonToToon(JsonObject);

    Assert.IsFalse(Result.EndsWith(#10), 'Output should not end with LF');
    Assert.IsFalse(Result.EndsWith(#13), 'Output should not end with CR');
    Assert.IsFalse(Result.EndsWith(#13#10), 'Output should not end with CRLF');
  finally
    JsonObject.Free;
  end;
end;

procedure TWhitespaceTests.NoTrailingSpaces_OnAnyLine;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  Result: string;
  Lines: TArray<string>;
  Line: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('name', 'test');

    JsonArray := TJSONArray.Create;
    Item := TJSONObject.Create;
    Item.AddPair('id', TJSONNumber.Create(1));
    Item.AddPair('name', 'Alice');
    JsonArray.Add(Item);
    JsonObject.AddPair('users', JsonArray);

    Result := TToon.JsonToToon(JsonObject);
    Lines := Result.Split([#13#10, #10, #13], TStringSplitOptions.None);

    for Line in Lines do
    begin
      Assert.IsFalse(Line.EndsWith(' '), 'Line should not end with space: "' + Line + '"');
      Assert.IsFalse(Line.EndsWith(#9), 'Line should not end with tab: "' + Line + '"');
    end;
  finally
    JsonObject.Free;
  end;
end;

end.
