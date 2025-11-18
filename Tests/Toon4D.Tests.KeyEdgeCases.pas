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
unit Toon4D.Tests.KeyEdgeCases;

/// <summary>
/// Tests for edge cases in key encoding (special characters, quotes, spaces, etc.)
/// Based on official TOON spec fixtures: objects.json
/// </summary>

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  Toon4D,
  Toon4D.Types;

type
  [TestFixture]
  TKeyEdgeCasesTests = class
  public
    [Test]
    procedure KeyWithBrackets_ShouldQuote;
    [Test]
    procedure KeyWithBraces_ShouldQuote;
    [Test]
    procedure KeyWithLeadingSpace_ShouldQuote;
    [Test]
    procedure KeyWithTrailingSpace_ShouldQuote;
    [Test]
    procedure KeyWithNewline_ShouldQuoteAndEscape;
    [Test]
    procedure KeyWithTab_ShouldQuoteAndEscape;
    [Test]
    procedure KeyWithEmbeddedQuote_ShouldQuoteAndEscape;
    [Test]
    procedure NumericKey_ShouldQuote;
    [Test]
    procedure EmptyStringKey_ShouldQuote;
  end;

implementation

uses
  System.SysUtils;

{ TKeyEdgeCasesTests }

procedure TKeyEdgeCasesTests.KeyWithBrackets_ShouldQuote;
var
  JsonObj: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObj := TJSONObject.Create;
  try
    JsonObj.AddPair('key[0]', 'value');

    Result := TToon.JsonToToon(JsonObj);

    Expected := '"key[0]": value';
    Assert.AreEqual(Expected, Result, 'Keys with brackets should be quoted');
  finally
    JsonObj.Free;
  end;
end;

procedure TKeyEdgeCasesTests.KeyWithBraces_ShouldQuote;
var
  JsonObj: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObj := TJSONObject.Create;
  try
    JsonObj.AddPair('key{x}', 'value');

    Result := TToon.JsonToToon(JsonObj);

    Expected := '"key{x}": value';
    Assert.AreEqual(Expected, Result, 'Keys with braces should be quoted');
  finally
    JsonObj.Free;
  end;
end;

procedure TKeyEdgeCasesTests.KeyWithLeadingSpace_ShouldQuote;
var
  JsonObj: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObj := TJSONObject.Create;
  try
    JsonObj.AddPair(' key', 'value');

    Result := TToon.JsonToToon(JsonObj);

    Expected := '" key": value';
    Assert.AreEqual(Expected, Result, 'Keys with leading space should be quoted');
  finally
    JsonObj.Free;
  end;
end;

procedure TKeyEdgeCasesTests.KeyWithTrailingSpace_ShouldQuote;
var
  JsonObj: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObj := TJSONObject.Create;
  try
    JsonObj.AddPair('key ', 'value');

    Result := TToon.JsonToToon(JsonObj);

    Expected := '"key ": value';
    Assert.AreEqual(Expected, Result, 'Keys with trailing space should be quoted');
  finally
    JsonObj.Free;
  end;
end;

procedure TKeyEdgeCasesTests.KeyWithNewline_ShouldQuoteAndEscape;
var
  JsonObj: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObj := TJSONObject.Create;
  try
    JsonObj.AddPair('key'#10'name', 'value');

    Result := TToon.JsonToToon(JsonObj);

    Expected := '"key\nname": value';
    Assert.AreEqual(Expected, Result, 'Keys with newline should be quoted and escaped');
  finally
    JsonObj.Free;
  end;
end;

procedure TKeyEdgeCasesTests.KeyWithTab_ShouldQuoteAndEscape;
var
  JsonObj: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObj := TJSONObject.Create;
  try
    JsonObj.AddPair('key'#9'name', 'value');

    Result := TToon.JsonToToon(JsonObj);

    Expected := '"key\tname": value';
    Assert.AreEqual(Expected, Result, 'Keys with tab should be quoted and escaped');
  finally
    JsonObj.Free;
  end;
end;

procedure TKeyEdgeCasesTests.KeyWithEmbeddedQuote_ShouldQuoteAndEscape;
var
  JsonObj: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObj := TJSONObject.Create;
  try
    JsonObj.AddPair('key"name', 'value');

    Result := TToon.JsonToToon(JsonObj);

    Expected := '"key\"name": value';
    Assert.AreEqual(Expected, Result, 'Keys with embedded quote should be quoted and escaped');
  finally
    JsonObj.Free;
  end;
end;

procedure TKeyEdgeCasesTests.NumericKey_ShouldQuote;
var
  JsonObj: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObj := TJSONObject.Create;
  try
    JsonObj.AddPair('123', 'value');

    Result := TToon.JsonToToon(JsonObj);

    Expected := '"123": value';
    Assert.AreEqual(Expected, Result, 'Numeric keys should be quoted');
  finally
    JsonObj.Free;
  end;
end;

procedure TKeyEdgeCasesTests.EmptyStringKey_ShouldQuote;
var
  JsonObj: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObj := TJSONObject.Create;
  try
    JsonObj.AddPair('', 'value');

    Result := TToon.JsonToToon(JsonObj);

    Expected := '"": value';
    Assert.AreEqual(Expected, Result, 'Empty string keys should be quoted');
  finally
    JsonObj.Free;
  end;
end;

end.
