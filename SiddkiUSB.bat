@echo off
REM ============================================================================
REM  SiddkiUSB - Hands-Free USB Auto-Copy System for Windows 10/11
REM  ULTIMATE VERSION - Auto-Detection, Auto-Fix, Built-in Diagnostics
REM ============================================================================
REM  IMPORTANT: Run as Administrator for full functionality
REM  Right-click CMD → Run as Administrator
REM ============================================================================

setlocal enabledelayedexpansion

REM Check if running as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ============================================================================
    echo [WARNING] NOT RUNNING AS ADMINISTRATOR
    echo ============================================================================
    echo This script needs Administrator privileges to:
    echo - Access all files on USB drives
    echo - Create necessary system configurations
    echo - Properly detect connected USB devices
    echo.
    echo RIGHT-CLICK THIS FILE AND SELECT "Run as administrator"
    echo OR
    echo Open Command Prompt as Administrator and run this script
    echo.
    echo Press any key to continue anyway (limited functionality)...
    pause
    echo.
)

REM ============================================================================
REM CONFIGURATION
REM ============================================================================
set "DEST_BASE=%USERPROFILE%\Documents\Siddki USB"
set "MONITOR_INTERVAL=2"
set "REMOVAL_CHECK_INTERVAL=1"
set "LOG_FILE=%TEMP%\SiddkiUSB_log.txt"
set "USB_DB=%TEMP%\SiddkiUSB_devices.txt"
set "DIAG_FILE=%TEMP%\SiddkiUSB_diagnostics.txt"
set "LAST_USB_LETTER="
set "COPY_IN_PROGRESS=0"
set "DETECTION_METHOD=UNKNOWN"

REM ============================================================================
REM PRE-FLIGHT CHECKS
REM ============================================================================

echo.
echo ============================================================================
echo  SiddkiUSB - Pre-Flight System Check
echo ============================================================================
echo.

REM Check if robocopy exists
where robocopy >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Robocopy not found. Installing...
    call :install_robocopy
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to install robocopy. Robocopy is required.
        pause
        exit /b 1
    )
)
echo [OK] Robocopy found

REM Check USB detection capability
call :detect_usb_method
if "!DETECTION_METHOD!"=="UNKNOWN" (
    echo [WARNING] No USB detection method available
    echo Attempting to enable WMIC or use alternative method...
    call :enable_wmic_or_fallback
)

REM Create destination folder
if not exist "!DEST_BASE!" (
    mkdir "!DEST_BASE!"
    if errorlevel 1 (
        echo [ERROR] Failed to create destination folder: !DEST_BASE!
        echo Please check permissions or run as Administrator.
        pause
        exit /b 1
    )
)
echo [OK] Destination folder ready: !DEST_BASE!

REM Initialize USB database
if not exist "!USB_DB!" (
    type nul > "!USB_DB!"
)

REM ============================================================================
REM MAIN BANNER
REM ============================================================================

echo.
echo ============================================================================
echo  SiddkiUSB - Hands-Free USB Auto-Copy System
echo ============================================================================
echo.
echo Destination: !DEST_BASE!
echo Detection Method: !DETECTION_METHOD!
echo Log File: !LOG_FILE!
echo.
echo Status: Waiting for USB insertion...
echo Press Ctrl+C to exit.
echo.
echo ============================================================================
echo.

REM Clear log
type nul > "!LOG_FILE!"
echo [START] SiddkiUSB initialized at %date% %time% >> "!LOG_FILE!"
echo [INFO] Detection Method: !DETECTION_METHOD! >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"

REM ============================================================================
REM MAIN MONITORING LOOP
REM ============================================================================

:monitor_loop
timeout /t !MONITOR_INTERVAL! /nobreak >nul

REM Get current connected USB drives
setlocal enabledelayedexpansion
call :get_connected_usb_drives
setlocal enabledelayedexpansion

REM Check for new USB drives
for /f "tokens=*" %%A in ('type "!USB_DB!" 2^>nul') do (
    set "OLD_USB=%%A"
)

if not "!DETECTED_USB!"=="" (
    if "!DETECTED_USB!" neq "!OLD_USB!" (
        echo [NEW USB] Detected: !DETECTED_USB! at %time%
        echo [NEW USB] Detected: !DETECTED_USB! at %time% >> "!LOG_FILE!"
        
        REM Store in database
        echo !DETECTED_USB! > "!USB_DB!"
        
        REM Start copy process
        call :copy_from_usb "!DETECTED_USB!"
        
        REM After copy, monitor for removal
        call :monitor_usb_removal "!DETECTED_USB!"
        
        REM Clear database
        type nul > "!USB_DB!"
    )
)

goto monitor_loop

REM ============================================================================
REM FUNCTION: Detect USB Detection Method
REM ============================================================================
:detect_usb_method

echo [DIAG] Detecting USB detection method...

REM Method 1: Try WMIC (Windows 10 standard)
wmic logicaldisk where drivetype=2 get deviceid >nul 2>&1
if !errorlevel! equ 0 (
    set "DETECTION_METHOD=WMIC"
    echo [DIAG] ✓ WMIC available
    exit /b 0
)

REM Method 2: Try PowerShell Get-Volume (Windows 10+)
powershell -Command "Get-Volume -ErrorAction Stop" >nul 2>&1
if !errorlevel! equ 0 (
    set "DETECTION_METHOD=POWERSHELL"
    echo [DIAG] ✓ PowerShell Get-Volume available
    exit /b 0
)

REM Method 3: Try diskpart
echo list disk | diskpart >nul 2>&1
if !errorlevel! equ 0 (
    set "DETECTION_METHOD=DISKPART"
    echo [DIAG] ✓ Diskpart available
    exit /b 0
)

REM Method 4: Manual drive detection (Z-A)
set "DETECTION_METHOD=MANUAL"
echo [DIAG] ✓ Using manual drive letter detection
exit /b 0

:enable_wmic_or_fallback

echo [FIX] Attempting to re-enable WMI service...
net start WinMgmt >nul 2>&1

REM Re-test WMIC
wmic os get caption >nul 2>&1
if !errorlevel! equ 0 (
    set "DETECTION_METHOD=WMIC"
    echo [OK] WMIC re-enabled successfully
    exit /b 0
)

echo [INFO] Using fallback detection method
exit /b 0

REM ============================================================================
REM FUNCTION: Get Connected USB Drives
REM ============================================================================
:get_connected_usb_drives

set "DETECTED_USB="

if "!DETECTION_METHOD!"=="WMIC" (
    call :usb_method_wmic
) else if "!DETECTION_METHOD!"=="POWERSHELL" (
    call :usb_method_powershell
) else if "!DETECTION_METHOD!"=="DISKPART" (
    call :usb_method_diskpart
) else (
    call :usb_method_manual
)

exit /b 0

REM ============================================================================
REM USB Detection Method: WMIC
REM ============================================================================
:usb_method_wmic

for /f "tokens=1" %%A in ('wmic logicaldisk where drivetype=2 get deviceid 2^>nul ^| findstr ":"') do (
    if not "!DETECTED_USB!"=="" (
        set "DETECTED_USB=!DETECTED_USB! %%A"
    ) else (
        set "DETECTED_USB=%%A"
    )
)

exit /b 0

REM ============================================================================
REM USB Detection Method: PowerShell
REM ============================================================================
:usb_method_powershell

for /f "tokens=1" %%A in ('powershell -Command "Get-Volume | Where-Object {$_.DriveType -eq 'Removable'} | Select-Object -ExpandProperty DriveLetter" 2^>nul') do (
    if not "!DETECTED_USB!"=="" (
        set "DETECTED_USB=!DETECTED_USB! %%A:"
    ) else (
        set "DETECTED_USB=%%A:"
    )
)

exit /b 0

REM ============================================================================
REM USB Detection Method: Diskpart
REM ============================================================================
:usb_method_diskpart

REM Create diskpart script
echo list disk > %TEMP%\diskpart_script.txt

for /f "tokens=2" %%A in ('diskpart /s %TEMP%\diskpart_script.txt 2^>nul ^| findstr "Disk"') do (
    REM Check if it's a removable disk (heuristic)
    set "DETECTED_USB=%%A"
)

del %TEMP%\diskpart_script.txt >nul 2>&1

exit /b 0

REM ============================================================================
REM USB Detection Method: Manual Drive Letter Scan
REM ============================================================================
:usb_method_manual

REM Scan drives Z to D (excluding C which is usually system drive)
for %%D in (Z Y X W V U T S R Q P O N M L K J I H G F E D) do (
    if exist %%D:\ (
        REM Check if it's not a network drive or system drive
        if not "%%D"=="C" (
            REM Simple heuristic: if drive is present and accessible
            dir %%D:\ >nul 2>&1
            if !errorlevel! equ 0 (
                set "DETECTED_USB=%%D:"
                goto :end_manual_scan
            )
        )
    )
)

:end_manual_scan
exit /b 0

REM ============================================================================
REM FUNCTION: Copy from USB
REM ============================================================================
:copy_from_usb

setlocal enabledelayedexpansion
set "USB_DRIVE=%~1"
set "USB_LETTER=%USB_DRIVE:~0,1%"
set "COPY_DEST=!DEST_BASE!\!USB_LETTER!_Drive_%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%"

echo.
echo ============================================================================
echo [COPY] Starting USB copy process
echo ============================================================================
echo USB Drive: !USB_DRIVE!
echo Destination: !COPY_DEST!
echo Time: %date% %time%
echo.

echo [COPY] Starting USB copy process >> "!LOG_FILE!"
echo USB Drive: !USB_DRIVE! >> "!LOG_FILE!"
echo Destination: !COPY_DEST! >> "!LOG_FILE!"
echo.

REM Create destination directory
mkdir "!COPY_DEST!" 2>nul
if errorlevel 1 (
    echo [ERROR] Failed to create destination directory
    echo [ERROR] Failed to create destination directory >> "!LOG_FILE!"
    exit /b 1
)

REM Perform copy using robocopy
set "COPY_IN_PROGRESS=1"

echo [INFO] Copying files... This may take a while depending on file size.
echo [INFO] Copying files... >> "!LOG_FILE!"

REM Robocopy command with retry and multi-threading
robocopy "!USB_DRIVE!\" "!COPY_DEST!" /E /R:3 /W:1 /MT:16 /DCOPY:DAT /COPY:DAT /LOG:"!COPY_DEST!\copy_log.txt" /LOG+:"!LOG_FILE!"

if !errorlevel! leq 7 (
    echo.
    echo [SUCCESS] Files copied successfully!
    echo [SUCCESS] Files copied successfully! >> "!LOG_FILE!"
    echo.
    timeout /t 3 /nobreak
) else (
    echo.
    echo [ERROR] Copy process failed with error code !errorlevel!
    echo [ERROR] Copy process failed with error code !errorlevel! >> "!LOG_FILE!"
    echo.
    timeout /t 3 /nobreak
)

set "COPY_IN_PROGRESS=0"

endlocal
exit /b 0

REM ============================================================================
REM FUNCTION: Monitor USB Removal
REM ============================================================================
:monitor_usb_removal

setlocal enabledelayedexpansion
set "USB_TO_MONITOR=%~1"
set "USB_LETTER_TO_MONITOR=%USB_TO_MONITOR:~0,1%"
set "REMOVAL_DETECTED=0"
set "CHECK_COUNT=0"

echo [MONITOR] Watching for USB removal...
echo [MONITOR] Watching for USB removal... >> "!LOG_FILE!"
echo.

:removal_check
timeout /t !REMOVAL_CHECK_INTERVAL! /nobreak >nul

set /a CHECK_COUNT+=1

REM Test if USB drive still exists
if exist "!USB_LETTER_TO_MONITOR!:\" (
    REM Drive still exists - continue monitoring
    REM Show progress every 10 checks
    if %CHECK_COUNT% gtr 10 (
        echo [MONITOR] USB still connected... (%CHECK_COUNT% checks)
        set "CHECK_COUNT=0"
    )
) else (
    REM Drive removed
    echo.
    echo ============================================================================
    echo [USB REMOVED] !USB_LETTER_TO_MONITOR!: has been safely removed
    echo ============================================================================
    echo [USB REMOVED] !USB_LETTER_TO_MONITOR!: has been safely removed >> "!LOG_FILE!"
    echo.
    set "REMOVAL_DETECTED=1"
)

if "!REMOVAL_DETECTED!"=="0" (
    goto removal_check
)

endlocal
exit /b 0

REM ============================================================================
REM FUNCTION: Install Robocopy
REM ============================================================================
:install_robocopy

echo [INFO] Robocopy is a built-in Windows utility and should be available.
echo [INFO] If you see this message, there may be a system issue.
echo.
echo Attempting to locate robocopy...

REM Check common robocopy locations
if exist "C:\Windows\System32\robocopy.exe" (
    echo [OK] Robocopy found at C:\Windows\System32\robocopy.exe
    exit /b 0
)

if exist "C:\Program Files\ImageX\robocopy.exe" (
    echo [OK] Robocopy found at C:\Program Files\ImageX\robocopy.exe
    exit /b 0
)

echo [ERROR] Robocopy not found in standard locations.
echo.
echo Please ensure Windows is fully updated:
echo 1. Run Windows Update
echo 2. Restart your computer
echo 3. Run this script again
echo.

exit /b 1

REM ============================================================================
REM END OF SCRIPT
REM ============================================================================
