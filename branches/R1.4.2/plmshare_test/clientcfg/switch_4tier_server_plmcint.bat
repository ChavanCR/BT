@ECHO off

:: # ------------------------------------------------------------------------------
:: # switch_4tier_server.bat sitchs the 4tier_server_URLS
:: # It is called by the startup manager application on pressing the button
:: # Works with local variables as int is only existing in ZUG
:: # PARAMETER INPUT:
:: # 	CCFG_DEBUG 	... TEST (shows but not executes) ON (SHOWS DEBUG Informations) or OFF
:: # EXPECTED ENVIRONEMNT VARIABLES:
:: # 	NONE
:: # SETENVIRONEMNT VARIABLES (needed by follwo up scripts):
:: # 	NONE	
:: # ------------------------------------------------------------------------------


:: # Set these variables mannually dending on the system 

:: Usally set by the installation in the system envirment variables
:: To use it within stratup Script remove BTC4T_ or change with global settings
setlocal

:: server switch shall be done to
set BTC4T_TC_SERVER=185.48.117.113
set BTC4T_TC_SPORT=7001
set BTC4T_TC_PROTOC=http
set BTC4T_TC_SNAME=TcWeb1
set BTC4T_TC_FMS=185.48.117.113
set BTC4T_TC_FPORT=4445
set BTC4T_TC_INST=plmcint

:: Initialize handover parameter
set CCFG_DEBUG=%1
if not defined CCFG_DEBUG set CCFG_DEBUG=OFF

:: environments
set BTC4T_TC_ROOT=C:\ugs\tc\112
set SED_OUT=C:\tempugs\configuration
set SED_IN=%~dp0templates
set SED_TP=%~dp0tools

:: toshorten calls CPYT measns COPY TRAGET
set CPYT_INST=%BTC4T_TC_ROOT%\install
set CPYT_MIDT=%BTC4T_TC_ROOT%\midtierservers
set CPYT_CONF=%BTC4T_TC_ROOT%\portal\plugins\configuration_11000.2.0
set CPYT_FMS=%BTC4T_TC_ROOT%\tccs
set CPYT_LINK=%BTC4T_TC_ROOT%\portal\links


:: DEBUG: shows Parameters
if /i not "%CCFG_DEBUG%" == "OFF" (
	echo -------------- 4-tier server parameters --------------------
	echo 4tier-Server: %BTC4T_TC_SERVER%:%BTC4T_TC_SPORT% - %BTC4T_TC_SNAME%
	echo protocol: %BTC4T_TC_PROTOC%
	echo FMS: %BTC4T_TC_FMS%:%BTC4T_TC_FPORT%
	echo DEBUG: %CCFG_DEBUG%
	echo ------------------------------------------------------------
	echo .
	echo -------------- 4-tier client parameters --------------------
	echo Client root: %BTC4T_TC_ROOT%
	echo Copy Target Install: %CPYT_INST%
	echo Copy Target Midtier: %CPYT_MIDT%
	echo Copy Target Configuration: %CPYT_CONF%
	echo Copy Target FMS: %CPYT_FMS%
	echo ------------------------------------------------------------
	echo .
	echo -------------- Tool parameters --------------------
	echo SED output %SED_OUT%
	echo SED Input: %SED_IN%
	echo SED Tools: %SED_TP%
	echo ------------------------------------------------------------
	if /i "%CCFG_DEBUG%" == "TEST" (
		goto exit
	)
)

	
:: ensure that the sed out exists and is empty
if /i "%CCFG_DEBUG%" == "ON" (
	echo  Next Step: DELETE %SED_OUT%
	pause
)
if not exist %SED_OUT% mkdir %SED_OUT%
del /F /Q %SED_OUT%\*.*

:: # execute change
if /i "%CCFG_DEBUG%" == "ON" (
	echo Execute SED - changes stored in %SED_OUT%
	pause
)
%SED_TP%\sed.exe -e s/BTC4T_TC_SERVER/%BTC4T_TC_SERVER%/g -e s/BTC4T_TC_SPORT/%BTC4T_TC_SPORT%/g -e s/BTC4T_TC_SNAME/%BTC4T_TC_SNAME%/g -e s/BTC4T_TC_PROTOC/%BTC4T_TC_PROTOC%/g %SED_IN%\midtierservers.properties.template > %SED_OUT%\midtierservers.properties
%SED_TP%\sed.exe -e s/BTC4T_TC_SERVER/%BTC4T_TC_SERVER%/g -e s/BTC4T_TC_SPORT/%BTC4T_TC_SPORT%/g -e s/BTC4T_TC_SNAME/%BTC4T_TC_SNAME%/g -e s/BTC4T_TC_PROTOC/%BTC4T_TC_PROTOC%/g %SED_IN%\configuration.xml.template > %SED_OUT%\configuration.xml
%SED_TP%\sed.exe -e s/BTC4T_TC_SERVER/%BTC4T_TC_SERVER%/g -e s/BTC4T_TC_SPORT/%BTC4T_TC_SPORT%/g -e s/BTC4T_TC_SNAME/%BTC4T_TC_SNAME%/g -e s/BTC4T_TC_PROTOC/%BTC4T_TC_PROTOC%/g %SED_IN%\client_specific.properties.template > %SED_OUT%\client_specific.properties
%SED_TP%\sed.exe -e s/BTC4T_TC_FMS/%BTC4T_TC_FMS%/g -e s/BTC4T_TC_FPORT/%BTC4T_TC_FPORT%/g -e s/BTC4T_TC_PROTOC/%BTC4T_TC_PROTOC%/g -e s/BTC4T_TC_INST/%BTC4T_TC_INST%/g %SED_IN%\fcc.xml.template > %SED_OUT%\fcc.xml
%SED_TP%\sed.exe -e s/BTC4T_TC_INST/%BTC4T_TC_INST%/g %SED_IN%\btportal.link.template > %SED_OUT%\btportal.link



:: # copy to client portal
:: # execute change
if /i "%CCFG_DEBUG%" == "ON" (
	echo  Next Step: change configutation and call genreg
	pause
	echo on 
)
copy /Y /V %SED_OUT%\midtierservers.properties %CPYT_MIDT%
copy /Y /V %SED_OUT%\configuration.xml %CPYT_INST%
copy /Y /V %SED_OUT%\client_specific.properties %CPYT_CONF%
copy /Y /V %SED_OUT%\fcc.xml %CPYT_FMS%
copy /Y /V %SED_OUT%\btportal.link %CPYT_LINK%

call %SED_TP%\genregxml.bat

:exit
echo off
endlocal









