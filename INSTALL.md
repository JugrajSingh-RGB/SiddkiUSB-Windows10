# SiddkiUSB - Installation & Setup Guide

## Pre-Installation Requirements

### System Requirements

✅ **Required:**
- Windows 10 (any edition: Home, Pro, Enterprise)
- Standard Command Prompt (`cmd.exe`) – built-in
- Administrator account access (for elevation)
- At least 100 MB free space in destination folder

✅ **Built-In (No Installation Needed):**
- Robocopy (`robocopy.exe`)
- WMIC (`wmic.exe`)
- Timeout utility (`timeout.exe`)
- VBScript engine (`cscript.exe`)

❌ **NOT Required:**
- PowerShell 7
- Windows Terminal
- Python
- Node.js
- .NET Framework
- Any third-party tools

### Optional: Administrator Account

While not strictly required, running as Administrator is **highly recommended** to:
- Access hidden and system files on the USB
- Preserve file security attributes
- Avoid "access denied" errors
- Ensure complete USB backup

---

## Installation Steps

### Step 1: Download SiddkiUSB Files

From the GitHub repository, download:

1. **`SiddkiUSB.bat`** – Main script (required)
2. **`LaunchAdmin.vbs`** – Optional elevation helper (recommended)
3. **`README.md`** – Full documentation (reference)
4. **`QUICKSTART.md`** – Quick reference (optional)
5. **`TECHNICAL.md`** – Technical details (optional)

**All files are text-based – safe to download and inspect before running.**

### Step 2: Save to a Convenient Location

Create a folder or use an existing one:

**Option A: Desktop (Easiest)**
```
C:\Users\YourUsername\Desktop\SiddkiUSB.bat
C:\Users\YourUsername\Desktop\LaunchAdmin.vbs
```

**Option B: Documents Folder**
```
C:\Users\YourUsername\Documents\SiddkiUSB\SiddkiUSB.bat
C:\Users\YourUsername\Documents\SiddkiUSB\LaunchAdmin.vbs
```

**Option C: Program Files (Advanced)**
```
C:\Program Files\SiddkiUSB\SiddkiUSB.bat
C:\Program Files\SiddkiUSB\LaunchAdmin.vbs
```

**Keep both `.bat` and `.vbs` files in the same folder.**

### Step 3: (Optional) Create a Shortcut

To make launching even easier:

1. Right-click on `LaunchAdmin.vbs`
2. Select "Send to" → "Desktop (create shortcut)"
3. A shortcut icon appears on your desktop
4. Now you can double-click the shortcut anytime to launch SiddkiUSB

---

## Verification Steps

### Verify Robocopy is Available

Open Command Prompt and test:

```batch
robocopy /?
```

**Expected output:** Robocopy help text (long list of flags)

**If command not found:** Your Windows installation may be incomplete. Contact Microsoft support.

### Verify WMIC is Available

Open Command Prompt and test:

```batch
wmic logicaldisk list
```

**Expected output:** List of all disk drives

**If command not found:** WMIC is disabled (very rare). You may need to enable it via:
- Windows Features → "Windows Management Instrumentation" → Enable
- Or contact your system administrator

### Verify Administrator Access

Open Command Prompt **as Administrator:**

1. Press `Win + R`
2. Type: `cmd`
3. Press `Ctrl + Shift + Enter` (or right-click → "Run as administrator")
4. Click "Yes" on the UAC prompt

**Expected:** Command Prompt window with "Administrator" in title bar

---

## Launch Methods

### Method 1: Right-Click Launch (Simplest)

1. Right-click `SiddkiUSB.bat`
2. Select "Run as administrator"
3. Click "Yes" on the UAC prompt
4. Script launches in Command Prompt

✅ **Pros:** No extra files needed, familiar interface  
❌ **Cons:** Requires right-click menu

### Method 2: VBScript Launcher (Most Convenient)

1. Download `LaunchAdmin.vbs` to the same folder as `SiddkiUSB.bat`
2. Double-click `LaunchAdmin.vbs`
3. Click "Yes" on the UAC prompt
4. Script launches automatically

✅ **Pros:** One-click launch, no navigation needed  
✅ **Cons:** None (built-in VBScript support)

**Creating a Desktop Shortcut to the Launcher:**
1. Right-click `LaunchAdmin.vbs`
2. Select "Send to" → "Desktop (create shortcut)"
3. Now double-click the shortcut from Desktop anytime

### Method 3: Command Prompt (Manual)

1. Open Command Prompt as Administrator
2. Navigate to the script folder:
   ```batch
   cd Desktop
   ```
   or
   ```batch
   cd "C:\Users\YourUsername\Documents\SiddkiUSB"
   ```
3. Run the script:
   ```batch
   SiddkiUSB.bat
   ```
4. Press Enter

✅ **Pros:** Full control, can see exact path  
❌ **Cons:** Most typing required

### Method 4: Scheduled Task (Advanced)

To run SiddkiUSB automatically at logon:

1. Press `Win + R`
2. Type: `taskschd.msc`
3. Click "Create Basic Task"
4. Name: "SiddkiUSB"
5. Trigger: "At logon"
6. Action: Start a program
   - Program: `C:\Windows\System32\cmd.exe`
   - Arguments: `/c "C:\Users\YourUsername\Desktop\SiddkiUSB.bat"`
7. Check "Run with highest privileges"
8. Finish

**Now the script runs automatically every time you log in.**

---

## First Run Checklist

### Before Launching

- [ ] Downloaded `SiddkiUSB.bat`
- [ ] Saved to a convenient location (Desktop, Documents, etc.)
- [ ] Optionally downloaded `LaunchAdmin.vbs` to same folder
- [ ] Verified robocopy is available: `robocopy /?`
- [ ] Verified WMIC is available: `wmic logicaldisk list`

### Launch & Verify

- [ ] Launched using your chosen method (right-click, VBScript, or CMD)
- [ ] UAC prompt appeared and you clicked "Yes"
- [ ] Command Prompt window opened with script running
- [ ] Script displays:
  ```
  ============================================================================
   SiddkiUSB - Hands-Free USB Auto-Copy System
  ============================================================================
  
  Destination: C:\Users\YourUsername\Documents\Siddki USB
  
  Status: Waiting for USB insertion...
  Press Ctrl+C to exit.
  
  ============================================================================
  ```
- [ ] Destination folder was created (check `Documents\Siddki USB\`)

### Test USB Copy

- [ ] Insert a USB drive with test files
- [ ] Script detects USB and displays:
  ```
  USB detected: E:\
  
  Starting copy operation...
  ```
- [ ] Wait for copy to complete
- [ ] Script displays:
  ```
  Copy operation completed. (Exit code: 1)
  
  Waiting for USB...
  ```
- [ ] Check destination folder – files are there
- [ ] Remove USB – script displays:
  ```
  USB removed — copy stopped.
  Partially copied files preserved for resume.
  
  Waiting for USB...
  ```

✅ **If all checks pass, installation is successful!**

---

## Configuration (Optional)

### Change Destination Folder

By default, files copy to:
```
C:\Users\YourUsername\Documents\Siddki USB\
```

To change this:

1. Right-click `SiddkiUSB.bat`
2. Select "Edit" (opens in Notepad)
3. Find this line (around line 20):
   ```batch
   set "DEST_BASE=%USERPROFILE%\Documents\Siddki USB"
   ```
4. Change to your desired path, e.g.:
   ```batch
   set "DEST_BASE=E:\MyUSBBackup"
   ```
   or
   ```batch
   set "DEST_BASE=D:\Archives\Siddki USB"
   ```
5. File → Save
6. Close Notepad

**Next time you run the script, it will use the new destination.**

### Change Monitoring Interval

By default, the script checks for USB insertion every 2 seconds.

To change this:

1. Open `SiddkiUSB.bat` in Notepad
2. Find (around line 23):
   ```batch
   set "MONITOR_INTERVAL=2"
   ```
3. Change the number:
   - `1` = Check every 1 second (faster detection, more CPU)
   - `2` = Check every 2 seconds (default, balanced)
   - `5` = Check every 5 seconds (slower detection, less CPU)
4. Save and close

### Change Robocopy Retry Behavior

By default, robocopy retries 3 times with 2-second wait between retries.

To change:

1. Open `SiddkiUSB.bat` in Notepad
2. Find the `robocopy` command line (around line 110)
3. Look for: `/R:3 /W:2`
4. Change to:
   - `/R:1 /W:1` = Fewer retries (faster on locked files)
   - `/R:5 /W:3` = More retries (better for unreliable USB)
5. Save and close

---

## Security Considerations

### Before Running

✅ **Safe to run:**
- Script only COPIES files (read-only)
- Script never EXECUTES anything
- Script uses Windows built-in tools only
- Script doesn't modify the USB
- Script doesn't access the network

❌ **NOT safe if you:**
- Don't trust the USB source (malware risk)
- Download the script from untrusted sources
- Don't verify the script content

### Best Practices

1. **Inspect the script before running:**
   - Right-click `SiddkiUSB.bat` → "Edit with Notepad"
   - Review the code (it's readable batch script)
   - Make sure it looks legitimate
   - Close without saving if unsure

2. **Run antivirus on the USB:**
   - Even though SiddkiUSB doesn't execute files
   - Run Windows Defender or other AV on copied files
   - Check for malware before opening files

3. **Use trusted source only:**
   - Download from this GitHub repository
   - Verify the file hasn't been modified
   - Never run scripts from untrusted sources

4. **Review copied files:**
   - Check the destination folder after copy
   - Make sure expected files are there
   - Delete anything suspicious before opening

---

## Troubleshooting Installation Issues

### Issue: "robocopy not found" error

**Cause:** Robocopy is missing or PATH is incorrect

**Solution:**
1. Open Command Prompt
2. Verify robocopy location:
   ```batch
   where robocopy
   ```
   Should show: `C:\Windows\System32\robocopy.exe`
3. If not found, your Windows installation is incomplete
4. Contact Microsoft support or reinstall Windows

### Issue: "wmic not found" error

**Cause:** WMIC is disabled or missing

**Solution:**
1. Open Command Prompt as Administrator
2. Try to enable WMIC:
   ```batch
   wbemtest
   ```
3. If that opens, WMIC is available
4. If not, you may need to enable it in Windows Features:
   - Press `Win + R`
   - Type: `optionalfeatures`
   - Find "Windows Management Instrumentation"
   - Make sure it's checked
   - Click OK and restart

### Issue: USB not detected

**Cause:** USB not recognized as removable drive

**Solution:**
1. Check Device Manager:
   - Press `Win + R`
   - Type: `devmgmt.msc`
   - Look for your USB under "Disk drives" or "Portable devices"
2. Try a different USB port (USB 3.0 port if available)
3. Try the USB on another computer to verify it works
4. If USB works on another computer, your USB port may be damaged

### Issue: "Access denied" errors during copy

**Cause:** Not running as Administrator

**Solution:**
1. Close the script (Ctrl+C, then Y)
2. Right-click `SiddkiUSB.bat` → "Run as administrator"
3. Click "Yes" on UAC prompt
4. Script now has permission to access all files

### Issue: Destination folder not created

**Cause:** Permission denied for Documents folder

**Solution:**
1. Create the folder manually:
   - Open File Explorer
   - Navigate to Documents
   - Right-click → "New" → "Folder"
   - Name it "Siddki USB"
2. Run script again – it should detect the folder

### Issue: Script launches but freezes immediately

**Cause:** Possible WMIC query timeout or permission issue

**Solution:**
1. Press Ctrl+C to stop
2. Try manual USB detection:
   ```batch
   wmic logicaldisk where drivetype=2 get name
   ```
3. If this hangs, WMIC may be misconfigured
4. Restart computer and try again

---

## Uninstallation

### Complete Removal

1. **Stop the script:**
   - Press Ctrl+C in the Command Prompt window
   - Type `Y` and press Enter

2. **Delete the files:**
   - Delete `SiddkiUSB.bat`
   - Delete `LaunchAdmin.vbs`
   - Delete any documentation files you downloaded
   - Delete the Desktop shortcut (if created)

3. **Clean up:**
   - Delete temporary log files: `%TEMP%\SiddkiUSB_log.txt`
   - Delete USB database: `%TEMP%\SiddkiUSB_devices.txt`

**That's it. No registry entries, no system files modified, no cleanup needed.**

### Keeping the Destination Folder

The destination folder (`C:\Users\YourUsername\Documents\Siddki USB\`) is preserved. You can:
- Keep it as an archive of copied USB files
- Move it to another location
- Delete it if you no longer need the files
- It's completely separate from the script

---

## Post-Installation Setup (Optional)

### Create a Batch File to Open Destination Folder

To quickly access copied files, create a file called `OpenDestination.bat`:

```batch
@echo off
start "" "%USERPROFILE%\Documents\Siddki USB"
```

Save it in the same folder as `SiddkiUSB.bat`. Double-click anytime to open the destination folder in File Explorer.

### Add to Context Menu (Advanced)

To add "Copy with SiddkiUSB" to your desktop context menu:

1. Press `Win + R`
2. Type: `regedit`
3. Navigate to: `HKEY_CLASSES_ROOT\Directory\Background\shell`
4. Right-click "shell" → "New" → "Key"
5. Name it: `SiddkiUSB`
6. Right-click the new "SiddkiUSB" key → "New" → "String Value"
7. Name: `(Default)`
8. Value: `Copy with SiddkiUSB`
9. Right-click "SiddkiUSB" → "New" → "Key"
10. Name: `command`
11. Right-click "(Default)" under command → "Modify"
12. Value: `C:\Path\To\LaunchAdmin.vbs`

Now right-click on desktop → "Copy with SiddkiUSB" launches the script.

---

## Getting Help

### Common Questions

**Q: Is it safe to run?**  
A: Yes. It only copies files using Windows built-in tools. No execution, no modification of the USB.

**Q: Will it work with external hard drives?**  
A: Yes, if Windows recognizes them as removable drives. Test with: `wmic logicaldisk where drivetype=2 get name`

**Q: Can I run it on Windows 11?**  
A: Yes. SiddkiUSB uses only Windows 10 built-in tools, all available in Windows 11.

**Q: What if I want to use a different destination folder?**  
A: Edit the script and change `DEST_BASE` variable (see Configuration section above).

**Q: Can I run multiple instances?**  
A: Yes, but they'll detect the same USB and try to copy simultaneously. Not recommended.

### Getting More Help

- **Quick questions:** See `QUICKSTART.md`
- **Full documentation:** See `README.md`
- **Technical details:** See `TECHNICAL.md`
- **Script issues:** Try the Troubleshooting section above

---

## Next Steps

1. ✅ Download the files
2. ✅ Save to a convenient location
3. ✅ Verify robocopy and WMIC are available
4. ✅ Launch using your preferred method
5. ✅ Test with a USB drive
6. ✅ (Optional) Configure destination or other settings
7. ✅ Keep it running while copying USBs

---

**Installation Complete!**

Your SiddkiUSB system is now ready to use. Insert a USB drive and let it work – no keyboard or mouse required!
