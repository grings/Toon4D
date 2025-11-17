# Toon4D Development Context

This document provides essential context for Claude Code when working on the Toon4D library.

## Project Overview

**Toon4D** is a Delphi implementation of a JSON → TOON encoder. TOON (Token-Oriented Object Notation) is a compact serialization format optimized for LLM prompts, achieving 30-60% token reduction vs JSON.

**Status:** Alpha - Test-driven development approach. 150+ unit tests written, core implementation in progress.

## Quick Reference Links

### Official TOON Specifications
- **Main Spec:** https://github.com/toon-format/spec
- **Format Repository:** https://github.com/toon-format/toon
- **Test Fixtures (340+):** https://github.com/toon-format/spec/tree/main/tests/fixtures

### Key Documents
- `SPEC.md` - Comprehensive technical specification (1300+ lines)
- `README.md` - User-facing documentation
- This file - Development context for Claude Code

## Project Structure

```
Toon4D/
├── Source/
│   ├── Toon4D.pas              ⚠️  API skeleton only (not implemented)
│   └── Toon4D.Types.pas        ✅  Type definitions complete
├── Tests/                      ✅  150+ tests (all passing structure)
│   ├── Toon4D.Tests.Primitives.pas    (46 tests)
│   ├── Toon4D.Tests.Arrays.pas        (29 tests)
│   ├── Toon4D.Tests.Nesting.pas       (13 tests)
│   ├── Toon4D.Tests.KeyFolding.pas    (16 tests)
│   ├── Toon4D.Tests.Delimiters.pas    (15 tests)
│   └── Toon4D.Tests.EdgeCases.pas     (31 tests)
└── SPEC.md                     ✅  Complete specification
```

## Coding Standards (CRITICAL)

### Delphi Naming Conventions

**✅ PascalCase for EVERYTHING:**
```pascal
var UserName: string;           // ✅ Correct
var userName: string;           // ❌ Wrong (camelCase)
var user_name: string;          // ❌ Wrong (snake_case)
```

**✅ No prefixes for parameters/locals:**
```pascal
procedure Process(Data: string);     // ✅ Correct
procedure Process(AData: string);    // ❌ Wrong (A prefix)

var MyValue: Integer;                // ✅ Correct
var LMyValue: Integer;               // ❌ Wrong (L prefix)
```

**✅ Minimum 3 letters (except common generics):**
```pascal
var Index: Integer;              // ✅ Correct
var Idx: Integer;                // ✅ Acceptable
var I: Integer;                  // ❌ Wrong (too short)
```

**✅ F prefix allowed for class fields:**
```pascal
type
  TMyClass = class
  private
    FFieldName: string;          // ✅ Correct
    FieldName: string;           // ⚠️  Also acceptable
  end;
```

**✅ Resourcestrings use PascalCase (NO S/RS/STR prefix):**
```pascal
resourcestring
  ErrorInvalidJson = 'Invalid JSON';     // ✅ Correct
  SErrorInvalidJson = 'Invalid JSON';    // ❌ Wrong (S prefix)
```

### Control Flow

**✅ Prefer `for..in` over indexed loops:**
```pascal
for Element in JsonArray do           // ✅ Preferred
  Process(Element);

for Index := 0 to Count - 1 do        // ⚠️  Only when indexing needed
  Process(Items[Index]);
```

**✅ Every `for` loop has `begin/end`:**
```pascal
for Element in List do
begin                                  // ✅ Always use begin/end
  Process(Element);
end;
```

**✅ `begin` on new line:**
```pascal
if Condition then
begin                                  // ✅ Correct
  DoSomething;
end;

if Condition then begin                // ❌ Wrong (same line)
```

**✅ `if` without `begin/end` only if one statement on one line:**
```pascal
if Value then Exit;                    // ✅ Correct

if Value then
  Result := True;                      // ✅ Correct

if Value then
begin                                  // ✅ Correct for clarity
  Result := True;
end;
```

**✅ Never swallow exceptions:**
```pascal
try
  DoSomething;
except
  on E: Exception do
  begin
    Log(E.Message);
    raise;                             // ✅ Always re-raise or wrap
  end;
end;

try
  DoSomething;
except
  // ❌ NEVER do this (silent catch)
end;
```

### Scoped Enums

**✅ ALWAYS use scoped enums:**
```pascal
{$SCOPEDENUMS ON}
type
  TMyEnum = (Value1, Value2, Value3);
{$SCOPEDENUMS OFF}

// Usage: always qualified
var MyValue := TMyEnum.Value1;         // ✅ Correct
var MyValue := Value1;                 // ❌ Wrong (unqualified)
```

### Inline Variables

**✅ Declare variables inline where meaningful:**
```pascal
var Count := GetCount;                 // ✅ Preferred
if Count > 0 then
  Process(Count);

var I: Integer;                        // ⚠️  Only when type inference fails
I := GetCount;
```

### Multi-line Strings

**✅ Use triple-quote syntax:**
```pascal
var JsonString := '''
{
  "name": "Alice",
  "age": 30
}
''';                                   // ✅ Correct
```

### Avoid Pointers

**✅ Minimize pointer usage:**
```pascal
function GetValue: string;             // ✅ Preferred
function GetValue: PChar;              // ❌ Avoid unless necessary
```

### String Literals

**✅ No repeated literals (use constants/resourcestrings):**
```pascal
const
  DefaultName = 'Unknown';

// ✅ Correct - use constant
if Name = '' then
  Name := DefaultName;

// ❌ Wrong - repeated literal
if Name = '' then
  Name := 'Unknown';
if OtherName = '' then
  OtherName := 'Unknown';
```

### Architecture

**✅ SOLID principles:**
- Single Responsibility
- Open/Closed
- Liskov Substitution
- Interface Segregation
- Dependency Inversion

**✅ No global state** - All configuration via parameters

**✅ Specific exceptions:**
```pascal
type
  EToonException = class(Exception);
  EToonEncodingException = class(EToonException);
  EToonInvalidJsonException = class(EToonException);
```

**✅ Clear error messages with context:**
```pascal
raise EToonInvalidJsonException.CreateFmt(
  'Invalid JSON at line %d: %s', [LineNumber, Details]
);
```

### File Headers

**✅ All source files must have Embarcadero-style header:**
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
unit UnitName;

/// <summary>
/// Brief description of unit purpose
/// </summary>

interface
```

### XML Documentation

**✅ All public members need XML docs:**
```pascal
/// <summary>
/// Encodes a TJSONValue to TOON format string.
/// </summary>
/// <param name="JsonValue">The JSON value to encode. Must not be nil.</param>
/// <param name="Options">Encoding options. Defaults to safe defaults.</param>
/// <returns>TOON formatted string conforming to TOON 2.0 specification.</returns>
/// <exception cref="EToonInvalidJsonException">Raised when JsonValue is nil.</exception>
/// <remarks>
/// This method performs graceful degradation by default. NaN and Infinity are
/// converted to null per TOON spec.
/// </remarks>
class function TToon.JsonToToon(
  JsonValue: TJSONValue;
  Options: TToonOptions = []
): string;
```

## TOON Format Quick Reference

### Key Concepts

**1. Three Array Formats:**

```toon
// Inline (primitives only)
tags[3]: admin,ops,dev

// Tabular (uniform objects)
users[2]{id,name}:
  1,Alice
  2,Bob

// List (mixed/non-uniform)
items[3]:
  - 1
  - name: value
  - text
```

**2. Quote Minimization:**

Strings need quotes when:
- Empty: `""`
- Leading/trailing whitespace: `" text "`, `"text "`
- Reserved: `"true"`, `"false"`, `"null"`
- Numeric pattern: `"123"`, `"3.14"`
- Special chars: `:`, `"`, `\`, `[`, `]`, `{`, `}`, control chars
- Active delimiter: `","` when comma is delimiter
- Leading hyphen-space: `"- something"`

Otherwise unquoted: `Alice`, `hello world`, `2023-01-15`

**3. Key Encoding:**

Keys unquoted if matching: `^[A-Za-z_][A-Za-z0-9_.]*$`

```toon
user_name: Alice         // ✅ Unquoted
first-name: Bob          // ❌ Needs quotes (hyphen)
"first-name": Bob        // ✅ Quoted
```

**4. Number Normalization:**

```toon
5.0 → 5          // Remove .0
3.14000 → 3.14   // Remove trailing zeros
-0 → 0           // Normalize negative zero
NaN → null       // Convert special values
Infinity → null
```

**5. Escape Sequences (exactly 5):**

- `\\` → backslash
- `\"` → double quote
- `\n` → newline
- `\r` → carriage return
- `\t` → tab

No other escapes allowed (not \u, \x, \/, etc.)

**6. Key Folding:**

```toon
// Without folding:
data:
  metadata:
    items[2]: a,b

// With safe folding:
data.metadata.items[2]: a,b
```

**7. Indentation:**

- Use spaces only (NEVER tabs for indentation)
- Consistent indent (default 2 spaces)
- Each nesting level adds one indent

## Implementation Architecture (SPEC.md Section 2.2)

### Required Units (from spec):

```
Toon4D.pas                  ✅  API skeleton done, needs implementation
Toon4D.Types.pas            ✅  Complete
Toon4D.Consts.pas           ❌  Not created yet (resourcestrings)
Toon4D.Writer.pas           ❌  Not created (core encoding logic)
Toon4D.Analyzer.pas         ❌  Not created (array format detection)
Toon4D.Utils.pas            ❌  Not created (quoting, escaping, validation)
```

### Dependency Order (implement in this order):

```
1. Toon4D.Consts.pas        (no dependencies)
2. Toon4D.Utils.pas         (depends on: Types, Consts)
3. Toon4D.Analyzer.pas      (depends on: Types, Utils)
4. Toon4D.Writer.pas        (depends on: Types, Consts, Analyzer, Utils)
5. Toon4D.pas               (depends on: all above)
```

## Test Coverage Analysis

### ✅ Excellent Coverage (150 tests)

**Primitives (46 tests):**
- Numbers: zero, integers, decimals, scientific notation, edge cases
- Strings: quoting rules, escaping, whitespace, special characters
- Booleans and null

**Arrays (29 tests):**
- Empty arrays
- Inline primitive arrays
- Tabular arrays (uniform objects)
- List arrays (mixed types)
- Root-level arrays
- Nested arrays

**Nesting (13 tests):**
- Deep nesting
- Mixed nesting patterns

**Key Folding (16 tests):**
- Safe folding mode
- Aggressive folding mode
- Edge cases

**Delimiters (15 tests):**
- Comma (default)
- Tab
- Pipe
- Delimiter-aware quoting

**Edge Cases (31 tests):**
- Nil values, malformed JSON
- Unicode, emoji
- Very large/small numbers
- Deep structures
- Error handling

### ❌ Missing Test Coverage

**Integration Tests (NONE):**
- Real-world REST API → TOON scenarios
- Large dataset performance
- Token count benchmarks (JSON vs TOON)
- LLM comprehension validation

**Conformance Tests (NONE):**
- Official TOON spec test fixtures (340+ tests available)
- Should fetch from: https://github.com/toon-format/spec/tree/main/tests/fixtures
- Create `Toon4D.Tests.Conformance.pas` to run these

**Performance Tests (NONE):**
- Large arrays (1000+ elements)
- Deep nesting (20+ levels)
- Very long strings (10KB+)
- Memory usage profiling

## Current Implementation Status

### ✅ Complete
- Type system (`Toon4D.Types.pas`)
- Test suite structure (150+ tests)
- API design (`Toon4D.pas` - signature only)
- Specification document (SPEC.md)

### ⚠️ Stub Implementation
- `Toon4D.pas` - Only raises "Not implemented yet"

### ❌ Not Started
- `Toon4D.Consts.pas` - Resourcestrings
- `Toon4D.Utils.pas` - Helper functions
- `Toon4D.Analyzer.pas` - Array format detection
- `Toon4D.Writer.pas` - Core encoding logic
- Integration tests
- Conformance tests
- Documentation samples

## Development Approach

**Test-Driven Development (TDD):**
1. Tests are already written (150+ unit tests)
2. All tests currently fail (implementation missing)
3. Implement units in dependency order
4. Run tests frequently to validate progress
5. Aim for 100% test pass rate

**Priority Order:**
1. Core encoding (primitives, objects, arrays)
2. Array format detection (inline vs tabular vs list)
3. Quote minimization and escaping
4. Key folding
5. Delimiter handling
6. Edge cases and error handling
7. Integration tests
8. Conformance tests
9. Performance optimization

## Running Tests

```bash
# Build and run (recommended - uses build.bat):
cd Tests
./build.bat
./Win32/Debug/Toon4D.Tests.exe

# From Delphi IDE:
1. Open Toon4D.Tests.dproj
2. Press F9 to run
3. Console window now stays open (already configured)
```

**Current Status (2025-11-17):**
- Total tests: 229
- Passing: 224 (97.8%)
- Failing: 5
  - Key folding issues (3 tests)
  - Quote minimization for timestamps (1 test)
  - Collision detection (1 test)

**Note:** Console window will wait for Enter key before closing (already configured in C:\dev\Toon4D\Tests\Toon4D.Tests.dpr:52-54).

## Common Development Tasks

### Adding a New Unit

1. Create file with proper header
2. Add XML documentation
3. Follow naming conventions
4. Update uses clauses in dependent units
5. Add to project file

### Implementing a Feature

1. Review test cases for that feature
2. Understand requirements from SPEC.md
3. Check TOON spec examples
4. Write implementation
5. Run tests to validate
6. Refactor if needed

### Debugging Failed Tests

1. Run specific test: `[Test]` attribute
2. Check test expectations vs actual output
3. Review SPEC.md for requirements
4. Check official TOON spec examples
5. Fix implementation
6. Verify all related tests pass

## Key Algorithms (SPEC.md Section 5)

### Array Format Detection
```pascal
if Array.Count = 0 then
  Format := Inline
else if AllElementsArePrimitives then
  Format := Inline
else if AllElementsAreObjectsWithIdenticalPrimitiveKeys then
  Format := Tabular
else
  Format := List
```

### Quote Detection
```pascal
NeedsQuoting if:
  - Empty string
  - Leading/trailing whitespace
  - Reserved literals (true/false/null)
  - Looks like number
  - Contains special chars (:, ", \, [, ], {, }, control)
  - Contains active delimiter
  - Starts with "- "
```

### Key Folding
```pascal
Fold single-key nested objects:
  data → metadata → items[2]: a,b
Becomes:
  data.metadata.items[2]: a,b

Safe mode: only fold valid identifiers (^[A-Za-z_][A-Za-z0-9_]*$)
Aggressive mode: implementation-defined (more permissive)
```

## Useful TOON Spec Sections

- **Section 4.1.4:** Quoting rules for values
- **Section 4.1.5:** Key encoding rules
- **Section 4.1.6:** Array header syntax
- **Section 4.1.7:** Primitive arrays (inline)
- **Section 4.1.8:** Tabular arrays
- **Section 4.1.9:** List arrays
- **Section 4.2.1:** Key folding
- **Section 5.1.2:** Array format detection algorithm
- **Section 5.1.3:** Quote minimization
- **Section 5.1.4:** Key folding algorithm

## Performance Expectations

**Token Reduction (from TOON research):**
- Uniform arrays: 30-55% reduction
- Nested objects: 20-30% reduction
- Mixed data: 15-25% reduction
- Large tabular: 40-60% reduction

**Benchmark Data (Appendix C):**
| Data Type | JSON Tokens | TOON Tokens | Reduction |
|-----------|-------------|-------------|-----------|
| 10 uniform objects | 450 | 280 | 37.8% |
| Deep hierarchy | 320 | 240 | 25.0% |
| 100 row table | 4500 | 2100 | 53.3% |

## Common Pitfalls

1. **Don't use tabs for indentation** - Always spaces
2. **Don't forget escape sequences** - Only 5 allowed
3. **Don't quote unnecessarily** - Implement quote minimization correctly
4. **Don't use wrong delimiter** - Check active delimiter in context
5. **Don't skip validation** - Implement both graceful and strict modes
6. **Don't violate naming conventions** - PascalCase everything
7. **Don't swallow exceptions** - Always re-raise or wrap
8. **Don't repeat string literals** - Use resourcestrings

## Quick Commands

```bash
# Check test coverage
grep -c "procedure.*Test" Tests/*.pas

# Count lines in source
wc -l Source/*.pas

# Find TODOs
grep -n "TODO\|FIXME\|XXX" Source/*.pas

# Run specific test (from IDE)
# Use Test attribute and Run Test context menu
```

## External Resources

When unsure about TOON behavior:
1. Check SPEC.md Section 4 (TOON 2.0 implementation details)
2. Check official spec: https://github.com/toon-format/spec
3. Review test expectations in Tests/*.pas
4. Check TypeScript reference implementation (if needed)

## Summary for Claude

**What You Need to Know:**
- This is a TDD project - tests exist, implementation doesn't
- Follow Delphi naming conventions strictly (PascalCase everything)
- Implement units in dependency order (Consts → Utils → Analyzer → Writer → Main)
- Reference SPEC.md for detailed requirements
- Aim for 100% test pass rate
- No global state - pass options as parameters
- Graceful error handling by default

**What to Avoid:**
- camelCase or snake_case naming
- A/L prefixes for parameters/locals
- S/RS/STR prefixes for resourcestrings
- Swallowing exceptions
- Repeated string literals
- Tabs for indentation
- Unnecessary pointer usage

**Priority Tasks:**
1. Implement Toon4D.Consts.pas (resourcestrings)
2. Implement Toon4D.Utils.pas (helper functions)
3. Implement Toon4D.Analyzer.pas (array detection)
4. Implement Toon4D.Writer.pas (core encoding)
5. Complete Toon4D.pas (main API)
6. Add integration tests
7. Add conformance tests

**Testing:**
- Run tests frequently (F9 in IDE)
- Console stays open for review (already configured)
- Aim for all green tests

**Documentation:**
- Keep README.md updated for users
- Keep this file updated for Claude context
- Add XML docs to all public members
