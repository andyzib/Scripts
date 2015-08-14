' This script is intended to run under a service account on Windows workstations. 
' The service account should have the ability to update the computer's description
' field in active directory, delegate the permissions in ADUC accordingly. 
'
' This script will: 
' 1. Find the currently logged on user. It will quit if nobody is logged in. 
' 2. Find the user's Display Name in Active Directory. 
' 3. Find the computer's manufacturer, model, and serial number using WMI. 
' 4. Write this info to the computer object's AD description field.  
' 
' Error Codes
' 1: Default VBScript Error
' 10: Admin Account logged in. 
' 11: Mailbox Account logged in. 
' 12: Conference Room Account logged in. 
' -2147024891: Access denied when writing info to Active Directory. 
' 
' Created by: Andrew Zbikowski <azbikowski@redbrickhealth.com>
' Version: 2013-08-22_01
Option Explicit


' ========== Script Setup =========
Dim objWMIService
Dim strComputer
Dim resultGetCurrentUser, resultGetDisplayName, restulGetComputerInfo

strComputer = "."
'Setup WMI object. 
Set objWMIService = GetObject("winmgmts:" _
    & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
' ========== End Script Setup =========


' ========== Main Body =========
resultGetCurrentUser = GetCurrentUser()
resultGetDisplayName = GetDisplayName(GetDN(GetCurrentUser()))
restulGetComputerInfo = GetComputerInfo()

UpdateADDescription resultGetCurrentUser, resultGetDisplayName, restulGetComputerInfo
WScript.Quit 0
' ========== End Main Body =========


Function UpdateADDescription(strUser, strDisplayName, strInfo)
	On Error Resume Next ' There is error handling here. 
	Dim objADSystemInfo, objLDAPComp
	Dim strDescription

	Set objADSystemInfo = CreateObject("ADSystemInfo")
	Set objLDAPComp = GetObject("LDAP://" & objADSystemInfo.ComputerName)
	
	strDescription = strUser & ", " & strDisplayName & ", " & strInfo & ", " & Now()
	
	objLDAPComp.Description = strDescription
	objLDAPComp.SetInfo
	
	If Err.Number <> 0 Then
  		WScript.Quit Err.Number
  		Err.Clear
	End If
End Function

Function GetCurrentUser()
	' ========== Find Currently Logged On User =========
	Dim boolLoggedOn
	Dim objComputer, objProcess
	Dim colProcessList, colProperties,colComputer
	Dim strUsername,strUsernameKeep
	
	Set colComputer = objWMIService.ExecQuery ("Select * from Win32_ComputerSystem")
	'Get currently logged on user's username

	boolLoggedOn = False
	For Each objComputer in colComputer
		If Not IsNull(objComputer.UserName) Then
			boolLoggedOn = True
		End If
	Next
	
	'If no one is logged on stop this madness. 
	If Not boolLoggedOn Then
		WScript.Quit
	End If
	
	Set colProcessList = objWMIService.ExecQuery _
	 ("SELECT * FROM Win32_Process WHERE Name = 'explorer.exe'")
	For Each objProcess in colProcessList
		colProperties = objProcess.GetOwner(strUsername)
		If Not strUsername = "" Then
			strUsernameKeep = LCase(strUsername)
		End If
	Next
	
	' Bail if it's an admin account logged in. 
	If InStr(strUsernameKeep,"admin") > 0 Then
		WScript.Quit 10
	End If
	
	' Bail if it's a mailbox account logged in. 
	If InStr(strUsernameKeep,"mailbox") > 0 Then
		WScript.Quit 11
	End If
	
	' Bail if it's a conference room account logged in. 
	If InStr(strUsernameKeep,"conf rm") > 0 Then
		WScript.Quit 12
	End If
	
	GetCurrentUser = strUsernameKeep
	' ========== End Find Currently Logged On User =========
End Function

' Get the DN for a Username. 
Function GetDN(strUser)
	Const ADS_NAME_INITTYPE_GC = 3
	Const ADS_NAME_TYPE_1779   = 1
	Const ADS_NAME_TYPE_NT4    = 3

	Dim objNameTranslate, objSysInfo, Result, strDomain
	
	Set objSysInfo = CreateObject( "WinNTSystemInfo" )
	strDomain = objSysInfo.DomainName

	Set objNameTranslate = CreateObject("NameTranslate")
	objNameTranslate.Init ADS_NAME_INITTYPE_GC, ""

	' If a domain name is not specified, use the current domain.
	If InStr(strUser, "\") = 0 Then
		strUser = strDomain & "\" & strUser
	End If

	On Error Resume Next
	objNameTranslate.Set ADS_NAME_TYPE_NT4, strUser
	If Err.Number = 0 Then
		Result = objNameTranslate.Get(ADS_NAME_TYPE_1779)
	Else
		Result = ""
	End If

	GetDN = Result
End Function

' Get User's Display Name
Function GetDisplayName(strUserDN)
	Dim objUser
	Set objUser = GetObject("LDAP://" & strUserDN)
	GetDisplayName = objUser.displayName
	Set objUser = Nothing
End Function

' Get the Computer Info
Function GetComputerInfo()
	Dim strComputerInfo
	Dim colSettings
	Dim objComputer

	Set colSettings = objWMIService.ExecQuery ("Select * from Win32_ComputerSystem")
	
	strComputerInfo = ""
	
	For Each objComputer in colSettings 
		strComputerInfo = Replace(objComputer.Manufacturer, ",","",1,-1) & ", " & Replace(objComputer.Model, ",","",1,-1)
	Next
	GetComputerInfo = Trim(strComputerInfo)
End Function