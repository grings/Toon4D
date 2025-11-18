{*******************************************************}
{                                                       }
{         Toon4D Library - LLM Data Optimization        }
{                                                       }
{                 DUnitX Test Suite                     }
{                  Test Helper Classes                  }
{                                                       }
{*******************************************************}
unit Toon4D.Tests.Helpers;

interface

uses
  System.SysUtils;

type
  TToonTestHelpers = class sealed
  public
    class function NormalizeLineEndings(const S: string): string; static;
  end;

implementation

uses
  Toon4D.Consts;

class function TToonTestHelpers.NormalizeLineEndings(const S: string): string;
begin
  Result := StringReplace(S, sLineBreak, ToonLineBreak, [rfReplaceAll]);
end;

end.
