# SiddkiUSB - Documentation Index

## Welcome to SiddkiUSB

**SiddkiUSB** is a hands-free USB auto-copy system for Windows 10 that requires only built-in tools – no PowerShell 7, Python, or external programs.

**Simply:**
1. Run `SiddkiUSB.bat`
2. Insert a USB
3. Watch files copy automatically
4. Remove USB whenever you want
5. Reinsert to resume copying

---

## 📚 Documentation Files

### For New Users

Start here if you're just getting started:

| Document | Purpose | Read Time |
|----------|---------|-----------|
| **[QUICKSTART.md](QUICKSTART.md)** | 30-second setup and quick reference | 5 min |
| **[INSTALL.md](INSTALL.md)** | Step-by-step installation guide | 10 min |

### For Detailed Information

Read these for comprehensive understanding:

| Document | Purpose | Read Time |
|----------|---------|-----------|
| **[README.md](README.md)** | Full documentation with all features explained | 30 min |
| **[TECHNICAL.md](TECHNICAL.md)** | Deep dive into robocopy, WMIC, USB detection, resume mechanism | 20 min |

### For Troubleshooting

Find solutions to common issues:

| Document | Location | Issues Covered |
|----------|----------|-----------------|
| **QUICKSTART.md** | Troubleshooting section | Quick fixes |
| **README.md** | Troubleshooting & FAQ sections | Common problems |
| **INSTALL.md** | Troubleshooting section | Installation issues |

---

## 🚀 Quick Links by Task

### "I want to get started NOW"
→ Read **[QUICKSTART.md](QUICKSTART.md)** (5 minutes)
→ Download `SiddkiUSB.bat`
→ Right-click → "Run as administrator"
→ Insert USB

### "I need step-by-step installation help"
→ Read **[INSTALL.md](INSTALL.md)** (10 minutes)
→ Follow each section carefully
→ Verify with the checklist

### "I want to understand how it works"
→ Read **[README.md](README.md)** (30 minutes)
→ Learn about USB detection, resume, file safety
→ See example workflows

### "I want the technical details"
→ Read **[TECHNICAL.md](TECHNICAL.md)** (20 minutes)
→ Learn robocopy flags and rationale
→ Understand WMIC USB detection
→ See performance analysis

### "Something isn't working"
→ Check **[INSTALL.md](INSTALL.md)** Troubleshooting section
→ Or **[README.md](README.md)** FAQ & Troubleshooting
→ Or **[QUICKSTART.md](QUICKSTART.md)** Troubleshooting

### "I want to customize the script"
→ See **[QUICKSTART.md](QUICKSTART.md)** Command Line Customization
→ Or **[INSTALL.md](INSTALL.md)** Configuration section
→ Or **[TECHNICAL.md](TECHNICAL.md)** for advanced settings

---

## 📋 Feature Checklist

### Core Features (All Included)

✅ **Hands-Free Operation**
- No keyboard/mouse needed after launch
- Automatic USB detection
- Automatic copying
- Automatic resume

✅ **Robust File Copying**
- Copy ALL file types (hidden, system, read-only)
- Preserve timestamps and attributes
- Handle files with unusual names
- Copy empty directories

✅ **Safe USB Removal**
- Detect removal instantly
- Stop copying gracefully
- Preserve partially copied files
- Resume automatically on reinsertion

✅ **Maximum Performance**
- Use robocopy (Windows' native copy engine)
- Minimal console overhead
- Near-optimal USB throughput
- Multi-threaded operation

✅ **Cumulative Destination**
- Single folder for all USB contents
- No `/MIR` (safe for multiple USBs)
- Files from multiple USBs coexist
- Smart resume on same USB

✅ **Zero Dependencies**
- Windows 10 built-in only
- No PowerShell 7, Python, .NET, etc.
- Can delete script anytime (no registry entries)
- No installation needed

---

## 📁 File Structure

```
SiddkiUSB/
├── SiddkiUSB.bat                    ← Main script (required)
├── LaunchAdmin.vbs                  ← Optional elevation helper
├── README.md                        ← Full documentation
├── QUICKSTART.md                    ← Quick reference
├── INSTALL.md                       ← Installation guide
├── TECHNICAL.md                     ← Technical details
└── INDEX.md                         ← This file
```

**Minimum required to run:** `SiddkiUSB.bat` only

**Recommended:** Also download `LaunchAdmin.vbs` for easy launching

**Documentation:** All `.md` files are optional reference materials

---

## 🔑 Key Concepts

### USB Detection
- Uses **WMIC** (Windows Management Instrumentation Command-line)
- Queries `logicaldisk where drivetype=2` (removable drives only)
- Works with any drive letter (E:, F:, G:, etc.)
- Checks every 2 seconds

**See:** [TECHNICAL.md](TECHNICAL.md#usb-detection-mechanism)

### Copy Engine
- Uses **Robocopy** (Windows built-in robust copy utility)
- Optimized flags for speed and reliability
- `/Z` flag enables resume capability
- Does NOT use `/MIR` (cumulative, not mirror)

**See:** [TECHNICAL.md](TECHNICAL.md#robocopy-configuration)

### Resume Mechanism
- Destination is cumulative (designed for multiple USBs)
- Robocopy skips already-copied files using timestamps
- Incomplete files are re-transmitted
- Automatic on reinsertion (same or different drive letter)

**See:** [README.md](README.md#resume-mechanism) or [TECHNICAL.md](TECHNICAL.md#resume-capability)

### File Safety
- Script only COPIES files (read-only)
- Never EXECUTES anything from USB
- Respects Windows file permissions
- No encryption bypass

**See:** [README.md](README.md#file-safety--access-control)

---

## 🎯 Common Scenarios

### Scenario 1: Basic USB Copying

**What you do:**
1. Launch script
2. Insert USB
3. Wait for copy to complete
4. Remove USB

**What SiddkiUSB does:**
- Detects USB automatically
- Copies all files to destination folder
- Displays completion message
- Returns to waiting

**See:** [QUICKSTART.md](QUICKSTART.md#what-happens-during-operation) or [README.md](README.md#quick-start)

### Scenario 2: USB Removal & Resume

**What you do:**
1. Plug in USB #1
2. Copy starts
3. Remove USB after 30 seconds (mid-copy)
4. Plug in same USB later

**What SiddkiUSB does:**
- Detects removal, stops copying
- Preserves partially copied files
- Resumes automatically when USB reinserted
- Completes copy from interruption point

**See:** [README.md](README.md#usb-removal-handling)

### Scenario 3: Multiple USBs

**What you do:**
1. Plug in USB #1, wait for completion
2. Remove USB #1
3. Plug in USB #2, wait for completion
4. Remove USB #2
5. Plug in USB #1 again

**What SiddkiUSB does:**
- All files from all USBs end up in same destination folder
- No duplicates (files skipped if already copied)
- Updated files overwritten (if source is newer)
- No timestamp folders or separation

**See:** [README.md](README.md#multiple-usb-copying-scenario)

### Scenario 4: Administrator Elevation

**What you do:**
1. Double-click `LaunchAdmin.vbs`
2. Click "Yes" on UAC prompt
3. Script launches

**What happens:**
- Windows shows familiar UAC dialog
- Script runs with administrator privileges
- Can access all files on USB
- Faster, more complete copying

**See:** [README.md](README.md#administrator-elevation-without-powershell-7-built-in-only) or [INSTALL.md](INSTALL.md#method-2-vbscript-launcher-most-convenient)

---

## ❓ FAQ Quick Answers

**Q: Is it safe?**
A: Yes. Built-in Windows tools only, no execution of USB files, read-only operation.

**Q: Does it require administrator?**
A: No, but recommended. Without it, some files may be skipped.

**Q: What about Windows 11?**
A: Yes, it works. Uses only Windows 10 built-in tools, all available in Windows 11.

**Q: Can I change the destination?**
A: Yes. Edit line 20 in `SiddkiUSB.bat` to change `DEST_BASE` path.

**Q: How do I uninstall?**
A: Delete the files. No registry entries or system changes.

**For more FAQs:** See [README.md](README.md#faq) or [QUICKSTART.md](QUICKSTART.md#common-questions)

---

## 🛠️ Configuration Guide

### Essential Settings

| Setting | File | Line | Default | How to Change |
|---------|------|------|---------|---------------|
| Destination folder | `SiddkiUSB.bat` | 20 | `%USERPROFILE%\Documents\Siddki USB` | Edit path |
| Monitoring interval | `SiddkiUSB.bat` | 23 | `2` seconds | Change to 1, 2, or 5 |
| Robocopy retries | `SiddkiUSB.bat` | ~110 | `/R:3 /W:2` | Change to `/R:1` or `/R:5` |

**See:** [QUICKSTART.md](QUICKSTART.md#command-line-customization) or [INSTALL.md](INSTALL.md#configuration-optional)

---

## 📊 Performance Reference

### Expected USB Speeds

| USB Type | Expected Speed | Robocopy Achievement |
|----------|-----------------|----------------------|
| USB 2.0 flash drive | 30–40 MB/s | 30–40 MB/s (near-optimal) |
| USB 3.0 flash drive | 100–200 MB/s | 100–200 MB/s (near-optimal) |
| USB 3.0 external HDD | 180+ MB/s | 180–220 MB/s (near-optimal) |

**See:** [README.md](README.md#performance-benchmarks-typical) or [TECHNICAL.md](TECHNICAL.md#usb-throughput-analysis)

---

## 🔍 Robocopy Flags Explained

### Most Important Flags

| Flag | Purpose | Why? |
|------|---------|------|
| `/E` | Copy all subdirectories, including empty | Complete structure |
| `/H` | Include hidden and system files | Backs up everything |
| `/Z` | Restartable mode | Enables resume capability |
| `/XO` | Exclude older files | Skip already-copied files |
| `/NP /NFL /NDL` | No progress/file/dir list | Reduce console overhead |

**See:** [TECHNICAL.md](TECHNICAL.md#flag-reference)

---

## 🐛 Troubleshooting Quick Tree

```
Problem: USB not detected
├─ Check: wmic logicaldisk where drivetype=2 get name
├─ Try: Different USB port
└─ Try: Different USB device

Problem: Access denied
├─ Solution: Run as Administrator
└─ Retry: Launch with LaunchAdmin.vbs

Problem: Copy speed slow
├─ Check: USB type (2.0 vs 3.0)
├─ Try: Direct USB port (not hub)
└─ Try: Different USB

Problem: Resume not working
├─ Check: Destination folder exists
├─ Try: Plug USB back in
└─ Expected: Auto-resume on reinsertion

Problem: Script crashes/freezes
├─ Stop: Ctrl+C then Y
├─ Check: robocopy /? (is it available?)
├─ Check: wmic logicaldisk list (is it available?)
└─ Retry: Restart and run as Administrator
```

**Full troubleshooting:** See [INSTALL.md](INSTALL.md#troubleshooting-installation-issues)

---

## 📞 Getting Help

### By Issue Type

| Issue | Best Reference |
|-------|-----------------|
| Installation | [INSTALL.md](INSTALL.md) |
| First launch | [QUICKSTART.md](QUICKSTART.md) |
| How it works | [README.md](README.md) |
| Technical details | [TECHNICAL.md](TECHNICAL.md) |
| Troubleshooting | [INSTALL.md](INSTALL.md#troubleshooting-installation-issues) + [README.md](README.md#troubleshooting) |

### By Reading Time

| Time Available | Read |
|---|---|
| 5 minutes | [QUICKSTART.md](QUICKSTART.md) |
| 10 minutes | [INSTALL.md](INSTALL.md) |
| 30 minutes | [README.md](README.md) |
| 1 hour | All files |

---

## 🎓 Learning Path

### For Beginners

1. **[QUICKSTART.md](QUICKSTART.md)** - Get it running in 5 minutes
2. Insert USB and test
3. Ask questions from [README.md](README.md#faq) if needed

### For Intermediate Users

1. **[INSTALL.md](INSTALL.md)** - Detailed installation
2. **[QUICKSTART.md](QUICKSTART.md)** - Understand all features
3. Configure destination folder
4. Test with multiple USBs

### For Advanced Users

1. **[README.md](README.md)** - Complete feature documentation
2. **[TECHNICAL.md](TECHNICAL.md)** - Deep technical understanding
3. Customize robocopy settings
4. Set up scheduled tasks or shortcuts

---

## 📝 Version Information

| Aspect | Details |
|--------|---------|
| **Version** | 1.0 |
| **Release Date** | September 2026 |
| **Windows 10 Compatibility** | ✅ Home, Pro, Enterprise (1909+) |
| **Windows 11 Compatibility** | ✅ All versions |
| **Built-in Tools Only** | ✅ Yes |
| **No External Dependencies** | ✅ Yes |

---

## 🔗 Quick Navigation

**Start Here:**
- New to SiddkiUSB? → [QUICKSTART.md](QUICKSTART.md)

**Installing:**
- Step-by-step guide → [INSTALL.md](INSTALL.md)

**Learning:**
- Full documentation → [README.md](README.md)

**Technical:**
- How it works → [TECHNICAL.md](TECHNICAL.md)

**Main Script:**
- Download → [SiddkiUSB.bat](SiddkiUSB.bat)

**Launcher:**
- Optional helper → [LaunchAdmin.vbs](LaunchAdmin.vbs)

---

## ✅ Pre-Launch Checklist

Before running SiddkiUSB:

- [ ] Downloaded `SiddkiUSB.bat`
- [ ] Saved to a convenient location (Desktop, Documents, etc.)
- [ ] Read [QUICKSTART.md](QUICKSTART.md) or [INSTALL.md](INSTALL.md)
- [ ] Verified robocopy available: `robocopy /?`
- [ ] Verified WMIC available: `wmic logicaldisk list`
- [ ] Decided on launch method (right-click or VBScript)
- [ ] (Optional) Downloaded `LaunchAdmin.vbs` to same folder
- [ ] Ready to test with a USB drive

✅ **All set! You can now launch SiddkiUSB.**

---

## 🎯 Next Steps

1. **Download** the files from this repository
2. **Read** [QUICKSTART.md](QUICKSTART.md) (5 minutes)
3. **Launch** using your preferred method
4. **Insert** a USB drive
5. **Watch** it copy automatically
6. **Enjoy** hands-free USB copying!

---

**Thank you for choosing SiddkiUSB!**

For questions, feedback, or issues, refer to the documentation above.

**Last Updated:** September 2026
