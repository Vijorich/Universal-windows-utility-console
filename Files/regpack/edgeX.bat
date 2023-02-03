@echo off
:menu
cls
echo.
echo.
echo. Disable Microsoft Edge background work
echo. Batch file by TECHNOSHAHTA
echo.
echo. discord.gg/mB6DprqmR9
echo. t.me/TECHNOSHAHTA
echo. github.com/donkrage/regpack
echo.
echo.
echo. 1. Disable Microsoft Edge background work
echo. 2. Restore all settings
echo. 3. Exit
echo.
choice /c 123 /n
if %errorlevel%==1 goto :disable
if %errorlevel%==2 goto :restore
if %errorlevel%==3 exit
goto :menu
:disable
cls
reg add HKLM\SOFTWARE\Policies\Microsoft\Edge /v BackgroundModeEnabled /t REG_DWORD /d 0 /f
reg add HKLM\SOFTWARE\Policies\Microsoft\Edge /v StartupBoostEnabled /t REG_DWORD /d 0 /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects" /f
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects" /f
for /f "delims=Endofsearch: " %%i in ('reg query HKLM\SYSTEM\CurrentControlSet\Services /f edgeupdate /k /e') do set update=%%i
if %update%==1 ( reg add HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate /v Start /t REG_DWORD /d 4 /f ) else ( echo ERROR: edgeupdate service was not found. )
for /f "delims=Endofsearch: " %%i in ('reg query HKLM\SYSTEM\CurrentControlSet\Services /f edgeupdatem /k /e') do set updatem=%%i
if %updatem%==1 ( reg add HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem /v Start /t REG_DWORD /d 4 /f ) else ( echo ERROR: edgeupdatem service was not found. )
for /f "delims=Endofsearch: " %%i in ('reg query HKLM\SYSTEM\CurrentControlSet\Services /f MicrosoftEdgeElevationService /k /e') do set elevation=%%i
if %elevation%==1 ( reg add HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService /v Start /t REG_DWORD /d 4 /f ) else ( echo ERROR: MicrosoftEdgeElevationService service was not found. )
schtasks /delete /tn MicrosoftEdgeUpdateTaskMachineCore /f
schtasks /delete /tn MicrosoftEdgeUpdateTaskMachineUA /f
echo.
pause
goto :menu
:restore
cls
reg delete HKLM\SOFTWARE\Policies\Microsoft\Edge /v BackgroundModeEnabled /f
reg delete HKLM\SOFTWARE\Policies\Microsoft\Edge /v StartupBoostEnabled /f
for /f "delims=Endofsearch: " %%i in ('reg query HKLM\SYSTEM\CurrentControlSet\Services /f edgeupdate /k /e') do set update=%%i
if %update%==1 ( reg add HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate /v Start /t REG_DWORD /d 2 /f ) else ( echo ERROR: edgeupdate service was not found. )
for /f "delims=Endofsearch: " %%i in ('reg query HKLM\SYSTEM\CurrentControlSet\Services /f edgeupdatem /k /e') do set updatem=%%i
if %updatem%==1 ( reg add HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem /v Start /t REG_DWORD /d 3 /f ) else ( echo ERROR: edgeupdatem service was not found. )
for /f "delims=Endofsearch: " %%i in ('reg query HKLM\SYSTEM\CurrentControlSet\Services /f MicrosoftEdgeElevationService /k /e') do set elevation=%%i
if %elevation%==1 ( reg add HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService /v Start /t REG_DWORD /d 3 /f ) else ( echo ERROR: MicrosoftEdgeElevationService service was not found. )
echo.
pause
goto :menu