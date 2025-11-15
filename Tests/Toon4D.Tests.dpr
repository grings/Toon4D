program Toon4D.Tests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
  DUnitX.TestFramework,
  Toon4D.Tests.Primitives in 'Toon4D.Tests.Primitives.pas',
  Toon4D.Tests.Arrays in 'Toon4D.Tests.Arrays.pas',
  Toon4D.Tests.Nesting in 'Toon4D.Tests.Nesting.pas',
  Toon4D.Tests.KeyFolding in 'Toon4D.Tests.KeyFolding.pas',
  Toon4D.Tests.Delimiters in 'Toon4D.Tests.Delimiters.pas',
  Toon4D.Tests.EdgeCases in 'Toon4D.Tests.EdgeCases.pas';

{$IFNDEF TESTINSIGHT}
var
  Runner: ITestRunner;
  Results: IRunResults;
  Logger: ITestLogger;
  NUnitLogger: ITestLogger;
{$ENDIF}

begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    TDUnitX.CheckCommandLine;
    Runner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;

    Logger := TDUnitXConsoleLogger.Create(True);
    Runner.AddLogger(Logger);

    NUnitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    Runner.AddLogger(NUnitLogger);

    Results := Runner.Execute;
    if not Results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on Exception do
      System.ExitCode := EXIT_ERRORS;
  end;
{$ENDIF}
end.
