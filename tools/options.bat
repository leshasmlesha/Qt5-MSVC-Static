@echo off


set MSVCVER=2019
set QTVER=5.15.3
set SSLVER=1.1.1m
set QTWEBKIT_VER=5.212
set PREFIX=C:\Qt
set EXTRABUILDOPTIONS=-qt-sqlite
set PATH=C:\Strawberry\perl\bin;%PATH%


REM DO NOT EDIT BELOW THIS LINE

set STARTDIR=%CD%
set SRCDIR=%CD%\sources
set BUILDDIR=%CD%\build
set PLATFORM=win32-msvc%MSVCVER%
set QTINSTALLDIR=%PREFIX%\%QTVER%\msvc%MSVCVER%_%VSCMD_ARG_TGT_ARCH%_static

set QTRELEASE=official
for %%A in (alpha beta rc) DO (echo.%QTVER% | find /I "%%A">Nul && set QTRELEASE=development)

set QTURL=http://mirror.netcologne.de/qtproject/%QTRELEASE%_releases/qt/%QTVER:~0,-2%/%QTVER%/submodules/qtbase-everywhere-opensource-src-%QTVER%.zip
set QTDIR=%SRCDIR%\qtbase-everywhere-src-%QTVER%
set QTBUILDDIR=%QTDIR%\build

set SSLURL=https://www.openssl.org/source/openssl-%SSLVER%.tar.gz
set SSLBUILDDIR=%SRCDIR%\openssl-%SSLVER%
set SSLINSTALLDIR=%QTINSTALLDIR%\openssl-%SSLVER%

set CURLOPTS=-L -C - -O
set ZOPTS=x -aos -y
set PATH=%STARTDIR%\tools\gnuwin32\bin;%STARTDIR%\tools\jom;%STARTDIR%\tools\nasm;%PATH%
