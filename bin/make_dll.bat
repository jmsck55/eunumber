REM Copyright (c) 2016-2022 James Cook
call ..\eusetenv.bat
call ..\owsetenv.bat
pause
euc -o minieun.dll -strict -dll -wat -keep ..\include\minieun.e
pause
euc -o myeun.dll -strict -dll -wat -keep ..\include\myeunumber.e
pause
euc -o libminieun.dll -strict -dll -wat -keep libminieun.e
pause
euc -o libmyeun.dll -strict -dll -wat -keep libmyeun.e
pause
cl386.exe ..\source\TestLibMyEun.c
pause
TestLibMyEun
pause
