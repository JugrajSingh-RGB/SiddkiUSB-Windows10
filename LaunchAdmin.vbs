' LaunchAdmin.vbs - Elevate SiddkiUSB.bat to Administrator
' ============================================================================
' This VBScript automatically launches SiddkiUSB.bat with Administrator
' privileges using Windows' built-in UAC (User Account Control) prompt.
' 
' USAGE:
'   1. Save this file (LaunchAdmin.vbs) in the same folder as SiddkiUSB.bat
'   2. Double-click LaunchAdmin.vbs
'   3. Click "Yes" on the UAC prompt
'   4. SiddkiUSB.bat will launch in an elevated Command Prompt
'
' ADVANTAGES:
'   - Pure Windows 10 - no external programs needed
'   - VBScript is built-in to all Windows 10 installations
'   - Familiar UAC prompt (same as right-clicking)
'   - No PowerShell 7 or Windows Terminal required
'
' SECURITY NOTE:
'   This script only launches SiddkiUSB.bat - it does not execute the
'   batch file in the current process. The script terminates after
'   successfully launching the elevated command prompt.
' ============================================================================

Set objShell = CreateObject("Shell.Application")

' Launch cmd.exe with /c SiddkiUSB.bat in elevated mode
' Parameters:
'   - "cmd.exe" = run command prompt
'   - "/c SiddkiUSB.bat" = execute SiddkiUSB.bat and close when done
'   - "" = start directory (empty = current directory)
'   - "runas" = request administrator elevation via UAC
'   - 1 = normal window (not hidden)

objShell.ShellExecute "cmd.exe", "/c SiddkiUSB.bat", "", "runas", 1

' Optional: Display a success message (comment out if you prefer silent launch)
' MsgBox "SiddkiUSB launched with Administrator privileges.", vbInformation, "SiddkiUSB"
