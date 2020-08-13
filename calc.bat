IF NOT "%EUDIR%"=="" GOTO label
set eudir=c:\euphoria405
set path=c:\euphoria405\bin;%path%
:label
eui calc.ex
pause
