' Script will generate a tab delimted text file of Microft Updates needed on
' computers listed in \\redbrickhealth.local\Shares\Teams\Engineering\TechOps_Team\Scripts\WindowsUpdatesNeededReport\Servers.txt
' Requires Microsoft Baseline Security Analyzer 2 to be installed on computer running this script. 
' Created by Andrew Zbikowski <andrew@zibnet.us>
'On Error Resume Next
Const ForReading = 1

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Set objFile = objFSO.OpenTextFile("\\vcorp105w\Teams\IT_Secure\Scripts\WindowsUpdatesNeededReport\Servers.txt", ForReading)

strOutputFile = Year(Now) & "-" & Month(Now) & "-" & Day(Now) & "_UpdatesNeeded.txt"
Set objOutput = objFSO.CreateTextFile("\\vcorp105w\Teams\IT_Secure\Scripts\WindowsUpdatesNeededReport\" & strOutputFile, True)


Dim arrFileLines()
i = 0
Do Until objFile.AtEndOfStream
	Redim Preserve arrFileLines(i)
	arrFileLines(i) = objFile.ReadLine
	i = i + 1
Loop
objFile.Close

'Prepare a regular expression object
Set objRegEx = New RegExp
objRegEx.IgnoreCase = True
objRegEx.Global = True
objRegEx.Pattern = "Missing.*KB.*"

objOutput.WriteLine "Server" & vbtab & "Update Name" & vbtab & "Rating"
For Each strTarget in arrFileLines
	strTarget = Trim(strTarget)
	WScript.Echo "Checking " & strTarget & "..."
	strCommand =  "C:\Program Files\Microsoft Baseline Security Analyzer 2\mbsacli.exe /target " & strTarget & " /n os+iis+sql+password"
	Set objScriptExec = objShell.Exec(strCommand) ' Execute MSBAcli
	strOutput = objScriptExec.StdOut.ReadAll ' Read in command output.
	Set matches = objRegEx.Execute(strOutput)
	for each match in matches
		'Missing | Security Update for Microsoft Office 2003 (KB974554) | Important |
		strTemp = Trim(match.Value)
		strTemp = Replace(strTemp, " | ", vbtab)
		strTemp = Replace(strTemp, "Missing", " ")
		objOutput.WriteLine Trim(strTarget) & Trim(strTemp) ' Write the output to file.
	Next
Next
objOutput.Close
WScript.Quit(0)