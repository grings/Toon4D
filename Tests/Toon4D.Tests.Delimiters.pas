{*******************************************************}
{                                                       }
{         Toon4D Library - LLM Data Optimization        }
{                                                       }
{                 DUnitX Test Suite                     }
{           Delimiter Options Tests                     }
{                                                       }
{*******************************************************}
unit Toon4D.Tests.Delimiters;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.JSON;

type
  [TestFixture]
  TDelimiterTests = class
  public
    [Test]
    procedure DelimiterComma_InlineArray_ShouldUseComma;

    [Test]
    procedure DelimiterTab_InlineArray_ShouldUseTab;

    [Test]
    procedure DelimiterPipe_InlineArray_ShouldUsePipe;

    [Test]
    procedure DelimiterComma_TabularArray_ShouldUseComma;

    [Test]
    procedure DelimiterTab_TabularArray_ShouldUseTabInHeader;

    [Test]
    procedure DelimiterPipe_TabularArray_ShouldUsePipeInHeader;

    [Test]
    procedure DelimiterTab_TabularRows_ShouldSeparateWithTab;

    [Test]
    procedure DelimiterPipe_TabularRows_ShouldSeparateWithPipe;

    [Test]
    procedure DelimiterComma_StringWithComma_ShouldQuote;

    [Test]
    procedure DelimiterTab_StringWithTab_ShouldQuote;

    [Test]
    procedure DelimiterPipe_StringWithPipe_ShouldQuote;

    [Test]
    procedure DelimiterComma_Default_ShouldNotShowInHeader;

    [Test]
    procedure DelimiterTab_ShouldShowInHeader;

    [Test]
    procedure DelimiterPipe_ShouldShowInHeader;

    [Test]
    procedure NestedArrays_CanHaveDifferentDelimiters;
  end;

implementation

uses
  Toon4D,
  Toon4D.Types;

procedure TDelimiterTests.DelimiterComma_InlineArray_ShouldUseComma;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Options: TToonOptions;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.Add('a');
    JsonArray.Add('b');
    JsonArray.Add('c');
    JsonObject.AddPair('items', JsonArray);

    Options := [TToonOption.DelimiterComma];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Expected := 'items[3]: a,b,c';
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TDelimiterTests.DelimiterTab_InlineArray_ShouldUseTab;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Options: TToonOptions;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.Add('a');
    JsonArray.Add('b');
    JsonArray.Add('c');
    JsonObject.AddPair('items', JsonArray);

    Options := [TToonOption.DelimiterTab];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Expected := 'items[3' + #9 + ']: a' + #9 + 'b' + #9 + 'c';
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TDelimiterTests.DelimiterPipe_InlineArray_ShouldUsePipe;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Options: TToonOptions;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.Add('a');
    JsonArray.Add('b');
    JsonArray.Add('c');
    JsonObject.AddPair('items', JsonArray);

    Options := [TToonOption.DelimiterPipe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Expected := 'items[3|]: a|b|c';
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TDelimiterTests.DelimiterComma_TabularArray_ShouldUseComma;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('id', TJSONNumber.Create(1));
    Item.AddPair('name', 'Alice');
    JsonArray.Add(Item);

    JsonObject.AddPair('users', JsonArray);

    Options := [TToonOption.DelimiterComma];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.Contains(ToonOutput, 'users[1]{id,name}:');
    Assert.Contains(ToonOutput, '1,Alice');
  finally
    JsonObject.Free;
  end;
end;

procedure TDelimiterTests.DelimiterTab_TabularArray_ShouldUseTabInHeader;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('id', TJSONNumber.Create(1));
    Item.AddPair('name', 'Alice');
    JsonArray.Add(Item);

    JsonObject.AddPair('users', JsonArray);

    Options := [TToonOption.DelimiterTab];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.Contains(ToonOutput, 'users[1' + #9 + ']{id' + #9 + 'name}:');
  finally
    JsonObject.Free;
  end;
end;

procedure TDelimiterTests.DelimiterPipe_TabularArray_ShouldUsePipeInHeader;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('id', TJSONNumber.Create(1));
    Item.AddPair('name', 'Alice');
    JsonArray.Add(Item);

    JsonObject.AddPair('users', JsonArray);

    Options := [TToonOption.DelimiterPipe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.Contains(ToonOutput, 'users[1|]{id|name}:');
  finally
    JsonObject.Free;
  end;
end;

procedure TDelimiterTests.DelimiterTab_TabularRows_ShouldSeparateWithTab;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('id', TJSONNumber.Create(1));
    Item.AddPair('name', 'Alice');
    JsonArray.Add(Item);

    JsonObject.AddPair('users', JsonArray);

    Options := [TToonOption.DelimiterTab];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.Contains(ToonOutput, '1' + #9 + 'Alice');
  finally
    JsonObject.Free;
  end;
end;

procedure TDelimiterTests.DelimiterPipe_TabularRows_ShouldSeparateWithPipe;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('id', TJSONNumber.Create(1));
    Item.AddPair('name', 'Alice');
    JsonArray.Add(Item);

    JsonObject.AddPair('users', JsonArray);

    Options := [TToonOption.DelimiterPipe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.Contains(ToonOutput, '1|Alice');
  finally
    JsonObject.Free;
  end;
end;

procedure TDelimiterTests.DelimiterComma_StringWithComma_ShouldQuote;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.Add('a,b');
    JsonArray.Add('c');
    JsonObject.AddPair('items', JsonArray);

    Options := [TToonOption.DelimiterComma];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.Contains(ToonOutput, '"a,b"');
  finally
    JsonObject.Free;
  end;
end;

procedure TDelimiterTests.DelimiterTab_StringWithTab_ShouldQuote;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.Add('a' + #9 + 'b');
    JsonArray.Add('c');
    JsonObject.AddPair('items', JsonArray);

    Options := [TToonOption.DelimiterTab];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.Contains(ToonOutput, '"a\tb"');
  finally
    JsonObject.Free;
  end;
end;

procedure TDelimiterTests.DelimiterPipe_StringWithPipe_ShouldQuote;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.Add('a|b');
    JsonArray.Add('c');
    JsonObject.AddPair('items', JsonArray);

    Options := [TToonOption.DelimiterPipe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.Contains(ToonOutput, '"a|b"');
  finally
    JsonObject.Free;
  end;
end;

procedure TDelimiterTests.DelimiterComma_Default_ShouldNotShowInHeader;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('id', TJSONNumber.Create(1));
    JsonArray.Add(Item);

    JsonObject.AddPair('items', JsonArray);

    Options := [TToonOption.DelimiterComma];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.Contains(ToonOutput, 'items[1]{id}:');
    Assert.IsFalse(ToonOutput.Contains('[1,]'));
  finally
    JsonObject.Free;
  end;
end;

procedure TDelimiterTests.DelimiterTab_ShouldShowInHeader;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.Add('a');
    JsonObject.AddPair('items', JsonArray);

    Options := [TToonOption.DelimiterTab];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.Contains(ToonOutput, '[1' + #9 + ']:');
  finally
    JsonObject.Free;
  end;
end;

procedure TDelimiterTests.DelimiterPipe_ShouldShowInHeader;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.Add('a');
    JsonObject.AddPair('items', JsonArray);

    Options := [TToonOption.DelimiterPipe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.Contains(ToonOutput, '[1|]:');
  finally
    JsonObject.Free;
  end;
end;

procedure TDelimiterTests.NestedArrays_CanHaveDifferentDelimiters;
var
  JsonObject: TJSONObject;
  OuterArray: TJSONArray;
  InnerArray: TJSONArray;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    OuterArray := TJSONArray.Create;
    InnerArray := TJSONArray.Create;
    InnerArray.Add('a');
    InnerArray.Add('b');
    OuterArray.Add(InnerArray);
    JsonObject.AddPair('items', OuterArray);

    Options := [TToonOption.DelimiterComma];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.Contains(ToonOutput, 'items[1]:');
    Assert.Contains(ToonOutput, '- [2]: a,b');
  finally
    JsonObject.Free;
  end;
end;

end.
