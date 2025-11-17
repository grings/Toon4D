{*******************************************************}
{                                                       }
{         Toon4D Library - LLM Data Optimization        }
{                                                       }
{                 DUnitX Test Suite                     }
{               Array Encoding Tests                    }
{                                                       }
{*******************************************************}
unit Toon4D.Tests.Arrays;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.JSON;

type
  [TestFixture]
  TArrayTests = class
  public
    [Test]
    procedure ArrayEmpty_ShouldEncodeWithZeroLength;

    [Test]
    procedure ArrayPrimitivesInline_ShouldEncodeCommaSeparated;

    [Test]
    procedure ArrayStringsInline_ShouldEncodeWithQuotesWhenNeeded;

    [Test]
    procedure ArrayNumbersInline_ShouldEncodeCanonical;

    [Test]
    procedure ArrayBooleansInline_ShouldEncodeLowercase;

    [Test]
    procedure ArrayMixedPrimitivesInline_ShouldEncodeAll;

    [Test]
    procedure ArrayWithNullInline_ShouldEncodeNull;

    [Test]
    procedure ArraySingleElement_ShouldEncodeWithLengthOne;

    [Test]
    procedure ArrayTabularUniformObjects_ShouldEncodeWithFieldHeader;

    [Test]
    procedure ArrayTabularSingleRow_ShouldEncodeOneRow;

    [Test]
    procedure ArrayTabularMultipleRows_ShouldEncodeIndentedRows;

    [Test]
    procedure ArrayTabularFieldOrder_ShouldPreserveOrder;

    [Test]
    procedure ArrayTabularWithNumbers_ShouldEncodeCanonical;

    [Test]
    procedure ArrayTabularWithBooleans_ShouldEncodeLowercase;

    [Test]
    procedure ArrayTabularWithNull_ShouldEncodeNull;

    [Test]
    procedure ArrayTabularWithQuotedStrings_ShouldQuote;

    [Test]
    procedure ArrayTabularEmptyStrings_ShouldQuote;

    [Test]
    procedure ArrayListMixedTypes_ShouldEncodeWithHyphens;

    [Test]
    procedure ArrayListObjects_ShouldEncodeNestedObjects;

    [Test]
    procedure ArrayListNestedArrays_ShouldEncodeNested;

    [Test]
    procedure ArrayListPrimitiveOnHyphenLine_ShouldEncodeInline;

    [Test]
    procedure ArrayListObjectFirstFieldOnHyphen_ShouldEncodeFirstField;

    [Test]
    procedure ArrayListObjectRemainingFieldsIndented_ShouldIndent;

    [Test]
    procedure ArrayNonUniformObjects_ShouldUseListFormat;

    [Test]
    procedure ArrayObjectsWithNestedValues_ShouldUseListFormat;

    [Test]
    procedure ArrayRootLevel_ShouldEncodeWithoutKey;

    [Test]
    procedure ArrayNestedInObject_ShouldIndentProperly;

    [Test]
    procedure ArrayOfArraysPrimitives_ShouldEncodeAsListItems;

    [Test]
    procedure ArrayLengthDeclaration_ShouldMatchActualCount;
  end;

implementation

uses
  Toon4D;

procedure TArrayTests.ArrayEmpty_ShouldEncodeWithZeroLength;
var
  JsonObject: TJSONObject;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('items', TJSONArray.Create);
    Expected := 'items[0]:';
    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayPrimitivesInline_ShouldEncodeCommaSeparated;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.Add('admin');
    JsonArray.Add('user');
    JsonArray.Add('guest');
    JsonObject.AddPair('roles', JsonArray);

    Expected := 'roles[3]: admin,user,guest';
    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayStringsInline_ShouldEncodeWithQuotesWhenNeeded;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.Add('simple');
    JsonArray.Add('with spaces');
    JsonArray.Add('');
    JsonObject.AddPair('tags', JsonArray);

    Expected := 'tags[3]: simple,with spaces,""';
    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayNumbersInline_ShouldEncodeCanonical;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.AddElement(TJSONNumber.Create(1));
    JsonArray.AddElement(TJSONNumber.Create(2.5));
    JsonArray.AddElement(TJSONNumber.Create(3));
    JsonObject.AddPair('numbers', JsonArray);

    Expected := 'numbers[3]: 1,2.5,3';
    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayBooleansInline_ShouldEncodeLowercase;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.AddElement(TJSONTrue.Create);
    JsonArray.AddElement(TJSONFalse.Create);
    JsonArray.AddElement(TJSONTrue.Create);
    JsonObject.AddPair('flags', JsonArray);

    Expected := 'flags[3]: true,false,true';
    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayMixedPrimitivesInline_ShouldEncodeAll;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.Add('text');
    JsonArray.AddElement(TJSONNumber.Create(42));
    JsonArray.AddElement(TJSONTrue.Create);
    JsonArray.AddElement(TJSONNull.Create);
    JsonObject.AddPair('mixed', JsonArray);

    Expected := 'mixed[4]: text,42,true,null';
    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayWithNullInline_ShouldEncodeNull;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.AddElement(TJSONNull.Create);
    JsonArray.AddElement(TJSONNull.Create);
    JsonObject.AddPair('nulls', JsonArray);

    Expected := 'nulls[2]: null,null';
    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArraySingleElement_ShouldEncodeWithLengthOne;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.Add('single');
    JsonObject.AddPair('items', JsonArray);

    Expected := 'items[1]: single';
    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayTabularUniformObjects_ShouldEncodeWithFieldHeader;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item1: TJSONObject;
  Item2: TJSONObject;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item1 := TJSONObject.Create;
    Item1.AddPair('id', TJSONNumber.Create(1));
    Item1.AddPair('name', 'Alice');
    JsonArray.Add(Item1);

    Item2 := TJSONObject.Create;
    Item2.AddPair('id', TJSONNumber.Create(2));
    Item2.AddPair('name', 'Bob');
    JsonArray.Add(Item2);

    JsonObject.AddPair('users', JsonArray);
    ToonOutput := TToon.JsonToToon(JsonObject);

    Assert.Contains(ToonOutput, 'users[2]{id,name}:');
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayTabularSingleRow_ShouldEncodeOneRow;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('id', TJSONNumber.Create(1));
    Item.AddPair('name', 'Alice');
    JsonArray.Add(Item);

    JsonObject.AddPair('users', JsonArray);

    Expected := '''
users[1]{id,name}:
  1,Alice
'''.Trim;

    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayTabularMultipleRows_ShouldEncodeIndentedRows;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item1: TJSONObject;
  Item2: TJSONObject;
  Item3: TJSONObject;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item1 := TJSONObject.Create;
    Item1.AddPair('id', TJSONNumber.Create(1));
    Item1.AddPair('name', 'Alice');
    JsonArray.Add(Item1);

    Item2 := TJSONObject.Create;
    Item2.AddPair('id', TJSONNumber.Create(2));
    Item2.AddPair('name', 'Bob');
    JsonArray.Add(Item2);

    Item3 := TJSONObject.Create;
    Item3.AddPair('id', TJSONNumber.Create(3));
    Item3.AddPair('name', 'Charlie');
    JsonArray.Add(Item3);

    JsonObject.AddPair('users', JsonArray);

    Expected := '''
users[3]{id,name}:
  1,Alice
  2,Bob
  3,Charlie
'''.Trim;

    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayTabularFieldOrder_ShouldPreserveOrder;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('zebra', '1');
    Item.AddPair('alpha', '2');
    Item.AddPair('beta', '3');
    JsonArray.Add(Item);

    JsonObject.AddPair('items', JsonArray);
    ToonOutput := TToon.JsonToToon(JsonObject);

    Assert.Contains(ToonOutput, 'items[1]{zebra,alpha,beta}:');
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayTabularWithNumbers_ShouldEncodeCanonical;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('int', TJSONNumber.Create(42));
    Item.AddPair('decimal', TJSONNumber.Create(3.14));
    Item.AddPair('zero', TJSONNumber.Create(0));
    JsonArray.Add(Item);

    JsonObject.AddPair('numbers', JsonArray);
    ToonOutput := TToon.JsonToToon(JsonObject);

    Assert.Contains(ToonOutput, '42,3.14,0');
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayTabularWithBooleans_ShouldEncodeLowercase;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('active', TJSONTrue.Create);
    Item.AddPair('verified', TJSONFalse.Create);
    JsonArray.Add(Item);

    JsonObject.AddPair('status', JsonArray);
    ToonOutput := TToon.JsonToToon(JsonObject);

    Assert.Contains(ToonOutput, 'true,false');
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayTabularWithNull_ShouldEncodeNull;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('name', 'Alice');
    Item.AddPair('middle', TJSONNull.Create);
    JsonArray.Add(Item);

    JsonObject.AddPair('users', JsonArray);
    ToonOutput := TToon.JsonToToon(JsonObject);

    Assert.Contains(ToonOutput, 'Alice,null');
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayTabularWithQuotedStrings_ShouldQuote;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('name', 'Alice Smith');
    Item.AddPair('role', 'admin');
    JsonArray.Add(Item);

    JsonObject.AddPair('users', JsonArray);
    ToonOutput := TToon.JsonToToon(JsonObject);

    Assert.Contains(ToonOutput, 'Alice Smith,admin');
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayTabularEmptyStrings_ShouldQuote;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('name', 'Alice');
    Item.AddPair('middle', '');
    JsonArray.Add(Item);

    JsonObject.AddPair('users', JsonArray);
    ToonOutput := TToon.JsonToToon(JsonObject);

    Assert.Contains(ToonOutput, 'Alice,""');
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayListMixedTypes_ShouldEncodeWithHyphens;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.AddElement(TJSONNumber.Create(1));
    JsonArray.Add('text');
    JsonArray.AddElement(TJSONTrue.Create);
    JsonObject.AddPair('items', JsonArray);

    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual('items[3]: 1,text,true', ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayListObjects_ShouldEncodeNestedObjects;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item1: TJSONObject;
  Item2: TJSONObject;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item1 := TJSONObject.Create;
    Item1.AddPair('id', TJSONNumber.Create(1));
    Item1.AddPair('name', 'Alice');
    JsonArray.Add(Item1);

    Item2 := TJSONObject.Create;
    Item2.AddPair('id', TJSONNumber.Create(2));
    Item2.AddPair('role', 'admin');
    JsonArray.Add(Item2);

    JsonObject.AddPair('items', JsonArray);

    Expected := '''
items[2]:
  - id: 1
    name: Alice
  - id: 2
    role: admin
'''.Trim;

    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayListNestedArrays_ShouldEncodeNested;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  InnerArray1: TJSONArray;
  InnerArray2: TJSONArray;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    InnerArray1 := TJSONArray.Create;
    InnerArray1.AddElement(TJSONNumber.Create(1));
    InnerArray1.AddElement(TJSONNumber.Create(2));
    JsonArray.AddElement(InnerArray1);

    InnerArray2 := TJSONArray.Create;
    InnerArray2.AddElement(TJSONNumber.Create(3));
    InnerArray2.AddElement(TJSONNumber.Create(4));
    JsonArray.AddElement(InnerArray2);

    JsonObject.AddPair('pairs', JsonArray);

    Expected := '''
pairs[2]:
  - [2]: 1,2
  - [2]: 3,4
'''.Trim;

    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayListPrimitiveOnHyphenLine_ShouldEncodeInline;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    JsonArray.Add('first');
    JsonArray.Add('second');
    JsonObject.AddPair('items', JsonArray);

    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual('items[2]: first,second', ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayListObjectFirstFieldOnHyphen_ShouldEncodeFirstField;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('id', TJSONNumber.Create(1));
    Item.AddPair('name', 'Alice');
    JsonArray.Add(Item);

    JsonObject.AddPair('items', JsonArray);

    Expected := '''
items[1]{id,name}:
  1,Alice
'''.Trim;

    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayListObjectRemainingFieldsIndented_ShouldIndent;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  ToonOutput: string;
  Expected: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('id', TJSONNumber.Create(1));
    Item.AddPair('name', 'Alice');
    Item.AddPair('role', 'admin');
    JsonArray.Add(Item);

    JsonObject.AddPair('items', JsonArray);

    Expected := '''
items[1]{id,name,role}:
  1,Alice,admin
'''.Trim;

    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayNonUniformObjects_ShouldUseListFormat;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item1: TJSONObject;
  Item2: TJSONObject;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item1 := TJSONObject.Create;
    Item1.AddPair('id', TJSONNumber.Create(1));
    Item1.AddPair('name', 'Alice');
    JsonArray.Add(Item1);

    Item2 := TJSONObject.Create;
    Item2.AddPair('id', TJSONNumber.Create(2));
    Item2.AddPair('role', 'admin');
    JsonArray.Add(Item2);

    JsonObject.AddPair('items', JsonArray);
    ToonOutput := TToon.JsonToToon(JsonObject);

    Assert.Contains(ToonOutput, 'items[2]:');
    Assert.Contains(ToonOutput, '- id:');
    Assert.IsFalse(ToonOutput.Contains('{'));
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayObjectsWithNestedValues_ShouldUseListFormat;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Item: TJSONObject;
  Nested: TJSONObject;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Item := TJSONObject.Create;
    Item.AddPair('id', TJSONNumber.Create(1));
    Nested := TJSONObject.Create;
    Nested.AddPair('city', 'NYC');
    Item.AddPair('address', Nested);
    JsonArray.Add(Item);

    JsonObject.AddPair('users', JsonArray);
    ToonOutput := TToon.JsonToToon(JsonObject);

    Assert.Contains(ToonOutput, 'users[1]:');
    Assert.IsFalse(ToonOutput.Contains('{id,'));
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayRootLevel_ShouldEncodeWithoutKey;
var
  JsonArray: TJSONArray;
  ToonOutput: string;
  Expected: string;
begin
  JsonArray := TJSONArray.Create;
  try
    JsonArray.Add('first');
    JsonArray.Add('second');

    Expected := '[2]: first,second';
    ToonOutput := TToon.JsonToToon(JsonArray);
    Assert.AreEqual(Expected, ToonOutput);
  finally
    JsonArray.Free;
  end;
end;

procedure TArrayTests.ArrayNestedInObject_ShouldIndentProperly;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  ToonOutput: string;
  Lines: TArray<string>;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonObject.AddPair('name', 'group');

    JsonArray := TJSONArray.Create;
    JsonArray.Add('item1');
    JsonArray.Add('item2');
    JsonObject.AddPair('items', JsonArray);

    ToonOutput := TToon.JsonToToon(JsonObject);
    Lines := ToonOutput.Split([sLineBreak]);

    Assert.AreEqual('name: group', Lines[0]);
    Assert.AreEqual('items[2]: item1,item2', Lines[1]);
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayOfArraysPrimitives_ShouldEncodeAsListItems;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  Inner1: TJSONArray;
  Inner2: TJSONArray;
  ToonOutput: string;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;

    Inner1 := TJSONArray.Create;
    Inner1.Add('a');
    Inner1.Add('b');
    JsonArray.AddElement(Inner1);

    Inner2 := TJSONArray.Create;
    Inner2.Add('c');
    Inner2.Add('d');
    JsonArray.AddElement(Inner2);

    JsonObject.AddPair('matrix', JsonArray);
    ToonOutput := TToon.JsonToToon(JsonObject);

    Assert.Contains(ToonOutput, 'matrix[2]:');
    Assert.Contains(ToonOutput, '- [2]: a,b');
    Assert.Contains(ToonOutput, '- [2]: c,d');
  finally
    JsonObject.Free;
  end;
end;

procedure TArrayTests.ArrayLengthDeclaration_ShouldMatchActualCount;
var
  JsonObject: TJSONObject;
  JsonArray: TJSONArray;
  ToonOutput: string;
  Index: Integer;
begin
  JsonObject := TJSONObject.Create;
  try
    JsonArray := TJSONArray.Create;
    for Index := 1 to 10 do
    begin
      JsonArray.AddElement(TJSONNumber.Create(Index));
    end;
    JsonObject.AddPair('numbers', JsonArray);

    ToonOutput := TToon.JsonToToon(JsonObject);
    Assert.Contains(ToonOutput, 'numbers[10]:');
  finally
    JsonObject.Free;
  end;
end;

end.
