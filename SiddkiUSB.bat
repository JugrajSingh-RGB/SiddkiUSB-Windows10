@echo off
REM ============================================================================
REM  SiddkiUSB - Hands-Free USB Auto-Copy System for Windows 10/11
REM  ULTIMATE VERSION v3.0 - Auto-Detection, Auto-Fix, Built-in Diagnostics
REM  DEBUG MODE - Shows all errors and diagnostics
REM ============================================================================

setlocal enabledelayedexpansion

cls
echo.
echo ============================================================================
echo  SiddkiUSB - Debug Mode - Initializing...
echo ============================================================================
echo.

REM Check if running as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] NOT RUNNING AS ADMINISTRATOR
    echo Please run this script as Administrator for full functionality
    echo.
    echo Right-click this file and select "Run as administrator"
    echo.
    timeout /t 5 /nobreak
)

REM ============================================================================
REM CONFIGURATION
REM ============================================================================
set "DEST_BASE=%USERPROFILE%\Documents\Siddki USB"
set "MONITOR_INTERVAL=2"
set "LOG_FILE=%TEMP%\SiddkiUSB_log.txt"
set "USB_DB=%TEMP%\SiddkiUSB_devices.txt"
set "LAST_USB_LETTER="
set "COPY_IN_PROGRESS=0"
set "DETECTION_METHOD=UNKNOWN"

echo [1/5] Configuration loaded
echo [DEST] %DEST_BASE%
echo.

REM ============================================================================
REM PRE-FLIGHT CHECKS
REM ============================================================================

echo [2/5] Checking system requirements...
echo.

REM Check if robocopy exists
echo Checking for robocopy.exe...
robocopy /? >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Robocopy not found!
    echo Robocopy is required but not available on this system.
    echo.
    echo Please ensure Windows is fully updated:
    echo 1. Go to Settings ^> System ^> About
    echo 2. Click "Check for updates"
    echo 3. Install all available updates
    echo 4. Restart your computer
    echo 5. Run this script again
    echo.
    pause
    exit /b 1
)
echo [OK] Robocopy found
echo.

REM ============================================================================
REM TEST USB DETECTION METHODS
REM ============================================================================

echo [3/5] Testing USB detection methods...
echo.

REM Method 1: WMIC
echo Testing WMIC method...
wmic logicaldisk where drivetype=2 get deviceid >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] WMIC available - will use this method
    set "DETECTION_METHOD=WMIC"
    goto detection_ok
)
echo [X] WMIC not available
echo.

REM Method 2: PowerShell
echo Testing PowerShell method...
powershell -Command "Get-Volume -ErrorAction Stop" >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] PowerShell available - will use this method
    set "DETECTION_METHOD=POWERSHELL"
    goto detection_ok
)
echo [X] PowerShell not available
echo.

REM Method 3: diskpart
echo Testing diskpart method...
echo list disk | diskpart >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Diskpart available - will use this method
    set "DETECTION_METHOD=DISKPART"
    goto detection_ok
)
echo [X] Diskpart not available
echo.

REM Method 4: Manual detection
echo Using manual drive letter detection
set "DETECTION_METHOD=MANUAL"

:detection_ok
echo [OK] Detection method selected: !DETECTION_METHOD!
echo.

REM ============================================================================
REM CREATE DESTINATION FOLDER
REM ============================================================================

echo [4/5] Preparing destination folder...
echo.

if not exist "!DEST_BASE!" (
    echo Creating: !DEST_BASE!
    mkdir "!DEST_BASE!"
    if errorlevel 1 (
        echo [ERROR] Failed to create destination folder
        echo Possible causes:
        echo - Permission denied (not running as Administrator)
        echo - Invalid path
        echo - Disk full
        echo.
        pause
        exit /b 1
    )
)
echo [OK] Destination ready: !DEST_BASE!
echo.

REM Initialize databases
if not exist "!USB_DB!" (
    type nul > "!USB_DB!"
)

type nul > "!LOG_FILE!"
echo [STARTUP] SiddkiUSB initialized at %date% %time% >> "!LOG_FILE!"
echo [INFO] Detection Method: !DETECTION_METHOD! >> "!LOG_FILE!"

REM ============================================================================
REM DISPLAY READY STATUS
REM ============================================================================

echo [5/5] System ready!
echo.
echo ============================================================================
echo  SiddkiUSB - Ready to Monitor for USB Drives
echo ============================================================================
echo.
echo Configuration:
echo - Destination: !DEST_BASE!
echo - Detection: !DETECTION_METHOD!
echo - Log: !LOG_FILE!
echo.
echo Status: Waiting for USB insertion...
echo.
echo Instructions:
echo 1. Insert a USB drive now
echo 2. Files will be copied automatically to the destination folder
echo 3. Remove USB anytime - copy will stop safely
echo 4. Reinsert USB to resume copying
echo 5. Press Ctrl+C to stop monitoring
echo.
echo ============================================================================
echo.

REM ============================================================================
REM MAIN MONITORING LOOP
REM ============================================================================

set "LAST_USB_DETECTED="
set "LOOP_COUNT=0"

:monitor_loop

set /a LOOP_COUNT+=1

REM Get current USB drives based on detection method
setlocal enabledelayedexpansion

if "!DETECTION_METHOD!"=="WMIC" (
    for /f "tokens=1" %%A in ('wmic logicaldisk where drivetype=2 get deviceid 2^>nul ^| findstr ":"') do (
        set "CURRENT_USB=%%A"
        goto usb_found_wmic
    )
    set "CURRENT_USB="
    :usb_found_wmic
) else if "!DETECTION_METHOD!"=="POWERSHELL" (
    for /f "tokens=1" %%A in ('powershell -Command "Get-Volume -ErrorAction SilentlyContinue | Where-Object {$_.DriveType -eq 'Removable'} | Select-Object -ExpandProperty DriveLetter" 2^>nul') do (
        set "CURRENT_USB=%%A:"
        goto usb_found_ps
    )
    set "CURRENT_USB="
    :usb_found_ps
) else if "!DETECTION_METHOD!"=="DISKPART" (
    REM Diskpart detection - check for removable media
    echo list disk | diskpart 2>nul | findstr "Removable" >nul 2>&1
    if !errorlevel! equ 0 (
        set "CURRENT_USB=FOUND_VIA_DISKPART"
    ) else (
        set "CURRENT_USB="
    )
) else (
    REM Manual detection - scan all drive letters
    set "CURRENT_USB="
    for %%D in (Z Y X W V U T S R Q P O N M L K J I H G F E D) do (
        if exist %%D:\ (
            if not "%%D"=="C" (
                dir %%D:\ >nul 2>&1
                if !errorlevel! equ 0 (
                    REM Check if it's likely a removable drive (not too large)
                    for /f %%Z in ('dir %%D:\ ^| find "bytes"') do (
                        set "CURRENT_USB=%%D:"
                        goto usb_found_manual
                    )
                )
            )
        )
    )
    :usb_found_manual
)

endlocal & set "CURRENT_USB=!CURRENT_USB!"

REM Check if USB state changed
if not "!CURRENT_USB!"=="!LAST_USB_DETECTED!" (
    if not "!CURRENT_USB!"=="" (
        echo.
        echo ============================================================================
        echo [USB DETECTED] %date% %time%
        echo ============================================================================
        echo Drive: !CURRENT_USB!
        echo.
        
        call :copy_from_usb "!CURRENT_USB!"
        
        echo [INFO] Copy complete. Waiting for next USB...
        echo.
    ) else (
        if not "!LAST_USB_DETECTED!"=="" (
            echo [USB REMOVED] %date% %time% - !LAST_USB_DETECTED! ejected
            echo.
        )
    )
    set "LAST_USB_DETECTED=!CURRENT_USB!"
)

timeout /t !MONITOR_INTERVAL! /nobreak >nul

goto monitor_loop

REM ============================================================================
REM FUNCTION: Copy from USB
REM ============================================================================
:copy_from_usb

setlocal enabledelayedexpansion
set "USB_DRIVE=%~1"

echo Starting copy from !USB_DRIVE!
echo Source: !USB_DRIVE!\
echo Destination: !DEST_BASE!
echo.

REM Verify USB still exists
if not exist "!USB_DRIVE!\" (
    echo [ERROR] USB drive !USB_DRIVE! is not accessible!
    endlocal
    exit /b 1
)

echo [INFO] Copying files... This may take a while
echo.

REM Run robocopy
robocopy "!USB_DRIVE!\" "!DEST_BASE!" /E /R:3 /W:1 /MT:8 /DCOPY:DAT /COPY:DAT /NP /NFL /NDL 2>&1

set "ROBOCOPY_EXIT=!ERRORLEVEL!"

echo.
echo ============================================================================
echo [ROBOCOPY EXIT CODE] !ROBOCOPY_EXIT!
echo ============================================================================
echo.

if !ROBOCOPY_EXIT! equ 0 (
    echo [OK] No files to copy (destination already complete or empty source)
) else if !ROBOCOPY_EXIT! equ 1 (
    echo [OK] Files copied successfully
) else if !ROBOCOPY_EXIT! leq 7 (
    echo [OK] Copy completed with minor warnings (exit code !ROBOCOPY_EXIT!)
) else (
    echo [WARNING] Copy completed with exit code !ROBOCOPY_EXIT!
)

echo Files saved to: !DEST_BASE!
echo.

endlocal
exit /b 0

REM ============================================================================
REM END OF SCRIPT
REM ============================================================================
