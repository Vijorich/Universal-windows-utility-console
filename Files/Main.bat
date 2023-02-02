@echo off & setlocal EnableDelayedExpansion
@title = UberCleaner
chcp 65001 >nul

SET v=1.6

verify on
cd /d "%~dp0"
COLOR A


rem													Startup check
rem ========================================================================================================
rem Created by Vijorich


:StartupCheck
title = Проверка...

for /f "tokens=6 delims=[]. " %%G in ('ver') Do (
	set _build=%%G
	if "%%G" lss "10586" (
		call :message "Эта версия windows не поддерживается!"
		pause
		exit
	)
) 

for /f %%i in ('PowerShell -Command "[Enum]::GetNames([Net.SecurityProtocolType]) -contains 'Tls12'"') do (
	if "%%i" == "False" (
		call :message "Ваша версия PowerShell не поддерживает TLS1.2 !"
		echo:  Обновите PowerShell https://aka.ms/PSWindows
		pause
		exit
	)
)


rem													Config check
rem ========================================================================================================
rem Created by Vijorich


:ConfigCheck
title = Ищу конфиг очистки...
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders" /v StateFlags0777"
cls
if %errorlevel% == 0 (goto :GatherInfo) else (call :CleanerSetup)


rem													System config
rem ========================================================================================================
rem Created by Vijorich


:GatherInfo
title = Собираю информацию...

for /f %%a in ('powershell -command "Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | Foreach {[int](($_.Sum/1GB))}"') do (set _memory=%%a)

if %_build% GEQ 22000 (
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
title = UberCleaner !v!
setlocal DisableDelayedExpansion

echo		1. Меню очистки
echo		2. Меню настроек реестра
echo		3. Меню схем питания
echo		4. Настроить mmagent
echo		5. Отключить резервное хранилище
echo		6. Отключить режим гибернации
echo		9. Выйти из программы
echo		0. Поддержать автора!
call :message
choice /C:12345690 /N
set _erl=%errorlevel%
if %_erl%==1 cls && call :message && goto CleanupMenu
if %_erl%==2 cls && call :message && goto RegEditMenu
if %_erl%==3 cls && call :message && goto PowerSchemesMenu
if %_erl%==4 cls && call :message "Настраиваю.." && goto MmagentSetup
if %_erl%==5 cls && goto offReservedStorage 
if %_erl%==6 cls && powercfg -h off && call :message "Режим гибернации отключен"
if %_erl%==7 exit 
if %_erl%==8 cls && call :message "Вы можете сделать приятно автору uber cleaner %v%!" && goto CheerUpAuthorMenu
goto MainMenu

:offReservedStorage
call :message "Ожидайте.."
start /wait /min %SystemRoot%\System32\Dism.exe /Online /Set-ReservedStorageState /State:Disabled
cls
call :message "Резервное хранилище отключено!"
goto MainMenu


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
Pause
cls
call :message && goto MainMenu

:fastCleanup
setlocal DisableDelayedExpansion
title = Чисти-чисти-чисти сука вот как блядь нужно чистить быстро раз-раз-раз! Чисти! Говно! Чисти!
call :message "Чищу, чищу, чищу"
Start /min /high .\cleanmgrplus\Cleanmgr+.exe /cp .\cleanmgrplus\std.cleanup
CD %WINDIR%\Temp >nul 2>&1 && RMDIR /S /Q . >nul 2>&1
CD %SYSTEMDRIVE%\Temp >nul 2>&1 && RMDIR /S /Q . >nul 2>&1
CD %Temp% >nul 2>&1 && RMDIR /S /Q . >nul 2>&1
CD %Tmp% >nul 2>&1 && RMDIR /S /Q . >nul 2>&1
DEL /F /S /Q %SYSTEMDRIVE%\*.log >nul 2>&1
DEL /F /S /Q %SYSTEMDRIVE%\*.bak >nul 2>&1
DEL /F /S /Q %SYSTEMDRIVE%\*.gid >nul 2>&1
start /min /wait WSReset.exe >nul 2>&1
taskkill /f /im WinStore.App.exe >nul 2>&1
ipconfig /release >nul 2>&1
arp -d * >nul 2>&1
nbtstat -R >nul 2>&1
ipconfig /flushdns >nul 2>&1
ipconfig /renew >nul 2>&1
endlocal
cls
call :message "Готово!" && goto MainMenu

:recommendedCleanup
setlocal DisableDelayedExpansion
title = Что чисти, епта? Как я буду вилкой-то чистить? Чё, совсем мудак, что ли? Покажи мне, как я буду чистить-то, ёпта! 
call :message "Чищу, чищу, чищу"
Start /min /high .\cleanmgrplus\Cleanmgr+.exe /cp .\cleanmgrplus\max.cleanup
CD %WINDIR%\Temp >nul 2>&1 && RMDIR /S /Q . >nul 2>&1
CD %SYSTEMDRIVE%\Temp >nul 2>&1 && RMDIR /S /Q . >nul 2>&1
CD %Temp% >nul 2>&1 && RMDIR /S /Q . >nul 2>&1
CD %Tmp% >nul 2>&1 && RMDIR /S /Q . >nul 2>&1
CD %WINDIR%\Prefetch >nul 2>&1 && RMDIR /S /Q . >nul 2>&1
CD %WINDIR%\SoftwareDistribution\Download >nul 2>&1 && RMDIR /S /Q . >nul 2>&1
DEL /F /S /Q %SYSTEMDRIVE%\*.log >nul 2>&1
DEL /F /S /Q %SYSTEMDRIVE%\*.bak >nul 2>&1
DEL /F /S /Q %SYSTEMDRIVE%\*.gid >nul 2>&1
start /min /wait WSReset.exe >nul 2>&1
taskkill /f /im WinStore.App.exe >nul 2>&1
ipconfig /release >nul 2>&1
arp -d * >nul 2>&1
nbtstat -R >nul 2>&1
ipconfig /flushdns >nul 2>&1
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
title = Хихихи применю рег и импут лага как не бывало
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
	call :regEditImport "\Windows 11 Only\w11 context menu fix" "\Windows 11 Only\w11 notifications" "\Windows 11 Only\w11 priority" "\Windows 11 Only\w11 share item"
    call :regEditTrustedImport "\Windows 11 Only\w11 defender X"
	call :regEditFullRegForAll
	cls && call :message "Применил общие .рег файлы и для шиндус 11!" && goto MainMenu
) else (
	call :regEditImport "\Windows 10 Only\w10 3d objects" "\Windows 10 Only\w10 newnetworkwindowoff" "\Windows 10 Only\w10 notifications" "\Windows 10 Only\w10 priority" "\Windows 10 Only\w10 share item" "\Windows 10 Only\w10 showsecondsinsystemclock"
    call :regEditTrustedImport "\Windows 10 Only\w10 defender X"
	call :regEditFullRegForAll
	cls && call :message "Применил общие .рег файлы и для шиндус 10!" && goto MainMenu
)

:regEditFullRegForAll
call :regEditImport "appcompability" "attachmentmanager" "autoupdate" "backgroundapps" "filesystem" "explorer" "driversearching" "cloudcontent"
call :regEditImport "systemprofile" "search" "regionalformats" "menushowdelay" "maintenance" "latestclr" "inspectre" "gamedvr" "fse"
call :regEditImport "uac" "telemetry" "systemrestore"
call :regEditTrustedImport "networkfolder X"
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
call :regEditImport "autoupdate" "cloudcontent" "driversearching"
call :message "Автообновления отключены!"
goto RegEditFirstPage

:appCompability
call :regEditImport "appcompability"
call :message "Компоненты совместимости отключены!"
goto RegEditFirstPage

:backgroundApps
call :regEditImport "backgroundapps"
call :message "Фоновые приложения отключены!"
goto RegEditFirstPage

:filesystemOptimization
call :regEditImport "filesystem" "explorer"
call :regEditTrustedImport "networkfolder X"
call :message "Файловая система оптимизирована!"
goto RegEditFirstPage

:largesystemCache
call :regEditImport "largesystemcache"
call :message "Функция largesystemcache включена!"
goto RegEditFirstPage

:gameDVR
call :regEditImport "gamedvr"
call :message "Гей бар отключен!"
goto RegEditFirstPage


:RegEditSecondPage
title = Вторая страница
echo		1. Возвращение старого просмотрщика фото
echo		2. Убрать задержку показа менюшек
echo		3. Установить нормальный форматы даты, времени и метрическую систему 
echo		4. Отключить веб поиск в меню поиска
echo		5. Уменьшение процента используемых ресурсов для лоу-приорити задач
echo		6. Отключить точки восстановления
echo		7. Глобальное отключение оптимизации во весь экран
echo		8. Следующая страница
echo		9. Предыдущая страница
echo		0. Вернуться
call :message
choice /C:1234567890 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto backOldPhotoViewer
if %_erl%==2 cls && goto menuShowDelay
if %_erl%==3 cls && goto regionalFormats
if %_erl%==4 cls && goto search
if %_erl%==5 cls && goto systemProfile
if %_erl%==6 cls && goto systemRestore
if %_erl%==7 cls && goto fse
if %_erl%==8 cls && call :message && goto RegEditThirdPage
if %_erl%==9 cls && call :message && goto RegEditFirstPage
if %_erl%==10 cls && call :message && goto RegEditMenu
goto RegEditSecondPage

:backOldPhotoViewer
call :regEditImport "backoldphotoviewer"
call :message "Старый просмотрщик фото вернулся!"
goto RegEditSecondPage

:menuShowDelay
call :regEditImport "menushowdelay"
call :message "Задержка показа меню убрана!"
goto RegEditSecondPage

:regionalFormats
call :regEditImport "regionalformats"
call :message "Форматы установленны!"
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


:RegEditThirdPage
title = Третья страница
echo		1. Использование только последних версий .NET
echo		2. Отключить все эксплойты, кроме CFG
echo		3. Отключить службы автообновления и фоновых процессов Edge браузера
echo		4. Отключить телеметрию NVIDIA
echo		5. Отключить все эксплойты
echo		6. Поставить префетч в значение 2
echo		8. Предыдущая страница
echo		9. Вернуться
call :message
choice /C:1234589 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto latestCLR
if %_erl%==2 cls && goto exploitsCFG
if %_erl%==3 cls && goto edge
if %_erl%==4 cls && goto nvdiaTelemetry
if %_erl%==5 cls && goto exploits
if %_erl%==6 cls && goto prefetcher2
if %_erl%==7 cls && call :message && goto RegEditSecondPage
if %_erl%==8 cls && call :message && goto RegEditMenu
goto RegEditThirdPage

:latestCLR
call :regEditImport "latestclr"
call :message "Использование только последних версий .NET включено!"
goto RegEditThirdPage

:exploitsCFG
call :regEditImport "exploitscfg"
call :message "Все эксплойты, кроме CFG отключены"
goto RegEditThirdPage

:edge
call :regEditImport "edge"
call :message "О нет! Они убили edge("
goto RegEditThirdPage

:nvdiaTelemetry
call :regEditImport "nvtelemetry"
call :message "Телеметрия убита"
goto RegEditThirdPage

:exploits
call :regEditImport "exploits"
call :message "Все эксплойты отключены"
goto RegEditThirdPage

:prefetcher2
call :regEditImport "prefetcher 2"
call :message "Настроил prefetch"
goto RegEditThirdPage


:RegEditWindows10Only
title = Только для 10 шиндуса
echo		1. Полностью отключить уведомления и центр уведомлений
echo		2. Увеличить приоритет для игр
echo		3. Удалить "Отправить" из контекстного меню
echo		4. Удалить папку "Объемные объекты"
echo		5. Полностью отключить дефендер, smartscreen, эксплойты
echo		6. Вывести секунды в системные часы
echo		7. Отключить уведомления при подключении новой сети
echo		9. Вернуться
call :message
choice /C:12345679 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto windows10Notifications
if %_erl%==2 cls && goto windows10Priority
if %_erl%==3 cls && goto windows10ShareItem
if %_erl%==4 cls && goto windows103dObjects
if %_erl%==5 cls && goto windows10Defender
if %_erl%==6 cls && goto windows10ShowSecondsInSystemClock
if %_erl%==7 cls && goto windows10NewnetworkWindow
if %_erl%==8 cls && call :message && goto RegEditMenu
goto RegEditWindows10Only

:windows10Notifications
call :regEditImport "\Windows 10 Only\w10 notifications"
call :message "Уведомления и центр уведомлений отключены!"
goto RegEditWindows10Only

:windows10Priority
call :regEditImport "\Windows 10 Only\w10 priority"
call :message "Приоритет для игр увеличен!"
goto RegEditWindows10Only

:windows10ShareItem
call :regEditImport "\Windows 10 Only\w10 share item"
call :message "Пункт отправить удален!"
goto RegEditWindows10Only

:windows103dObjects
call :regEditImport "\Windows 10 Only\w10 3d objects"
call :message "Пункт объемные объекты удален!"
goto RegEditWindows10Only

:windows10Defender
call :regEditTrustedImport "\Windows 10 Only\w10 defender X"
call :message "Защита пала!"
goto RegEditWindows10Only

:windows10ShowSecondsInSystemClock
call :regEditImport "\Windows 10 Only\w10 showsecondsinsystemclock"
call :message "Секунды в часах включены!"
goto RegEditWindows10Only

:windows10NewnetworkWindow
call :regEditImport "\Windows 10 Only\w10 newnetworkwindowoff"
call :message "Уведомления при подключении новой сети выключены!"
goto RegEditWindows10Only


:RegEditWindows11Only
title = Только для 11 шиндуса
echo		1. Пофиксить новое контекстное меню
echo		2. Увеличить приоритет для игр
echo		3. Удалить "Отправить" из контекстного меню
echo		4. Полностью отключить дефендер, smartscreen, эксплойты
echo		5. Полностью отключить уведомления
echo		9. Вернуться
call :message
choice /C:123459 /N
set _erl=%errorlevel%
if %_erl%==1 cls && goto windows11ContextMenuFix
if %_erl%==2 cls && goto windows11Priority
if %_erl%==3 cls && goto windows11ShareItem
if %_erl%==4 cls && goto windows11Defender
if %_erl%==5 cls && goto windows11Notifications
if %_erl%==6 cls && call :message && goto RegEditMenu
goto RegEditWindows11Only

:windows11ContextMenuFix
call :regEditImport "\Windows 11 Only\w11 context menu fix"
call :message "Новое контекстное меню исправлено!"
goto RegEditWindows11Only

:windows11Priority
call :regEditImport "\Windows 11 Only\w11 priority"
call :message "Приоритет для игр увеличен!"
goto RegEditWindows11Only

:windows11ShareItem
call :regEditImport "\Windows 11 Only\w11 share item"
call :message "Пункт отправить удален!"
goto RegEditWindows11Only

:windows11Defender
call :regEditTrustedImport "\Windows 11 Only\w11 defender X"
call :message "Защита пала!"
goto RegEditWindows11Only

:windows11Notifications
call :regEditImport "\Windows 11 Only\w11 notifications"
call :message "Уведомления отключены!"
goto RegEditWindows11Only


rem													mmagent
rem ========================================================================================================
rem Created by Vijorich


:MmagentSetup
title = Кручу верчу, на настройку sysmain дрочу

call :message "На чем у вас установленна система?"
echo 1) SSD
echo 2) HDD
echo 9) Выйти
choice /C:129 /N
set _erl=%errorlevel%
if %_erl%==1 cls && call :message "Настраиваю.." && goto MmagentSetupSSD
if %_erl%==2 cls && call :message "Настраиваю.." && goto MmagentSetupHDD
if %_erl%==3 cls && call :message && goto MainMenu

:MmagentSetupHDD
call :regEditImport "prefetcher 0"
cls && call :message "Настроено для hdd!" && goto MainMenu

:MmagentSetupSSD
call :regEditImport "prefetcher 3"
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
	cls && call :message "Настроено для ssd, windows 11!" && goto MainMenu
) else (
	call :powershell "enable-mmagent -ApplicationPreLaunch" "disable-mmagent -MC" "disable-mmagent -PC" "set-mmagent -moaf %_mmMemory%"
	cls && call :message "Настроено для ssd, windows 10!" && goto MainMenu
)


rem													Power Schemes
rem ========================================================================================================
rem Created by Vijorich


:PowerSchemesMenu
title = Схемка схемку покрывает
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

powercfg /import %~dp0\powerschemes\diohas_D.pow >nul 2>&1
powercfg /import %~dp0\powerschemes\diohas_MS.pow >nul 2>&1
powercfg /import %~dp0\powerschemes\diohas_U.pow >nul 2>&1
powercfg /import %~dp0\powerschemes\diohas_Ultra.pow >nul 2>&1
powercfg /import %~dp0\powerschemes\Shingeki_no_Windows.pow >nul 2>&1

start powercfg.cpl

goto :eof


rem													Functions
rem ========================================================================================================
rem Created by Vijorich


:download
(
	PowerShell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object Net.WebClient).DownloadFile('%~1', '%~2')"
) >nul 2>&1
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
echo Начав поддерживать от 15 рублей в месяц!: 
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