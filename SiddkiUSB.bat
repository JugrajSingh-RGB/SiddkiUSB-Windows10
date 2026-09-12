@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================================
REM  SiddkiUSB - Hands-Free USB Auto-Copy System for Windows 10/11
REM  Windows 10/11 compatible batch version: corrected variable names, labels,
REM  date-safe folders, USB detection, and removal checks.
REM ============================================================================

REM Keep the window open if the script hits an unexpected error during startup.
pushd "%~dp0" >nul 2>&1

REM Check if running as Administrator.
net session >nul 2>&1
if errorlevel 1 (
    echo.
    echo ============================================================================
    echo [WARNING] NOT RUNNING AS ADMINISTRATOR
    echo ============================================================================
    echo This script works best with Administrator privileges.
    echo Right-click this file and select "Run as administrator".
    echo.
    echo Press any key to continue anyway...
    pause >nul
)

REM ============================================================================
REM CONFIGURATION
REM ============================================================================
set "DEST_BASE=%USERPROFILE%\Documents\Siddki USB"
set "MONITOR_INTERVAL=2"
set "REMOVAL_CHECK_INTERVAL=1"
set "WORK_DIR=%TEMP%\SiddkiUSB"
set "LOG_FILE=%WORK_DIR%\SiddkiUSB_log.txt"
set "USB_DB=%WORK_DIR%\SiddkiUSB_devices.txt"
set "DIAG_FILE=%WORK_DIR%\SiddkiUSB_diagnostics.txt"
set "COPY_IN_PROGRESS=0"
set "DETECTION_METHOD=UNKNOWN"
set "SLEEP_COMMAND=TIMEOUT"

if not exist "%WORK_DIR%" mkdir "%WORK_DIR%" >nul 2>&1

echo.
echo ============================================================================
echo  SiddkiUSB - Pre-Flight System Check
echo ============================================================================
echo.

where robocopy >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Robocopy was not found. It is normally built into Windows.
    call :install_robocopy
    if errorlevel 1 (
        echo.
        echo Press any key to exit...
        pause >nul
        exit /b 1
    )
)
echo [OK] Robocopy found

choice /c Y /t 1 /d Y >nul 2>&1
if not errorlevel 1 set "SLEEP_COMMAND=CHOICE"

call :detect_usb_method
if "%DETECTION_METHOD%"=="UNKNOWN" (
    echo [WARNING] No USB detection method available.
    call :enable_wmic_or_fallback
)

if not exist "%DEST_BASE%" (
    mkdir "%DEST_BASE%" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to create destination folder:
        echo         "%DEST_BASE%"
        echo.
        echo Press any key to exit...
        pause >nul
        exit /b 1
    )
)
echo [OK] Destination folder ready: %DEST_BASE%

type nul > "%USB_DB%"
type nul > "%LOG_FILE%"

echo.
echo ============================================================================
echo  SiddkiUSB - Hands-Free USB Auto-Copy System
echo ============================================================================
echo.
echo Destination: %DEST_BASE%
echo Detection Method: %DETECTION_METHOD%
echo Log File: %LOG_FILE%
echo.
echo Status: Waiting for USB insertion...
echo Press Ctrl+C to exit.
echo.
echo ============================================================================
echo.

echo [START] SiddkiUSB initialized at %date% %time%>>"%LOG_FILE%"
echo [INFO] Detection Method: %DETECTION_METHOD%>>"%LOG_FILE%"
echo.>>"%LOG_FILE%"

:monitor_loop
call :sleep %MONITOR_INTERVAL%

call :get_connected_usb_drives

set "OLD_USB="
for /f "usebackq delims=" %%A in ("%USB_DB%") do set "OLD_USB=%%A"

if not "%DETECTED_USB%"=="" (
    if /i not "%DETECTED_USB%"=="%OLD_USB%" (
        echo [NEW USB] Detected: %DETECTED_USB% at %time%
        echo [NEW USB] Detected: %DETECTED_USB% at %time%>>"%LOG_FILE%"

        echo %DETECTED_USB%>"%USB_DB%"
        call :copy_from_usb "%DETECTED_USB%"
        goto main_loop
    )
)

goto monitor_loop

:detect_usb_method
echo [DIAG] Detecting USB detection method...

powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.IO.DriveInfo]::GetDrives() | Where-Object { $_.DriveType -eq 'Removable' -and $_.IsReady } | Select-Object -First 1" >nul 2>&1
if not errorlevel 1 (
    set "DETECTION_METHOD=POWERSHELL_DRIVEINFO"
    echo [DIAG] PowerShell DriveInfo available
    exit /b 0
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=2' | Select-Object -First 1" >nul 2>&1
if not errorlevel 1 (
    set "DETECTION_METHOD=POWERSHELL_CIM"
    echo [DIAG] PowerShell CIM available
    exit /b 0
)

wmic logicaldisk where drivetype=2 get deviceid >nul 2>&1
if not errorlevel 1 (
    set "DETECTION_METHOD=WMIC"
    echo [DIAG] WMIC available
    exit /b 0
)

set "DETECTION_METHOD=MANUAL"
echo [DIAG] Using manual drive letter detection
exit /b 0

:enable_wmic_or_fallback
echo [FIX] Attempting to start WMI service...
net start WinMgmt >nul 2>&1

wmic os get caption >nul 2>&1
if not errorlevel 1 (
    set "DETECTION_METHOD=WMIC"
    echo [OK] WMIC re-enabled successfully
    exit /b 0
)

set "DETECTION_METHOD=MANUAL"
echo [INFO] Using manual fallback detection method
exit /b 0

:get_connected_usb_drives
set "DETECTED_USB="

if "%DETECTION_METHOD%"=="POWERSHELL_DRIVEINFO" (
    call :usb_method_powershell_driveinfo
) else if "%DETECTION_METHOD%"=="POWERSHELL_CIM" (
    call :usb_method_powershell_cim
) else if "%DETECTION_METHOD%"=="WMIC" (
    call :usb_method_wmic
) else if "%DETECTION_METHOD%"=="POWERSHELL" (
    call :usb_method_powershell
) else (
    call :usb_method_manual
)

exit /b 0

:usb_method_powershell_driveinfo
for /f "tokens=1" %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.IO.DriveInfo]::GetDrives() | Where-Object { $_.DriveType -eq 'Removable' -and $_.IsReady } | ForEach-Object { $_.Name.Substring(0,2) }" 2^>nul') do (
    if not defined DETECTED_USB (
        set "DETECTED_USB=%%A"
    ) else (
        set "DETECTED_USB=!DETECTED_USB! %%A"
    )
)
exit /b 0

:usb_method_powershell_cim
for /f "tokens=1" %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=2' | ForEach-Object { $_.DeviceID }" 2^>nul') do (
    if not defined DETECTED_USB (
        set "DETECTED_USB=%%A"
    ) else (
        set "DETECTED_USB=!DETECTED_USB! %%A"
    )
)
exit /b 0

:usb_method_wmic
for /f "skip=1 tokens=1" %%A in ('wmic logicaldisk where drivetype^=2 get deviceid 2^>nul ^| findstr ":"') do (
    if not defined DETECTED_USB (
        set "DETECTED_USB=%%A"
    ) else (
        set "DETECTED_USB=!DETECTED_USB! %%A"
    )
)
exit /b 0

:usb_method_powershell
for /f "tokens=1" %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Volume | Where-Object { $_.DriveType -eq 'Removable' -and $_.DriveLetter } | ForEach-Object { [string]$_.DriveLetter + ':' }" 2^>nul') do (
    if not defined DETECTED_USB (
        set "DETECTED_USB=%%A"
    ) else (
        set "DETECTED_USB=!DETECTED_USB! %%A"
    )
)
exit /b 0

:usb_method_manual
for %%D in (Z Y X W V U T S R Q P O N M L K J I H G F E D) do (
    if exist "%%D:\" (
        dir "%%D:\" >nul 2>&1
        if not errorlevel 1 (
            set "DETECTED_USB=%%D:"
            goto end_manual_scan
        )
    )
)

:end_manual_scan
exit /b 0

:copy_from_usb
setlocal EnableDelayedExpansion
set "USB_DRIVE=%~1"
set "USB_LETTER=%USB_DRIVE:~0,1%"
set "USB_SOURCE=%USB_LETTER%:\."

for /f %%A in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Date -Format yyyy-MM-dd_HH-mm-ss"') do set "STAMP=%%A"
set "COPY_DEST=%DEST_BASE%\%USB_LETTER%_Drive_%STAMP%"

echo.
echo ============================================================================
echo [COPY] Starting USB copy process
echo ============================================================================
echo USB Drive: !USB_DRIVE!
echo Destination: !COPY_DEST!
echo Time: %date% %time%
echo.

if not exist "!COPY_DEST!\" mkdir "!COPY_DEST!" >nul 2>&1

if not exist "!COPY_DEST!\" (
    echo [ERROR] Failed to create destination directory.
    endlocal
    exit /b 1
)

set "COPY_IN_PROGRESS=1"

:copy_loop

if not exist "!USB_LETTER!:\" (
    echo.
    echo [USB DISCONNECTED] !USB_LETTER!: was removed.
    echo [WAITING] Waiting for USB to come back...

:wait_for_usb
    call :sleep 2

    if not exist "!USB_LETTER!:\" goto wait_for_usb

    echo.
    echo [USB RETURNED] !USB_LETTER!: detected again.
    echo [INFO] Resuming copy...
    echo.
)

robocopy "!USB_SOURCE!" "!COPY_DEST!" /E /R:0 /W:0 /MT:16 /DCOPY:DAT /COPY:DAT /XD "System Volume Information"
set "ROBOCOPY_EXIT=!errorlevel!"

if not exist "!USB_LETTER!:\" (
    echo.
    echo [USB DISCONNECTED] USB was removed during copying.
    echo [WAITING] Waiting for USB to come back...

:wait_after_copy_disconnect
    call :sleep 2

    if not exist "!USB_LETTER!:\" goto wait_after_copy_disconnect

    echo.
    echo [USB RETURNED] USB detected again.
    echo [INFO] Resuming copy...
    echo.

    goto copy_loop
)

if !ROBOCOPY_EXIT! leq 7 (
    echo.
    echo [SUCCESS] Files copied successfully.
) else (
    echo.
    echo [ERROR] Copy process failed with error code !ROBOCOPY_EXIT!.
)

set "COPY_IN_PROGRESS=0"
call :sleep 3
endlocal
exit /b 0

:monitor_usb_removal
setlocal EnableDelayedExpansion
set "USB_TO_MONITOR=%~1"
set "USB_LETTER_TO_MONITOR=%USB_TO_MONITOR:~0,1%"
set "CHECK_COUNT=0"

echo [MONITOR] Watching for USB removal...
echo [MONITOR] Watching for USB removal...>>"%LOG_FILE%"
echo.

:removal_check
call :sleep %REMOVAL_CHECK_INTERVAL%
set /a CHECK_COUNT+=1

if exist "!USB_LETTER_TO_MONITOR!:\" (
    if !CHECK_COUNT! geq 10 (
        echo [MONITOR] USB still connected... (!CHECK_COUNT! checks)
        set "CHECK_COUNT=0"
    )
    goto removal_check
)

echo.
echo ============================================================================
echo [USB REMOVED] !USB_LETTER_TO_MONITOR!: has been removed
echo ============================================================================
echo [USB REMOVED] !USB_LETTER_TO_MONITOR!: has been removed>>"%LOG_FILE%"
echo.

endlocal
exit /b 0

:install_robocopy
if exist "%SystemRoot%\System32\robocopy.exe" (
    echo [OK] Robocopy found at %SystemRoot%\System32\robocopy.exe
    exit /b 0
)

echo [ERROR] Robocopy not found in standard locations.
echo Please run Windows Update, restart, and try again.
exit /b 1

:sleep
setlocal
set "SECONDS=%~1"
if "%SLEEP_COMMAND%"=="CHOICE" (
    choice /c Y /t %SECONDS% /d Y >nul 2>&1
) else (
    timeout /t %SECONDS% /nobreak >nul 2>&1
)
endlocal
exit /b 0
