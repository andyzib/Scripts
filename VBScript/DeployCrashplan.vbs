Option Explicit

Const TEST = FALSE ' Set to true for testing. No installation will be preformed. 
Const SHAREPATH = "\\example\GPSoftware$\Crashplan\"
Const INSTALLER32BIT = "CrashPlanPROe-x32_Win.exe"
Const INSTALLER64BIT = "CrashPlanPROe-x64_Win.exe"
Const ForWriting = 2

Dim objWMIService
Dim colProcessList, objProcess, colProperties
Dim colComputer, objComputer
Dim strComputer
Dim objFSO, objShell, objScriptLog
Dim boolCPInstalled, strCPExe
Dim boolLoggedOn
Dim strUsername, strUserDomain, strUsernameKeep
Dim strPublic, strUserHome
Dim strLog
Dim strCPArgs, strCPInstall
Dim Bits
Dim strScriptLog

Set objShell = WScript.CreateObject("WScript.Shell") 
Set objFSO = CreateObject("Scripting.FileSystemObject")

' ========== Check for Existing CrashPlan Install CrashPlanService.exe ==========
' Assume not installed until proven otherwise. 
boolCPInstalled = False

' ========== Turn on logging here. ==========
strScriptLog = objShell.ExpandEnvironmentStrings("%SystemDrive%") & "\Crashplan_InstallScript.log"
Set objScriptLog = objFSO.OpenTextFile(strScriptLog,ForWriting,True)
objScriptLog.WriteLine "Script started at " & Now()
' ========== Logging is now on. =============

' Check Program Files on 32 & 64 bit Windows
strCPExe = objShell.ExpandEnvironmentStrings("%ProgramFiles%") & "\CrashPlan\CrashPlanService.exe"
If objFSO.FileExists(strCPExe) Then
    boolCPInstalled = True
    objScriptLog.WriteLine "Found CrashPlan Install at " & strCPExe
End If

' Check Program Files (x86) on 64 bit Windows
strCPExe = objShell.ExpandEnvironmentStrings("%ProgramFiles(x86)%") & "\CrashPlan\CrashPlanService.exe"
If objFSO.FileExists(strCPExe) Then
    boolCPInstalled = True
	objScriptLog.WriteLine "Found CrashPlan Install at " & strCPExe
End If

' Quit if installed
If boolCPInstalled Then
	objScriptLog.WriteLine "CrashPlan is already installed."
	objScriptLog.WriteLine "Install script completed at " & Now()
	objScriptLog.Close
	WScript.Quit(0)
End If
' ========== End Check for Existing CrashPlan Install CrashPlanService.exe ========

' This is used for finding logged in user and process list. 
strComputer = "."
'Setup WMI object. 
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")

' ========== Find Currently Logged On User =========
'Get currently logged on user's username
Set colComputer = objWMIService.ExecQuery _
    ("Select * from Win32_ComputerSystem")

boolLoggedOn = False
For Each objComputer in colComputer
    If Not IsNull(objComputer.UserName) Then
        boolLoggedOn = True
    End If
Next

'If no one is logged on stop this madness. 
If Not boolLoggedOn Then
	objScriptLog.WriteLine "Nobody is logged in."
	objScriptLog.WriteLine "Install script completed at " & Now()
	objScriptLog.Close
	WScript.Quit
End If

Set colProcessList = objWMIService.ExecQuery _
 ("SELECT * FROM Win32_Process WHERE Name = 'explorer.exe'")
For Each objProcess in colProcessList
	colProperties = objProcess.GetOwner(strUsername,strUserDomain)
	If Not strUsername = "" Then
    	strUsernameKeep = LCase(strUsername)
    	objScriptLog.WriteLine "Process " & objProcess.Name & " is owned by " _
        	 & strUserDomain & "\" & strUsername & "."
	End If
Next

' Bail if it's an admin account logged in. 
If InStr(strUsernameKeep,"admin") > 0 Then
	objScriptLog.WriteLine strUsernameKeep & " is an admin account. Install canceled."
	objScriptLog.Close
	WScript.Quit
End If

' Bail if it's a mailbox account logged in. 
If InStr(strUsernameKeep,"mailbox") > 0 Then
	objScriptLog.WriteLine strUsernameKeep & " is an mailbox account. Install canceled."
	objScriptLog.Close
	WScript.Quit
End If

' Bail if it's a conference room account logged in. 
If InStr(strUsernameKeep,"conf rm") > 0 Then
	objScriptLog.WriteLine strUsernameKeep & " is an Conference Room account. Install canceled."
	objScriptLog.Close
	WScript.Quit
End If

' ========== End Find Currently Logged On User =========

' ========== Find User Home Directory =========
strPublic = objShell.ExpandEnvironmentStrings("%PUBLIC%")
strUserHome = Replace(LCase(strPublic),"public",LCase(strUsername)) 
strUserHome = Replace(strUserHome,LCase(objShell.ExpandEnvironmentStrings("%SystemDrive%")),objShell.ExpandEnvironmentStrings("%SystemDrive%"),1,1)
' ========== End Find User Home Directory =========

strLog = objShell.ExpandEnvironmentStrings("%SystemDrive%") & "\Crashplan_Install.log"

' 32 or 64 Bit OS? 
Bits = GetObject("winmgmts:root\cimv2:Win32_Processor='cpu0'").AddressWidth

strCPArgs = " /qn /l* "&strLog&" CP_ARGS=CP_USER_NAME="&strUsername&"&CP_USER_HOME="&strUserHome&" CP_SILENT=True"

If Bits = "64" Then
	strCPInstall = SHAREPATH & INSTALLER64BIT & strCPArgs
Else 
	' 32 bit
	strCPInstall = SHAREPATH & INSTALLER32BIT & strCPArgs
End If

' ========= Debug Output ==========
objScriptLog.WriteLine "DOMAIN: " & strUserDomain
objScriptLog.WriteLine "USERNAME: " & strUsernameKeep
objScriptLog.WriteLine "HOME DIR: " & strUserHome
objScriptLog.WriteLine "LOG FILE: " & strLog
objScriptLog.WriteLine "Operating System: Windows " & Bits & " Bit" 
objScriptLog.WriteLine "Install Command: " & strCPInstall
' ========= End Debug Output =========

' Time to Run! 
If Not TEST Then 
	objShell.Run strCPInstall,0,True ' Run installer, wait for it to finish. 
End If

StopCPApps()
objScriptLog.WriteLine "Install script completed at " & Now()
objScriptLog.Close
WScript.Quit


' Forcibly stop the CrashPlanTray.exe and CrashPlanDesktop.exe that startup as the 
' service account after installation.  
Function StopCPApps()
	Dim objWMIService, objProcess, colProcess
	Dim strComputer, strProcessKill
	strComputer = "."
	strProcessKill = "'CrashPlanTray.exe'"
	
	Set objWMIService = GetObject("winmgmts:" _
		& "{impersonationLevel=impersonate}!\\" _
		& strComputer & "\root\cimv2")
	
	Set colProcess = objWMIService.ExecQuery _
		("Select * from Win32_Process Where Name = " & strProcessKill )
	For Each objProcess in colProcess
		objProcess.Terminate()
	Next
	
	strProcessKill = "'CrashPlanDesktop.exe'"
	Set colProcess = objWMIService.ExecQuery _
		("Select * from Win32_Process Where Name = " & strProcessKill )
	For Each objProcess in colProcess
		objProcess.Terminate()
	Next	
End Function
