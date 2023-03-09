@echo off & setlocal enabledelayedexpansion
chcp 866 >nul

set _version=1.72

verify on
cd /d "%~dp0"
color 0A
mode con:cols=90 lines=20


rem													Startup check
rem ========================================================================================================
rem Created by Vijorich


:StartupCheck
title = Проверка..

for /f "tokens=6 delims=[]. " %%G in ('ver') do (
	set _build=%%G
	if "%%G" lss "10586" (
		color 04
		call :message "Эта версия windows не поддерживается!"
		pause
		exit
	)
) 

for /f %%G in ('PowerShell -Command "[Enum]::GetNames([Net.SecurityProtocolType]) -contains 'Tls12'"') do (
	if "%%G"=="False" (
		color 04
		call :message "Ваша версия PowerShell не поддерживает TLS1.2 !"
		echo:  Обновите PowerShell https://aka.ms/PSWindows
		pause
		exit
	)
)

set host1=wikipedia.org
set host2=google.com
set host3=ya.ru

ping %host1% -l 1 -n 1 >nul
if "%errorlevel%"=="1" (ping %host2% -l 1 -n 2 >nul)
if "%errorlevel%"=="1" (ping %host3% -l 1 -n 2 >nul)
if "%errorlevel%"=="0" (set "_networkState=True") else (set "_networkState=False")

if "%_networkState%"=="True" (
	cls
	goto :UpdateCheck
) else (
	cls
	goto :ConfigCheck
)


rem													Updater
rem ========================================================================================================
rem Created by Vijorich


:UpdateCheck
title = Поиск обновлений..
set _currentPath=%~dp0
set _currentPath=%_currentPath:~0,-7%

for /f %%a in ('PowerShell -Command "$PSVersionTable.PSVersion.Build"') do (set _powerShellVersion=%%a)

if "%_powerShellVersion%" GEQ "22000" (
	for /f %%a in ('PowerShell -Command "((Invoke-WebRequest -Uri "https://api.github.com/repos/Vijorich/Uber-cleaner/releases/latest").content | ConvertFrom-Json).tag_name"') do (set _newVersion=%%a)
) else (
	for /f %%a in ('PowerShell -Command "((Invoke-WebRequest -Uri "https://api.github.com/repos/Vijorich/Uber-cleaner/releases/latest" -UseBasicParsing).content | ConvertFrom-Json).tag_name"') do (set _newVersion=%%a)
)

if "%_newVersion%" gtr "%_version%" (
	call :message "Доступна новая версия!"
	call :message "%_version% ваша версия"
	call :message "%_newVersion% последняя версия"
	call :UpdateMenu
	exit /b
) else (
	if "%_newVersion%" lss "%_version%" (
		call :message "Что-то здесь не так, ваша версия выше последней, во избежание ошибок установите последнюю версию"
		call :message "%_version% ваша версия"
	call :message "%_newVersion% последняя версия"
		call :UpdateMenu
		exit /b
	) else (
		if exist "UpdateLog.txt" (
			call :message "Uber cleaner обновлен до версии !_version!"
			title = Список обновлений!
			type UpdateLog.txt
			del /f "UpdateLog.txt" >nul 2>&1
			del /f "UC.zip" >nul 2>&1
			timeout 25
			cls && goto ConfigCheck
		) else (
			cls && goto ConfigCheck
		)
	)
)
	
exit /b


:UpdateMenu
echo		1. Установить обновление
echo		2. Не сейчас
call :message
choice /C:12 /N
set _erl=%errorlevel%
if %_erl%==1 cls && call :message && goto UpdateDownload
if %_erl%==2 cls && call :message && goto ConfigCheck
goto UpdateMenu


:UpdateDownload
title = Обновление..
call :download https://github.com/Vijorich/Uber-cleaner/releases/download/%_newVersion%/UC.zip "UC.zip"
powershell -command "Expand-Archive -Force '%~dp0UC.zip' '%_currentPath%'" && start %_currentPath%/Start
exit


rem													Config check
rem ========================================================================================================
rem Created by Vijorich


:ConfigCheck
title = Поиск предустановок очистки...
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders" /v StateFlags0777"
cls
if %errorlevel% == 0 (goto :GatherInfo) else (call :CleanerSetup)


rem													System config
rem ========================================================================================================
rem Created by Vijorich


:GatherInfo
title = Распознавание версии Windows..

if %_build% geq 22000 (
	set _winver=11
) else (
	set _winver=10
)

call :message


rem													Main menu
rem ========================================================================================================
rem Created by Vijorich


:MainMenu
setlocal EnableDelayedExpansion
title = UberCleaner %_version%
setlocal DisableDelayedExpansion
echo		1. Меню очистки..
echo		2. Меню настроек реестра..
echo		3. Меню схем питания..
echo		4. Меню дополнительных настрек..
echo		5. Настроить mmagent..
echo		6. Скачать и установить программы..
echo		9. Выйти из программы
echo		0. Поддержать автора!..
call :message
choice /C:12345690 /N
set _erl=%errorlevel%
if %_erl%==1 cls && call :message && goto CleanupMenu
if %_erl%==2 cls && call :message && goto RegEditMenu
if %_erl%==3 cls && call :message && goto PowerSchemesMenu
if %_erl%==4 cls && call :message && goto AdditionalSettingsMenu
if %_erl%==5 cls && call :message "Настраиваю.." && goto MmagentSetup
if %_erl%==6 cls && call :message && goto ProgramDownload
if %_erl%==7 exit 
if %_erl%==8 cls && call :message "Вы можете сделать приятно автору uber cleaner %_version%!" && goto CheerUpAuthorMenu
goto MainMenu


rem													Additional settings Menu
rem ========================================================================================================
rem Created by Vijorich


:AdditionalSettingsMenu
title = Дополнительные настройки

echo		1. Отключить резервное хранилище
echo		2. Отключить режим гибернации
echo		3. Отключить виджеты (Windows Web Experience Pack)
echo		4. Отключить Xbox оверлеи
echo		5. Отключить Nvidia Ansel
echo		9. Вернуться в главное меню
call :message
choice /C:123459 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto offReservedStorage
if %_erl%==2 cls && powercfg -h off && call :message "Режим гибернации отключен"
if %_erl%==3 cls && goto offWindowsWebExperiencePack
if %_erl%==4 cls && goto offXboxOverlays
if %_erl%==5 cls && goto offNvidiaAnsel
if %_erl%==6 cls && call :message && goto MainMenu
goto :AdditionalSettingsMenu

:offReservedStorage
call :message "Ожидайте.."
start /wait /min %SystemRoot%\System32\Dism.exe /Online /Set-ReservedStorageState /State:Disabled
cls
call :message "Резервное хранилище отключено!"
goto :AdditionalSettingsMenu

:offWindowsWebExperiencePack
call :message "Ожидайте.."
echo Y | winget uninstall "windows web experience pack"
cls
call :message "Виджеты отключены!"
goto :AdditionalSettingsMenu

:offXboxOverlays
call :message "Ожидайте.."
PowerShell -Command "Get-AppxPackage -AllUsers Microsoft.XboxGameOverlay | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage -AllUsers Microsoft.XboxSpeechToTextOverlay | Remove-AppxPackage"
PowerShell -Command "Get-AppxPackage -AllUsers Microsoft.XboxGamingOverlay | Remove-AppxPackage"
taskkill /f /im GameBarFTServer.exe >nul 2>&1
taskkill /f /im GameBar.exe >nul 2>&1
cls
call :message "Xbox оверлеи отключены!"
goto :AdditionalSettingsMenu

:offNvidiaAnsel
set _target=NvCameraEnable.exe
for /f "delims=" %%x in ('"dir /b /s /a-d-l "%windir%\System32\DriverStore\%_target%" 2>nul"') do set _targetFullPath=%%x
if not defined _targetFullPath (call :message %_target% не найден !!! & pause >nul & goto :AdditionalSettingsMenu)
%_targetFullPath% off
call :message "Ansel отключен!"
goto :AdditionalSettingsMenu


rem													Cleanup Menu
rem ========================================================================================================
rem Created by Vijorich


:CleanupMenu
title = Меню очистки
echo		1. Нужна ли мне очистка?
echo		2. Быстрая ~1min-5min
echo		3. Рекомендуемая ~5min-1hour
echo		9. Вернуться в главное меню
echo		0. Что? Каво? Куда? .тхт
call :message
choice /C:12390 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto checkUp
if %_erl%==2 cls && goto fastCleanup
if %_erl%==3 cls && goto recommendedCleanup
if %_erl%==4 cls && call :message && goto MainMenu
if %_erl%==5 cls && goto cleanupInfo
goto CleanupMenu

:checkUp
title = Вилкой или не вилкой, вот в чем вопрос
call :message "Сейчас посмотрим.."
Dism.exe /Online /Cleanup-Image /AnalyzeComponentStore
pause
cls
call :message && goto MainMenu

:fastCleanup
setlocal DisableDelayedExpansion
title = Производится быстрая очистка
call :message "Чищу, чищу, чищу"
start /min /wait .\cleanmgrplus\Cleanmgr+.exe /cp /nowindow .\cleanmgrplus\std.cleanup
call :delete %Temp%
call :delete %WINDIR%\Temp
call :delete %SYSTEMDRIVE%\Temp
del /F /S /Q %SYSTEMDRIVE%\*.log >nul 2>&1
del /F /S /Q %SYSTEMDRIVE%\*.bak >nul 2>&1
del /F /S /Q %SYSTEMDRIVE%\*.gid >nul 2>&1
start /min /wait WSReset.exe >nul 2>&1
taskkill /f /im WinStore.App.exe >nul 2>&1
endlocal
cls
call :message "Готово!" && goto MainMenu

:recommendedCleanup
setlocal DisableDelayedExpansion
title = Производится рекомендуемая очистка
call :message "Чищу, чищу, чищу"
start /min /wait .\cleanmgrplus\Cleanmgr+.exe /cp /nowindow .\cleanmgrplus\max.cleanup
call :delete %Temp%
call :delete %WINDIR%\Temp
call :delete %SYSTEMDRIVE%\Temp
call :delete %WINDIR%\minidump
call :delete %WINDIR%\Prefetch
call :delete %UserProfile%\AppData\Local\Microsoft\Windows\WER
call :delete %UserProfile%\AppData\Local\Microsoft\Windows\Temporary Internet Files
call :delete %UserProfile%\AppData\Local\Microsoft\Windows\IECompatCache
call :delete %UserProfile%\AppData\Local\Microsoft\Windows\IECompatUaCache
call :delete %UserProfile%\AppData\Local\Microsoft\Windows\IEDownloadHistory
call :delete %UserProfile%\AppData\Local\Microsoft\Windows\INetCache
call :delete %UserProfile%\AppData\Local\Microsoft\Windows\INetCookies
call :delete %UserProfile%\AppData\Local\Microsoft\Terminal Server Client\Cache
call :delete %WINDIR%\SoftwareDistribution\Download
del /F /S /Q %SYSTEMDRIVE%\*.log >nul 2>&1
del /F /S /Q %SYSTEMDRIVE%\*.bak >nul 2>&1
del /F /S /Q %SYSTEMDRIVE%\*.gid >nul 2>&1
start /min /wait WSReset.exe >nul 2>&1
taskkill /f /im WinStore.App.exe >nul 2>&1
ipconfig /flushdns >nul 2>&1
ipconfig /release >nul 2>&1
arp -d * >nul 2>&1
nbtstat -R >nul 2>&1
netsh int ip reset >nul 2>&1
netsh winsock reset >nul 2>&1
ipconfig /renew >nul 2>&1
Dism /online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1
Dism /online /Cleanup-Image /SPSuperseded >nul 2>&1
vssadmin delete shadows /all /quiet >nul 2>&1
echo Y | chkdsk /f /r /b
shutdown /r /t 60 /c "Через минуту перезагрузка, сохраните все данные!"
endlocal
exit

:cleanupInfo
start %~dp0\cleanmgrplus\readme.txt
call :message && goto CleanupMenu


rem													Reg Edit Menu
rem ========================================================================================================
rem Created by Vijorich


:RegEditMenu
title = Меню .reg файлов
echo		1. Просто применить рекомендуемые настройки
echo		2. Точечная настройка (для любой версии шиндус)
echo		3. Только для 10 шиндуса
echo		4. Только для 11 шиндуса
echo		9. Вернуться в главное меню!
echo		0. Це шо? .тхт
call :message
choice /C:123490 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto RegEditFullReg
if %_erl%==2 cls && call :message && goto RegEditFirstPage
if %_erl%==3 cls && call :message && goto RegEditWindows10Only
if %_erl%==4 cls && call :message && goto RegEditWindows11Only
if %_erl%==5 cls && call :message && goto MainMenu
if %_erl%==6 cls && goto regEditInfo
goto RegEditMenu

:regEditInfo
start %~dp0\regpack\readme.txt
call :message && goto RegEditFirstPage

:RegEditFullReg
if %_build% GEQ 22000 (
	call :regEditImport "\Windows 11 Only\win11contextmenu" "\Windows 11 Only\win11priority" "\Windows 11 Only\win11shareitem"
	call :regEditTrustedImport "\Windows 11 Only\win11defenderX"
	call :batTrustedImport "\Windows 11 Only\win11defendersubserviceX"
	call :regEditFullRegForAll
	cls && call :message "Применил общие .рег файлы для шиндус 11!" && goto MainMenu
) else (
	call :regEditImport "\Windows 10 Only\win10folder3d" "\Windows 10 Only\win10networkwizard" "\Windows 10 Only\win10priority" "\Windows 10 Only\win10shareitem" "\Windows 10 Only\win10showsecondsinsystemclock"
    call :regEditTrustedImport "\Windows 10 Only\win10defenderX"
	call :regEditFullRegForAll
	cls && call :message "Применил общие .рег файлы для шиндус 10!" && goto MainMenu
)

:regEditFullRegForAll
call :regEditImport "appcompatibility" "attachmentmanager" "backgroundapps" "filesystem" "explorer" "driversearching" "cloudcontent"
call :regEditImport "systemprofile" "search" "menushowdelay" "maintenance" "latestclr" "inspectre" "gamebar" "fse"
call :regEditImport "uac" "telemetry" "systemrestore"
call :regEditTrustedImport "foldernetworkX"
goto :eof


:RegEditFirstPage
title = Первая страница
echo		1. Отключить телеметрию и прочее (см. в тхт файле)
echo		2. Отключить все автообновления
echo		3. Отключение компонентов совместимости
echo		4. Отключение фоновых приложений
echo		5. Оптимизация файловой системы
echo		6. Включить функцию largesystemcache
echo		7. Отключение гей бара
echo		8. Следующая страница
echo		9. Вернуться
call :message
choice /C:123456789 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto telemetry
if %_erl%==2 cls && goto autoUpdate
if %_erl%==3 cls && goto appCompability
if %_erl%==4 cls && goto backgroundApps
if %_erl%==5 cls && goto filesystemOptimization
if %_erl%==6 cls && goto largesystemCache
if %_erl%==7 cls && goto gameDVR
if %_erl%==8 cls && call :message && goto RegEditSecondPage
if %_erl%==9 cls && call :message && goto RegEditMenu
goto RegEditFirstPage

:telemetry
call :regEditImport "inspectre" "uac" "maintenance" "attachmentmanager" "telemetry"
call :message "Жучки отключены!"
goto RegEditFirstPage

:autoUpdate
call :regEditImport "cloudcontent" "driversearching"
call :message "Автообновления отключены!"
goto RegEditFirstPage

:appCompability
call :regEditImport "appcompatibility"
call :message "Компоненты совместимости отключены!"
goto RegEditFirstPage

:backgroundApps
call :regEditImport "backgroundapps"
call :message "Фоновые приложения отключены!"
goto RegEditFirstPage

:filesystemOptimization
call :regEditImport "filesystem" "explorer"
call :regEditTrustedImport "foldernetworkX"
call :message "Файловая система оптимизирована!"
goto RegEditFirstPage

:largesystemCache
call :regEditImport "largesystemcache"
call :message "Функция largesystemcache включена!"
goto RegEditFirstPage

:gameDVR
call :regEditImport "gamebar"
call :message "Гей бар отключен!"
goto RegEditFirstPage


:RegEditSecondPage
title = Вторая страница
echo		1. Возвращение старого просмотрщика фото
echo		2. Убрать задержку показа менюшек
echo		3. Отключить веб поиск в меню поиска
echo		4. Уменьшение процента используемых ресурсов для лоу-приорити задач
echo		5. Отключить точки восстановления
echo		6. Глобальное отключение оптимизации во весь экран
echo		7. Отключить телеметрию NVIDIA
echo		8. Следующая страница
echo		9. Предыдущая страница
echo		0. Вернуться
call :message
choice /C:1234567890 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto backOldPhotoViewer
if %_erl%==2 cls && goto menuShowDelay
if %_erl%==3 cls && goto search
if %_erl%==4 cls && goto systemProfile
if %_erl%==5 cls && goto systemRestore
if %_erl%==6 cls && goto fse
if %_erl%==7 cls && goto nvdiaTelemetry
if %_erl%==8 cls && call :message && goto RegEditThirdPage
if %_erl%==9 cls && call :message && goto RegEditFirstPage
if %_erl%==10 cls && call :message && goto RegEditMenu
goto RegEditSecondPage

:backOldPhotoViewer
call :regEditImport "oldphotoviewer"
call :message "Старый просмотрщик фото вернулся!"
goto RegEditSecondPage

:menuShowDelay
call :regEditImport "menushowdelay"
call :message "Задержка показа меню убрана!"
goto RegEditSecondPage

:search
call :regEditImport "search"
call :message "Веб-поиск отключен!"
goto RegEditSecondPage

:systemProfile
call :regEditImport "systemprofile"
call :message "Процент используемых ресурсов уменьшен!"
goto RegEditSecondPage

:systemRestore
call :regEditImport "systemrestore"
call :message "Точки восстановления отключены!"
goto RegEditSecondPage

:fse
call :regEditImport "fse"
call :message "Оптимизация во весь экран отключена!"
goto RegEditSecondPage

:nvdiaTelemetry
call :regEditImport "nvtelemetry"
call :message "Телеметрия убита"
goto RegEditSecondPage


:RegEditThirdPage
title = Третья страница
echo		1. Использование только последних версий .NET
echo		2. Поставить префетч в значение 2
echo		3. Отключить службы автообновления и фоновых процессов Edge браузера
echo		8. Предыдущая страница
echo		9. Вернуться
call :message
choice /C:12389 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto latestCLR
if %_erl%==2 cls && goto prefetcher2
if %_erl%==3 cls && goto edge
if %_erl%==4 cls && call :message && goto RegEditSecondPage
if %_erl%==5 cls && call :message && goto RegEditMenu
goto RegEditThirdPage

:latestCLR
call :regEditImport "latestclr"
call :message "Использование только последних версий .NET включено!"
goto RegEditThirdPage

:prefetcher2
call :regEditImport "prefetcher 2"
call :message "Настроил prefetch"
goto RegEditThirdPage

:edge
call :batTrustedImport "edge"
call :message "О нет! Они убили edge("
goto RegEditThirdPage


:RegEditWindows10Only
title = .reg файлы для windows 10
echo		1. Увеличить приоритет для игр
echo		2. Удалить "Отправить" из контекстного меню
echo		3. Удалить папку "Объемные объекты"
echo		4. Полностью отключить дефендер, smartscreen, эксплойты
echo		5. Вывести секунды в системные часы
echo		6. Отключить уведомления при подключении новой сети
echo		9. Вернуться
call :message
choice /C:12345679 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto windows10Priority
if %_erl%==2 cls && goto windows10ShareItem
if %_erl%==3 cls && goto windows103dObjects
if %_erl%==4 cls && goto windows10Defender
if %_erl%==5 cls && goto windows10ShowSecondsInSystemClock
if %_erl%==6 cls && goto windows10NewnetworkWindow
if %_erl%==8 cls && call :message && goto RegEditMenu
goto RegEditWindows10Only

:windows10Priority
call :regEditImport "\Windows 10 Only\win10priority"
call :message "Приоритет для игр увеличен!"
goto RegEditWindows10Only

:windows10ShareItem
call :regEditImport "\Windows 10 Only\win10shareitem"
call :message "Пункт отправить удален!"
goto RegEditWindows10Only

:windows103dObjects
call :regEditImport "\Windows 10 Only\win10folder3d"
call :message "Пункт объемные объекты удален!"
goto RegEditWindows10Only

:windows10Defender
call :regEditTrustedImport "\Windows 10 Only\win10defenderX"
call :message "Защита пала!"
goto RegEditWindows10Only

:windows10ShowSecondsInSystemClock
call :regEditImport "\Windows 10 Only\win10showsecondsinsystemclock"
call :message "Секунды в часах включены!"
goto RegEditWindows10Only

:windows10NewnetworkWindow
call :regEditImport "\Windows 10 Only\win10networkwizard"
call :message "Уведомления при подключении новой сети выключены!"
goto RegEditWindows10Only


:RegEditWindows11Only
title = .reg файлы для windows 11
echo		1. Пофиксить новое контекстное меню
echo		2. Увеличить приоритет для игр
echo		3. Удалить "Отправить" из контекстного меню
echo		4. Полностью отключить дефендер
echo		9. Вернуться
call :message
choice /C:12349 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto windows11ContextMenuFix
if %_erl%==2 cls && goto windows11Priority
if %_erl%==3 cls && goto windows11ShareItem
if %_erl%==4 cls && goto windows11Defender
if %_erl%==5 cls && call :message && goto RegEditMenu
goto RegEditWindows11Only

:windows11ContextMenuFix
call :regEditImport "\Windows 11 Only\win11contextmenu"
call :message "Новое контекстное меню исправлено!"
goto RegEditWindows11Only

:windows11Priority
call :regEditImport "\Windows 11 Only\win11priority"
call :message "Приоритет для игр увеличен!"
goto RegEditWindows11Only

:windows11ShareItem
call :regEditImport "\Windows 11 Only\win11shareitem"
call :message "Пункт отправить удален!"
goto RegEditWindows11Only

:windows11Defender
call :regEditTrustedImport "\Windows 11 Only\win11defenderX"
call :batTrustedImport "\Windows 11 Only\win11defendersubserviceX"
call :message "Защита пала!"
goto RegEditWindows11Only

rem													mmagent
rem ========================================================================================================
rem Created by Vijorich


:MmagentSetup
title = Настройка sysmain

set _SystemPath=%SystemRoot:~0,-8%
set par1=solid state device
set par2=ssd
set par3=nvme

set err1=failed
set err2=error

smartctl -i %_SystemPath% |>NUL find /i "%par1%"
If "%errorlevel%"=="1" (smartctl -i %_SystemPath% |>NUL find /i "%par2%")
If "%errorlevel%"=="1" (smartctl -i %_SystemPath% |>NUL find /i "%par3%")
If "%errorlevel%"=="0" (goto :MmagentSetupSSD)
smartctl -i %_SystemPath% |>NUL find /i "%err1%"
If "%errorlevel%"=="1" (smartctl -i %_SystemPath% |>NUL find /i "%err2%")
If "%errorlevel%"=="0" (goto :IdentityFailed) Else (goto :MmagentSetupHDD)

:IdentityFailed
title = Ошибка в определении диска
call :message "Ошибка в определении диска, проверьте его целостность и корректность работы"
echo		1. HDD..
echo		2. SSD..
echo		9. Вернуться в главное меню..
call :message
choice /C:129 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto :MmagentSetupHDD
if %_erl%==2 cls && goto :MmagentSetupSSD
if %_erl%==3 cls && call :message && goto :MainMenu
goto IdentityFailed

:MmagentSetupHDD
title = Настройка для HDD
call :regEditImport "prefetcher 0" && cls && call :message "Настроено для HDD!" && goto MainMenu
call :message "ОШИБКА!"
Pause
goto MainMenu

:MmagentSetupSSD
title = Настройка для SSD
call :regEditImport "prefetcher 3" 

for /f %%a in ('powershell -command "(Get-WmiObject Win32_PhysicalMemory).capacity | Measure-Object -Sum | Foreach {[int]($_.Sum/1GB)}"') do (set _memory=%%a)

set /a _mmMemory=%_memory%*32

if %_mmMemory% LEQ 128 (
	set _mmMemory=128
) else (
	if %_mmMemory% GEQ 1024 (
		set _mmMemory=1024
	)
)

if %_build% GEQ 22000 (
	title = Настройка для SSD, windows 11
	call :powershell "enable-mmagent -ApplicationPreLaunch" "enable-mmagent -MC" "disable-mmagent -PC" "set-mmagent -moaf %_mmMemory%"
	cls && call :message "Настроено для SSD, windows 11!" && goto MainMenu
) else (
	title = Настройка для SSD, windows 10
	call :powershell "enable-mmagent -ApplicationPreLaunch" "disable-mmagent -MC" "disable-mmagent -PC" "set-mmagent -moaf %_mmMemory%"
	cls && call :message "Настроено для SSD, windows 10!" && goto MainMenu
)

rem													Power Schemes
rem ========================================================================================================
rem Created by Vijorich


:PowerSchemesMenu
title = Меню схем питания
echo		1. Импортировать схемы, выбрать нужную и удалить неиспользующиеся
echo		2. Импортировать схемы и выбрать нужную
echo		3. Удалить неиспользующиеся
echo		9. Вернуться в главное меню
call :message
choice /C:1239 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto powerSchemesMix
if %_erl%==2 cls && goto powerSchemesImport
if %_erl%==3 cls && goto powerSchemesDelete
if %_erl%==4 cls && call :message && goto MainMenu
goto PowerSchemesMenu

:powerSchemesMix
call :message "Выберите нужную схему!"
call :applyPowerSchemes
type %~dp0\powerschemes\readme.txt
pause
for /f "skip=2 tokens=2,4 delims=:()" %%G in ('powercfg -list') do (powercfg -delete %%G)
cls
call :message "Готово!"
goto MainMenu

:powerSchemesImport
call :message "Выберите нужную схему!"
call :applyPowerSchemes

type %~dp0\powerschemes\readme.txt
pause
cls
call :message "Готово!"
goto MainMenu

:powerSchemesDelete
for /f "skip=2 tokens=2,4 delims=:()" %%G in ('powercfg -list') do (powercfg -delete %%G)
cls
call :message "Удалил!" 
goto MainMenu

:applyPowerSchemes

powercfg /import %~dp0\powerschemes\Shingeki_no_Windows_2.3.pow >nul 2>&1
powercfg /import %~dp0\powerschemes\Shingeki_no_Windows_2.3_U.pow >nul 2>&1
powercfg /import %~dp0\powerschemes\Shingeki_no_Windows_2.3_RN.pow >nul 2>&1

start powercfg.cpl

goto :eof


::													ProgramDownload

:ProgramDownload
title = Загрузка программ
echo		1. Библиотеки..
echo		2. Полезные программы..
echo		9. Вернуться в главное меню..
call :message
choice /C:129 /N
set _erl=%errorlevel%
if %_erl%==1 cls && call :message && goto RuntimeMenu
if %_erl%==2 cls && call :message && goto UsefullProgs
if %_erl%==3 exit 
goto ProgramDownload

:RuntimeMenu
title = Библиотеки
echo		1. Visual C++
echo		2. .Net
echo		3. DirectX
echo		9. Предыдущая страница
call :message
choice /C:1239 /N
set _erl=%errorlevel%
if %_erl%==1 cls && call :message && goto VisualC
if %_erl%==2 cls && call :message && goto DotNet
if %_erl%==3 cls && call :message && goto DirectX
if %_erl%==4 cls && call :message && goto ProgramDownload
goto RuntimeMenu

:VisualC
set is_64=0 && if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set is_64=1) else (if "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set is_64=1))

if "%is_64%" == "1" goto 64

call :message "2005.."
winget install "Microsoft Visual C++ 2005 Redistributable"
call :message "2008.."
winget install "Microsoft Visual C++ 2008 Redistributable - x86"
call :message "2010.."
winget install "Microsoft Visual C++ 2010 x86 Redistributable"
call :message "2012.."
winget install "Microsoft Visual C++ 2012 Redistributable (x86)"
call :message "2013.."
winget install "Microsoft Visual C++ 2013 Redistributable (x86)"
call :message "2015, 2017 ^& 2019.."
winget install "Microsoft Visual C++ 2015-2022 Redistributable (x86)"
cls
call :message "Установка завершена"
goto RuntimeMenu

:64
call :message "2005.."
winget install "Microsoft Visual C++ 2005 Redistributable"
winget install "Microsoft Visual C++ 2005 Redistributable (x64)"
call :message "2008.."
winget install "Microsoft Visual C++ 2008 Redistributable - x86"
winget install "Microsoft Visual C++ 2008 Redistributable - x64"
call :message "2010.."
winget install "Microsoft Visual C++ 2010 x86 Redistributable"
winget install "Microsoft Visual C++ 2010 x64 Redistributable"
call :message "2012.."
winget install "Microsoft Visual C++ 2012 Redistributable (x86)"
winget install "Microsoft Visual C++ 2012 Redistributable (x64)"
call :message "2013.."
winget install "Microsoft Visual C++ 2013 Redistributable (x86)"
winget install "Microsoft Visual C++ 2013 Redistributable (x64)"
call :message "2015, 2017 ^& 2019.."
winget install "Microsoft Visual C++ 2015-2022 Redistributable (x86)"
winget install "Microsoft Visual C++ 2015-2022 Redistributable (x64)"
cls
call :message "Установка завершена"
goto RuntimeMenu

:DotNet
call :message "3.1.."
winget install "Microsoft .NET Windows Desktop Runtime 3.1"
call :message "5.0.."
winget install "Microsoft .NET Windows Desktop Runtime 5.0"
call :message "6.0.."
winget install "Microsoft .NET Windows Desktop Runtime 6.0"
call :message "7.0.."
winget install "Microsoft .NET Windows Desktop Runtime 7.0"
cls
call :message "Установка завершена"
goto RuntimeMenu

:DirectX
winget install "DirectX End-User Runtime Web Installer"
cls
call :message "Установка завершена"
goto RuntimeMenu


:UsefullProgs
title = Полезные программы
echo		1. 7-zip
echo		2. Notepad++
echo		3. Autoruns
echo		4. WinMerge
echo		5. DDU
echo		6. HWiNFO
echo		7. Rust desk
echo		8. Следующая страница
echo		9. Предыдущая страница
call :message
choice /C:123456789 /N
set _erl=%errorlevel%
if %_erl%==1 cls && call :message && goto 7zip
if %_erl%==2 cls && call :message && goto notepad
if %_erl%==3 cls && call :message && goto autoruns
if %_erl%==4 cls && call :message && goto winMerge
if %_erl%==5 cls && call :message && goto ddu
if %_erl%==6 cls && call :message && goto HWiNFO
if %_erl%==7 cls && call :message && goto rustDesk
if %_erl%==8 cls && call :message && goto SecondUsefullProgs
if %_erl%==9 cls && call :message && goto ProgramDownload
goto UsefullProgs

:7zip
winget install "7zip.7zip"
cls
if "%errorlevel%" equ "0" (
	call :message "Установка завершена"
) If "%errorlevel%" equ "-1978335189" (
	call :message "Программа уже установленна"
) If "%errorlevel%" equ "9009" (
	call :message "Отсутствует установщик пакетов winget"
	call :message "Установите программу из офф источника https://learn.microsoft.com/ru-ru/windows/package-manager/winget/"
) Else (
	call :message "Неизвестная ошибка"
)
goto UsefullProgs

:notepad
winget install "notepad++"
cls
call :errorCheck
goto UsefullProgs

:autoruns
winget install "Autoruns"
cls
call :errorCheck
goto UsefullProgs

:winMerge
winget install "winmerge"
cls
call :errorCheck
goto UsefullProgs

:ddu
winget install "ddu"
cls
call :errorCheck
goto UsefullProgs

:HWiNFO
winget install "HWiNFO"
cls
call :errorCheck
goto UsefullProgs

:rustDesk
winget install "RustDesk"
cls
call :errorCheck
goto UsefullProgs


:SecondUsefullProgs
title = Полезные программы
echo		1. Text-Grab
echo		2. qBittorent
echo		3. TranslucentTB
echo		4. BCUninstaller
echo		5. Rufus
echo		6. Win11-Coursor
echo		7. Msi-Util
echo		8. ExplorerPatcher
echo		9. Предыдущая страница
call :message
choice /C:123456789 /N
set _erl=%errorlevel%
if %_erl%==1 cls && call :message && goto textGrab
if %_erl%==2 cls && call :message && goto qBittorent
if %_erl%==3 cls && call :message && goto translucentTB
if %_erl%==4 cls && call :message && goto BCU
if %_erl%==5 cls && call :message && goto rufus
if %_erl%==6 cls && call :message && goto coursor
if %_erl%==7 cls && call :message && goto msiUtil
if %_erl%==8 cls && call :message && goto explorerPatcher
if %_erl%==9 cls && call :message && goto UsefullProgs
goto SecondUsefullProgs

:textGrab
winget install "Text-Grab"
cls
call :errorCheck
goto SecondUsefullProgs

:qBittorent
winget install "qBittorrent.qBittorrent"
cls
call :errorCheck
goto SecondUsefullProgs

:translucentTB
winget install "TranslucentTB"
cls
call :errorCheck
goto SecondUsefullProgs

:BCU
winget install "BCUninstaller"
cls
call :errorCheck
goto SecondUsefullProgs

:rufus
winget install "Rufus.Rufus"
cls
call :errorCheck
goto SecondUsefullProgs

:coursor
cd %UserProfile%\Desktop
call :download "https://github.com/PSGitHubUser1/Windows-11-Cursor-Concept-Pro-v2.x/releases/download/v2.2pro_big-v2/Windows.Cursor.Concept.v2.2+big.v2.zip" "Win11Coursor.zip"
call :message "Архив скачан на рабочий стол"
cd %~dp0
goto SecondUsefullProgs

:msiUtil
cd %UserProfile%\Desktop
call :download "https://download2435.mediafire.com/poh28xtppbogFdzRwDj3cv6AYgiIjy7IWbog5nCfYFzaLd8vJYghZA47RDoxYXHlqqVHOmVP-FXWXi847vncp9baFLpJiA/ewpy1p0rr132thk/MSI_util_v3.zip" "MSI_util_v3.zip"
call :message "Архив скачан на рабочий стол"
cd %~dp0
goto SecondUsefullProgs

:explorerPatcher
winget install "ExplorerPatcher"
cls
call :errorCheck
goto SecondUsefullProgs


rem													Functions
rem ========================================================================================================
rem Created by Vijorich


:download
(
	PowerShell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('%~1', '%~2')"
) >nul 2>&1
goto :eof

:delete
pushd "%~1" 2>nul && ( rd /Q /S . 2>nul & popd )
goto :eof

:errorCheck
if "%errorlevel%" equ "0" (
	call :message "Установка завершена"
) else if "%errorlevel%" equ "-1978335189" (
	call :message "Программа уже установленна"
) else if "%errorlevel%" equ "9009" (
	call :message "Отсутствует установщик пакетов winget"
	call :message "Установите программу из офф источника:"
	call :message "https://learn.microsoft.com/ru-ru/windows/package-manager/winget/"
) else (
	call :message "Неизвестная ошибка"
)
goto :eof

:message
setlocal DisableDelayedExpansion
echo:
echo:  %~1
echo:
endlocal
goto :eof

:powerShell
(
powershell -executionpolicy bypass -command "%~1" ; "%~2" ; "%~3" ; "%~4" ; "%~5" 
) >nul 2>&1
goto :eof

:regEditImport
setlocal DisableDelayedExpansion
regedit /s "%~dp0\regpack\%~1.reg" ; "%~dp0\regpack\%~2.reg" ; "%~dp0\regpack\%~3.reg" ; "%~dp0\regpack\%~4.reg" ; "%~dp0\regpack\%~5.reg" ; "%~dp0\regpack\%~6.reg" ; "%~dp0\regpack\%~7.reg" ; "%~dp0\regpack\%~8.reg" ; "%~dp0\regpack\%~9.reg"
endlocal
goto :eof

:regEditTrustedImport
setlocal DisableDelayedExpansion
"%~dp0\regpack\PowerRun\PowerRun.exe" Regedit.exe /S "%~dp0\regpack\%~1.reg" ; "%~dp0\regpack\%~2.reg" ; "%~dp0\regpack\%~3.reg"
endlocal
goto :eof

:batTrustedImport
setlocal DisableDelayedExpansion
"%~dp0\regpack\PowerRun\PowerRun.exe" "%~dp0\regpack\%~1.bat" ; "%~dp0\regpack\%~2.bat" ; "%~dp0\regpack\%~3.bat"
endlocal
goto :eof

rem													Cheers
rem ========================================================================================================
rem Created by Vijorich


:CheerUpAuthorMenu
title = Я старался!
echo 1. Скинув смешную гифку ребятам из техношахты!
echo 2. Пощекотав кнопку подписки на youtube канале
echo.
echo Скинув денюжку на покушать:
echo 3. donationalerts
echo 4. donatepay
echo.
echo Подписавшись на бусти: 
echo 5. boosty
echo.
echo 9. Вернуться в главное меню
call :message
choice /C:123459 /N
set _erl=%errorlevel%
if %_erl%==1 cls && start https://discord.gg/mB6DprqmR9 && call :message
if %_erl%==2 cls && start https://www.youtube.com/channel/UCtTvQl-7zOJjTZw0s2m82aQ && call :message
if %_erl%==3 cls && start https://www.donationalerts.com/r/vijorich && call :message
if %_erl%==4 cls && start https://new.donatepay.ru/@906344 && call :message
if %_erl%==5 cls && start https://boosty.to/vijor && call :message
if %_erl%==6 cls && call :message && goto MainMenu
goto CheerUpAuthorMenu

rem													Cleaner setup
rem ========================================================================================================
rem Created by Vijorich


:CleanerSetup
SET FLAG=StateFlags0777 && SET REG_VALUE=00000002
SET REG_LOC=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches
Set "NUM_ENTRIES=0" && Set "LAST_ENTRY=0"
SET VOLUME_LOCATIONS=("Active Setup Temp Folders", "Content Indexer Cleaner", "Downloaded Program Files", "Internet Cache Files", "Memory Dump Files", "Microsoft_Event_Reporting_2.0_Temp_Files", "Offline Pages Files", "Old ChkDsk Files", "Previous Installations", "Remote Desktop Cache Files", "ServicePack Cleanup", "Setup Log Files", "System error memory dump files", "System error minidump files", "Temporary Files", "Temporary Setup Files", "Temporary Sync Files", "Update Cleanup", "Upgrade Discarded Files", "WebClient and WebPublisher Cache", "Windows Defender", "Windows Error Reporting Archive Files", "Windows Error Reporting Queue Files", "Windows Error Reporting System Archive Files", "Windows Error Reporting System Queue Files", "Windows ESD installation files", "Windows Upgrade Log Files")
for /F "delims=" %%i IN ('reg query "%REG_LOC%"') do set /a "NUM_ENTRIES+=1"
FOR /F "delims=" %%G IN ('reg query "%REG_LOC%"') do (
set /a "LAST_ENTRY+=1"
Set DYNAMIC_ARRAY_VOLUMES=!DYNAMIC_ARRAY_VOLUMES!, "%%~nxG"
Set DYNAMIC_ARRAY_VOLUMES[%%~nxG]=!LAST_ENTRY!
if !LAST_ENTRY! == 1 Set DYNAMIC_ARRAY_VOLUMES="%%~nxG"
if !LAST_ENTRY! == %NUM_ENTRIES% GOTO :ARRAY_BUILT
)
:ARRAY_BUILT
echo. && echo (%DYNAMIC_ARRAY_VOLUMES%) && echo.
SET OMITTED_LOCATIONS=("")
for %%q in %OMITTED_LOCATIONS% do SET DYNAMIC_ARRAY_VOLUMES=!DYNAMIC_ARRAY_VOLUMES:%%q, =!
for %%q in %OMITTED_LOCATIONS% do SET DYNAMIC_ARRAY_VOLUMES=!DYNAMIC_ARRAY_VOLUMES:, %%q=!
echo The following would be a reduced list of locations: && echo (%DYNAMIC_ARRAY_VOLUMES%) && echo.
for %%i in (%DYNAMIC_ARRAY_VOLUMES%) do (
REG ADD "%REG_LOC%\%%~i" /v %FLAG% /t REG_DWORD /d %REG_VALUE% /f
)
cls
goto :eof