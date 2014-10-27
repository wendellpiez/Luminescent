set CALABASH_LMNL=C:\Bin\xmlcalabash-1.0.21-95\calabash LMNL-xLMNL.xpl

rem LMNL file should be a URI, absolute or relative to the lib/up subdirectory

set LMNLFILE=../../advicetoacaterpillar.lmnl

echo Invoking Calabash with string option provided
%CALABASH_LMNL% lmnl-file=%LMNLFILE%
