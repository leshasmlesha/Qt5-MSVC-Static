@echo off
setlocal

IF exist %SSLINSTALLDIR% (
    echo Found OpenSSL
) ELSE (
    echo Could not find OpenSSL in %SSLINSTALLDIR%
    echo use "qt.bat openssl" to install it.
    exit /b 1
)

IF exist %QTDIR% (
    cd %QTDIR%
) ELSE ( 
    echo Could not find Qt sources in %QTDIR%
    exit /b 1
)

IF exist %QTBUILDDIR% (
    echo Cleaning old Qt build dir
    rd /s /q %QTBUILDDIR%
)

md %QTBUILDDIR%
cd %QTBUILDDIR%  ||  exit /b %errorlevel%

echo Configuring Qt...
set OPENSSL_ROOT_DIR=%SSLINSTALLDIR%
%QTDIR%\configure.bat -prefix %QTINSTALLDIR% ^
-platform %PLATFORM% ^
-debug-and-release ^
-static -static-runtime ^
-nomake examples -nomake tests ^
-optimize-size %EXTRABUILDOPTIONS% ^
-openssl-linked
IF %errorlevel% NEQ 0 exit /b %errorlevel%

echo Configuration complete
echo Will install to %QTINSTALLDIR%

endlocal

