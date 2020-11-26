REM Copyright (c) 2020 James J. Cook
IF NOT "%EUDIR%"=="" GOTO label
set EUDIR=%ONEDRIVE%\euphoria40
set path=%EUDIR%\bin;%path%
:label
eui calc.ex
pause
