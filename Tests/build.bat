@echo off
setlocal

set DCC32="c:\program files (x86)\embarcadero\studio\37.0\bin\dcc32.exe"
set PROJECT=Toon4D.Tests.dpr
set OUTPUT_DIR=.\Win32\Debug

echo Building %PROJECT%...

%DCC32% -$O- -$W+ --no-config -B -Q -TX.exe ^
  -AGenerics.Collections=System.Generics.Collections;Generics.Defaults=System.Generics.Defaults;WinTypes=Winapi.Windows;WinProcs=Winapi.Windows;DbiTypes=BDE;DbiProcs=BDE;DbiErrs=BDE ^
  -DDEBUG ^
  -E%OUTPUT_DIR% ^
  -I"c:\program files (x86)\embarcadero\studio\37.0\lib\Win32\debug";..\Source;"c:\program files (x86)\embarcadero\studio\37.0\lib\Win32\release";C:\Users\marco\Documents\Embarcadero\Studio\37.0\Imports;C:\Users\marco\Documents\Embarcadero\Studio\37.0\Imports\Win32;"c:\program files (x86)\embarcadero\studio\37.0\Imports";C:\Users\Public\Documents\Embarcadero\Studio\37.0\Dcp;"c:\program files (x86)\embarcadero\studio\37.0\include";C:\Users\marco\Documents\Embarcadero\Studio\37.0\CatalogRepository\TaurusTLS\1.0.0.33\Source\;c:\dev\components\topgrid\lib;C:\dev\components\Topgrid\Source;C:\dev\components\QuickReport6\src ^
  -LEC:\Users\Public\Documents\Embarcadero\Studio\37.0\Bpl ^
  -LNC:\Users\Public\Documents\Embarcadero\Studio\37.0\Dcp ^
  -NU%OUTPUT_DIR% ^
  -NSSystem.Win;Data.Win;Datasnap.Win;Web.Win;Soap.Win;Xml.Win;Bde;System;Xml;Data;Datasnap;Web;Soap;Winapi; ^
  -O..\Source;"c:\program files (x86)\embarcadero\studio\37.0\lib\Win32\release";C:\Users\marco\Documents\Embarcadero\Studio\37.0\Imports;C:\Users\marco\Documents\Embarcadero\Studio\37.0\Imports\Win32;"c:\program files (x86)\embarcadero\studio\37.0\Imports";C:\Users\Public\Documents\Embarcadero\Studio\37.0\Dcp;"c:\program files (x86)\embarcadero\studio\37.0\include";C:\Users\marco\Documents\Embarcadero\Studio\37.0\CatalogRepository\TaurusTLS\1.0.0.33\Source\;c:\dev\components\topgrid\lib;C:\dev\components\Topgrid\Source;C:\dev\components\QuickReport6\src ^
  -R..\Source;"c:\program files (x86)\embarcadero\studio\37.0\lib\Win32\release";C:\Users\marco\Documents\Embarcadero\Studio\37.0\Imports;C:\Users\marco\Documents\Embarcadero\Studio\37.0\Imports\Win32;"c:\program files (x86)\embarcadero\studio\37.0\Imports";C:\Users\Public\Documents\Embarcadero\Studio\37.0\Dcp;"c:\program files (x86)\embarcadero\studio\37.0\include";C:\Users\marco\Documents\Embarcadero\Studio\37.0\CatalogRepository\TaurusTLS\1.0.0.33\Source\;c:\dev\components\topgrid\lib;C:\dev\components\Topgrid\Source;C:\dev\components\QuickReport6\src ^
  -U"c:\program files (x86)\embarcadero\studio\37.0\lib\Win32\debug";..\Source;"c:\program files (x86)\embarcadero\studio\37.0\lib\Win32\release";C:\Users\marco\Documents\Embarcadero\Studio\37.0\Imports;C:\Users\marco\Documents\Embarcadero\Studio\37.0\Imports\Win32;"c:\program files (x86)\embarcadero\studio\37.0\Imports";C:\Users\Public\Documents\Embarcadero\Studio\37.0\Dcp;"c:\program files (x86)\embarcadero\studio\37.0\include";C:\Users\marco\Documents\Embarcadero\Studio\37.0\CatalogRepository\TaurusTLS\1.0.0.33\Source\;c:\dev\components\topgrid\lib;C:\dev\components\Topgrid\Source;C:\dev\components\QuickReport6\src ^
  -V ^
  -VN ^
  -NBC:\Users\Public\Documents\Embarcadero\Studio\37.0\Dcp ^
  -NHC:\Users\Public\Documents\Embarcadero\Studio\37.0\hpp\Win32 ^
  -NO%OUTPUT_DIR% ^
  %PROJECT%

if errorlevel 1 (
  echo Build failed!
  exit /b 1
)

echo Build successful!
echo Executable: %OUTPUT_DIR%\Toon4D.Tests.exe
