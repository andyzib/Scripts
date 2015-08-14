On Error Resume Next

sExecutable = LCase(Mid(Wscript.FullName, InstrRev(Wscript.FullName,"\")+1))
If sExecutable <> "cscript.exe" Then
  Set oShell = CreateObject("wscript.shell")
  oShell.Run "cscript.exe """ & Wscript.ScriptFullName & """"
  Wscript.Quit
End If
 
' Get AD User logon name
strPrompt = "Enter AD group (User logon name)."
strGroup = InputBox (strPrompt,strPrompt)

strGroupDN = GetDN(strGroup)

if strGroupDN = "" Then
	WScript.Echo "Error, group named """ & strGroup & """ not found." 
End If
 
Set objGroup = GetObject(strGroupDN)
objGroup.GetInfo
 
arrMemberOf = objGroup.GetEx("member")

WScript.Echo strGroup
WScript.Echo UBound(arrMemberOf)+1 & " Group Members:"
For Each strMember in arrMemberOf
	Set re = New RegExp
	re.Pattern = "^CN=(.+?),OU.*$"
	re.IgnoreCase = true
	re.Global = True
	Set matches = re.Execute(strMember)
	if matches.Count = 1 Then
		' Item(0) is the first and only match.
		WScript.Echo matches.Item(0).SubMatches(0)
	Else
		WScript.Echo "Error: Unexpected number of results."
		WScript.Echo strMember
	End If
Next

strMessage = "Press the ENTER key to continue. "
Wscript.StdOut.Write strMessage

Do While Not WScript.StdIn.AtEndOfLine
   Input = WScript.StdIn.Read(1)
Loop
WScript.Echo "The script is complete."

WScript.Quit(0)

Function GetDN(sGroup)
    Set rootDSE=GetObject("LDAP://RootDSE")
    DomainContainer = rootDSE.Get("defaultNamingContext")

    Set conn = CreateObject("ADODB.Connection")
    conn.Provider = "ADSDSOObject"
    conn.Open "ADs Provider"

    ldapStrUsers = "<GC://" & DomainContainer & _
    ">;(&(&(& (cn=" & sGroup & _ 
    ") (| (&(objectCategory=*)(objectClass=*)) ))));adspath;subtree"

    Set rs1 = conn.Execute(ldapStrUsers)

    While Not rs1.EOF
          Set FoundObject = GetObject (rs1.Fields(0).Value)
          GetDN = "LDAP://" & FoundObject.distinguishedName
          rs1.MoveNext
    Wend

    Set rs1=Nothing
    Set conn = Nothing
    Set rootDSE = Nothing
End Function