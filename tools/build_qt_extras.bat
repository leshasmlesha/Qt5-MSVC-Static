@echo off
setlocal EnableDelayedExpansion

set EXTPATH=%SRCDIR%\%EXTNAME%-everywhere-src-%QTVER%
set QMAKE=%QTINSTALLDIR%\bin\qmake.exe

IF NOT "%EXTNAME%" == "" (

    echo PATH: %EXTPATH%
    echo QMAKE: %QMAKE%

    set URL=http://download.qt.io/%QTRELEASE%_releases/qt/%QTVER:~0,-2%/%QTVER%/submodules/%EXTNAME%-everywhere-src-%QTVER%.zip

    cd %SRCDIR%
    echo Downloading !URL!
    curl %CURLOPTS% !URL!

    rd %EXTPATH% /s /q
    7z %ZOPTS% %EXTNAME%-everywhere-src-%QTVER%.zip || exit /b %errorlevel%
    cd ..

    cd %EXTPATH% ||  exit /b %errorlevel%

    echo Configuring %EXTNAME%...
    %QMAKE%
    IF %errorlevel% NEQ 0 exit /b %errorlevel%

    echo Building %EXTNAME%...
    jom
    IF %errorlevel% NEQ 0 exit /b %errorlevel%

    echo Installing %EXTNAME%...
    jom install
    IF %errorlevel% NEQ 0 exit /b %errorlevel%

    echo %EXTNAME% installed
) ELSE (
    echo Missing extension name!
)

endlocal
