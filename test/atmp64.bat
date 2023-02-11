REM Copyright (c) 2016-2022 James Cook
@echo off
set eudir=%ONEDRIVE%\euphoria-4.1.0-Windows-x64
set euinc=..\include;%euinc%
set path=%eudir%\bin;%path%
eui atmp.ex
pause
