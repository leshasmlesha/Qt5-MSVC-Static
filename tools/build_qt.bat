@echo off
setlocal

cd %QTBUILDDIR% ||  exit /b %errorlevel%

echo Building Qt...
ninja
IF %errorlevel% NEQ 0 exit /b %errorlevel%

echo Installing Qt...
ninja install
IF %errorlevel% NEQ 0 exit /b %errorlevel%

echo Qt sucessfully installed

endlocal
