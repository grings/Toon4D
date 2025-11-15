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

interface

uses
  System.SysUtils;

type
  {$SCOPEDENUMS ON}
  TToonOption = (
    Indent2Spaces,
    Indent4Spaces,
    IndentCustom,
    DelimiterComma,
    DelimiterTab,
    DelimiterPipe,
    KeyFoldingNone,
    KeyFoldingSafe,
    KeyFoldingAggressive,
    PreferTabular,
    PreferList,
    ForceInlineForPrimitives,
    StrictValidation,
    LenientValidation,
    MinimalQuoting,
    AlwaysQuoteStrings,
    NormalizeNumbers,
    PreserveNumberFormat,
    NoTrailingWhitespace,
    CompactOutput,
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

  EToonException = class(Exception);
  EToonEncodingException = class(EToonException);
  EToonInvalidJsonException = class(EToonException);
  EToonConfigurationException = class(EToonException);

implementation

class function TToonConfig.Default: TToonConfig;
begin
  Result.Options := [
    TToonOption.Indent2Spaces,
    TToonOption.DelimiterComma,
    TToonOption.KeyFoldingSafe,
    TToonOption.PreferTabular
  ];
  Result.CustomIndentSize := 2;
end;

class function TToonConfig.Minimal: TToonConfig;
begin
  Result.Options := [
    TToonOption.Indent2Spaces,
    TToonOption.DelimiterComma
  ];
  Result.CustomIndentSize := 2;
end;

class function TToonConfig.Strict: TToonConfig;
begin
  Result.Options := [
    TToonOption.Indent2Spaces,
    TToonOption.DelimiterComma,
    TToonOption.StrictValidation,
    TToonOption.StrictConformance
  ];
  Result.CustomIndentSize := 2;
end;

end.
