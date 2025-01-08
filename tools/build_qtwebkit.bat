@echo off
setlocal EnableDelayedExpansion

set EXTPATH=%SRCDIR%\%EXTNAME%-%QTWEBKIT_VER%
set QMAKE=%QTINSTALLDIR%\bin\qmake.exe

IF NOT "%EXTNAME%" == "" (

	echo PATH: %EXTPATH%
	echo QMAKE: %QMAKE%

	set URL=https://github.com/qtwebkit/qtwebkit.git
	mkdir %EXTPATH%
	cd %EXTPATH%
	echo Downloading !URL!
	git clone --depth 10 -b qtwebkit-5.212 !URL! .

	cd %EXTPATH% ||  exit /b %errorlevel%

	echo Configuring %EXTNAME%...
	IF %errorlevel% NEQ 0 exit /b %errorlevel%

	echo Building/Installing %EXTNAME%...
	if "%CL%"=="/MP" (
	set CL=
	)
	if "%if_debug%" == "debug" (
		if "%arch%" == "x86" (
			py Tools\qt\build-qtwebkit-conan.py --compiler=msvc --build_type=Debug --arch=x86 --qt=%QTINSTALLDIR% --install --cmakeargs="-DENABLE_WEBKIT2=OFF -DENABLE_OPENGL=OFF -DENABLE_TOOLS=OFF -DENABLE_TEST_SUPPORT=OFF -DENABLE_API_TESTS=OFF -DENABLE_GEOLOCATION=OFF -DENABLE_DEVICE_ORIENTATION=OFF"
		) else (
			py Tools\qt\build-qtwebkit-conan.py --compiler=msvc --build_type=Debug --qt=%QTINSTALLDIR% --install --cmakeargs="-DENABLE_WEBKIT2=OFF -DENABLE_OPENGL=OFF -DENABLE_TOOLS=OFF -DENABLE_TEST_SUPPORT=OFF -DENABLE_API_TESTS=OFF -DENABLE_GEOLOCATION=OFF -DENABLE_DEVICE_ORIENTATION=OFF"
		)
	) else (
		if "%arch%" == "x86" (
			py Tools\qt\build-qtwebkit-conan.py --compiler=msvc --arch=x86 --qt=%QTINSTALLDIR% --install --cmakeargs="-DENABLE_WEBKIT2=OFF -DENABLE_OPENGL=OFF -DENABLE_TOOLS=OFF -DENABLE_TEST_SUPPORT=OFF -DENABLE_API_TESTS=OFF -DENABLE_GEOLOCATION=OFF -DENABLE_DEVICE_ORIENTATION=OFF"
		) else (
			py Tools\qt\build-qtwebkit-conan.py --compiler=msvc --qt=%QTINSTALLDIR% --install --cmakeargs="-DENABLE_WEBKIT2=OFF -DENABLE_OPENGL=OFF -DENABLE_TOOLS=OFF -DENABLE_TEST_SUPPORT=OFF -DENABLE_API_TESTS=OFF -DENABLE_GEOLOCATION=OFF -DENABLE_DEVICE_ORIENTATION=OFF"
		)
	)
	IF %errorlevel% NEQ 0 exit /b %errorlevel%

	echo %EXTNAME% installed
) ELSE (
	echo Missing extension name!
)

endlocal
