'==========================================================================
'
' VBScript Source File -- Created with SAPIEN Technologies PrimalScript 2012
'
' NAME: Local Administrators Report
'
' AUTHOR: Andrew Zbikowski, RedBrick Health
' DATE  : 3/13/2013
'
' COMMENT: Requested by Matt Chartrand
'
'==========================================================================
Option Explicit
'On Error Resume Next

Const LDAP_DOMAIN = "dc=example,dc=local"
Const ADS_SCOPE_SUBTREE = 2

' Objects for getting info from AD
Dim objConnection, objCommand, objRecordSet, objRype, objGroup, objUser, objType
Dim strOutput
' Objects and variables for dealting with a text file. 
Dim objFSO, objFile, objShell, strTemp, strFileName, strFullFilePath
' Objects and variables for sending email. 

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

strTemp = objShell.ExpandEnvironmentStrings("%HOMEDRIVE%") & objShell.ExpandEnvironmentStrings("%HOMEPATH%")

' Check if file exists. 
strFileName = Replace(Date(),"/", "-") & "_LocalAdministratorReport.csv"
strFullFilePath = strTemp & "\" & strFileName
If (objFSO.FileExists(strFullFilePath)) Then
	WScript.Echo "Output file " & strFullFilePath & " exists, aborting!"
	WScript.Quit
End If
' If we get this far, create the output file. 
Set objFile = objFSO.CreateTextFile(strFullFilePath)


Set objConnection = CreateObject("ADODB.Connection")
Set objCommand =   CreateObject("ADODB.Command")
objConnection.Provider = "ADsDSOObject"
objConnection.Open "Active Directory Provider"
Set objCommand.ActiveConnection = objConnection

objCommand.Properties("Page Size") = 1000
objCommand.Properties("Searchscope") = ADS_SCOPE_SUBTREE

objCommand.CommandText = _
    "SELECT ADsPath FROM 'LDAP://" & LDAP_DOMAIN & "' WHERE objectCategory='group' AND name='ACL-LocalAdministrators*'"

strOutput = "Group,Members"
objFile.WriteLine strOutput
       
Set objRecordSet = objCommand.Execute

objRecordSet.MoveFirst
Do Until objRecordSet.EOF
    Set objType = GetObject(objRecordSet.Fields("ADsPath").Value)
        If objType.GroupType < 0  Then
            strOutput = objType.cn & ","
            strOutput = GetGroupMembers(objType.distinguishedName)
        End If
    objFile.WriteLine strOutput
    objRecordSet.MoveNext
Loop

objFile.Close

Function GetGroupMembers (strGroupDN) 
	Set objGroup = GetObject("LDAP://" & strGroupDN)
	objGroup.GetInfo
	For Each objUser in objGroup.Members
		strOutput = strOutput & Replace(objUser.Name,"CN=","") & ","
	Next
	strOutput = Left(strOutput,Len(strOutput)-1)
	Set objGroup = Nothing
	GetGroupMembers = strOutput
End Function
