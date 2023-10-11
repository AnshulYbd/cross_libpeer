echo off

@REM launch the script in power shell or command prompt as below command
@REM cmd.exe /c .\cmake_win_build.cmd
@REM 628567ff661132941941a9a4ba68b63d  gcc-linaro-5.4.1-2017.01-i686-mingw32_arm-linux-gnueabihf.tar.xz

set root_dir=%cd%

path|find "%root_dir%\BuildTools\cmake-3.24-win\bin"    >nul || set path=%path%;%root_dir%\BuildTools\cmake-3.24-win\bin
path|find "%root_dir%\BuildTools\wget-win"    >nul || set path=%path%;%root_dir%\BuildTools\wget-win
path|find "%root_dir%\BuildTools\make-win"    >nul || set path=%path%;%root_dir%\BuildTools\make-win
path|find "%root_dir%\BuildTools\7z-win"    >nul || set path=%path%;%root_dir%\BuildTools\7z-win

set HOSTARCH=i686-mingw32

SET GCC_NAME5=gcc-linaro-5.4.1-2017.01-%HOSTARCH%_arm-linux-gnueabihf
SET GCC_NAME=%GCC_NAME5%
@REM echo "%root_dir%\toolchains\5.2\%GCC_NAME%"
set GCC_PATH="%root_dir%/toolchains/%GCC_NAME%"
set GCC_TAR_PATH="%root_dir%/toolchains/%GCC_NAME%.tar.xz"
set EXRACT_BIN="7z.exe"

if exist "%GCC_PATH%" (
	echo PATH exits %GCC_PATH%
) else (
	mkdir %root_dir%\toolchains
	cd %root_dir%\toolchains
	if exist "%GCC_TAR_PATH%" (
		echo "TAR ball exists, but not gcc folder."
	) else (
		echo "Downloading tar ball now"
		wget https://releases.linaro.org/components/toolchain/binaries/5.4-2017.01/arm-linux-gnueabihf/%GCC_NAME%.tar.xz
	)

	%EXRACT_BIN% x %GCC_NAME%.tar.xz -so | %EXRACT_BIN% x -si -y -ttar
)


rd /s /q %root_dir%\dist_release

rd /s /q %root_dir%\third_party\libsrtp\build_release
mkdir %root_dir%\third_party\libsrtp\build_release
cd %root_dir%\third_party\libsrtp\build_release
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="-fPIC" -DTEST_APPS=off -DCMAKE_INSTALL_PREFIX=%root_dir%\dist_release -DCMAKE_TOOLCHAIN_FILE=..\..\tc-%HOSTARCH%.cmake ..
cmake --build . --target install

rd /s /q %root_dir%\third_party\cJSON\build_release
mkdir %root_dir%\third_party\cJSON\build_release
cd %root_dir%\third_party\cJSON\build_release
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="-fPIC" -DBUILD_SHARED_LIBS=off -DENABLE_CJSON_TEST=off -DCMAKE_INSTALL_PREFIX=%root_dir%\dist_release -DCMAKE_TOOLCHAIN_FILE=..\..\tc-%HOSTARCH%.cmake ..
cmake --build . --target install

rd /s /q %root_dir%\third_party\mbedtls\build_release
mkdir %root_dir%\third_party\mbedtls\build_release
cd %root_dir%\third_party\mbedtls\build_release
sed -i 's/\/\/#define MBEDTLS_SSL_DTLS_SRTP/#define MBEDTLS_SSL_DTLS_SRTP/g' %root_dir%\third_party\mbedtls\include\mbedtls\mbedtls_config.h
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="-fPIC" -DENABLE_TESTING=off -DENABLE_PROGRAMS=off -DCMAKE_INSTALL_PREFIX=%root_dir%\dist_release -DCMAKE_TOOLCHAIN_FILE=..\..\tc-%HOSTARCH%.cmake ..
cmake --build . --target install

rd /s /q %root_dir%\third_party\usrsctp\build_release
mkdir %root_dir%\third_party\usrsctp\build_release
cd %root_dir%\third_party\usrsctp\build_release
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="-fPIC" -Dsctp_build_programs=off -DCMAKE_INSTALL_PREFIX=%root_dir%\dist_release -DCMAKE_TOOLCHAIN_FILE=..\..\tc-%HOSTARCH%.cmake ..
cmake --build . --target install

rd /s /q %root_dir%\third_party\MQTT-C\build_release
mkdir %root_dir%\third_party\MQTT-C\build_release
cd %root_dir%\third_party\MQTT-C\build_release
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release  -DMQTT_C_EXAMPLES=off -DCMAKE_PREFIX_PATH=%root_dir%\dist_release -DCMAKE_INSTALL_LIBDIR=%root_dir%\dist_release\lib -DCMAKE_INSTALL_INCLUDEDIR=%root_dir%\dist_release\include -DMQTT_C_MbedTLS_SUPPORT=on -DMBEDTLS_LIBRARY=%root_dir%/dist/libmbedtls.a -DMBEDTLS_INCLUDE_DIRS=%root_dir%/dist/include -DCMAKE_TOOLCHAIN_FILE=..\..\tc-%HOSTARCH%.cmake ..
cmake --build . --target install
cp %root_dir%\third_party\MQTT-C\examples\templates\mbedtls_sockets.h %root_dir%\dist_release\include\

rd /s /q %root_dir%\cmake_win_build_release
mkdir %root_dir%\cmake_win_build_release && cd %root_dir%\cmake_win_build_release

cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%root_dir%\dist_release  -DCMAKE_TOOLCHAIN_FILE=..\tc-%HOSTARCH%.cmake ..
cmake --build . --target install
cd %root_dir%