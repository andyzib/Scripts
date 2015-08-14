' VBScript that searches an OU (and it's sub OUs) for inactive computer accounts. 
' If it finds inactive computer accounts, a comment is added.
' If you read the code, there is a line that can be uncommented to disable
' the computer account. 
' Uses DSQuery.exe, which is part of Windows XP or Windows Server 2003

' Written by Andrew Zbikowski <andyzib@gmail.com>

Option Explicit

' Objects
Dim objShell, objScriptExec, objComputer

Set objShell = CreateObject("WScript.Shell") ' Create Shell Object.

Dim intCount

Dim strOutput, strCommand, strOU, strQuery, strLDAP, strDesc, strHostname ' Strings

Dim arrNames, arrNamesExceptions ' Arrays

' The command to run.
strCommand = "c:\windows\system32\dsquery.exe computer -stalepwd 90 -limit 0 "
' OU to check (Sub OUs will be checked as well.)
strOU = """ou=Computers,ou=Corporate,dc=example,dc=local"""
strQuery = strCommand & strOU ' Full Query String.

set objScriptExec = objShell.Exec(strQuery) ' Execute the Query

' Read output of the dsquery command into strOutput. 
strOutput = objScriptExec.StdOut.ReadAll ' Read in command output. 

arrNames = split(strOutput, VBCr) ' Split Output into an array

strOutput = "" ' strOutput will now be used for displaying output to the user. 

arrNamesExceptions = array() ' Linux/MacOS computers don't always update their AD accounts.

' strLDAP is the full LDAP name of the computer. without LDAP://
intCount = 0
For Each strLDAP in arrNames
	strLDAP = Replace(strLDAP, VBCr, "")
	strLDAP = Replace(strLDAP, VBlf, "")
	On Error Resume Next ' Needed incase a computer doesn't have a description. 
	if Len(strLDAP) > 25 then ' DC=corp,DC=tcc,DC=inet is 22 characters, plus quote marks and other misc...
		strHostname = GetHostName(strLDAP)
		strLDAP = Replace(strLDAP, Chr(34), "") ' Remove quotation marks from strLDAP. 
		Set objComputer = GetObject("LDAP://" & strLDAP) ' Gets the computer object from AD.
		If Not objComputer.AccountDisabled Then ' Don't disable computer accounts if they are already disabled. 
			if CheckExceptions(strHostname) then
				strOutput = strOutput & strHostname & " is not active but is in exception list. No action taken." & VBCr ' Output
			else
				strDesc = objComputer.Get("description") ' Perserve existing description
				' Add reason for disabled object to description. 
				strDesc = strDesc & " 90 days of inactivity on " & Date()
				strDesc = Trim(strDesc)
				objComputer.Put "description", strDesc ' Set the description on the object
				'objComputer.AccountDisabled = True ' Disable the computer object
				objComputer.SetInfo ' Save the changes to AD
				'strOutput = strOutput &  "Disabled " & strHostname & VBCr ' Output
				strOutput = strOutput & "Updated Description on " & strHostname & VBCr ' Output
			end if
		Else
			strOutput = strOutput & strHostname & " Already Disabled." & VBCr
		End If
		Set objComputer = Nothing ' Destroy the VB Script Computer object. 
	End if
	strHostname = "" ' Clear current host name. 
	strDesc = "" ' Clear the description, or it will get ugly as this loops. 
	intCount = intCount + 1
	' This script can generate more output than MsgBox can display so 
	if intCount = 20 then
		MsgBox strOutput, 64, "Results"
		strOutput = ""
		intCount = 0
	end if
Next
MsgBox strOutput, 64, "Results"

' Takes in the LDAP string from dsquery.exe and returns just the hostname. 
function GetHostName(strDN)
	Dim objRegExp, RegExpMatch, strHost ' Some variables. 
	Set objRegExp = New RegExp ' Regular Expression Object
	With objRegExp
		'.Pattern = "CN=(.+?),.+"
		.Pattern = "^.+CN=(.+?),.+$"
		.IgnoreCase = True
		.Global = False
	End With
	Set RegExpMatch = objRegExp.Execute(strDN)
	' VBScript Regular Expressions could be better...
	' We should only get 1 match as Global property if false.
	if RegExpMatch.Count = 1 Then
		' Item(0) is the first and only match.
		strHost = RegExpMatch.Item(0).SubMatches(0)
	Else
		strOutput = strOutput &  "Problem with RexExp match." & VBCr
		strHost = FALSE
	End if
	Set RegExpMatch = Nothing
	Set objRegExp = Nothing
	'WScript.Echo "GetHostName Debug: " & strHost
	GetHostName = strHost
End function

' Returns true if strHostname is in the exception list. 
function CheckExceptions(strCompName)
	Dim strHost, MatchFound
	MatchFound = FALSE
	for each strHost in arrNamesExceptions		
		'if strcomp(LCase(strHost), LCase(strCompName)) then
		if LCase(strHost) = LCase(strCompName) then
			MatchFound = TRUE
		end if
	next
	CheckExceptions = MatchFound
End Function
