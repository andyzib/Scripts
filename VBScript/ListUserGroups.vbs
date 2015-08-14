On Error Resume Next

sExecutable = LCase(Mid(Wscript.FullName, InstrRev(Wscript.FullName,"\")+1))
If sExecutable <> "cscript.exe" Then
  Set oShell = CreateObject("wscript.shell")
  oShell.Run "cscript.exe """ & Wscript.ScriptFullName & """"
  Wscript.Quit
End If

Const DOMAIN = "CONTOSO"

' Get AD User logon name
strPrompt = "Enter AD username (User logon name)."
strUser = InputBox (strPrompt,strPrompt)

strUserDN = GetDN(strUser)
Set objUser = GetObject("LDAP://" & strUserDN)

Set objUser=GetObject("LDAP://" & strUserDN) 
Set colGroups = objUser.Groups

intCount = 0 

WScript.Echo strUser & " is a member of the following groups:"
For Each objGroup in colGroups
    Output(objGroup.CN)
    GetNested(objGroup)
Next
WScript.Echo "Total Groups: " & intCount

strMessage = "Press the ENTER key to continue. "
Wscript.StdOut.Write strMessage

Do While Not WScript.StdIn.AtEndOfLine
   Input = WScript.StdIn.Read(1)
Loop
WScript.Echo "The script is complete."

WScript.Quit(0)

Function Output(strOutput)
	WScript.Echo strOutput
	intCount = intCount+1
End Function


Function GetNested(objGroup)
    On Error Resume Next
    colMembers = objGroup.GetEx("memberOf")
    For Each strMember in colMembers
        strPath = "LDAP://" & strMember
        Set objNestedGroup = _
        GetObject(strPath)
        Output("NESTED: " & objNestedGroup.CN)
        GetNested(objNestedGroup)
    Next
End Function

Function GetDN(strUser)
	Const ADS_NAME_INITTYPE_GC = 3
	Const ADS_NAME_TYPE_1779   = 1
	Const ADS_NAME_TYPE_NT4    = 3

	Dim objNameTranslate, Result

	Set objNameTranslate = CreateObject("NameTranslate")
	objNameTranslate.Init ADS_NAME_INITTYPE_GC, ""

	' If a domain name is not specified, use the current domain.
	If InStr(strUser, "\") = 0 Then
		strUser = CreateObject("WScript.Network").UserDomain _
		& "\" & strUser
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