' Checks to see if MBAM Agent is currently installed. 
' If not installed, installs it from the network.
Option Explicit
' UNC Path to MBAM Installer
Const INSTALLEXE = "\\SERVER\gpsoftware$\Microsoft\MBAM\2.0\"

' Relative path to MBAM Service. 
Const SERVICEEXE = "\Microsoft\MDOP MBAM\MBAMAgent.exe"

Dim objFSO, objShell
Dim boolMBAM
Dim strMBAM, strCommand, strInstallExec, strBits

set objFSO = WScript.CreateObject("Scripting.FileSystemObject")
set objShell = WScript.CreateObject("WScript.Shell")

' Check to see if MBAM is already installed.
strMBAM = objShell.ExpandEnvironmentStrings( "%ProgramFiles%" ) & SERVICEEXE

If objFSO.FileExists(strMBAM) Then
	WScript.Quit
Else 
	boolMBAM = FALSE
End If

' Determine if 32 or 64 bit Operating System and set correct installer. 
strBits = GetObject("winmgmts:root\cimv2:Win32_Processor='cpu0'").AddressWidth
If strBits = 32 Then
	strInstallExec = INSTALLEXE & "x86\MBAMClient.msi"
ElseIf strBits = 64 Then
	strInstallExec = INSTALLEXE & "x64\MBAMClient.msi"
Else 
	WScript.Quit(1)
End If

' If MBAM Service is not installed, run the installer! 
If Not boolMBAM Then
	' First update Group Policy so the computer has the MBAM configuration. 
	strCommand = objShell.ExpandEnvironmentStrings( "%WINDIR%" ) & "\System32\gpupdate.exe "
	strCommand = strCommand & "/target:Computer"
	objShell.Run strCommand, 7, TRUE
	' Now run MBAM installer. 
	strCommand = objShell.ExpandEnvironmentStrings( "%WINDIR%" ) & "\System32\msiexec.exe " 
	strCommand = strCommand & "/i " & strInstallExec & " /quiet /qn /norestart"
	objShell.Run strCommand, 7, TRUE
End If
WScript.Quit