' SCRIPT: CheckPWExpire.vbs
' This script checks an AD account (entered by user) to see if the account is 
' locked out or if the password has expired. If the account is not locked out
' and the password is not expired, the script will display when the account's 
' password was last changed, the difference in days between when the password 
' was last set and today, the maximum password age for the AD domain, and when 
' the password will expire. 
' Created by Andrew Zbikowski <andyzib@gmail.com> 

Option Explicit

Dim objUserLDAP
Dim strPrompt, strUser, strUserDN, strDomain, objSysInfo

' Get the NETBIOS name of your domain. 
Set objSysInfo = CreateObject( "WinNTSystemInfo" )
strDomain = objSysInfo.DomainName

' Get AD User logon name
strPrompt = "Enter AD username (User logon name)."
strUser = InputBox (strPrompt,strPrompt)

strUserDN = GetDN(strUser)
WScript.Echo CheckExpired(strUserDN)

Function GetDN(strUser)
	Const ADS_NAME_INITTYPE_GC = 3
	Const ADS_NAME_TYPE_1779   = 1
	Const ADS_NAME_TYPE_NT4    = 3

	Dim objNameTranslate, Result

	Set objNameTranslate = CreateObject("NameTranslate")
	objNameTranslate.Init ADS_NAME_INITTYPE_GC, ""

	' If a domain name is not specified, use the current domain.
	If InStr(strUser, "\") = 0 Then
		strUser = strDomain	& "\" & strUser
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

Function CheckExpired(strUserDN)
	Const SEC_IN_DAY = 86400
	Const ADS_UF_DONT_EXPIRE_PASSWD = &h10000
	
	Dim objUserLDAP, objDomainNT
	Dim intCurrentValue, dtmValue, intTimeInterval, intMaxPwdAge
	Dim strReturn
	strReturn = ""
	Set objUserLDAP = GetObject ("LDAP://" & strUserDN)	
	intCurrentValue = objUserLDAP.Get("userAccountControl")
	
	If IsAccountLocked(objUserLDAP) Then
		strReturn = strReturn & "The account is locked out."
	ElseIf intCurrentValue and ADS_UF_DONT_EXPIRE_PASSWD Then
		'Wscript.Echo "The password does not expire."
		strReturn = strReturn & "The password does not expire."
	Else
		dtmValue = objUserLDAP.PasswordLastChanged 
		'Wscript.echo "The password was last changed on " & _
		'DateValue(dtmValue) & " at " & TimeValue(dtmValue) & VbCrLf & _
		'"The difference between when the password was last set" & VbCrLf & _
		'"and today is " & int(now - dtmValue) & " days"
		strReturn = strReturn & "The password was last changed on " & _
		DateValue(dtmValue) & " at " & TimeValue(dtmValue) & VbCrLf & _
		"The difference between when the password was last set" & VbCrLf & _
		"and today is " & int(now - dtmValue) & " days" & VbCrLf
		intTimeInterval = int(now - dtmValue)

		Set objDomainNT = GetObject("WinNT://" & strDomain)
		intMaxPwdAge = objDomainNT.Get("MaxPasswordAge")
		If intMaxPwdAge < 0 Then
			'WScript.Echo "The Maximum Password Age is set to 0 in the " & _
			'"domain. Therefore, the password does not expire."
			strReturn = strReturn & "The Maximum Password Age is set to 0 in the " & _
			"domain. Therefore, the password does not expire." & VbCrLf
		Else
			intMaxPwdAge = (intMaxPwdAge/SEC_IN_DAY)
			'Wscript.echo "The maximum password age is " & intMaxPwdAge & " days"
			strReturn = strReturn & "The maximum password age is " & intMaxPwdAge & " days" & VbCrLf
			If intTimeInterval >= intMaxPwdAge Then
				'Wscript.echo "The password has expired."
				strReturn = strReturn & "The password has expired." & VbCrLf
			Else
				'Wscript.echo "The password will expire on " & _
				'DateValue(dtmValue + intMaxPwdAge) & " (" & _
				'int((dtmValue + intMaxPwdAge) - now) & " days from today" & ")."
				strReturn = strReturn & "The password will expire on " & _
				DateValue(dtmValue + intMaxPwdAge) & " (" & _
				int((dtmValue + intMaxPwdAge) - now) & " days from today" & ")." & VbCrLf
			End If
		End If
	End If
	CheckExpired = strReturn
End Function

' Check Account Lockout Status >>>>>
Function IsAccountLocked(byval objUser)
	Dim objLockout
	on error resume next
	set objLockout = objUser.get("lockouttime")

	if err.number = -2147463155 then
		isAccountLocked = False
		exit Function
	end if
	on error goto 0
	
	if objLockout.lowpart = 0 And objLockout.highpart = 0 Then
		isAccountLocked = False
	Else
		isAccountLocked = True
	End If

End Function