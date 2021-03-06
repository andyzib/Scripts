'==========================================================================
'
' VBScript Source File -- Created with SAPIEN Technologies PrimalScript 2012
'
' NAME: AMCRestart.vbs
'
' AUTHOR: Andrew Zbikowski , RedBrick Health
' DATE  : 3/15/2013
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
Const SHAREUNC="\\example\Teams\Kipple\AMC_MCIS_Server_Logs"
' CTIEXE: Full path to executable. 
Const MCISLOGPATH="C:\Program Files (x86)\AMC Technology\MCIS\Server\Logs"
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
SanitizeLogs()
CopyLogs()
ShowOutput()
WScript.Quit
' End Main Body.
'==========================================================================

Function SanitizeLogs()
	Dim objFolder, objFile, objRE, objFileSanitized, arrLogfiles, strLine, objMatches, objMatch, strSubmatch, colLogFiles, objLogFile
	arrLogfiles = Array("browser_connector.log", "cti_connector.log", "SalesForceAdapter.log")
	Set objRE = New RegExp
	objRE.Pattern = "^.*Password.*=.*'(.+)'.*$"
	objRE.Global = True ' Replace every occurance, not just the first.
	objRE.IgnoreCase = True ' Not case sensitive
	Set objFolder = objFSO.GetFolder(MCISLOGPATH)
  	Set colLogFiles = objFolder.Files

	For Each objLogFile In colLogFiles
		If objFSO.FileExists(MCISLOGPATH & "\" & objLogFile.Name) Then
			' Open file and read line by line, looking for password strings. 
			Set objFile = objFSO.OpenTextFile(MCISLOGPATH & "\" & objLogFile.Name)
			Set objFileSanitized = objFSO.CreateTextFile(MCISLOGPATH & "\" & Replace(objLogFile.Name, ".log", "_sanitized.log"), True)
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
	Dim strCopyDestination, strLogDir, strLogfile, strUsername, strTimestamp, strComputerName, objFolder, colLogFiles, objLogFile
	
	strLogDir = MCISLOGPATH & "\"
	
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
		strCopyDestination = objShell.SpecialFolders("Desktop") & "\AMCLogs\" & strTimestamp & "_" & strComputerName & "_" & strUsername & "\"
		' Create local folder if it doesn't exist. 
		If Not objFSO.FolderExists(objShell.SpecialFolders("Desktop") & "\AMCLogs\") Then
			objFSO.CreateFolder objShell.SpecialFolders("Desktop") & "\AMCLogs\"
		End If
		If Not objFSO.FolderExists(strCopyDestination) Then
			objFSO.CreateFolder strCopyDestination
		End If
	End If
	
	Set objFolder = objFSO.GetFolder(MCISLOGPATH)
  	Set colLogFiles = objFolder.Files
	' Now Copy Files!
	'WScript.Echo "Copying files to " & strCopyDestination
	For Each objLogFile In colLogFiles
		strLogfile = Replace(objLogFile.Name, ".log", "_sanitized.log")
		If objFSO.FileExists(strLogDir & strLogfile) Then
			objFSO.CopyFile strLogDir & strLogfile, strCopyDestination, True
			objFSO.DeleteFile strLogDir & strLogfile
		End If
		'WScript.Echo "Copied " & strLogDir & strLogfile & " to " & strCopyDestination
	Next
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
	WScript.Echo strOutput
End Function
