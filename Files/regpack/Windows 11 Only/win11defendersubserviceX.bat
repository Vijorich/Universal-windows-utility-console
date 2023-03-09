@echo off
for /f "delims=Endofsearch: " %%r in ('reg query HKLM\SYSTEM\CurrentControlSet\Services /f webthreatdefusersvc_ /k') do if %%r==0 ( echo ERROR: Windows 11 Defender Sub-Service was not found. ) else ( for /f "eol=E" %%i in ('reg query HKLM\SYSTEM\CurrentControlSet\Services /f webthreatdefusersvc_ /k') do reg add %%i /v Start /t REG_DWORD /d 4 /f )
pause