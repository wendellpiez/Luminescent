@echo off

rem Invoke Calabash to run given pipeline (.xpr) on given LMNL instance (.lmnl)
rem ARG 1 will be the basename of the pipeline; ARG 2 will be the reference to the file name as (relative) URI

set XPR=%1
set LMNLFILE=%2
set CALABASH=C:\Bin\xmlcalabash-1.1.8-96\xmlcalabash-1.1.8-96.jar

rem Set up call to Calabash with data stream into port 'source' (by default), wf check pipeline.
set LUMINESCENT=java -jar %CALABASH% -dtext/plain@%LMNLFILE% %XPR%.xpl

echo Running XProc %XPR%.xpr on LMNL file %LMNLFILE% ...
rem Go for it --
%LUMINESCENT%
rem echo Running XProc %XPR%.xpr on LMNL file %LMNLFILE% ...
