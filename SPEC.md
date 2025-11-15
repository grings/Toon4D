# Toon4D Library - Technical Specification

**Version:** 1.0
**Date:** 2025-01-15
**Status:** Draft
**Target TOON Spec:** 2.0

---

## 1. Executive Summary

### 1.1 Purpose
Toon4D is a production-ready Delphi library that encodes JSON data to TOON (Token-Oriented Object Notation) format. TOON is a compact, human-readable serialization format designed specifically for Large Language Model (LLM) applications, achieving 30-60% token reduction compared to standard JSON while maintaining or improving LLM comprehension.

### 1.2 Scope
- **In Scope:** JSON → TOON encoding (uni-directional)
- **Out of Scope:** TOON → JSON decoding (reserved for future versions)
- **Target Spec:** Full TOON 2.0 specification compliance
- **Primary Use Case:** Optimizing structured data payloads for LLM API calls (OpenAI, Anthropic, etc.)

### 1.3 Key Features
- Complete TOON 2.0 specification implementation
- Zero external dependencies (Delphi RTL only)
- Cross-platform support (Windows, macOS, Linux, iOS, Android)
- Embarcadero-style API design (static class methods)
- Graceful error handling with spec-compliant fallbacks
- Comprehensive configurability via options set
- DUnitX test suite with official TOON conformance tests

---

## 2. Architecture

### 2.1 Design Principles
1. **SOLID Compliance:** Single responsibility, interface-driven where meaningful
2. **Zero Global State:** All configuration via options parameters
3. **Fail-Safe Defaults:** Sensible defaults for all configuration options
4. **Explicit Dependencies:** Clear boundaries between units
5. **Future-Proof:** Architecture prepared for TOON spec updates and decoder addition

### 2.2 Unit Structure

Following Embarcadero REST.* pattern:

```
Toon4D/
├── Source/
│   ├── Toon4D.pas                 // Main API (TToon static class)
│   ├── Toon4D.Types.pas           // Types, enums, attributes, options
│   ├── Toon4D.Consts.pas          // Resource strings for errors/messages
│   ├── Toon4D.Writer.pas          // Core TOON encoding logic
│   ├── Toon4D.Analyzer.pas        // JSON structure analysis (tabular detection)
│   └── Toon4D.Utils.pas           // Helper functions (quoting, escaping, validation)
├── Tests/
│   ├── Toon4D.Tests.Writer.pas
│   ├── Toon4D.Tests.Analyzer.pas
│   ├── Toon4D.Tests.Conformance.pas
│   └── Toon4D.Tests.Integration.pas
├── Samples/
│   ├── BasicUsage/
│   ├── LLMIntegration/
│   └── AdvancedOptions/
└── Docs/
    ├── README.md
    └── API.md
```

### 2.3 Dependency Graph

```
Toon4D.pas
  ├── Toon4D.Types.pas
  ├── Toon4D.Consts.pas
  ├── Toon4D.Writer.pas
  │   ├── Toon4D.Types.pas
  │   ├── Toon4D.Consts.pas
  │   ├── Toon4D.Analyzer.pas
  │   └── Toon4D.Utils.pas
  ├── Toon4D.Analyzer.pas
  │   ├── Toon4D.Types.pas
  │   └── Toon4D.Utils.pas
  └── Toon4D.Utils.pas
      ├── Toon4D.Types.pas
      └── Toon4D.Consts.pas

External Dependencies: System.JSON, System.SysUtils, System.Classes (Delphi RTL only)
```

---

## 3. API Specification

### 3.1 Main API Class: TToon

Located in `Toon4D.pas`, following Embarcadero's `TJson` pattern.

```pascal
type
  TToon = class sealed
  public
    const DefaultOptions: TToonOptions = [
      TToonOption.KeyFoldingSafe,
      TToonOption.Indent2Spaces,
      TToonOption.DelimiterComma,
      TToonOption.PreferTabular
    ];

    class function JsonToToon(
      JsonValue: TJSONValue;
      Options: TToonOptions = DefaultOptions
    ): string; overload; static;

    class function JsonToToon(
      const JsonString: string;
      Options: TToonOptions = DefaultOptions
    ): string; overload; static;

    class function Validate(
      const ToonString: string;
      out ErrorMessage: string
    ): Boolean; static;

    class function GetLibraryVersion: string; static;
  end;
```

### 3.2 Options System

Located in `Toon4D.Types.pas`.

```pascal
type
  {$SCOPEDENUMS ON}
  TToonOption = (
    // Indentation
    Indent2Spaces,
    Indent4Spaces,
    IndentCustom,

    // Delimiter selection
    DelimiterComma,
    DelimiterTab,
    DelimiterPipe,

    // Key folding strategy
    KeyFoldingNone,
    KeyFoldingSafe,
    KeyFoldingAggressive,

    // Array format preferences
    PreferTabular,
    PreferList,
    ForceInlineForPrimitives,

    // Validation strictness
    StrictValidation,
    LenientValidation,

    // Quote minimization
    MinimalQuoting,
    AlwaysQuoteStrings,

    // Number formatting
    NormalizeNumbers,
    PreserveNumberFormat,

    // Whitespace handling
    NoTrailingWhitespace,
    CompactOutput,

    // Error handling
    GracefulDegradation,
    StrictConformance
  );
  {$SCOPEDENUMS OFF}

  TToonOptions = set of TToonOption;

  TToonIndentSize = 2..8;

  TToonConfig = record
    Options: TToonOptions;
    CustomIndentSize: TToonIndentSize;
    class function Default: TToonConfig; static;
    class function Minimal: TToonConfig; static;
    class function Strict: TToonConfig; static;
  end;
```

### 3.3 Error Handling

All errors use specific exception types defined in `Toon4D.Types.pas`:

```pascal
type
  EToonException = class(Exception);
  EToonEncodingException = class(EToonException);
  EToonInvalidJsonException = class(EToonException);
  EToonConfigurationException = class(EToonException);
```

**Graceful Degradation Strategy (Default):**
- NaN/Infinity → `null` (per TOON spec)
- Invalid UTF-8 → sanitize to valid UTF-8
- Unsupported JSON types → convert to string representation
- Log warnings but continue processing

**Strict Conformance Mode:**
- Raise exceptions for any spec deviation
- Fail fast on invalid input
- Suitable for development/testing

---

## 4. TOON 2.0 Specification Implementation

### 4.1 Core Features (MUST Implement)

#### 4.1.1 Data Model
- Support all JSON primitives: string, number, boolean, null
- Preserve object key order
- Preserve array element order
- Round-trip fidelity within Delphi's floating-point precision

#### 4.1.2 Number Normalization
- Emit canonical decimal form (no exponent notation)
- No leading zeros except single "0"
- No trailing zeros in fractional parts
- Zero fractional parts rendered as integers (e.g., `5.0` → `5`)
- Normalize `-0` to `0`
- Convert `NaN` and `Infinity` to `null`

#### 4.1.3 String Escaping
Support exactly five escape sequences:
- `\\` → backslash
- `\"` → double quote
- `\n` → newline
- `\r` → carriage return
- `\t` → tab

#### 4.1.4 Quoting Rules for Values
Quote strings when containing:
- Empty content (`""`)
- Leading/trailing whitespace
- Reserved literals: `true`, `false`, `null`
- Numeric patterns
- Special characters: `:`, `"`, `\`, `[`, `]`, `{`, `}`, control characters
- Active delimiter (comma/tab/pipe)
- Leading hyphen with space (`- `)

#### 4.1.5 Key Encoding Rules
Object keys and field names:
- Unquoted if matching: `^[A-Za-z_][A-Za-z0-9_.]*$`
- Otherwise quoted and escaped per string rules

#### 4.1.6 Array Header Syntax
Format: `key[N<delimiter?>]{field1<delimiter>field2}:`
- `N` = array length (required)
- Delimiter optional in brackets (comma default, tab = `\t`, pipe = `|`)
- Field list required for tabular arrays
- Colon always terminates header

#### 4.1.7 Primitive Arrays (Inline)
```
tags[3]: admin,ops,dev
```
Empty arrays: `key[0]:`

#### 4.1.8 Tabular Arrays
Requirements:
- All elements are objects
- All objects have identical primitive-valued keys
- No nested objects/arrays in values

Format:
```
users[2]{id,name,role}:
  1,Alice,admin
  2,Bob,user
```

#### 4.1.9 List Arrays (Mixed/Non-Uniform)
When tabular requirements not met:
```
items[3]:
  - 1
  - key: value
  - text
```

#### 4.1.10 Indentation
- Use consistent spaces per level (default 2, configurable)
- **NEVER** use tabs for indentation
- Strict mode: validate exact multiples of indent size

#### 4.1.11 Delimiter Scoping
Each array header declares active delimiter for:
- Inline value splitting
- Tabular row parsing
- Nested arrays can change delimiter

### 4.2 Optional Features (SHOULD Implement)

#### 4.2.1 Key Folding
Collapse single-key wrapper chains:
```
// Without key folding:
data:
  metadata:
    items[2]: a,b

// With safe key folding:
data.metadata.items[2]: a,b
```

**Safe Mode Requirements:**
- All folded segments match `^[A-Za-z_][A-Za-z0-9_]*$`
- No collision with existing dotted keys
- No quoting needed for any segment

**Aggressive Mode:**
- Allow more segments to fold (implementation-defined)

#### 4.2.2 Custom Indent Size
Support indent sizes: 2, 4, 6, 8 spaces

#### 4.2.3 Delimiter Selection
Support three delimiters:
- Comma (`,`) - default
- Tab (`\t`) - for data with many commas
- Pipe (`|`) - for data with commas and tabs

### 4.3 Validation Requirements

#### 4.3.1 Encoder Conformance Checklist
- [x] UTF-8 output with LF line endings
- [x] Consistent indentation (no mixed spaces)
- [x] Proper escape sequences (only 5 valid types)
- [x] Delimiter-aware quoting
- [x] Array length matches actual count
- [x] Preserve key/element order
- [x] Canonical number format
- [x] `-0` → `0` conversion
- [x] `NaN`/`Infinity` → `null` conversion
- [x] No trailing whitespace per line
- [x] No trailing newline at EOF

#### 4.3.2 Strict Mode Validation
When `TToonOption.StrictValidation` enabled:
- Verify array count matches declared `[N]`
- Validate indentation is exact multiples
- Verify no tabs in indentation
- Check field consistency in tabular arrays
- Validate no blank lines inside arrays

---

## 5. Implementation Details

### 5.1 Core Algorithm: JSON → TOON Encoding

#### 5.1.1 High-Level Flow
```
1. Parse JSON string → TJSONValue (or accept TJSONValue directly)
2. Validate JSON structure
3. Analyze structure for array format detection
4. Build internal representation with formatting metadata
5. Serialize to TOON string with proper indentation/escaping
6. Validate output (if strict mode)
7. Return TOON string
```

#### 5.1.2 Array Format Detection Algorithm

Located in `Toon4D.Analyzer.pas`:

```pascal
function AnalyzeArray(JsonArray: TJSONArray): TToonArrayFormat;
begin
  if JsonArray.Count = 0 then
    Exit(TToonArrayFormat.Inline);

  if AllElementsArePrimitives(JsonArray) then
    Exit(TToonArrayFormat.Inline);

  if AllElementsAreObjectsWithIdenticalPrimitiveKeys(JsonArray) then
    Exit(TToonArrayFormat.Tabular);

  Result := TToonArrayFormat.List;
end;
```

**Tabular Eligibility Check:**
```pascal
function AllElementsAreObjectsWithIdenticalPrimitiveKeys(
  JsonArray: TJSONArray
): Boolean;
var
  FirstObject: TJSONObject;
  FieldNames: TArray<string>;
  Element: TJSONValue;
  CurrentObject: TJSONObject;
begin
  if JsonArray.Count = 0 then
    Exit(False);

  // First element must be object
  if not (JsonArray.Items[0] is TJSONObject) then
    Exit(False);

  FirstObject := JsonArray.Items[0] as TJSONObject;
  FieldNames := ExtractFieldNames(FirstObject);

  // All values in first object must be primitives
  if not AllValuesArePrimitives(FirstObject) then
    Exit(False);

  // Check remaining elements
  for Element in JsonArray do
  begin
    if not (Element is TJSONObject) then
      Exit(False);

    CurrentObject := Element as TJSONObject;

    // Must have identical field names
    if not FieldNamesMatch(CurrentObject, FieldNames) then
      Exit(False);

    // All values must be primitives
    if not AllValuesArePrimitives(CurrentObject) then
      Exit(False);
  end;

  Result := True;
end;
```

#### 5.1.3 Quote Minimization

Located in `Toon4D.Utils.pas`:

```pascal
function NeedsQuoting(const Value: string; Context: TQuoteContext): Boolean;
begin
  // Empty string always quoted
  if Value = '' then
    Exit(True);

  // Leading/trailing whitespace
  if (Value[1] = ' ') or (Value[Length(Value)] = ' ') then
    Exit(True);

  // Reserved literals
  if Value.Equals('true') or Value.Equals('false') or Value.Equals('null') then
    Exit(True);

  // Looks like number
  if LooksLikeNumber(Value) then
    Exit(True);

  // Contains special characters
  if ContainsAny(Value, [':', '"', '\', '[', ']', '{', '}']) then
    Exit(True);

  // Contains control characters
  if HasControlCharacters(Value) then
    Exit(True);

  // Contains active delimiter
  if ContainsDelimiter(Value, Context.ActiveDelimiter) then
    Exit(True);

  // Leading "- "
  if Value.StartsWith('- ') then
    Exit(True);

  Result := False;
end;
```

#### 5.1.4 Key Folding Algorithm

Located in `Toon4D.Writer.pas`:

```pascal
function TryFoldKeys(
  JsonObject: TJSONObject;
  FoldingMode: TToonKeyFoldingMode
): TToonFoldResult;
var
  CurrentObject: TJSONObject;
  FoldedPath: TStringBuilder;
  CanFold: Boolean;
begin
  Result.Success := False;
  CurrentObject := JsonObject;
  FoldedPath := TStringBuilder.Create;
  try
    CanFold := True;

    while (CurrentObject.Count = 1) and CanFold do
    begin
      var Pair := CurrentObject.Pairs[0];
      var KeyName := Pair.JsonString.Value;

      // Check if key is valid identifier segment
      if not IsValidIdentifierSegment(KeyName) then
      begin
        CanFold := False;
        Break;
      end;

      // Add to folded path
      if FoldedPath.Length > 0 then
        FoldedPath.Append('.');
      FoldedPath.Append(KeyName);

      // Check if value is object to continue folding
      if Pair.JsonValue is TJSONObject then
        CurrentObject := Pair.JsonValue as TJSONObject
      else
      begin
        // Reached the end value
        Result.Success := True;
        Result.FoldedKey := FoldedPath.ToString;
        Result.FinalValue := Pair.JsonValue;
        Break;
      end;
    end;
  finally
    FoldedPath.Free;
  end;
end;
```

### 5.2 String Building Strategy

Use `TStringBuilder` for efficient string concatenation:

```pascal
type
  TToonWriter = class
  private
    Builder: TStringBuilder;
    CurrentIndentLevel: Integer;
    IndentSize: Integer;
    ActiveDelimiter: Char;

    procedure WriteIndent;
    procedure WriteLine(const Line: string);
    procedure WriteValue(JsonValue: TJSONValue);
    procedure WriteObject(JsonObject: TJSONObject);
    procedure WriteArray(JsonArray: TJSONArray; const KeyName: string);
    procedure WriteTabularArray(JsonArray: TJSONArray; const KeyName: string);
    procedure WriteListArray(JsonArray: TJSONArray; const KeyName: string);
    procedure WriteInlineArray(JsonArray: TJSONArray; const KeyName: string);
  public
    constructor Create(Config: TToonConfig);
    destructor Destroy; override;

    function Encode(JsonValue: TJSONValue): string;
  end;
```

### 5.3 Memory Management

- All `TJSONValue` instances managed by caller (library does not take ownership)
- Internal `TStringBuilder` instances freed in destructor
- No global state or singletons
- Exception-safe resource cleanup with `try..finally`

### 5.4 Performance Considerations

**Optimization Strategy (Functionality First):**
1. Correct implementation prioritized over performance
2. Use `TStringBuilder` for string building (avoid `+` operator)
3. Pre-allocate collections with capacity hints where count known
4. Avoid redundant string allocations
5. Single-pass algorithms where possible

**NOT Required (Future Optimization):**
- Memory pooling
- Streaming/chunked encoding
- Parallel processing
- Custom memory allocators

---

## 6. Testing Strategy

### 6.1 Test Framework
**DUnitX** (Embarcadero standard)

### 6.2 Test Coverage

#### 6.2.1 Unit Tests (`Toon4D.Tests.Writer.pas`)
- Primitive value encoding (strings, numbers, booleans, null)
- Number normalization (canonical form, -0 → 0, NaN/Infinity → null)
- String escaping (all 5 escape sequences)
- Quote minimization (all quoting rules)
- Key encoding (quoted vs unquoted)
- Indentation (2-space, 4-space, custom)
- Delimiter handling (comma, tab, pipe)

#### 6.2.2 Array Format Tests (`Toon4D.Tests.Analyzer.pas`)
- Empty arrays
- Primitive arrays (inline format)
- Tabular arrays (all elements uniform objects)
- List arrays (mixed/non-uniform)
- Nested arrays
- Root-level arrays

#### 6.2.3 Key Folding Tests
- Single-key chain folding
- Safe mode validation
- Collision detection
- Invalid identifier segments

#### 6.2.4 Conformance Tests (`Toon4D.Tests.Conformance.pas`)
**Use official TOON spec test fixtures from `github.com/toon-format/spec`:**
- Clone test fixtures from repository
- Implement test runner for all fixture files
- Validate encoder output matches expected TOON
- Cover all edge cases defined in spec

Test fixture structure:
```
tests/fixtures/
├── primitives/
├── arrays/
├── objects/
├── escaping/
├── key-folding/
└── edge-cases/
```

#### 6.2.5 Integration Tests (`Toon4D.Tests.Integration.pas`)
Real-world scenarios:
- REST API response → TOON for LLM prompt
- Large nested JSON structures
- Unicode handling (emoji, multi-byte characters)
- All delimiter types with realistic data
- Configuration combinations

#### 6.2.6 Error Handling Tests
- Invalid JSON input
- Malformed structures
- Configuration conflicts (e.g., multiple delimiter options)
- Graceful degradation vs strict mode behavior

### 6.3 Test Metrics
- **Minimum Code Coverage:** 85%
- **All TOON Spec Conformance Tests:** 100% pass rate
- **Edge Cases:** 100% coverage per spec Section 14

---

## 7. Documentation Requirements

### 7.1 README.md

**Structure:**
```markdown
# Toon4D Library - LLM Data Optimization

## Overview
Brief description of TOON format and library purpose

## Installation
GetIt Package Manager instructions
Manual installation from GitHub

## Quick Start
Basic usage example

## Features
List of supported TOON 2.0 features

## Configuration
TToonOptions explanation with examples

## API Reference
Link to detailed API docs

## Examples
Link to sample projects

## Performance
Token reduction benchmarks

## Contributing
Guidelines for contributors

## License
MIT License

## Credits
TOON format specification authors
```

### 7.2 API Documentation (XML Doc Comments)

All public types/methods must have XML documentation:

```pascal
/// <summary>
/// Encodes a TJSONValue to TOON format string.
/// </summary>
/// <param name="JsonValue">The JSON value to encode. Must not be nil.</param>
/// <param name="Options">Encoding options. Defaults to DefaultOptions.</param>
/// <returns>TOON formatted string conforming to TOON 2.0 specification.</returns>
/// <exception cref="EToonInvalidJsonException">Raised when JsonValue is nil or invalid.</exception>
/// <exception cref="EToonEncodingException">Raised when encoding fails in strict mode.</exception>
/// <remarks>
/// This method performs graceful degradation by default. NaN and Infinity are
/// converted to null per TOON spec. Enable TToonOption.StrictConformance to
/// raise exceptions instead.
/// </remarks>
class function TToon.JsonToToon(
  JsonValue: TJSONValue;
  Options: TToonOptions = DefaultOptions
): string;
```

### 7.3 Sample Projects

#### 7.3.1 BasicUsage
Simple console app demonstrating:
- JSON string → TOON conversion
- TJSONObject → TOON conversion
- Different configuration options

#### 7.3.2 LLMIntegration
Realistic example:
- Call REST API to get JSON data
- Convert to TOON format
- Send to LLM (mock or real API call)
- Show token count comparison (JSON vs TOON)

#### 7.3.3 AdvancedOptions
Demonstrate:
- All delimiter types
- Key folding modes
- Custom indent sizes
- Strict vs graceful error handling

---

## 8. Distribution and Packaging

### 8.1 Package Metadata

**Package Name:** `Toon4D Library - LLM Data Optimization`

**Short Name:** `Toon4D`

**Version:** `1.0.0` (Semantic Versioning)

**Description:**
```
Production-ready JSON to TOON encoder for Delphi applications.
Encode structured data to Token-Oriented Object Notation (TOON) format
for LLM API calls with 30-60% token reduction. Full TOON 2.0 specification
compliance. Cross-platform support (Windows, macOS, Linux, iOS, Android).
```

**Keywords:** `JSON, TOON, LLM, AI, token-optimization, serialization, encoder`

**Author:** `[To Be Specified]`

**License:** MIT License

**Homepage:** `https://github.com/[organization]/toon4d`

**Support Platforms:**
- Win32
- Win64
- macOS (64-bit)
- Linux (64-bit)
- iOS (Device & Simulator)
- Android (ARM & Intel)

**Minimum Delphi Version:** Delphi 11 Alexandria

**Tested With:**
- Delphi 11 Alexandria
- Delphi 12 Athens

### 8.2 GetIt Package Structure

```
Toon4D/
├── BPL/                    # Compiled packages
├── DCP/                    # Package cache files
├── Source/                 # Source code
├── Samples/               # Example projects
├── Docs/                  # Documentation
├── Tests/                 # DUnitX test projects
├── LICENSE.txt            # MIT License
├── README.md              # Main documentation
└── Toon4D.groupproj       # Project group
```

### 8.3 GitHub Repository

**Repository:** `github.com/[organization]/toon4d`

**Branches:**
- `main` - Stable releases only
- `develop` - Active development
- `feature/*` - Feature branches
- `release/*` - Release preparation

**Tags:** Semantic versioning (e.g., `v1.0.0`, `v1.1.0`)

**GitHub Releases:**
- Include compiled BPL files
- Include source code archive
- Release notes with changelog
- Link to GetIt package

### 8.4 Continuous Integration

**Suggested CI/CD (Not Required for v1.0):**
- GitHub Actions for automated builds
- Run DUnitX tests on commit
- Build for all platforms
- Generate documentation
- Publish to GitHub Releases

---

## 9. Coding Standards

### 9.1 Delphi Style Guide Compliance

**Naming Conventions:**
- **PascalCase everywhere:** Units, types, interfaces, classes, records, methods, properties, fields, variables, parameters, constants, generics
- **Minimum 3 letters:** No single-letter identifiers (except common generics: T, K, V in external libraries)
- **Resourcestrings:** No prefix (S/RS/STR), use PascalCase with meaningful names
- **No prefixes for parameters:** No `A` prefix
- **No prefixes for local variables:** No `L` prefix
- **F prefix allowed for class fields:** `FFieldName: string;`

**Code Structure:**
- **Inline variables mandatory**
- **No comments in code** (code should be self-documenting)
- **Attributes on separate line:** After method attribute, method declaration on next line
- **Respect external library naming:** DUnitX, Spring4D conventions preserved

**Control Flow:**
- **Prefer `for..in`** over classical `for` (unless counting/indexing necessary)
- **Every `for` loop has `begin/end`**
- **`begin` on new line**
- **`if` without `begin/end`** only if entire body is one statement on one line
- **Never swallow exceptions:** Always re-raise, wrap, or handle/log in `except`
- **Use `try..finally`** for resource lifecycle

**Enums:**
```pascal
{$SCOPEDENUMS ON}
type
  TMyEnum = (Value1, Value2, Value3);
{$SCOPEDENUMS OFF}

// Usage: always qualified
var MyValue := TMyEnum.Value1;
```

**Multi-line Strings:**
```pascal
var MyString := '''
This is line one
This is line two
''';
```

**Architecture:**
- SOLID principles
- Interface-driven where meaningful
- No global state
- Clear boundaries
- Explicit dependencies
- Specific exceptions with clear error messages

**Strings & Expressions:**
- Avoid pointers where possible (`@`, `^`, `PChar` casting)
- No repeated string literals (use constants/resourcestrings for 2+ occurrences)
- Avoid complex chained expressions (use meaningful intermediate variables)

### 9.2 File Headers

All source files must have Embarcadero-style header:

```pascal
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
unit Toon4D.Types;

/// <summary>
/// Type definitions, enumerations, and attributes for Toon4D library.
/// </summary>

interface
```

### 9.3 Resource Strings

Located in `Toon4D.Consts.pas`:

```pascal
resourcestring
  ErrorInvalidJson = 'Invalid JSON input: %s';
  ErrorNilJsonValue = 'JSON value cannot be nil';
  ErrorConflictingOptions = 'Conflicting options specified: %s and %s';
  ErrorEncodingFailed = 'TOON encoding failed: %s';
  ErrorStrictValidation = 'Strict validation failed: %s';

  InfoTokenReduction = 'Token reduction: %.1f%% (%d → %d tokens)';
  InfoArrayFormatDetected = 'Array format detected: %s';
```

---

## 10. Development Phases

### 10.1 Phase 1: Foundation (Week 1)
**Deliverables:**
- `Toon4D.Types.pas` - All types, enums, options, exceptions
- `Toon4D.Consts.pas` - Resource strings
- `Toon4D.Utils.pas` - Helper functions (quoting, escaping, validation)
- Basic unit tests for utils

**Exit Criteria:**
- All types compile without errors
- Utility functions tested (quote detection, escape sequences)
- Resource strings complete

### 10.2 Phase 2: Core Encoding (Week 2)
**Deliverables:**
- `Toon4D.Analyzer.pas` - Array format detection
- `Toon4D.Writer.pas` - Core TOON encoding logic
- Unit tests for analyzer and writer

**Exit Criteria:**
- Can encode primitives, objects, arrays (all formats)
- Number normalization working
- String escaping working
- Indentation correct
- All unit tests passing

### 10.3 Phase 3: Advanced Features (Week 3)
**Deliverables:**
- Key folding implementation (safe and aggressive modes)
- All delimiter types (comma, tab, pipe)
- Custom indent sizes
- Configuration validation
- Comprehensive unit tests

**Exit Criteria:**
- All TOON 2.0 optional features implemented
- Configuration combinations tested
- Edge cases handled

### 10.4 Phase 4: API & Integration (Week 4)
**Deliverables:**
- `Toon4D.pas` - Main API class
- Integration tests
- Sample projects (BasicUsage, LLMIntegration, AdvancedOptions)

**Exit Criteria:**
- Public API finalized
- All integration tests passing
- Samples compile and run on all platforms

### 10.5 Phase 5: Conformance & Testing (Week 5)
**Deliverables:**
- `Toon4D.Tests.Conformance.pas` - Official TOON spec test runner
- All conformance tests from `toon-format/spec` repository
- Bug fixes from conformance testing

**Exit Criteria:**
- 100% TOON spec conformance tests passing
- 85%+ code coverage
- Zero known bugs

### 10.6 Phase 6: Documentation & Packaging (Week 6)
**Deliverables:**
- README.md with complete documentation
- API.md with detailed API reference
- XML documentation for all public members
- GetIt package prepared
- GitHub repository setup with CI/CD

**Exit Criteria:**
- Documentation complete and reviewed
- Package installs successfully via GetIt
- GitHub releases published
- Sample projects documented

---

## 11. Future Enhancements (Out of Scope for v1.0)

### 11.1 Version 1.x Potential Features
- TOON → JSON decoder
- TOON → Delphi object deserialization
- Streaming encoder for large datasets
- Performance optimizations (memory pooling, parallel processing)
- TOON syntax highlighting for IDE
- Visual TOON editor component

### 11.2 Version 2.x Potential Features
- TOON 3.0 specification support (if released)
- Binary TOON format (hypothetical)
- Schema validation
- TOON query language
- Integration with FireDAC datasets

---

## 12. Success Criteria

### 12.1 Technical Requirements
- [x] Full TOON 2.0 specification compliance
- [x] 100% official conformance tests passing
- [x] 85%+ code coverage
- [x] Zero external dependencies (RTL only)
- [x] Cross-platform support (Windows, macOS, Linux, iOS, Android)
- [x] Delphi 11+ compatibility
- [x] Graceful error handling (default)
- [x] Configurable options (all spec features)

### 12.2 Quality Requirements
- [x] DUnitX test suite complete
- [x] XML documentation for all public APIs
- [x] README.md with examples
- [x] Sample projects running on all platforms
- [x] Code follows Delphi style guide
- [x] No compiler warnings
- [x] No memory leaks (verified with FastMM4/FastMM5)

### 12.3 Distribution Requirements
- [x] MIT License applied
- [x] GitHub repository public
- [x] GetIt package published
- [x] Versioned releases (Semantic Versioning)
- [x] Installation instructions documented

### 12.4 Performance Requirements
- [x] Functional correctness prioritized
- [x] No obvious performance bottlenecks
- [x] Efficient string building (TStringBuilder)
- [x] Single-pass algorithms where feasible

---

## 13. Acceptance Testing

### 13.1 Developer Testing Checklist
Before submitting for review:
- [ ] All DUnitX tests pass (100%)
- [ ] All TOON conformance tests pass (100%)
- [ ] Code coverage ≥85%
- [ ] No compiler warnings or hints
- [ ] No memory leaks detected
- [ ] All platforms build successfully
- [ ] Sample projects run without errors
- [ ] Documentation complete (README, API docs, XML comments)
- [ ] Code follows style guide (automated linter check if available)

### 13.2 Integration Testing Scenarios

**Scenario 1: Basic JSON → TOON**
```pascal
var
  Json := '{"name":"Alice","age":30,"active":true}';
  Toon := TToon.JsonToToon(Json);

Assert.AreEqual('''
name: Alice
age: 30
active: true
'''.Trim, Toon);
```

**Scenario 2: Tabular Array**
```pascal
var
  Json := '{"users":[{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]}';
  Toon := TToon.JsonToToon(Json);

Assert.Contains(Toon, 'users[2]{id,name}:');
Assert.Contains(Toon, '1,Alice');
Assert.Contains(Toon, '2,Bob');
```

**Scenario 3: Key Folding**
```pascal
var
  Json := '{"data":{"metadata":{"version":"1.0"}}}';
  Options := TToon.DefaultOptions + [TToonOption.KeyFoldingSafe];
  Toon := TToon.JsonToToon(Json, Options);

Assert.Contains(Toon, 'data.metadata.version: 1.0');
```

**Scenario 4: Delimiter Options**
```pascal
var
  Json := '{"items":["a,b","c,d"]}';
  Options := [TToonOption.DelimiterPipe];
  Toon := TToon.JsonToToon(Json, Options);

Assert.Contains(Toon, 'items[2|]: a,b|c,d');
```

**Scenario 5: Number Normalization**
```pascal
var
  Json := '{"pi":3.14159,"zero":0.0,"negative":-0,"nan":null}';
  Toon := TToon.JsonToToon(Json);

Assert.Contains(Toon, 'pi: 3.14159');
Assert.Contains(Toon, 'zero: 0');
Assert.Contains(Toon, 'negative: 0');
Assert.Contains(Toon, 'nan: null');
```

**Scenario 6: Real-World LLM Use Case**
```pascal
// Simulate REST API response with user data
var
  ApiResponse := '''
  {
    "users": [
      {"id": 1, "name": "Alice Johnson", "role": "admin", "active": true},
      {"id": 2, "name": "Bob Smith", "role": "user", "active": true},
      {"id": 3, "name": "Charlie Brown", "role": "user", "active": false}
    ],
    "metadata": {
      "total": 3,
      "page": 1,
      "timestamp": "2025-01-15T10:30:00Z"
    }
  }
  ''';

var
  ToonOutput := TToon.JsonToToon(ApiResponse);
  JsonTokens := CountTokens(ApiResponse);  // Mock function
  ToonTokens := CountTokens(ToonOutput);   // Mock function
  ReductionPercent := ((JsonTokens - ToonTokens) / JsonTokens) * 100;

Assert.IsTrue(ReductionPercent >= 30,
  'Expected at least 30% token reduction for tabular data');

// Verify TOON structure
Assert.Contains(ToonOutput, 'users[3]{id,name,role,active}:');
Assert.Contains(ToonOutput, 'metadata.total: 3');
```

---

## 14. Glossary

**TOON (Token-Oriented Object Notation):** A compact, human-readable serialization format optimized for LLM prompts, achieving 30-60% token reduction vs JSON.

**Tabular Array:** TOON array format for uniform objects with identical primitive fields, rendered as CSV-style rows.

**List Array:** TOON array format for mixed/non-uniform elements, rendered with hyphen-prefixed list items.

**Inline Array:** TOON array format for primitive values, rendered as comma-separated values on single line.

**Key Folding:** TOON optimization that collapses single-key nested object chains into dotted paths (e.g., `a.b.c: value`).

**Delimiter Scoping:** TOON feature where each array header declares the active delimiter for splitting values (comma, tab, or pipe).

**Graceful Degradation:** Error handling strategy that converts invalid values to spec-compliant alternatives (e.g., NaN → null) instead of raising exceptions.

**Strict Conformance:** Error handling mode that raises exceptions for any spec deviation.

**Quote Minimization:** TOON optimization that omits quotes from strings when safe per specification rules.

**Canonical Number Format:** Decimal representation without exponent notation, no leading/trailing zeros, per TOON spec.

---

## 15. References

1. **TOON Official Specification v2.0**
   https://github.com/toon-format/spec/blob/main/SPEC.md

2. **TOON Format Repository**
   https://github.com/toon-format/toon

3. **TOON TypeScript Reference Implementation**
   https://www.npmjs.com/package/@toon-format/toon

4. **Embarcadero Delphi Documentation**
   https://docwiki.embarcadero.com/

5. **System.JSON Documentation**
   https://docwiki.embarcadero.com/Libraries/en/System.JSON

6. **DUnitX Testing Framework**
   https://github.com/VSoftTechnologies/DUnitX

---

## 16. Appendices

### Appendix A: Configuration Examples

```pascal
// Minimal configuration (fastest)
var MinimalConfig := TToonConfig.Minimal;
// Result: 2-space indent, comma delimiter, no key folding

// Default configuration (balanced)
var DefaultConfig := TToonConfig.Default;
// Result: 2-space indent, comma delimiter, safe key folding, tabular preferred

// Strict configuration (development)
var StrictConfig := TToonConfig.Strict;
// Result: All validations enabled, strict conformance, detailed errors

// Custom configuration
var CustomOptions: TToonOptions := [
  TToonOption.Indent4Spaces,
  TToonOption.DelimiterTab,
  TToonOption.KeyFoldingAggressive,
  TToonOption.PreferTabular,
  TToonOption.MinimalQuoting,
  TToonOption.GracefulDegradation
];
var CustomConfig := TToonConfig.Default;
CustomConfig.Options := CustomOptions;
CustomConfig.CustomIndentSize := 4;
```

### Appendix B: Complete API Surface

```pascal
// Main API
class function TToon.JsonToToon(JsonValue: TJSONValue; Options: TToonOptions = DefaultOptions): string; overload;
class function TToon.JsonToToon(const JsonString: string; Options: TToonOptions = DefaultOptions): string; overload;
class function TToon.Validate(const ToonString: string; out ErrorMessage: string): Boolean;
class function TToon.GetLibraryVersion: string;

// Configuration helpers
class function TToonConfig.Default: TToonConfig;
class function TToonConfig.Minimal: TToonConfig;
class function TToonConfig.Strict: TToonConfig;

// Exceptions
EToonException
EToonEncodingException
EToonInvalidJsonException
EToonConfigurationException
```

### Appendix C: Token Reduction Benchmarks

Expected token reduction percentages based on TOON format research:

| Data Type | JSON Tokens | TOON Tokens | Reduction % |
|-----------|-------------|-------------|-------------|
| Uniform array (10 objects, 5 fields) | 450 | 280 | 37.8% |
| Nested objects (deep hierarchy) | 320 | 240 | 25.0% |
| Mixed arrays (primitives + objects) | 280 | 220 | 21.4% |
| Large tabular dataset (100 rows) | 4500 | 2100 | 53.3% |
| Complex real-world API response | 1200 | 750 | 37.5% |

**Average reduction: 35-40% for typical LLM use cases**

---

## Document Control

**Version History:**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-01-15 | [Author] | Initial specification based on requirements gathering |

**Approval:**

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Product Owner | | | |
| Technical Lead | | | |
| Developer | | | |

---

**END OF SPECIFICATION**
