' Checks to see if Mozilla Firefox Maintenance Service is currently installed. 
' If not installed, installs it from the network. Also installs or upgrades
' Mozilla Firefox. 
Option Explicit
' UNC Path to Chrome Installer
Const INSTALLEXE = "\\example\gpsoftware$\Mozilla\Firefox\FirefoxSetup.exe"
Const INSTALLINI = "\\example\gpsoftware$\Mozilla\Firefox\FirefoxSetup.ini"

' Relative path to Firefox Maintenance Service. 
Const SERVICEEXE = "\Mozilla Maintenance Service\maintenanceservice.exe"

Dim objFSO, objShell
Dim boolFF32, boolFF64
Dim strFF32, strFF64, strInstallExec
Dim strShortcut

set objFSO = WScript.CreateObject("Scripting.FileSystemObject")
set objShell = WScript.CreateObject("WScript.Shell")

' Full path to Chrome.exe
strFF32 = objShell.ExpandEnvironmentStrings( "%ProgramFiles%" ) & SERVICEEXE
strFF64 = objShell.ExpandEnvironmentStrings( "%ProgramFiles(x86)%" ) & SERVICEEXE

boolFF32 = FALSE
boolFF64 = FALSE

If objFSO.FileExists(strFF32) Then
	boolFF32 = TRUE
End If

If objFSO.FileExists(strFF64) Then
	boolFF64 = TRUE
End If

' If Firefox Service is not installed, run the installer! 
If Not boolFF32 AND not boolFF64 Then
	strInstallExec = INSTALLEXE & " -ms /INI:" & INSTALLINI
	objShell.Run strInstallExec, 7, TRUE
End If

strShortcut = objShell.ExpandEnvironmentStrings( "%Public%" ) & "\Desktop\Mozilla Firefox.lnk"
If objFSO.FileExists(strShortcut) Then
	objFSO.DeleteFile strShortcut
End If