REM Copyright (c) 2020 James J. Cook
@echo off
IF NOT "%EUDIR%"=="" GOTO label
set EUDIR=%ONEDRIVE%\euphoria40
set path=%EUDIR%\bin;%path%
:label
eui test.ex
pause
