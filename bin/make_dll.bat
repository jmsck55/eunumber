REM Copyright (c) 2016-2022 James Cook
call ..\eusetenv.bat
call ..\owsetenv.bat
pause
euc -o minieun.dll -strict -dll -wat -keep ..\include\minieun.e
upx minieun.dll
pause
euc -o myeun.dll -strict -dll -wat -keep ..\include\myeunumber.e
upx myeun.dll
pause
euc -o libminieun.dll -strict -dll -wat -keep libminieun.e
upx libminieun.dll
pause
euc -o libmyeun.dll -strict -dll -wat -keep libmyeun.e
upx libmyeun.dll
pause
cl386.exe ..\source\TestLibMyEun.c
upx TestLibMyEun.exe
pause
TestLibMyEun
pause
