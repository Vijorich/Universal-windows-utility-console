reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v DisableAntiVirus /t REG_DWORD /d 1 /f
reg add HKLM\SOFTWARE\Policies\Microsoft\Windows\System /v EnableSmartScreen /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v ConfigureAppInstallControlEnabled /t REG_DWORD /d 0 /f
reg add HKLM\SYSTEM\CurrentControlSet\Control\CI\Config /v VulnerableDriverBlocklistEnable /t REG_DWORD /d 0 /f
reg add HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy /v VerifiedAndReputablePolicyState /t REG_DWORD /d 0 /f
reg add HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity /v Enabled /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v MitigationAuditOptions /t REG_BINARY /d 000000000000000000000000000000000000000000000000 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v MitigationOptions /t REG_BINARY /d 222222000002000000020000000000000000000000000000 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\diagsvc /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\SecurityHealthService /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\Sense /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\SgrmAgent /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\SgrmBroker /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\WdBoot /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\WdFilter /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\WdiServiceHost /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\WdiSystemHost /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\webthreatdefsvc /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\webthreatdefusersvc /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\WinDefend /v Start /t REG_DWORD /d 4 /f
reg add HKLM\SYSTEM\CurrentControlSet\Services\wscsvc /v Start /t REG_DWORD /d 4 /f
for /f "eol=E" %%i in ('reg query HKLM\SYSTEM\CurrentControlSet\Services /f webthreatdefusersvc_ /k') do reg add %%i /v Start /t REG_DWORD /d 4 /f
exit /b