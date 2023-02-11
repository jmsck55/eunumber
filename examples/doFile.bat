REM Copyright (c) 2016-2022 James Cook
call ..\eusetenv.bat
rem First argument is output, the rest are input, processed in order.
eui dofile.ex %1 %*
pause
