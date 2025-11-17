{*******************************************************}
{                                                       }
{         Toon4D Library - LLM Data Optimization        }
{                                                       }
{                 DUnitX Test Suite                     }
{              Key Folding Feature Tests                }
{                                                       }
{*******************************************************}
unit Toon4D.Tests.KeyFolding;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.JSON;

type
  [TestFixture]
  TKeyFoldingTests = class
  public
    [Test]
    procedure KeyFoldingDisabled_ShouldNotFold;

    [Test]
    procedure KeyFoldingSafe_SingleKeyChain_ShouldFold;

    [Test]
    procedure KeyFoldingSafe_TwoLevelChain_ShouldFold;

    [Test]
    procedure KeyFoldingSafe_ThreeLevelChain_ShouldFold;

    [Test]
    procedure KeyFoldingSafe_InvalidIdentifier_ShouldNotFold;

    [Test]
    procedure KeyFoldingSafe_KeyWithSpaces_ShouldNotFold;

    [Test]
    procedure KeyFoldingSafe_KeyWithHyphen_ShouldNotFold;

    [Test]
    procedure KeyFoldingSafe_KeyStartingWithNumber_ShouldNotFold;

    [Test]
    procedure KeyFoldingSafe_ValidUnderscore_ShouldFold;

    [Test]
    procedure KeyFoldingSafe_ValidDot_ShouldFold;

    [Test]
    procedure KeyFoldingSafe_ChainEndsWithPrimitive_ShouldFold;

    [Test]
    procedure KeyFoldingSafe_ChainEndsWithArray_ShouldFold;

    [Test]
    procedure KeyFoldingSafe_ChainEndsWithObject_ShouldNotFold;

    [Test]
    procedure KeyFoldingSafe_MultipleKeysAtEnd_ShouldNotFold;

    [Test]
    procedure KeyFoldingSafe_CollisionDetection_ShouldNotFold;

    [Test]
    procedure KeyFoldingAggressive_ShouldFoldMoreCases;
  end;

implementation

uses
  Toon4D,
  Toon4D.Types;

procedure TKeyFoldingTests.KeyFoldingDisabled_ShouldNotFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Level2: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level2 := TJSONObject.Create;
    Level2.AddPair('value', TJSONNumber.Create(42));
    Level1.AddPair('metadata', Level2);
    JsonObject.AddPair('data', Level1);

    Options := [TToonOption.KeyFoldingNone];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Expected := '''
data:
  metadata:
    value: 42
'''.Trim;

    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingSafe_SingleKeyChain_ShouldFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level1.AddPair('value', TJSONNumber.Create(42));
    JsonObject.AddPair('data', Level1);

    Options := [TToonOption.KeyFoldingSafe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Expected := 'data.value: 42';
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingSafe_TwoLevelChain_ShouldFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Level2: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level2 := TJSONObject.Create;
    Level2.AddPair('version', '1.0');
    Level1.AddPair('metadata', Level2);
    JsonObject.AddPair('data', Level1);

    Options := [TToonOption.KeyFoldingSafe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Expected := 'data.metadata.version: "1.0"';
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingSafe_ThreeLevelChain_ShouldFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Level2: TJSONObject;
  Level3: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level2 := TJSONObject.Create;
    Level3 := TJSONObject.Create;
    Level3.AddPair('count', TJSONNumber.Create(100));
    Level2.AddPair('stats', Level3);
    Level1.AddPair('metadata', Level2);
    JsonObject.AddPair('data', Level1);

    Options := [TToonOption.KeyFoldingSafe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Expected := 'data.metadata.stats.count: 100';
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingSafe_InvalidIdentifier_ShouldNotFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level1.AddPair('value', TJSONNumber.Create(42));
    JsonObject.AddPair('data-key', Level1);

    Options := [TToonOption.KeyFoldingSafe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.IsFalse(ToonOutput.Contains('data-key.value'));
    Assert.Contains(ToonOutput, '"data-key":');
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingSafe_KeyWithSpaces_ShouldNotFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level1.AddPair('value', TJSONNumber.Create(42));
    JsonObject.AddPair('data key', Level1);

    Options := [TToonOption.KeyFoldingSafe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.IsFalse(ToonOutput.Contains('.value'));
    Assert.Contains(ToonOutput, '"data key":');
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingSafe_KeyWithHyphen_ShouldNotFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level1.AddPair('value', TJSONNumber.Create(42));
    JsonObject.AddPair('data-key', Level1);

    Options := [TToonOption.KeyFoldingSafe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.IsFalse(ToonOutput.Contains('data-key.value'));
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingSafe_KeyStartingWithNumber_ShouldNotFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level1.AddPair('value', TJSONNumber.Create(42));
    JsonObject.AddPair('123data', Level1);

    Options := [TToonOption.KeyFoldingSafe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.IsFalse(ToonOutput.Contains('123data.value'));
    Assert.Contains(ToonOutput, '"123data":');
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingSafe_ValidUnderscore_ShouldFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Level2: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level2 := TJSONObject.Create;
    Level2.AddPair('value', TJSONNumber.Create(42));
    Level1.AddPair('meta_data', Level2);
    JsonObject.AddPair('user_info', Level1);

    Options := [TToonOption.KeyFoldingSafe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Expected := 'user_info.meta_data.value: 42';
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingSafe_ValidDot_ShouldFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level1.AddPair('count', TJSONNumber.Create(5));
    JsonObject.AddPair('user.name', Level1);

    Options := [TToonOption.KeyFoldingSafe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Expected := 'user.name.count: 5';
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingSafe_ChainEndsWithPrimitive_ShouldFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level1.AddPair('value', 'test');
    JsonObject.AddPair('data', Level1);

    Options := [TToonOption.KeyFoldingSafe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Expected := 'data.value: test';
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingSafe_ChainEndsWithArray_ShouldFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  JsonArray: TJSONArray;
  Options: TToonOptions;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    JsonArray := TJSONArray.Create;
    JsonArray.Add('a');
    JsonArray.Add('b');
    Level1.AddPair('items', JsonArray);
    JsonObject.AddPair('data', Level1);

    Options := [TToonOption.KeyFoldingSafe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Expected := 'data.items[2]: a,b';
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingSafe_ChainEndsWithObject_ShouldNotFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Level2: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level2 := TJSONObject.Create;
    Level2.AddPair('a', TJSONNumber.Create(1));
    Level2.AddPair('b', TJSONNumber.Create(2));
    Level1.AddPair('nested', Level2);
    JsonObject.AddPair('data', Level1);

    Options := [TToonOption.KeyFoldingSafe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.IsFalse(ToonOutput.Contains('data.nested.a'));
    Assert.Contains(ToonOutput, 'data:');
    Assert.Contains(ToonOutput, '  nested:');
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingSafe_MultipleKeysAtEnd_ShouldNotFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level1.AddPair('a', TJSONNumber.Create(1));
    Level1.AddPair('b', TJSONNumber.Create(2));
    JsonObject.AddPair('data', Level1);

    Options := [TToonOption.KeyFoldingSafe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.IsFalse(ToonOutput.Contains('data.a'));
    Assert.IsFalse(ToonOutput.Contains('data.b'));
    Assert.Contains(ToonOutput, 'data:');
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingSafe_CollisionDetection_ShouldNotFold;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level1.AddPair('value', TJSONNumber.Create(42));
    JsonObject.AddPair('data', Level1);
    JsonObject.AddPair('data.value', TJSONNumber.Create(99));

    Options := [TToonOption.KeyFoldingSafe];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.IsFalse(ToonOutput.Contains('data.value: 42'));
    Assert.Contains(ToonOutput, 'data:');
  finally
    JsonObject.Free;
  end;
end;

procedure TKeyFoldingTests.KeyFoldingAggressive_ShouldFoldMoreCases;
var
  JsonObject: TJSONObject;
  Level1: TJSONObject;
  Options: TToonOptions;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    Level1 := TJSONObject.Create;
    Level1.AddPair('value', TJSONNumber.Create(42));
    JsonObject.AddPair('data', Level1);

    Options := [TToonOption.KeyFoldingAggressive];
    ToonOutput := TToon.JsonToToon(JsonObject, Options);

    Assert.Contains(ToonOutput, 'data.value: 42');
  finally
    JsonObject.Free;
  end;
end;

end.
