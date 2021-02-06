@echo off
setlocal

cd %QTBUILDDIR% ||  exit /b %errorlevel%

echo Building Qt...
jom
IF %errorlevel% NEQ 0 exit /b %errorlevel%

echo Installing Qt...
jom install
IF %errorlevel% NEQ 0 exit /b %errorlevel%

echo Qt sucessfully installed

endlocal
