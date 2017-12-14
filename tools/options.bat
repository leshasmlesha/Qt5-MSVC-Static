@echo off

set STARTDIR=%CD%
set SRCDIR=%CD%\sources
set BUILDDIR=%CD%\build

set PLATFORM=win32-msvc2017
set QTVER=5.10.0
set ICUVER=60.1
set SSLVER=1.1.0g

set QTINSTALLDIR=C:\Qt\%QTVER%-static

set QTRELEASE=official
for %%A in (alpha beta rc) DO (echo.%QTVER% | find /I "%%A">Nul && set QTRELEASE=development)

set QTURL=http://download.qt.io/%QTRELEASE%_releases/qt/%QTVER:~0,-2%/%QTVER%/submodules/qtbase-everywhere-src-%QTVER%.zip
set QTDIR=%SRCDIR%\qtbase-everywhere-src-%QTVER%
set QTBUILDDIR=%QTDIR%\build

call set ICUVER_UNDERSCORE=%%ICUVER:.=_%%
set ICUURL=http://download.icu-project.org/files/icu4c/%ICUVER%/icu4c-%ICUVER_UNDERSCORE%-src.zip
set ICUBUILDDIR=%SRCDIR%\icu-%ICUVER%
set ICUINSTALLDIR=%QTINSTALLDIR%\icu

set SSLURL=https://www.openssl.org/source/openssl-%SSLVER%.tar.gz
set SSLBUILDDIR=%SRCDIR%\openssl-%SSLVER%
set SSLINSTALLDIR=%QTINSTALLDIR%\openssl

set PATH=C:Python27\;C:\Strawberry\perl\bin;%STARTDIR%\tools\gnuwin32\bin;%STARTDIR%\tools\jom;%PATH%
set UNIXPATH=C:\msys64\usr\bin;%PATH%

set CURLOPTS=-L -C - -O
set ZOPTS=x -aos -y
