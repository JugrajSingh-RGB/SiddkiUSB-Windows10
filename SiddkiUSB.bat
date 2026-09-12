@echo off
REM ============================================================================
REM  SiddkiUSB - Hands-Free USB Auto-Copy System for Windows 10
REM  Designed for standard Windows 10 + CMD + built-in tools only
REM ============================================================================
REM  IMPORTANT: This script should ideally run with Administrator privileges
REM  to access all files on the USB and ensure maximum compatibility.
REM  If you see access denied errors, right-click CMD and select "Run as administrator"
REM  before launching this script.
REM ============================================================================

setlocal enabledelayedexpansion

REM Configuration
set "DEST_BASE=%USERPROFILE%\Documents\Siddki USB"
set "MONITOR_INTERVAL=2"
set "REMOVAL_CHECK_INTERVAL=1"
set "LOG_FILE=%TEMP%\SiddkiUSB_log.txt"
set "USB_DB=%TEMP%\SiddkiUSB_devices.txt"
set "LAST_USB_LETTER="
set "COPY_IN_PROGRESS=0"

REM Create destination folder if it doesn't exist
if not exist "!DEST_BASE!" (
    mkdir "!DEST_BASE!"
    if errorlevel 1 (
        echo [ERROR] Failed to create destination folder: !DEST_BASE!
        echo Please check permissions or run as Administrator.
        pause
        exit /b 1
    )
)

echo.
echo ============================================================================
echo  SiddkiUSB - Hands-Free USB Auto-Copy System
echo ============================================================================
echo.
echo Destination: !DEST_BASE!
echo.
echo Status: Waiting for USB insertion...
echo Press Ctrl+C to exit.
echo.
echo ============================================================================
echo.

REM Initialize USB database
if not exist "!USB_DB!" (
    type nul > "!USB_DB!"
)

:MONITOR_LOOP
    REM Check if a USB drive is currently connected
    for /f "tokens=*" %%A in ('call :GET_USB_DRIVE') do (
        set "CURRENT_USB=%%A"
    )
    
    if "!CURRENT_USB!" neq "" (
        REM USB is connected
        if "!LAST_USB_LETTER!" neq "!CURRENT_USB!" (
            REM New USB detected
            set "LAST_USB_LETTER=!CURRENT_USB!"
            call :HANDLE_USB_INSERTION "!CURRENT_USB!"
        )
    ) else (
        REM No USB connected
        if "!LAST_USB_LETTER!" neq "" (
            REM USB was removed
            if !COPY_IN_PROGRESS! equ 1 (
                echo.
                echo USB removed — copy stopped.
                echo Partially copied files preserved for resume.
                set "COPY_IN_PROGRESS=0"
            )
            set "LAST_USB_LETTER="
            echo.
            echo Waiting for USB...
        )
    )
    
    timeout /t !MONITOR_INTERVAL! /nobreak > nul
    goto MONITOR_LOOP

:GET_USB_DRIVE
    REM Use WMIC to identify removable USB storage devices
    REM This is more reliable than polling drive letters manually
    for /f "tokens=1,2" %%A in ('wmic logicaldisk where drivetype^=2 get name^,size /value 2^>nul ^| findstr "^Name="') do (
        set "DRIVE_NAME=%%B"
        if "!DRIVE_NAME!" neq "" (
            echo !DRIVE_NAME!
            exit /b 0
        )
    )
    exit /b 1

:HANDLE_USB_INSERTION
    setlocal enabledelayedexpansion
    set "USB_DRIVE=%~1"
    
    REM Verify the drive still exists before starting copy
    if not exist "!USB_DRIVE!\nul" (
        echo [WARNING] USB !USB_DRIVE! was detected but is no longer accessible.
        exit /b 1
    )
    
    echo USB detected: !USB_DRIVE!
    echo.
    echo Starting copy operation...
    echo Source: !USB_DRIVE!\
    echo Destination: !DEST_BASE!
    echo.
    
    set "COPY_IN_PROGRESS=1"
    set "START_TIME=!time!"
    
    REM Record this USB in the database (simple tracking)
    echo !USB_DRIVE! !START_TIME! >> "!USB_DB!"
    
    REM Run Robocopy with optimized settings for performance and resume
    REM /E          = Copy subdirectories including empty ones
    REM /R:3        = Retry 3 times (reasonable, not excessive)
    REM /W:2        = Wait 2 seconds between retries
    REM /NP         = No progress (reduces console overhead)
    REM /NFL        = No file list (reduces console overhead)
    REM /NDL        = No directory list (reduces console overhead)
    REM /NJH        = No job header (cleaner output)
    REM /NJS        = No job summary (we'll do our own minimal summary)
    REM /COPY:DATS = Copy data, attributes, timestamps, security
    REM /DCOPY:T   = Copy directory timestamps
    REM /A+:TH     = Include hidden/system attributes in copy
    REM /H         = Include hidden and system files
    REM /S         = Copy subdirectories (non-empty)
    REM /E         = Include empty subdirectories
    REM /XO        = Exclude older files (resume behavior - only copy if source is newer or missing)
    REM /IS        = Include same files (overwrite if needed for integrity)
    REM /IT        = Include tweaked files
    REM /Z         = Restartable mode (if copy is interrupted, can resume)
    
    REM Check drive exists before robocopy
    if not exist "!USB_DRIVE!\nul" (
        echo [ERROR] USB drive !USB_DRIVE! is not accessible.
        set "COPY_IN_PROGRESS=0"
        exit /b 1
    )
    
    robocopy "!USB_DRIVE!" "!DEST_BASE!" /E /R:3 /W:2 /NP /NFL /NDL /NJH /NJS /COPY:DATS /DCOPY:T /H /Z /IS /IT 2>&1
    
    set "ROBOCOPY_EXIT=!ERRORLEVEL!"
    
    REM Robocopy exit codes:
    REM 0 = No files copied
    REM 1 = Files copied successfully
    REM 2 = Some files/dirs were skipped (not errors)
    REM 4 = Some files were mismatched and skipped (often acceptable)
    REM 8 = Some files could not be copied (access denied, locked, etc.)
    REM 16 = Serious error in Robocopy itself
    
    if !ROBOCOPY_EXIT! geq 16 (
        echo [ERROR] Robocopy encountered a serious error (code: !ROBOCOPY_EXIT!)
    ) else if !ROBOCOPY_EXIT! equ 0 (
        echo No new files to copy.
    ) else (
        echo Copy operation completed. (Exit code: !ROBOCOPY_EXIT!)
    )
    
    set "COPY_IN_PROGRESS=0"
    echo.
    echo Waiting for USB...
    echo.
    
    endlocal
    exit /b 0

:ERROR_HANDLER
    echo [ERROR] An unexpected error occurred.
    echo Returning to monitor loop...
    set "COPY_IN_PROGRESS=0"
    set "LAST_USB_LETTER="
    exit /b 1

endlocal
