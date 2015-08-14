' Script to check for Connected Backup and Remove It!!! 

Option Explicit
Dim objFSO, objShell
Dim strCPExe, boolCPInstalled
Dim strCBExe, boolCBInstalled
Dim strCBUninstall

Set objShell = WScript.CreateObject("WScript.Shell") 
Set objFSO = CreateObject("Scripting.FileSystemObject")

' ========== Check for Connected Backup Installation. 
' Assume not installed until proven otherwise. 
boolCBInstalled = False

If funIsServiceInstalled("AgentService") Then
    boolCBInstalled = True
End If

' ========== End Connected Backup Installation Check. 

' ========== Make sure CrashPlan is installed. 
' Assume not installed until proven otherwise. 
boolCPInstalled = False

' Check Program Files on 32 & 64 bit Windows
strCPExe = objShell.ExpandEnvironmentStrings("%ProgramFiles%") & _
	"\CrashPlan\CrashPlanService.exe"
If objFSO.FileExists(strCPExe) Then
    boolCPInstalled = True
End If

' Check Program Files (x86) on 64 bit Windows
strCPExe = objShell.ExpandEnvironmentStrings("%ProgramFiles(x86)%") & _
	"\CrashPlan\CrashPlanService.exe"
If objFSO.FileExists(strCPExe) Then
    boolCPInstalled = True
End If

' Quit if installed
If Not boolCPInstalled Then
	' Run CrashPlan installer, wait for it to finish before going forward. 
	objShell.Run objShell.ExpandEnvironmentStrings("%windir%") & _
		"\System32\cscript.exe \\SERVER\GPSoftware$\CrashPlan\DeployCrashplan.vbs",0,True
End If
' ========== End of CrashPlan Installation Check

' Quit if Connected Backup is not installed
If boolCBInstalled = False Then
	'WScript.Echo "Connected Backup Not Found!"
	WScript.Quit(0)
End If

' ========== Remove Connected Backup.
strCBUninstall = objShell.ExpandEnvironmentStrings("%windir%") & _
	"\System32\msiexec.exe /x {393E4C89-67E9-43BF-AD29-94D19F7624F7} /qn"
'WScript.Echo "Running " & strCBUninstall
objShell.Run strCBUninstall,0,True ' Run installer, wait for it to finish.
' ========== End Remove Connected Backup. 
Wscript.Quit

' Check for an installed service. 
' Credit: http://www.codeproject.com/Tips/44995/VBScript-check-to-see-if-a-service-is-installed
Function funIsServiceInstalled(svcName)
	Dim strComputer, objWMIService, isServiceInstalled, svcQry, objOutParams, objSvc
    strComputer = "."
    Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\CIMV2") 
    
    ' Obtain an instance of the the class 
    ' using a key property value.
    
    funIsServiceInstalled = FALSE
    
    svcQry = "SELECT * from Win32_Service"
    Set objOutParams = objWMIService.ExecQuery(svcQry)

    For Each objSvc in objOutParams
        Select Case objSvc.Name
            Case svcName
                funIsServiceInstalled = TRUE
        End Select
    Next
End Function
