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
unit Toon4D.Tests.ObjectEdgeCases;

/// <summary>
/// Tests for object value quoting edge cases
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
  TObjectEdgeCasesTests = class
  public
    [Test]
    procedure ValueWithColon_ShouldQuote;
    [Test]
    procedure ValueWithComma_ShouldQuote;
    [Test]
    procedure ValueWithNewline_ShouldQuoteAndEscape;
    [Test]
    procedure ValueWithQuote_ShouldQuoteAndEscape;
    [Test]
    procedure ValueWithLeadingSpace_ShouldQuote;
    [Test]
    procedure ValueWithTrailingSpace_ShouldQuote;
    [Test]
    procedure ValueReservedTrue_ShouldQuote;
    [Test]
    procedure ValueReservedFalse_ShouldQuote;
    [Test]
    procedure ValueReservedNull_ShouldQuote;
    [Test]
    procedure ValueLooksLikeNumber_ShouldQuote;
    [Test]
    procedure KeyWithColon_ShouldQuote;
    [Test]
    procedure KeyWithComma_ShouldQuote;
    [Test]
    procedure KeyWithControlChar_ShouldQuoteAndEscape;
  end;

implementation

uses
  System.SysUtils;

{ TObjectEdgeCasesTests }

procedure TObjectEdgeCasesTests.ValueWithColon_ShouldQuote;
var
  JsonObject: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('time', '10:30:00');

    Result := TToon.JsonToToon(JsonObject);

    Expected := 'time: "10:30:00"';
    Assert.AreEqual(Expected, Result, 'Value with colon must be quoted');
  finally
    JsonObject.Free;
  end;
end;

procedure TObjectEdgeCasesTests.ValueWithComma_ShouldQuote;
var
  JsonObject: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('name', 'Smith, John');

    Result := TToon.JsonToToon(JsonObject);

    Expected := 'name: "Smith, John"';
    Assert.AreEqual(Expected, Result, 'Value with comma must be quoted');
  finally
    JsonObject.Free;
  end;
end;

procedure TObjectEdgeCasesTests.ValueWithNewline_ShouldQuoteAndEscape;
var
  JsonObject: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('text', 'line1'#10'line2');

    Result := TToon.JsonToToon(JsonObject);

    Expected := 'text: "line1\nline2"';
    Assert.AreEqual(Expected, Result, 'Value with newline must be quoted and escaped');
  finally
    JsonObject.Free;
  end;
end;

procedure TObjectEdgeCasesTests.ValueWithQuote_ShouldQuoteAndEscape;
var
  JsonObject: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('quote', 'He said "hello"');

    Result := TToon.JsonToToon(JsonObject);

    Expected := 'quote: "He said \"hello\""';
    Assert.AreEqual(Expected, Result, 'Value with quote must be quoted and escaped');
  finally
    JsonObject.Free;
  end;
end;

procedure TObjectEdgeCasesTests.ValueWithLeadingSpace_ShouldQuote;
var
  JsonObject: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('text', ' leading');

    Result := TToon.JsonToToon(JsonObject);

    Expected := 'text: " leading"';
    Assert.AreEqual(Expected, Result, 'Value with leading space must be quoted');
  finally
    JsonObject.Free;
  end;
end;

procedure TObjectEdgeCasesTests.ValueWithTrailingSpace_ShouldQuote;
var
  JsonObject: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('text', 'trailing ');

    Result := TToon.JsonToToon(JsonObject);

    Expected := 'text: "trailing "';
    Assert.AreEqual(Expected, Result, 'Value with trailing space must be quoted');
  finally
    JsonObject.Free;
  end;
end;

procedure TObjectEdgeCasesTests.ValueReservedTrue_ShouldQuote;
var
  JsonObject: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('text', 'true');

    Result := TToon.JsonToToon(JsonObject);

    Expected := 'text: "true"';
    Assert.AreEqual(Expected, Result, 'String value "true" must be quoted');
  finally
    JsonObject.Free;
  end;
end;

procedure TObjectEdgeCasesTests.ValueReservedFalse_ShouldQuote;
var
  JsonObject: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('text', 'false');

    Result := TToon.JsonToToon(JsonObject);

    Expected := 'text: "false"';
    Assert.AreEqual(Expected, Result, 'String value "false" must be quoted');
  finally
    JsonObject.Free;
  end;
end;

procedure TObjectEdgeCasesTests.ValueReservedNull_ShouldQuote;
var
  JsonObject: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('text', 'null');

    Result := TToon.JsonToToon(JsonObject);

    Expected := 'text: "null"';
    Assert.AreEqual(Expected, Result, 'String value "null" must be quoted');
  finally
    JsonObject.Free;
  end;
end;

procedure TObjectEdgeCasesTests.ValueLooksLikeNumber_ShouldQuote;
var
  JsonObject: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('text', '123');

    Result := TToon.JsonToToon(JsonObject);

    Expected := 'text: "123"';
    Assert.AreEqual(Expected, Result, 'String value that looks like number must be quoted');
  finally
    JsonObject.Free;
  end;
end;

procedure TObjectEdgeCasesTests.KeyWithColon_ShouldQuote;
var
  JsonObject: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('key:name', 'value');

    Result := TToon.JsonToToon(JsonObject);

    Expected := '"key:name": value';
    Assert.AreEqual(Expected, Result, 'Key with colon must be quoted');
  finally
    JsonObject.Free;
  end;
end;

procedure TObjectEdgeCasesTests.KeyWithComma_ShouldQuote;
var
  JsonObject: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('key,name', 'value');

    Result := TToon.JsonToToon(JsonObject);

    Expected := '"key,name": value';
    Assert.AreEqual(Expected, Result, 'Key with comma must be quoted');
  finally
    JsonObject.Free;
  end;
end;

procedure TObjectEdgeCasesTests.KeyWithControlChar_ShouldQuoteAndEscape;
var
  JsonObject: TJSONObject;
  Result: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('key'#0'name', 'value');

    Result := TToon.JsonToToon(JsonObject);

    Assert.IsTrue(Result.StartsWith('"key'), 'Key with control char must be quoted');
    Assert.Contains(Result, 'name":', 'Key must be properly escaped');
  finally
    JsonObject.Free;
  end;
end;

end.
