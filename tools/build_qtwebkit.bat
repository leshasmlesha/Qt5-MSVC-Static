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
	git checkout .

	cd ../../
	
	copy /y Tools\patches\qtwebkit\build-qtwebkit-conan.py %EXTPATH%\Tools\qt\build-qtwebkit-conan.py
	copy /y Tools\patches\qtwebkit\conan_dependencies_version.py %EXTPATH%\Tools\qt\conan_dependencies_version.py
	copy /y Tools\patches\qtwebkit\conanfile.py %EXTPATH%\Tools\qt\conanfile.py
	copy /y Tools\patches\qtwebkit\FindLibXslt.cmake %EXTPATH%\Source\cmake\FindLibXslt.cmake
	copy /y Tools\patches\qtwebkit\FindLibXml2.cmake %EXTPATH%\Source\cmake\FindLibXml2.cmake
	copy /y Tools\patches\qtwebkit\FindICU.cmake %EXTPATH%\Source\cmake\FindICU.cmake
	copy /y Tools\patches\qtwebkit\FindJPEG.cmake %EXTPATH%\Source\cmake\FindJPEG.cmake
	copy /y Tools\patches\qtwebkit\OptionsQt.cmake %EXTPATH%\Source\cmake\OptionsQt.cmake
	copy /y Tools\patches\qtwebkit\PlatformQt.cmake %EXTPATH%\Source\WebKit\PlatformQt.cmake


	cd %EXTPATH% ||  exit /b %errorlevel%

	echo Configuring %EXTNAME%...
	IF %errorlevel% NEQ 0 exit /b %errorlevel%

	echo Building/Installing %EXTNAME%...
	if "%CL%"=="/MP" (
	set CL=
	)
	if "%if_debug%" == "debug" (
		if "%arch%" == "x86" (
			py Tools\qt\build-qtwebkit-conan.py --compiler=msvc --build_type=Debug --arch=x86 --qt=%QTINSTALLDIR% --install --cmakeargs="-DENABLE_WEBKIT2=OFF -DENABLE_OPENGL=OFF -DENABLE_TOOLS=OFF -DENABLE_TEST_SUPPORT=OFF -DUSE_STATIC_RUNTIME=ON -DENABLE_API_TESTS=OFF -DENABLE_GEOLOCATION=OFF -DENABLE_DEVICE_ORIENTATION=OFF"
		) else (
			py Tools\qt\build-qtwebkit-conan.py --compiler=msvc --build_type=Debug --qt=%QTINSTALLDIR% --install --cmakeargs="-DENABLE_WEBKIT2=OFF -DENABLE_OPENGL=OFF -DENABLE_TOOLS=OFF -DENABLE_TEST_SUPPORT=OFF -DUSE_STATIC_RUNTIME=ON -DENABLE_API_TESTS=OFF -DENABLE_GEOLOCATION=OFF -DENABLE_DEVICE_ORIENTATION=OFF"
		)
	) else (
		if "%arch%" == "x86" (
			py Tools\qt\build-qtwebkit-conan.py --compiler=msvc --arch=x86 --qt=%QTINSTALLDIR% --install --cmakeargs="-DENABLE_WEBKIT2=OFF -DENABLE_OPENGL=OFF -DENABLE_TOOLS=OFF -DENABLE_TEST_SUPPORT=OFF -DUSE_STATIC_RUNTIME=ON -DENABLE_API_TESTS=OFF -DENABLE_GEOLOCATION=OFF -DENABLE_DEVICE_ORIENTATION=OFF"
		) else (
			py Tools\qt\build-qtwebkit-conan.py --compiler=msvc --qt=%QTINSTALLDIR% --install --cmakeargs="-DENABLE_WEBKIT2=OFF -DENABLE_OPENGL=OFF -DENABLE_TOOLS=OFF -DENABLE_TEST_SUPPORT=OFF -DUSE_STATIC_RUNTIME=ON -DENABLE_API_TESTS=OFF -DENABLE_GEOLOCATION=OFF -DENABLE_DEVICE_ORIENTATION=OFF"
		)
	)
	IF %errorlevel% NEQ 0 exit /b %errorlevel%

	echo %EXTNAME% installed
) ELSE (
	echo Missing extension name!
)

endlocal
