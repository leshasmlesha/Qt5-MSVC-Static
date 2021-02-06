set arch=x86
if "%arch%" == "x64" set vcarch=amd64
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" %arch%

qt openssl
qt setup
qt build
qt extra qtimageformats
qt extra qtdeclarative
qt extra qtlocation
qt extra qtmultimedia
qt extra qtsensors
qt extra qtwebchannel
qt qtwebkit

call tools\options.bat

set arch=x64
if "%arch%" == "x64" set vcarch=amd64
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" %arch%

qt openssl
qt setup
qt build
qt extra qtimageformats
qt extra qtdeclarative
qt extra qtlocation
qt extra qtmultimedia
qt extra qtsensors
qt extra qtwebchannel
qt qtwebkit

call tools\options.bat