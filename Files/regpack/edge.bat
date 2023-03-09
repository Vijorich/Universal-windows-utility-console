@echo off
reg add HKLM\SOFTWARE\Policies\Microsoft\Edge /v BackgroundModeEnabled /t REG_DWORD /d 0 /f
reg add HKLM\SOFTWARE\Policies\Microsoft\Edge /v StartupBoostEnabled /t REG_DWORD /d 0 /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects" /f
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects" /f
for /f "delims=Endofsearch: " %%i in ('reg query HKLM\SYSTEM\CurrentControlSet\Services /f edgeupdate /k /e') do if %%i==0 ( echo ERROR: edgeupdate service was not found. ) else ( reg add HKLM\SYSTEM\CurrentControlSet\Services\edgeupdate /v Start /t REG_DWORD /d 4 /f )
for /f "delims=Endofsearch: " %%a in ('reg query HKLM\SYSTEM\CurrentControlSet\Services /f edgeupdatem /k /e') do if %%a==0 ( echo ERROR: edgeupdatem service was not found. ) else ( reg add HKLM\SYSTEM\CurrentControlSet\Services\edgeupdatem /v Start /t REG_DWORD /d 4 /f )
for /f "delims=Endofsearch: " %%h in ('reg query HKLM\SYSTEM\CurrentControlSet\Services /f MicrosoftEdgeElevationService /k /e') do if %%h==0 ( echo ERROR: MicrosoftEdgeElevationService service was not found. ) else ( reg add HKLM\SYSTEM\CurrentControlSet\Services\MicrosoftEdgeElevationService /v Start /t REG_DWORD /d 4 /f )
schtasks /change /tn MicrosoftEdgeUpdateTaskMachineCore /disable
schtasks /change /tn MicrosoftEdgeUpdateTaskMachineUA /disable
pause