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
unit Toon4D.Tests.OfficialFixtures;

/// <summary>
/// Tests using official TOON specification fixture files
/// Fixtures stored locally in Tests/fixtures/ directory
/// </summary>

interface

uses
  DUnitX.TestFramework,
  System.JSON,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Generics.Collections,
  Toon4D,
  Toon4D.Types,
  Toon4D.Tests.Helpers;

type
  TFixtureTest = record
    Name: string;
    Description: string;
    Input: TJSONValue;
    Expected: string;
    Options: TToonOptions;
  end;

  [TestFixture]
  TOfficialFixturesTests = class
  public
    [Test]
    procedure Primitives_OfficialFixtures;
    [Test]
    procedure ArraysPrimitive_OfficialFixtures;
    [Test]
    procedure ArraysTabular_OfficialFixtures;
    [Test]
    procedure ArraysObjects_OfficialFixtures;
    [Test]
    procedure ArraysNested_OfficialFixtures;
    [Test]
    procedure Objects_OfficialFixtures;
    [Test]
    procedure KeyFolding_OfficialFixtures;
    [Test]
    procedure Delimiters_OfficialFixtures;
    [Test]
    procedure Whitespace_OfficialFixtures;
  end;

implementation

var
  GFixturesPath: string;

function GetFixturesPath: string;
begin
  if GFixturesPath = '' then
  begin
    var TestExePath := ExtractFilePath(ParamStr(0));
    var TestsDir := ExtractFilePath(ExcludeTrailingPathDelimiter(TestExePath));
    TestsDir := ExtractFilePath(ExcludeTrailingPathDelimiter(TestsDir));
    GFixturesPath := IncludeTrailingPathDelimiter(TestsDir) + 'fixtures\';
  end;
  Result := GFixturesPath;
end;

function LoadFixtureFile(const FileName: string): string;
begin
  var LocalPath := GetFixturesPath + FileName;

  if not TFile.Exists(LocalPath) then
    raise Exception.CreateFmt('Fixture file not found: %s', [LocalPath]);

  Result := TFile.ReadAllText(LocalPath, TEncoding.UTF8);
end;

procedure ParseOptionsFromTest(const TestObj: TJSONObject; out Options: TToonOptions);
begin
  Options := [];

  var OptionsObj: TJSONObject;
  if not TestObj.TryGetValue<TJSONObject>('options', OptionsObj) then
    Exit;

  var Delimiter: string;
  if OptionsObj.TryGetValue<string>('delimiter', Delimiter) then
  begin
    if (Delimiter = 'tab') or (Delimiter = #9) then
      Options := Options + [TToonOption.DelimiterTab]
    else if (Delimiter = 'pipe') or (Delimiter = '|') then
      Options := Options + [TToonOption.DelimiterPipe];
  end;

  var FlattenDepth: Integer;
  var HasFlattenDepthZero := OptionsObj.TryGetValue<Integer>('flattenDepth', FlattenDepth) and (FlattenDepth = 0);

  if HasFlattenDepthZero then
    Options := Options + [TToonOption.KeyFoldingNone]
  else
  begin
    var KeyFolding: string;
    if OptionsObj.TryGetValue<string>('keyFolding', KeyFolding) then
    begin
      if KeyFolding = 'safe' then
        Options := Options + [TToonOption.KeyFoldingSafe]
      else if KeyFolding = 'aggressive' then
        Options := Options + [TToonOption.KeyFoldingAggressive];
    end;

    if OptionsObj.TryGetValue<Integer>('flattenDepth', FlattenDepth) then
    begin
      if FlattenDepth = 1 then
        Options := Options + [TToonOption.KeyFoldingDepth1]
      else if FlattenDepth = 2 then
        Options := Options + [TToonOption.KeyFoldingDepth2];
    end;
  end;

  var IndentSize: Integer;
  if OptionsObj.TryGetValue<Integer>('indent', IndentSize) then
  begin
    if IndentSize = 4 then
      Options := Options + [TToonOption.Indent4Spaces];
  end;
end;

function LoadFixtures(const FileName: string): TArray<TFixtureTest>;
begin
  var JsonContent := LoadFixtureFile(FileName);
  var Results := TList<TFixtureTest>.Create;
  try
    var RootObj := TJSONObject.ParseJSONValue(JsonContent) as TJSONObject;
    try
      var TestsArray: TJSONArray;
      if not RootObj.TryGetValue<TJSONArray>('tests', TestsArray) then
        raise Exception.CreateFmt('No "tests" array found in %s', [FileName]);

      for var Index := 0 to TestsArray.Count - 1 do
      begin
        var TestObj := TestsArray.Items[Index] as TJSONObject;

        var Test: TFixtureTest;
        Test.Name := TestObj.GetValue<string>('name');
        Test.Description := TestObj.GetValue<string>('description', '');
        Test.Input := TestObj.GetValue<TJSONValue>('input').Clone as TJSONValue;
        Test.Expected := TestObj.GetValue<string>('expected');

        ParseOptionsFromTest(TestObj, Test.Options);

        Results.Add(Test);
      end;

      Result := Results.ToArray;
    finally
      RootObj.Free;
    end;
  finally
    Results.Free;
  end;
end;

procedure TOfficialFixturesTests.Primitives_OfficialFixtures;
begin
  var Fixtures := LoadFixtures('primitives.json');
  try
    for var Fixture in Fixtures do
    begin
      var Actual := TToon.JsonToToon(Fixture.Input, Fixture.Options);
      Assert.AreEqual(TToonTestHelpers.NormalizeLineEndings(Fixture.Expected), Actual, 'Test: ' + Fixture.Name);
    end;
  finally
    for var Fixture in Fixtures do
      Fixture.Input.Free;
  end;
end;

procedure TOfficialFixturesTests.ArraysPrimitive_OfficialFixtures;
begin
  var Fixtures := LoadFixtures('arrays-primitive.json');
  try
    for var Fixture in Fixtures do
    begin
      var Actual := TToon.JsonToToon(Fixture.Input, Fixture.Options);
      Assert.AreEqual(TToonTestHelpers.NormalizeLineEndings(Fixture.Expected), Actual, 'Test: ' + Fixture.Name);
    end;
  finally
    for var Fixture in Fixtures do
      Fixture.Input.Free;
  end;
end;

procedure TOfficialFixturesTests.ArraysTabular_OfficialFixtures;
begin
  var Fixtures := LoadFixtures('arrays-tabular.json');
  try
    for var Fixture in Fixtures do
    begin
      var Actual := TToon.JsonToToon(Fixture.Input, Fixture.Options);
      Assert.AreEqual(TToonTestHelpers.NormalizeLineEndings(Fixture.Expected), Actual, 'Test: ' + Fixture.Name);
    end;
  finally
    for var Fixture in Fixtures do
      Fixture.Input.Free;
  end;
end;

procedure TOfficialFixturesTests.ArraysObjects_OfficialFixtures;
begin
  var Fixtures := LoadFixtures('arrays-objects.json');
  try
    for var Fixture in Fixtures do
    begin
      var Actual := TToon.JsonToToon(Fixture.Input, Fixture.Options);
      Assert.AreEqual(TToonTestHelpers.NormalizeLineEndings(Fixture.Expected), Actual, 'Test: ' + Fixture.Name);
    end;
  finally
    for var Fixture in Fixtures do
      Fixture.Input.Free;
  end;
end;

procedure TOfficialFixturesTests.ArraysNested_OfficialFixtures;
begin
  var Fixtures := LoadFixtures('arrays-nested.json');
  try
    for var Fixture in Fixtures do
    begin
      var Actual := TToon.JsonToToon(Fixture.Input, Fixture.Options);
      Assert.AreEqual(TToonTestHelpers.NormalizeLineEndings(Fixture.Expected), Actual, 'Test: ' + Fixture.Name);
    end;
  finally
    for var Fixture in Fixtures do
      Fixture.Input.Free;
  end;
end;

procedure TOfficialFixturesTests.Objects_OfficialFixtures;
begin
  var Fixtures := LoadFixtures('objects.json');
  try
    for var Fixture in Fixtures do
    begin
      var Actual := TToon.JsonToToon(Fixture.Input, Fixture.Options);
      Assert.AreEqual(TToonTestHelpers.NormalizeLineEndings(Fixture.Expected), Actual, 'Test: ' + Fixture.Name);
    end;
  finally
    for var Fixture in Fixtures do
      Fixture.Input.Free;
  end;
end;

procedure TOfficialFixturesTests.KeyFolding_OfficialFixtures;
begin
  var Fixtures := LoadFixtures('key-folding.json');
  try
    for var Fixture in Fixtures do
    begin
      var Actual := TToon.JsonToToon(Fixture.Input, Fixture.Options);
      Assert.AreEqual(TToonTestHelpers.NormalizeLineEndings(Fixture.Expected), Actual, 'Test: ' + Fixture.Name);
    end;
  finally
    for var Fixture in Fixtures do
      Fixture.Input.Free;
  end;
end;

procedure TOfficialFixturesTests.Delimiters_OfficialFixtures;
begin
  var Fixtures := LoadFixtures('delimiters.json');
  try
    for var Fixture in Fixtures do
    begin
      var Actual := TToon.JsonToToon(Fixture.Input, Fixture.Options);
      Assert.AreEqual(TToonTestHelpers.NormalizeLineEndings(Fixture.Expected), Actual, 'Test: ' + Fixture.Name);
    end;
  finally
    for var Fixture in Fixtures do
      Fixture.Input.Free;
  end;
end;

procedure TOfficialFixturesTests.Whitespace_OfficialFixtures;
begin
  var Fixtures := LoadFixtures('whitespace.json');
  try
    for var Fixture in Fixtures do
    begin
      var Actual := TToon.JsonToToon(Fixture.Input, Fixture.Options);
      Assert.AreEqual(TToonTestHelpers.NormalizeLineEndings(Fixture.Expected), Actual, 'Test: ' + Fixture.Name);
    end;
  finally
    for var Fixture in Fixtures do
      Fixture.Input.Free;
  end;
end;

end.
