@echo off
setlocal EnableDelayedExpansion

set EXTPATH=%SRCDIR%\%EXTNAME%-opensource-src-%QTWEBKIT_VER%
set QMAKE=%QTINSTALLDIR%\bin\qmake.exe

IF NOT "%EXTNAME%" == "" (

    echo PATH: %EXTPATH%
    echo QMAKE: %QMAKE%

	set URL=http://download.qt.io/snapshots/ci/%EXTNAME%/%QTWEBKIT_VER%/latest/src/submodules/%EXTNAME%-opensource-src-%QTWEBKIT_VER%.zip

    cd %SRCDIR%
    echo Downloading !URL!
    curl %CURLOPTS% !URL!

    rd %EXTPATH% /s /q
    7z %ZOPTS% %EXTNAME%-opensource-src-%QTWEBKIT_VER%.zip || exit /b %errorlevel%
    cd ..
	
	copy /y Tools\patches\qtwebkit\build-qtwebkit-conan.py %EXTPATH%\Tools\qt\build-qtwebkit-conan.py
	copy /y Tools\patches\qtwebkit\conan_dependencies_version.py %EXTPATH%\Tools\qt\conan_dependencies_version.py
	copy /y Tools\patches\qtwebkit\conanfile.py %EXTPATH%\Tools\qt\conanfile.py
	copy /y Tools\patches\qtwebkit\FindLibXslt.cmake %EXTPATH%\Source\cmake\FindLibXslt.cmake
	copy /y Tools\patches\qtwebkit\FindLibXml2.cmake %EXTPATH%\Source\cmake\FindLibXml2.cmake
	copy /y Tools\patches\qtwebkit\FindICU.cmake %EXTPATH%\Source\cmake\FindICU.cmake

    cd %EXTPATH% ||  exit /b %errorlevel%

    echo Configuring %EXTNAME%...
    start /W "Configuring %EXTNAME%" pip3 install conan || exit /b %errorlevel%
    IF %errorlevel% NEQ 0 exit /b %errorlevel%

    echo Building/Installing %EXTNAME%...
	if "%arch%" == "x86" (
	Tools\qt\build-qtwebkit-conan.py --compiler=msvc --arch=x86 --qt=%QTINSTALLDIR% --install
    ) else (
    Tools\qt\build-qtwebkit-conan.py --compiler=msvc --qt=%QTINSTALLDIR% --install
    )
	IF %errorlevel% NEQ 0 exit /b %errorlevel%

    echo %EXTNAME% installed
) ELSE (
    echo Missing extension name!
)

endlocal
