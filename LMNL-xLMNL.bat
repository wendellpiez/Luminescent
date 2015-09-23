@echo off
rem Accept LMNLFILE as argument 1
set LMNLFILE=%1
set CALABASH=C:\Bin\xmlcalabash-1.1.8-96\xmlcalabash-1.1.8-96.jar

rem Set up call to Calabash with data stream into port 'source' (by default), wf check pipeline.
set WF_CHECK=java -jar %CALABASH% -dtext/plain@%LMNLFILE% LMNL-xLMNL.xpl

rem Go for it --
%WF_CHECK%
