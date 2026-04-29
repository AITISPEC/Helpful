@echo off
chcp 65001 >nul
color a
title Anti Hidden
pause
dir /AS /B > list.txt
FOR /F "eol=# tokens=1* delims=:" %%i in (list.txt) do (
    attrib -s -h -r "%%i"
)
del list.txt
pause
