@echo off
rem Accept LMNLFILE as argument 1
set LMNLFILE=%1

rem Set up call to Calabash with data stream into port 'source' (by default), wf check pipeline.
set WF_CHECK=C:\Bin\xmlcalabash-1.0.21-95\calabash -dtext/plain@%LMNLFILE% LMNL-wf-check.xpl

rem Go for it --
%WF_CHECK%
