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
%QTDIR%\configure.bat -prefix %QTINSTALLDIR% -platform %PLATFORM% ^
-opensource -release -confirm-license -opengl dynamic -static -static-runtime ^
-qt-libpng -qt-libjpeg -qt-zlib -qt-pcre -no-compile-examples -nomake examples -nomake tests ^
-optimize-size %EXTRABUILDOPTIONS% ^
-openssl-linked OPENSSL_PREFIX=%SSLINSTALLDIR%
IF %errorlevel% NEQ 0 exit /b %errorlevel%

echo Configuration complete
echo Will install to %QTINSTALLDIR%

endlocal

