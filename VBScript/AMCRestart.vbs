'==========================================================================
'
' NAME: AMCRestart.vbs
' AUTHOR: Andrew Zbikowski , RedBrick Health
' DATE  : 4/14/2013
' Version: 2013-04-14_v1
'
' COMMENT: Script to collect logs and restart CTI Adapter on CallCenter
' - Forcibly quit the AMC Salesforce CTI Adapter: StopCTIAdapter()
' - Copy log files to server directory USERNAME_COMPUTERNAME_YYYY-MM-DD_HH_MM_SS: CopyLogs()
' - Remove plaintext passwords from log files: SanitizeLogs()
' - Restart the AMC Salesfoce CTI Adapter: StartCTIAdapter()
'==========================================================================
Option Explicit
'==========================================================================
' Configuration
' SHAREUNC: Path to network share for logs to be copied to. 
Const SHAREUNC="\\example\Teams\Kipple\AMCLogs"
' CTIEXE: Full path to executable. 
Const CTIEXEPATH="c:\Program Files (x86)\AMC Technology\Application Adapters\Salesforce.com Adapter\"
Const CTIEXENAME="SalesforceCTI.exe" 
Const GETFEEDBACK=True ' Set to false if you don't want the script to prompt agent to enter a problem description. 
Const TRIGGERSERVER=True ' Enable/Disable writing a file that will trigger log collection on the MCIS server. 
' End Configuration - No edits required below.
'==========================================================================

'==========================================================================
' Global Objects and Variables
Dim objShell, objFSO, strOutput

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
' End Global Objects and Variables
'==========================================================================

'==========================================================================
' Main Body.
StopCTIAdapter()
SanitizeLogs()
CopyLogs()
StartCTIAdapter()
ShowOutput()
WScript.Quit
' End Main Body.
'==========================================================================

' Forcibly stop the process. 
Function StopCTIAdapter()
	Dim objWMIService, objProcess, colProcess
	Dim strComputer, strProcessKill
	strComputer = "."
	strProcessKill = "'" & CTIEXENAME & "'"
	
	Set objWMIService = GetObject("winmgmts:" _
		& "{impersonationLevel=impersonate}!\\" _
		& strComputer & "\root\cimv2")
	
	Set colProcess = objWMIService.ExecQuery _
		("Select * from Win32_Process Where Name = " & strProcessKill )
	For Each objProcess in colProcess
		objProcess.Terminate()
	Next
End Function

Function StartCTIAdapter()
	objShell.Run Chr(34) & CTIEXEPATH & CTIEXENAME & Chr(34), 1, False
	strOutput = strOutput & "AMC Salesforce.com CIT Adapter Restarted!" & VBCr
End Function

Function SanitizeLogs()
	Dim objRE, objFile, objFileSanitized, strLogDir, arrLogfiles, strLogfile, strLine, objMatches, objMatch, strSubmatch
	strLogDir = CTIEXEPATH & "logs\"
	arrLogfiles = Array("browser_connector.log", "cti_connector.log", "SalesForceAdapter.log")
	Set objRE = New RegExp
	objRE.Pattern = "^.*Password.*=.*'(.+)'.*$"
	objRE.Global = True ' Replace every occurance, not just the first.
	objRE.IgnoreCase = True ' Not case sensitive
	For Each strLogfile in arrLogfiles
		If objFSO.FileExists(strLogDir & strLogfile) Then
			' Open file and read line by line, looking for password strings. 
			Set objFile = objFSO.OpenTextFile(strLogDir & strLogfile)
			Set objFileSanitized = objFSO.CreateTextFile(strLogDir & Replace(strLogfile, ".log", "_sanitized.log"), True)
			Do While not objFile.AtEndOfStream 
    			strLine =  objFile.ReadLine()
    			Set objMatches = objRE.Execute(strLine)
    			If objMatches.Count > 0 Then
    				For Each objMatch In objMatches
    					For Each strSubmatch In objMatch.SubMatches
    						strLine = Replace(strLine, strSubmatch, "********")
    					Next
    				Next
    			End If
    			objFileSanitized.WriteLine strLine
			Loop
			objFile.Close
			objFileSanitized.Close
		'Else
		'	WScript.Echo strLogDir & strLogfile & " not found!"
		End If
	Next
	strOutput = strOutput & "Logfiles sanitized!" & VBCr
End Function

Function CopyLogs()
	Dim strCopyDestination, strLogDir, arrLogfiles, strLogfile, strUsername, strTimestamp, strComputerName
	
	strLogDir = CTIEXEPATH & "logs\"
	arrLogfiles = Array("browser_connector.log", "cti_connector.log", "SalesForceAdapter.log")
	strUsername = objShell.ExpandEnvironmentStrings("%USERNAME%")
	strTimestamp = GetTimestamp()
	strComputerName = objShell.ExpandEnvironmentStrings("%COMPUTERNAME%")
	
	' Figure out if logs will be copied to network or local directory. 
	If objFSO.FolderExists(SHAREUNC) Then
		strCopyDestination = SHAREUNC & "\" & strTimestamp & "_" & strComputerName & "_" & strUsername & "\"
		If Not objFSO.FolderExists(strCopyDestination) Then
			objFSO.CreateFolder(strCopyDestination)
		End If
	Else
		strCopyDestination = objShell.ExpandEnvironmentStrings("%USERPROFILE%") & "\Documents\AMCLogs\" & strTimestamp & "_" & strComputerName & "_" & strUsername & "\"
		' Create local folder if it doesn't exist. 
		If Not objFSO.FolderExists(objShell.ExpandEnvironmentStrings("%USERPROFILE%") & "\Documents\AMCLogs") Then
			objFSO.CreateFolder objShell.ExpandEnvironmentStrings("%USERPROFILE%") & "\Documents\AMCLogs"
		End If
		If Not objFSO.FolderExists(strCopyDestination) Then
			objFSO.CreateFolder strCopyDestination
		End If
	End If
	' Now Copy Files!
	'WScript.Echo "Copying files to " & strCopyDestination
	For Each strLogfile In arrLogfiles
		strLogfile = Replace(strLogfile, ".log", "_sanitized.log")
		If objFSO.FileExists(strLogDir & strLogfile) Then
			objFSO.CopyFile strLogDir & strLogfile, strCopyDestination, True
			objFSO.DeleteFile strLogDir & strLogfile
		End If
		'WScript.Echo "Copied " & strLogDir & strLogfile & " to " & strCopyDestination
	Next
	If GETFEEDBACK = True Then
		GetReason(strCopyDestination) ' Log the reason.
	End If
	If TRIGGERSERVER = True Then
		If Not objFSO.FileExists(SHAREUNC & "\" & "ZZ_CollectServerLogs.txt") Then
			objFSO.CreateTextFile(SHAREUNC & "\" & "ZZ_CollectServerLogs.txt")
		End If
	End If
	strOutput = strOutput & "Logfiles copied to " & strCopyDestination & VBCr
End Function

' Returns a Timestamp in the following format:
' YYYY-MM-DD_HH.MM.SS'
Function GetTimestamp()
	Dim sYYYY, sMM, sDD, sHH, sNN, sSS, strNow, sReturn
	strNow = Now()
	sYYYY = DatePart("yyyy", strNow)
	sMM = Lpad(DatePart("m", strNow), 2, "0")
	sDD = Lpad(DatePart("d", strNow), 2, "0")
	sHH = Lpad(DatePart("h", strNow), 2, "0")
	sNN = Lpad(DatePart("n", strNow), 2, "0")
	sSS = Lpad(DatePart("s", strNow), 2, "0")
	GetTimestamp = sYYYY & "-" & sMM & "-" & sDD & "_" & sHH & "." & sNN & "." & sSS
End Function

Function Lpad(strInput, length, character)
	Dim strOutput
    If Len(strInput) >= length Then
		strOutput = strInput
	Else
		Do While Len(strOutput) <= length - Len(strInput)-1
			strOutput = character & strOutput 
		Loop
		strOutput = strOutput & strInput
	End if
	Lpad = strOutput
End Function

Function ShowOutput()
	MsgBox strOutput,0,"Restart AMC Adapter" 
End Function

Function GetReason(strOutputDir)
	Dim objFileReason, strTimestamp, strReason, strPrompt
	strReason = ""
	strPrompt = "Please enter description of the problem."
	Do While strReason = ""
		strReason = InputBox(strPrompt,strPrompt) 
	Loop
	Set objFileReason = objFSO.CreateTextFile(strOutputDir & "Description.txt")
	strTimestamp = Replace(GetTimestamp(),".",":")
	strTimestamp = Replace(strTimestamp,"_"," ")
	objFileReason.WriteLine("Time logs collected: " & strTimestamp)
	objFileReason.WriteLine("Agent ID: " & objShell.ExpandEnvironmentStrings("%USERNAME%"))
	objFileReason.WriteLine("Description of Problem: " & strReason)
End Function