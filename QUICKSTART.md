# SiddkiUSB - Quick Reference Guide

## 30-Second Setup

1. **Download** `SiddkiUSB.bat` to your Desktop
2. **Right-click** `SiddkiUSB.bat` → "Run as administrator"
3. **Click** "Yes" on UAC prompt
4. **Insert USB** → automatic copying starts
5. **Remove USB** → script pauses safely
6. **Insert USB again** → resume copying automatically

---

## File Locations

| Item | Location |
|------|----------|
| Main script | `SiddkiUSB.bat` (download from repo) |
| Optional launcher | `LaunchAdmin.vbs` (download from repo) |
| Destination folder | `%USERPROFILE%\Documents\Siddki USB\` |
| Temp logs | `%TEMP%\SiddkiUSB_log.txt` |
| USB database | `%TEMP%\SiddkiUSB_devices.txt` |

---

## Launch Methods

### Method 1: Right-Click (Recommended)
```
1. Right-click SiddkiUSB.bat
2. Select "Run as administrator"
3. Click "Yes" on UAC prompt
```

### Method 2: Double-Click Launcher (Easiest)
```
1. Double-click LaunchAdmin.vbs
2. Click "Yes" on UAC prompt
3. Script launches automatically
```

### Method 3: Command Prompt (Manual)
```
1. Open Command Prompt as Administrator
2. Type: SiddkiUSB.bat
3. Press Enter
```

---

## What Happens During Operation

```
============================================================================
 SiddkiUSB - Hands-Free USB Auto-Copy System
============================================================================

Destination: C:\Users\Username\Documents\Siddki USB

Status: Waiting for USB insertion...
Press Ctrl+C to exit.

============================================================================

[User inserts USB]

USB detected: E:\

Starting copy operation...
Source: E:\
Destination: C:\Users\Username\Documents\Siddki USB

Copy operation completed. (Exit code: 1)

Waiting for USB...

[User removes USB]

USB removed — copy stopped.
Partially copied files preserved for resume.

Waiting for USB...

[User reinserts same USB]

USB detected: E:\

Starting copy operation...
Source: E:\
Destination: C:\Users\Username\Documents\Siddki USB

Copy operation completed. (Exit code: 1)

Waiting for USB...
```

---

## Exit the Script

Press **Ctrl+C** in the Command Prompt window:

```
============================================================================

^C
Terminate batch job (Y/N)? Y
```

Type `Y` and press Enter to stop.

---

## Performance Expectations

| USB Type | Expected Speed |
|----------|-----------------|
| USB 2.0 flash drive | 30–40 MB/s |
| USB 3.0 flash drive | 100–120 MB/s |
| USB 3.0 external HDD | 180–220 MB/s |

**Actual speed depends on:**
- USB device hardware
- USB port type (2.0 vs 3.0)
- Destination drive speed (HDD vs SSD)
- File system (NTFS, FAT32, exFAT)

---

## Troubleshooting Quick Fixes

### ❌ "Access Denied" Error
**Solution:** Run as Administrator
- Right-click `SiddkiUSB.bat` → "Run as administrator"

### ❌ USB Not Detected
**Solution:** Try a different USB port or test USB on another computer

### ❌ Some Files Not Copied
**Solution:** Run as Administrator to access hidden/system files

### ❌ Copy Speed Very Slow
**Solution:** Check if using USB 2.0 (slower) vs USB 3.0 (faster)

### ❌ Resume Not Working
**Solution:** Just plug USB back in – robocopy will auto-resume copying

---

## Robocopy Exit Codes (Reference)

| Code | Meaning | Action |
|------|---------|--------|
| 0 | No files copied | Continues monitoring (normal) |
| 1 | Files copied successfully | Continues monitoring (normal) |
| 2 | Files/dirs skipped | Continues monitoring (normal) |
| 4 | Some files mismatched | Continues monitoring (normal) |
| 8 | Some files access denied | Continues monitoring (may re-try next time) |
| 16+ | Serious robocopy error | Script logs and continues monitoring |

**You do NOT need to fix these – script handles them automatically.**

---

## USB Detection & Monitoring

**How it detects USB:**
```batch
wmic logicaldisk where drivetype=2 get name
```

This finds all **removable** drives (USB, external HDDs, SD cards) but NOT internal hard drives.

**Check interval:** Every 2 seconds

**Why 2 seconds?**
- Fast enough to detect insertion/removal promptly
- Slow enough to not waste CPU power

---

## Destination Folder Structure

All files from all USBs end up in:
```
C:\Users\Username\Documents\Siddki USB\
```

**No separate folders per USB insertion.**

Example with multiple USBs:
```
Siddki USB\
├── DCIM\
│   ├── photo1.jpg (from USB #1)
│   └── photo2.jpg (from USB #1)
├── Videos\
│   └── movie.mp4 (from USB #2)
└── Documents\
    └── file.pdf (from USB #3)
```

---

## What Gets Copied

✅ **YES - These are copied:**
- Normal files
- Hidden files
- System files
- Read-only files
- Empty folders
- All nested directories
- File metadata (timestamps, attributes)

❌ **NO - These are NOT executed:**
- `.exe` files (copied as files, not run)
- `.bat` / `.cmd` batch scripts
- `.ps1` PowerShell scripts
- `.vbs` VBScript files
- `.js` JavaScript files
- Any other executables

**The script only COPIES – it never RUNS anything from the USB.**

---

## Administrator Elevation (Why Needed?)

Windows protects these files:
- Hidden files (`System Volume Information`, `$RECYCLE.BIN`, etc.)
- System files with restricted permissions
- Files with security attributes

**Without Administrator:**
- Some files skipped (access denied)
- Hidden folders not copied
- Metadata not preserved

**With Administrator:**
- All accessible files copied
- Complete backup of USB contents
- Full metadata preservation

---

## Resume Capability

### How Resume Works

1. USB inserted → copy starts → files transfer
2. USB removed → copy stops → files preserved
3. Same USB reinserted → copy resumes from where it left off

**Robocopy automatically:**
- Skips files already fully copied
- Resumes incomplete files
- Uses timestamps to avoid re-copying

**NO configuration needed – it's automatic.**

### Limitations

- Cannot distinguish between two different USBs with the same drive letter
- But this is OK because destination is cumulative (designed for multiple USBs)
- Files won't be duplicated even if same USB copied twice

---

## System Requirements

**Minimum:**
- Windows 10 (any edition: Home, Pro, Enterprise)
- Standard Command Prompt (`cmd.exe`)
- Administrator account access

**Built-in (NO downloads needed):**
- ✅ `cmd.exe` – always included
- ✅ `robocopy.exe` – included since Windows Vista
- ✅ `timeout.exe` – standard utility
- ✅ `wmic.exe` – Windows Management Instrumentation
- ✅ VBScript – built-in scripting engine

**NOT required:**
- ❌ PowerShell 7 (not in Windows 10)
- ❌ Windows Terminal (not in Windows 10)
- ❌ Python, Node.js, .NET
- ❌ Third-party tools or utilities
- ❌ Installation of anything

---

## Performance Tips

### For Maximum Speed

1. **Use USB 3.0 port** (faster than 2.0)
2. **Destination on SSD** (faster than HDD)
3. **Run as Administrator** (fewer permission delays)
4. **Avoid USB hubs** (use direct port connection)
5. **Close other programs** (reduce CPU contention)

### For Best Reliability

1. **Never force-eject USB** (let it finish copying)
2. **Don't move destination folder** during operation
3. **Keep USB plugged in** if possible until copy shows "completed"

---

## Command Line Customization

### Change Destination Folder

Edit `SiddkiUSB.bat` line 20:

**Current:**
```batch
set "DEST_BASE=%USERPROFILE%\Documents\Siddki USB"
```

**Change to (example):**
```batch
set "DEST_BASE=E:\MyUSBBackup"
```

### Change Monitoring Interval

Edit line 23:

**Current:**
```batch
set "MONITOR_INTERVAL=2"
```

**Options:**
```batch
set "MONITOR_INTERVAL=1"    REM Faster detection, more CPU
set "MONITOR_INTERVAL=5"    REM Slower detection, less CPU
```

### Change Robocopy Retries

Edit the `robocopy` command line:

**Current:**
```batch
/R:3 /W:2
```

**Options:**
```batch
/R:1 /W:1    REM Fewer retries (faster on locked files)
/R:5 /W:3    REM More retries (better for unreliable USB)
```

---

## Security Checklist

- ✅ Script only COPIES files (read-only operation)
- ✅ Script never EXECUTES anything from USB
- ✅ Uses Windows built-in tools only (trusted source)
- ✅ No administrator privilege abuse (only for file access)
- ✅ No encryption bypass (respects Windows security)
- ✅ No network communication (fully offline)
- ✅ Can safely delete `SiddkiUSB.bat` anytime (no registry entries)

---

## Common Questions

**Q: Will it overwrite existing files?**  
A: Yes, but only if the source file is newer or necessary for integrity. Already-identical files are skipped.

**Q: Can I use it with multiple USBs at once?**  
A: No, it handles one USB at a time. Insert one, let it finish, then insert the next.

**Q: What if the USB disconnects halfway?**  
A: Script detects it, stops safely, preserves copied files. Next insertion resumes automatically.

**Q: Can I move the destination folder?**  
A: Yes, but partially copied files won't be found, so copy restarts. Better to set destination correctly at start.

**Q: Does it work on Windows 11?**  
A: Yes. Uses only Windows 10 built-in tools, all available in Windows 11.

**Q: How do I see detailed logs?**  
A: Edit `SiddkiUSB.bat` and uncomment the logging lines (around line 140). Logs save to `%TEMP%\SiddkiUSB_log.txt`

---

## Uninstall

Simply delete:
- `SiddkiUSB.bat`
- `LaunchAdmin.vbs` (if downloaded)

**That's it.** No registry entries, no hidden files, no cleanup needed.

---

## Getting Help

1. **USB not detected?**
   - Test: Open CMD and run:
     ```batch
     wmic logicaldisk where drivetype=2 get name
     ```
   - Your USB letter should appear in the list

2. **Access denied errors?**
   - Always run as Administrator
   - Some files may be locked by Windows/antivirus

3. **Copy speed seems slow?**
   - Check USB type (2.0 vs 3.0)
   - Try different USB port
   - Close other programs

4. **Script crashes or behaves oddly?**
   - Restart by pressing Ctrl+C, then relaunch
   - Make sure running as Administrator
   - Check that robocopy is available: `robocopy /?`

---

## Version Info

- **Version:** 1.0
- **Date:** September 2026
- **Tested on:** Windows 10 Home, Pro, Enterprise (1909+)
- **Dependencies:** Windows 10 built-in tools only

---

**For full documentation, see `README.md`**
