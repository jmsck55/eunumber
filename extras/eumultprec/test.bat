@echo off
SET EUDIR=%ONEDRIVE%\euphoria40
SET PATH=%EUDIR%\bin;%PATH%
eui.exe test.ex
pause