@echo off
setlocal

call tools\options.bat

IF NOT "%1"=="" (

    IF "%1"=="download" (
        call tools\download.bat
    )
    IF "%1"=="setup" (
        call tools\setup_qt.bat
    )
    IF "%1"=="build" (
        call tools\build_qt.bat
    )
    IF "%1"=="openssl" (
        call tools\build_openssl.bat
    )
    IF "%1"=="extra" (
        set EXTNAME=%2
        call tools\build_qt_extras.bat
    )
	IF "%1"=="qtwebkit" (
        set EXTNAME=%1
        call tools\build_qtwebkit.bat
    )

) ELSE (
    echo **Available commands**
    echo download: Download and extracts required sources
    echo openssl : Build OpenSSL
    echo setup : Setup Qt
    echo build : build Qt
    echo extra [name]: Download and build qt extension [name]
)

endlocal
