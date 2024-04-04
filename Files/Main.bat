@echo off
@setlocal enabledelayedexpansion
@chcp 65001 >nul

set _version=1.8.6
verify on
cd /d "%~dp0"

:: Запрос запуска от имени админа
fltmc >nul 2>&1 || (
    echo Administrator privileges are required.
    PowerShell Start -Verb RunAs '%0' 2> nul || (
        echo Right-click on the script and select "Run as administrator".
        pause & exit 1
    )
    exit 0
)
setlocal EnableExtensions DisableDelayedExpansion

::													Startup check
:: ========================================================================================================
:: Created by Vijorich


:StartupCheck
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
		call :message "Обновите PowerShell https://aka.ms/PSWindows"
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
	goto :GatherInfo
)


::													Updater
:: ========================================================================================================
:: Created by Vijorich


:UpdateCheck
cd..
set _currentPath=%cd%
cd /d "%~dp0"

for /f %%a in ('PowerShell -Command "$PSVersionTable.PSVersion.Build"') do (set _powerShellVersion=%%a)

if "%_powerShellVersion%" GEQ "22000" (
	for /f %%a in ('PowerShell -Command "((Invoke-WebRequest -Uri "https://api.github.com/repos/Vijorich/Universal-windows-utility-console/releases/latest").content | ConvertFrom-Json).tag_name"') do (set _newVersion=%%a)
) else (
	for /f %%a in ('PowerShell -Command "((Invoke-WebRequest -Uri "https://api.github.com/repos/Vijorich/Universal-windows-utility-console/releases/latest" -UseBasicParsing).content | ConvertFrom-Json).tag_name"') do (set _newVersion=%%a)
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
	    if "%1" equ "1" (
			call :message "UniWin обновлен до версии !_version!"
			if "%_powerShellVersion%" GEQ "22000" (
				PowerShell -Command "((Invoke-WebRequest -Uri "https://api.github.com/repos/Vijorich/Universal-windows-utility-console/releases/latest").content | ConvertFrom-Json).name"
				echo.
				PowerShell -Command "((Invoke-WebRequest -Uri "https://api.github.com/repos/Vijorich/Universal-windows-utility-console/releases/latest").content | ConvertFrom-Json).body"
			) else (
				PowerShell -Command "((Invoke-WebRequest -Uri "https://api.github.com/repos/Vijorich/Universal-windows-utility-console/releases/latest" -UseBasicParsing).content | ConvertFrom-Json).name"
				echo.
				PowerShell -Command "((Invoke-WebRequest -Uri "https://api.github.com/repos/Vijorich/Universal-windows-utility-console/releases/latest" -UseBasicParsing).content | ConvertFrom-Json).body"
			)
			call :message "Нажмите любую кнопку, чтобы продолжить"
			del /f "UWU.zip" >nul 2>&1
			timeout 60 > nul
			cls && goto GatherInfo
		) else (
			cls && goto GatherInfo
		)
	)
)
exit /b


:UpdateMenu
echo.	1. Установить обновление
echo.	2. Не сейчас
call :message
choice /C:12 /N
set _erl=%errorlevel%
if %_erl%==1 cls && call :message && goto UpdateDownload
if %_erl%==2 cls && call :message && goto GatherInfo
goto UpdateMenu


:UpdateDownload
rmdir /s /q powerschemes
rmdir /s /q regpack
call :download "https://github.com/Vijorich/Universal-windows-utility-console/releases/download/%_newVersion%/UWU.zip" "UWU.zip"
powershell -command "Expand-Archive -Force '%~dp0UWU.zip' '%_currentPath%'" && start "" "%_currentPath%\Start.lnk" 1 && exit /b
echo Произошла ошибка
exit


::													System config
:: ========================================================================================================
:: Created by Vijorich


:GatherInfo

if %_build% geq 22000 (
	set _winver=11
) else (
	set _winver=10
)

call :message


::													Main menu
:: ========================================================================================================
:: Created by Vijorich


:MainMenu
echo.	1. Меню очистки..
echo.	2. Меню настроек реестра..
echo.	3. Меню схем питания..
echo.	4. Меню дополнительных настрек..
echo.	5. Настроить mmagent..
echo.	6. Скачать и установить программы..
echo.	9. Выйти из программы
echo.	0. Поддержать автора!..
call :message
choice /C:12345690 /N
set _erl=%errorlevel%
if %_erl%==1 cls && call :message && goto CleanupMenu
if %_erl%==2 cls && call :message && goto RegEditMenu
if %_erl%==3 cls && call :message && goto PowerSchemesMenu
if %_erl%==4 cls && call :message && goto AdditionalSettingsMenu
if %_erl%==5 cls && call :message "Настраиваю.." && goto MmagentSetup
if %_erl%==6 cls && call :message && goto ProgramDownload
if %_erl%==7 exit /b
if %_erl%==8 cls && call :message "Вы можете сделать приятно автору UniWin %_version%!" && goto CheerUpAuthorMenu
goto MainMenu


::													Additional settings Menu
:: ========================================================================================================
:: Created by Vijorich


:AdditionalSettingsMenu
echo.	1. Отключить резервное хранилище
echo.	2. Отключить режим гибернации
echo.	3. Отключить виджеты (Windows Web Experience Pack)
echo.	4. Отключить Xbox оверлеи
echo.	5. Отключить Nvidia Ansel
echo.	6. Активировать Windows (massgrave)
echo.	7. Проверить файловую систему (компьютер сразу перезагрузится)

echo.	9. Вернуться в главное меню
call :message
choice /C:12345679 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto offReservedStorage
if %_erl%==2 cls && powercfg -h off && call :message "Режим гибернации отключен"
if %_erl%==3 cls && goto offWindowsWebExperiencePack
if %_erl%==4 cls && goto offXboxOverlays
if %_erl%==5 cls && goto offNvidiaAnsel
if %_erl%==6 cls && goto massgrave
if %_erl%==7 cls && goto checkdsk
if %_erl%==8 cls && call :message && goto MainMenu
goto :AdditionalSettingsMenu

:offReservedStorage
call :message "Ожидайте.."
start /wait /min "%SystemRoot%\System32\Dism.exe" /Online /Set-ReservedStorageState /State:Disabled
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
if not defined _targetFullPath (call :message "%_target% не найден" & goto :AdditionalSettingsMenu)
%_targetFullPath% off
call :message "Ansel отключен!"
goto :AdditionalSettingsMenu

:massgrave
PowerShell -Command "irm https://massgrave.dev/get | iex"
goto :AdditionalSettingsMenu

:checkdsk
echo Y | chkdsk /f /r /b
shutdown /r


::													Cleanup Menu
:: ========================================================================================================
:: Created by Vijorich


:CleanupMenu
echo.	1. Нужна ли мне очистка?
echo.	2. Быстрая ~1min-5min
echo.	3. Рекомендуемая ~5min-1hour
echo.	4. Максимальная (эксперементальная)
echo.	9. Вернуться в главное меню
echo.	0. Прочитай меня.тхт
call :message
choice /C:123490 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto checkUp
if %_erl%==2 cls && goto fastCleanup
if %_erl%==3 cls && goto recommendedCleanup
if %_erl%==4 cls && goto maxCleanup
if %_erl%==5 cls && call :message && goto MainMenu
if %_erl%==6 cls && goto cleanupInfo
goto CleanupMenu

:cleanupInfo
start "" "%~dp0CleanReadme.txt"
call :message && goto CleanupMenu

:checkUp
call :message "Сейчас посмотрим.."
Dism.exe /Online /Cleanup-Image /AnalyzeComponentStore
pause
cls
call :message && goto MainMenu

:fastCleanup
setlocal DisableDelayedExpansion
call :message "Чищу, чищу, чищу"
call :delete %Temp%
call :delete %WINDIR%\Temp
call :delete %SYSTEMDRIVE%\Temp
del /F /S /Q %SYSTEMDRIVE%\*.log
del /F /S /Q %SYSTEMDRIVE%\*.bak
del /F /S /Q %SYSTEMDRIVE%\*.gid
start /min /wait WSReset.exe >nul 2>&1
taskkill /f /im WinStore.App.exe >nul 2>&1
endlocal
cls
call :message "Готово!" && goto MainMenu

:recommendedCleanup
setlocal DisableDelayedExpansion
call :message "Чищу, чищу, чищу"
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
net stop wuauserv >nul && call :delete %WINDIR%\SoftwareDistribution\Download && net start wuauserv >nul
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
endlocal
cls
call :message "Готово!" && goto MainMenu

:maxCleanup
call maxCleanup.bat
cls
call :message "Готово!" && goto MainMenu

::													Reg Edit Menu
:: ========================================================================================================
:: Created by Vijorich


:RegEditMenu
echo.	1. Просто применить рекомендуемые настройки
echo.	2. Точечная настройка (для любой версии шиндус)
echo.	3. Только для 10 шиндуса
echo.	4. Только для 11 шиндуса
echo.	9. Вернуться в главное меню!
echo.	0. Прочитай меня.тхт
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
start "" "%~dp0regpack\readme.txt"
call :message && goto RegEditFirstPage

:RegEditFullReg
if %_build% GEQ 22000 (
	call :regEditImport "\Windows 11 Only\win11shareitem"
	call :regEditTrustedImport "\Windows 11 Only\win11defenderX"
	call :batTrustedImport "\Windows 11 Only\win11defsubsvcX"
	call :regEditFullRegForAll
	cls && call :message "Применил общие .рег файлы для шиндус 11!" && goto MainMenu
) else (
	call :regEditImport "\Windows 10 Only\win10folder3d" "\Windows 10 Only\win10networkwizard" "\Windows 10 Only\win10shareitem"
    call :regEditTrustedImport "\Windows 10 Only\win10defenderX"
	call :regEditFullRegForAll
	cls && call :message "Применил общие .рег файлы для шиндус 10!" && goto MainMenu
)

:regEditFullRegForAll
call :regEditImport "accessibility" "appcompatibility" "attachmentmanager" "backgroundapps" "cloudcontent" "driversearching" "inspectre" "latestclr" "priority"
call :regEditImport "responsiveness" "search" "systemrestore" "3dedit" "menushowdelay"
goto :eof


:RegEditFirstPage
echo.	1. Отключение защиты Spectre, Meltdown и т.д
echo.	2. Отключить все автообновления
echo.	3. Отключение компонентов совместимости
echo.	4. Отключение фоновых приложений
echo.	5. Оптимизация файловой системы
echo.	6. Включить функцию largesystemcache
echo.	7. Отключение гейм бара
echo.	8. Следующая страница
echo.	9. Вернуться
call :message
choice /C:123456789 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto maintenance
if %_erl%==2 cls && goto autoUpdate
if %_erl%==3 cls && goto appCompability
if %_erl%==4 cls && goto backgroundApps
if %_erl%==5 cls && goto filesystemOptimization
if %_erl%==6 cls && goto largesystemCache
if %_erl%==7 cls && goto gameDVR
if %_erl%==8 cls && call :message && goto RegEditSecondPage
if %_erl%==9 cls && call :message && goto RegEditMenu
goto RegEditFirstPage

:maintenance
call :regEditImport "inspectre" "uac" "maintenance"
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
call :message "Гейм бар отключен!"
goto RegEditFirstPage


:RegEditSecondPage
echo.	1. Возвращение старого просмотрщика фото
echo.	2. Убрать задержку показа менюшек
echo.	3. Отключить веб поиск в меню поиска
echo.	4. Уменьшение процента используемых ресурсов для лоу-приорити задач
echo.	5. Отключить точки восстановления
echo.	6. Убрать "Изменить с помощью Paint 3D"
echo.	7. Увеличить приоритет для игр
echo.	8. Следующая страница
echo.	9. Предыдущая страница
echo.	0. Вернуться
call :message
choice /C:1234567890 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto backOldPhotoViewer
if %_erl%==2 cls && goto menuShowDelay
if %_erl%==3 cls && goto search
if %_erl%==4 cls && goto responsiveness
if %_erl%==5 cls && goto systemRestore
if %_erl%==6 cls && goto 3dedit
if %_erl%==7 cls && goto priority
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

:responsiveness
call :regEditImport "responsiveness"
call :message "Процент используемых ресурсов уменьшен!"
goto RegEditSecondPage

:systemRestore
call :regEditImport "systemrestore"
call :message "Точки восстановления отключены!"
goto RegEditSecondPage

:3dedit
call :regEditImport "3dedit"
call :message "Изменить с помощью Paint 3D убран!"
goto RegEditSecondPage

:priority
call :regEditImport "priority"
call :message "Телеметрия убита"
goto RegEditSecondPage


:RegEditThirdPage
echo.	1. Использование только последних версий .NET
echo.	2. Поставить префетч в значение 2
echo.	3. Отключить службы автообновления и фоновых процессов Edge браузера
echo.	4. Отключение настроек для людей с ограниченными возможностями
echo.	8. Предыдущая страница
echo.	9. Вернуться
call :message
choice /C:123489 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto latestCLR
if %_erl%==2 cls && goto prefetcher2
if %_erl%==3 cls && goto edge
if %_erl%==4 cls && goto accessibility
if %_erl%==5 cls && call :message && goto RegEditSecondPage
if %_erl%==6 cls && call :message && goto RegEditMenu
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
call :regEditImport "edgeupdate"
call :message "О нет! Они убили edge("
goto RegEditThirdPage

:accessibility
call :regEditImport "accessibility"
call :message "Отключил"
goto RegEditThirdPage


:RegEditWindows10Only
echo.	1. Удалить "Отправить" из контекстного меню
echo.	2. Удалить папку "Объемные объекты"
echo.	3. Полностью отключить дефендер, smartscreen, эксплойты
echo.	4. Вывести секунды в системные часы
echo.	5. Отключить уведомления при подключении новой сети
echo.	9. Вернуться
call :message
choice /C:123459 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto windows10ShareItem
if %_erl%==2 cls && goto windows103dObjects
if %_erl%==3 cls && goto windows10Defender
if %_erl%==4 cls && goto windows10ShowSecondsInSystemClock
if %_erl%==5 cls && goto windows10NewnetworkWindow
if %_erl%==6 cls && call :message && goto RegEditMenu
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
echo.	1. Пофиксить новое контекстное меню
echo.	2. Удалить "Отправить" из контекстного меню
echo.	3. Полностью отключить дефендер
echo.	4. Отключить виджеты и copilot
echo.	9. Вернуться
call :message
choice /C:12349 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto windows11ContextMenuFix
if %_erl%==2 cls && goto windows11ShareItem
if %_erl%==3 cls && goto windows11Defender
if %_erl%==4 cls && goto win11widgets
if %_erl%==5 cls && call :message && goto RegEditMenu
goto RegEditWindows11Only

:windows11ContextMenuFix
call :regEditImport "\Windows 11 Only\win11contextmenu"
call :message "Новое контекстное меню исправлено!"
goto RegEditWindows11Only

:windows11ShareItem
call :regEditImport "\Windows 11 Only\win11shareitem"
call :message "Пункт отправить удален!"
goto RegEditWindows11Only

:windows11Defender
call :regEditTrustedImport "\Windows 11 Only\win11defenderX"
call :batTrustedImport "\Windows 11 Only\win11defsubsvcX"
call :message "Защита пала!"
goto RegEditWindows11Only

:win11widgets
call :regEditImport "\Windows 11 Only\win11widgets"
call :message "Отключил!"
goto RegEditWindows11Only

::													mmagent
:: ========================================================================================================
:: Created by Vijorich


:MmagentSetup
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
call :message "Ошибка в определении диска, проверьте его целостность и корректность работы"
echo.	1. HDD..
echo.	2. SSD..
echo.	9. Вернуться в главное меню..
call :message
choice /C:129 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto :MmagentSetupHDD
if %_erl%==2 cls && goto :MmagentSetupSSD
if %_erl%==3 cls && call :message && goto :MainMenu
goto IdentityFailed

:MmagentSetupHDD
call :regEditImport "prefetcher 0" && cls && call :message "Настроено для HDD!" && goto MainMenu
call :message "ОШИБКА!"
Pause
goto MainMenu

:MmagentSetupSSD
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
	call :powershell "enable-mmagent -ApplicationPreLaunch" "enable-mmagent -MC" "disable-mmagent -PC" "set-mmagent -moaf %_mmMemory%"
	cls && call :message "Настроено для SSD, windows 11!" && goto MainMenu
) else (
	call :powershell "enable-mmagent -ApplicationPreLaunch" "disable-mmagent -MC" "disable-mmagent -PC" "set-mmagent -moaf %_mmMemory%"
	cls && call :message "Настроено для SSD, windows 10!" && goto MainMenu
)

::													Power Schemes
:: ========================================================================================================
:: Created by Vijorich


:PowerSchemesMenu
echo.	1. Импортировать схемы, выбрать нужную и удалить неиспользующиеся
echo.	2. Импортировать схемы и выбрать нужную
echo.	3. Удалить неиспользующиеся
echo.	9. Вернуться в главное меню
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
call :powerSchemesDescription
pause
for /f "skip=2 tokens=2,4 delims=:()" %%G in ('powercfg -list') do (powercfg -delete %%G)
cls
call :message "Готово!"
goto MainMenu

:powerSchemesImport
call :message "Выберите нужную схему!"
call :applyPowerSchemes
call :powerSchemesDescription
pause
cls
call :message "Готово!"
goto MainMenu

:powerSchemesDelete
for /f "skip=2 tokens=2,4 delims=:()" %%G in ('powercfg -list') do (powercfg -delete %%G)
cls
call :message "Удалил!" 
goto MainMenu

:powerSchemesDescription
echo.	Схема для статического множества имеет вид (x.y)
echo.	Универсальная схема имеет вид (x.y_U)
echo.	Если не знаете какую выбрать, то выбирайте универсальную
echo.
goto :eof

:applyPowerSchemes
for /f tokens^=* %%i in ('where "%~dp0powerschemes\:*.pow"') do powercfg /import "%%i" >nul
start powercfg.cpl
goto :eof


::													ProgramDownload
:: ========================================================================================================
:: Created by Vijorich


:ProgramDownload
echo.	1. Библиотеки..
echo.	2. Полезные программы..
echo.	9. Вернуться в главное меню..
call :message
choice /C:129 /N
set _erl=%errorlevel%
if %_erl%==1 cls && call :message && goto RuntimeMenu
if %_erl%==2 cls && call :message && goto UsefullProgs
if %_erl%==3 cls && call :message && goto MainMenu
goto ProgramDownload


:RuntimeMenu
echo.	1. Visual C++
echo.	2. .Net
echo.	3. DirectX
echo.	4. K-Lite Codec Pack..
echo.	9. Предыдущая страница
call :message
choice /C:12349 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto VisualC
if %_erl%==2 cls && goto DotNet
if %_erl%==3 cls && goto DirectX
if %_erl%==4 cls && call :message && goto klitecodecs
if %_erl%==5 cls && call :message && goto ProgramDownload
goto RuntimeMenu

:VisualC
set is_64=0 && if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set is_64=1) else (if "%PROCESSOR_ARCHITEW6432%"=="AMD64" (set is_64=1))

if "%is_64%" == "1" goto 64

call :wingetInstall "Visual C++ 2005 Redistributable (x86)", "Microsoft Visual C++ 2005 Redistributable"
call :wingetInstall "Visual C++ 2008 Redistributable (x86)", "Microsoft Visual C++ 2008 Redistributable - x86"
call :wingetInstall "Visual C++ 2010 Redistributable (x86)", "Microsoft Visual C++ 2010 x86 Redistributable"
call :wingetInstall "Visual C++ 2012 Redistributable (x86)", "Microsoft Visual C++ 2012 Redistributable (x86)"
call :wingetInstall "Visual C++ 2013 Redistributable (x86)", "Microsoft Visual C++ 2013 Redistributable (x86)"
call :wingetInstall "Visual C++ 2015-2022 Redistributable (x86)", "Microsoft Visual C++ 2015-2022 Redistributable (x86)"
cls
call :message "Установка Visual C++ Redistributables завершена"
goto RuntimeMenu

:64
call :wingetInstall "Visual C++ 2005 Redistributable (x86)", "Microsoft Visual C++ 2005 Redistributable"
call :wingetInstall "Visual C++ 2005 Redistributable (x64)", "Microsoft Visual C++ 2005 Redistributable (x64)"
call :wingetInstall "Visual C++ 2008 Redistributable (x86)", "Microsoft Visual C++ 2008 Redistributable - x86"
call :wingetInstall "Visual C++ 2008 Redistributable (x64)", "Microsoft Visual C++ 2008 Redistributable - x64"
call :wingetInstall "Visual C++ 2010 Redistributable (x86)", "Microsoft Visual C++ 2010 x86 Redistributable"
call :wingetInstall "Visual C++ 2010 Redistributable (x86)", "Microsoft Visual C++ 2010 x64 Redistributable"
call :wingetInstall "Visual C++ 2012 Redistributable (x86)", "Microsoft Visual C++ 2012 Redistributable (x86)"
call :wingetInstall "Visual C++ 2012 Redistributable (x64)", "Microsoft Visual C++ 2012 Redistributable (x64)"
call :wingetInstall "Visual C++ 2013 Redistributable (x86)", "Microsoft Visual C++ 2013 Redistributable (x86)"
call :wingetInstall "Visual C++ 2013 Redistributable (x64)", "Microsoft Visual C++ 2013 Redistributable (x64)"
call :wingetInstall "Visual C++ 2015-2022 Redistributable (x86)", "Microsoft Visual C++ 2015-2022 Redistributable (x86)"
call :wingetInstall "Visual C++ 2015-2022 Redistributable (x64)", "Microsoft Visual C++ 2015-2022 Redistributable (x64)"
cls
call :message "Установка Visual C++ Redistributables завершена"
goto RuntimeMenu

:DotNet
call :wingetInstall ".NET 3.1", "Microsoft .NET Windows Desktop Runtime 3.1"
call :wingetInstall ".NET 5.0", "Microsoft .NET Windows Desktop Runtime 5.0"
call :wingetInstall ".NET 6.0", "Microsoft .NET Windows Desktop Runtime 6.0"
call :wingetInstall ".NET 7.0", "Microsoft .NET Windows Desktop Runtime 7.0"
call :wingetInstall ".NET 8.0", "Microsoft .NET Windows Desktop Runtime 8.0"
cls
call :message "Установка .NET Runtimes завершена"
goto RuntimeMenu

:DirectX
call :wingetInstall "DirectX", "DirectX End-User Runtime Web Installer"
goto RuntimeMenu


:klitecodecs
echo.	1. Basic
echo.	2. Standard - Рекомендуется
echo.	3. Full
echo.	4. Mega
echo.	9. Предыдущая страница..
call :message
choice /C:12349 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto basic
if %_erl%==2 cls && goto standard
if %_erl%==3 cls && goto full
if %_erl%==4 cls && goto mega
if %_erl%==5 cls && call :message && goto RuntimeMenu
goto klitecodecs

:basic
call :wingetInstall "K-Lite Codec Pack Basic", "K-Lite Codec Pack Basic"
goto klitecodecs

:standard
call :wingetInstall "K-Lite Codec Pack Standard", "K-Lite Codec Pack Standard"
goto klitecodecs

:full
call :wingetInstall "K-Lite Codec Pack Full", "K-Lite Codec Pack Full"
goto klitecodecs

:mega
call :wingetInstall "K-Lite Mega Codec Pack", "K-Lite Mega Codec Pack"
goto klitecodecs


:UsefullProgs
echo.	1. 7-zip
echo.	2. Notepad++
echo.	3. Autoruns
echo.	4. WinMerge
echo.	5. DDU
echo.	6. HWiNFO
echo.	7. Rust desk
echo.	8. Следующая страница..
echo.	9. Предыдущая страница..
call :message
choice /C:123456789 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto 7zip
if %_erl%==2 cls && goto notepad
if %_erl%==3 cls && goto autoruns
if %_erl%==4 cls && goto winMerge
if %_erl%==5 cls && goto ddu
if %_erl%==6 cls && goto HWiNFO
if %_erl%==7 cls && goto rustDesk
if %_erl%==8 cls && call :message && goto SecondUsefullProgs
if %_erl%==9 cls && call :message && goto ProgramDownload
goto UsefullProgs

:7zip
call :wingetInstall "7-zip", "7zip.7zip"
goto UsefullProgs

:notepad
call :wingetInstall "Notepad++", "Notepad++.Notepad++"
goto UsefullProgs

:autoruns
call :wingetInstall "Autoruns", "Microsoft.Sysinternals.Autoruns"
goto UsefullProgs

:winMerge
call :wingetInstall "WinMerge", "WinMerge.WinMerge"
goto UsefullProgs

:ddu
call :wingetInstall "Display Driver Uninstaller", "Wagnardsoft.DisplayDriverUninstaller"
goto UsefullProgs

:HWiNFO
call :wingetInstall "HWiNFO", "REALiX.HWiNFO"
goto UsefullProgs

:rustDesk
call :wingetInstall "RustDesk", "RustDesk.RustDesk"
goto UsefullProgs


:SecondUsefullProgs
echo.	1. Text-Grab
echo.	2. qBittorent
echo.	3. TranslucentTB
echo.	4. BCUninstaller
echo.	5. Rufus
echo.	6. Msi-Util
echo.	8. Следующая страница..
echo.	9. Предыдущая страница..
call :message
choice /C:123456789 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto textGrab
if %_erl%==2 cls && goto qBittorent
if %_erl%==3 cls && goto translucentTB
if %_erl%==4 cls && goto BCU
if %_erl%==5 cls && goto rufus
if %_erl%==6 cls && goto coursor
if %_erl%==7 cls && goto msiUtil
if %_erl%==8 cls && call :message && goto ThirdUsefullProgs
if %_erl%==9 cls && call :message && goto UsefullProgs
goto SecondUsefullProgs

:textGrab
call :wingetInstall "Text Grab", "JosephFinney.Text-Grab"
goto SecondUsefullProgs

:qBittorent
call :wingetInstall "qBittorrent", "qBittorrent.qBittorrent"
goto SecondUsefullProgs

:translucentTB
call :wingetInstall "TranslucentTB", "9PF4KZ2VN4W9"
goto SecondUsefullProgs

:BCU
call :wingetInstall "BCUninstaller", "Klocman.BulkCrapUninstaller"
goto SecondUsefullProgs

:rufus
call :wingetInstall "Rufus", "Rufus.Rufus"
goto SecondUsefullProgs

:msiUtil
cd "%UserProfile%\Desktop"
call :message "Загрузка MSI_util_v3.."
call :download "https://download2435.mediafire.com/poh28xtppbogFdzRwDj3cv6AYgiIjy7IWbog5nCfYFzaLd8vJYghZA47RDoxYXHlqqVHOmVP-FXWXi847vncp9baFLpJiA/ewpy1p0rr132thk/MSI_util_v3.zip" "MSI_util_v3.zip"
cls
call :message "Архив загружен на рабочий стол"
cd /d "%~dp0"
goto SecondUsefullProgs


:ThirdUsefullProgs
echo.	1. ExplorerPatcher
echo.	2. QEMU
echo.	3. PowerToys
echo.	4. LibreOffice
echo.	5. OpenOffice
echo.	9. Предыдущая страница..
call :message
choice /C:123459 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto explorerPatcher
if %_erl%==2 cls && goto qemu
if %_erl%==3 cls && goto powerToys
if %_erl%==4 cls && goto libreOffice
if %_erl%==5 cls && goto openOffice
if %_erl%==6 cls && call :message && goto SecondUsefullProgs
goto ThirdUsefullProgs

:explorerPatcher
call :wingetInstall "ExplorerPatcher", "valinet.ExplorerPatcher"
goto ThirdUsefullProgs

:qemu
call :wingetInstall "QEMU" ,"SoftwareFreedomConservancy.QEMU"
goto ThirdUsefullProgs

:powerToys
call :wingetInstall "PowerToys" ,"Microsoft.PowerToys"
goto ThirdUsefullProgs

:libreOffice
call :wingetInstall "LibreOffice" ,"TheDocumentFoundation.LibreOffice"
goto ThirdUsefullProgs

:openOffice
call :wingetInstall "OpenOffice" ,"Apache.OpenOffice"
goto ThirdUsefullProgs


::													Functions
:: ========================================================================================================
:: Created by Vijorich


:download
(
	PowerShell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('%~1', '%~2')"
) >nul 2>&1
goto :eof

:delete
pushd "%~1" 2>nul && ( rd /Q /S . 2>nul & popd )
goto :eof

:TestDelete
pushd "%~1" 2>nul  && ( rd /Q /S . 2>nul & popd )
goto :eof

:wingetInstall
call :message "Установка %~1.."
winget install "%~2"
cls
if "%errorlevel%" equ "0" (
	color 0A
	call :message "Установка %~1 завершена"
) else if "%errorlevel%" equ "-1978335189" (
	color 0A
	call :message "%~1 уже установлен и обновления не найдены"
) else if "%errorlevel%" equ "-1978334963" (
	color 0A
	call :message "%~1 уже установлен и обновления не найдены"
) else if "%errorlevel%" equ "9009" (
	color 0C
	call :message "Отсутствует установщик пакетов winget"
	call :message "Установите программу из офф источника:"
	call :message "https://learn.microsoft.com/ru-ru/windows/package-manager/winget/"
) else (
	color 0C
	call :message "Неизвестная ошибка"
)
	color 0A
goto :eof

:message
setlocal DisableDelayedExpansion
echo.
echo. %~1
echo.
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


::													Cheers
:: ========================================================================================================
:: Created by Vijorich


:CheerUpAuthorMenu
echo.	1. Скинуть смешную гифку ребятам из техношахты!
echo.	2. Пощекотав кнопку подписки на youtube канале
echo.
echo.	Скинув денюжку на покушать:
echo.	3. donationalerts
echo.	4. donatepay
echo.
echo.	Подписавшись на бусти: 
echo.	5. boosty
echo.
echo.	9. Вернуться в главное меню
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