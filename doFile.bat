@echo off
rem First argument is output, the rest are input, processed in order.
eui dofile.ex %1 %*
pause
