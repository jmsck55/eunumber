set eudir=c:\euphoria405
set path=%eudir%\bin;%path%
echo Open Watcom Build Environment
SET PATH=C:\WATCOM\BINW;%PATH%
SET PATH=C:\WATCOM\BINNT;%PATH%
SET INCLUDE=C:\WATCOM\H\NT;%INCLUDE%
SET INCLUDE=C:\WATCOM\H\NT;%INCLUDE%
SET INCLUDE=%INCLUDE%;C:\WATCOM\H\NT\DIRECTX
SET INCLUDE=%INCLUDE%;C:\WATCOM\H\NT\DDK
SET INCLUDE=C:\WATCOM\H;%INCLUDE%
SET WATCOM=C:\WATCOM
SET EDPATH=C:\WATCOM\EDDAT
SET WHTMLHELP=C:\WATCOM\BINNT\HELP
SET WIPFC=C:\WATCOM\WIPFC
euc -o libmyeun.dll -strict -dll -wat -keep libeun.e
upx libmyeun.dll
cl386.exe TestLibMyEun.c
upx TestLibMyEun.exe
TestLibMyEun
pause