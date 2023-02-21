@echo off
for /f "eol=E" %%i in ('reg query HKLM\SYSTEM\CurrentControlSet\Services /f webthreatdefusersvc_ /k') do reg add %%i /v Start /t REG_DWORD /d 4 /f
pause