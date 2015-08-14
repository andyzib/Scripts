'==========================================================================
' Allows a user to update their Global Address Book Information.
' Author: Andrew Zbikowski <andyzib@gmail.com>
'==========================================================================

Option Explicit

' http://msdn2.microsoft.com/en-us/library/aa772282(VS.85).aspx
' Const ADS_PROPERTY_CLEAR = 1 ' Remove/Clear Value
' Const ADS_PROPERTY_UPDATE = 2 ' Replace current value with new.
' Const ADS_PROPERTY_APPEND = 3 ' Append values to existing values.
'Const ADS_PROPERTY_DELETE = 4 ' Delete values from object. 
Const ADS_PROPERTY_UPDATE = 2  ' Constant needed for doing a particular update.

Dim objConfig ' Dictionary object for configuration
Dim arrConfigKeys ' Keys for objConfig
Dim strConfigKey  ' Individual key from the array of keys
Set objConfig = CreateObject("scripting.dictionary")
' The actual keys
arrConfigKeys = Array("physicalDeliveryOfficeName", "telephoneNumber", _
 "streetAddress", "postOfficeBox", "l", "st", "postalCode",  "C", "co", "countryCode", _
 "homePhone", "pager", "mobile", "facsimileTelephoneNumber", "otherTelephone", _
 "title")

 ' Begin Configuration
For Each strConfigKey in arrConfigKeys
	objConfig.Add strConfigKey, FALSE ' Nothing configurable by default.
Next
' Uncommont (Remove ' from start) to enable the ability for the user to change these fields.
'EnableField("physicalDeliveryOfficeName") ' Office (General Tab)
EnableField("telephoneNumber") ' Phone Number (General Tab)
'EnableField("otherTelephone") ' Other Telephone (General Tab)
'EnableField("streetAddress") ' Sreet (Address Tab)
'EnableField("postOfficeBox") ' P.O. Box (Address Tab)
'EnableField("l") ' City (Address Tab)
'EnableField("st") ' State/province (Address Tab)
'EnableField("postalCode") ' Zip/Postal Code (Address Tab)
' Need to look at proper values for these in ADSI edit. 
' DO NOT USE EnableField("C") ' Country/region (Address Tab)
' DO NOT USE EnableField("co") ' Country/region (Address Tab) 
' DO NOT USE EnableField("countryCode") ' Country/region (Address Tab)
'EnableField("homePhone") ' Home Phone (Telephones Tab)
'EnableField("pager") ' Pager (Telephones Tab)
EnableField("mobile") ' Mobile (Telephones Tab)
'EnableField("facsimileTelephoneNumber") ' Fax
' DO NOT USE EnableField("title") ' Requires special AD permissions
' End Configuration, no further edits required. 

' Objects
Dim objShell, objUser, objFSO, objFile
' Strings
Dim strUsername,strUserDN,strOutput,strInput,strOtherPhone,strNewValue,strTemp1,strTemp2,strChoice,strHomePath
' Arrays
Dim arrOtherPhone
' Integers
Dim intCount

Set objShell = WScript.CreateObject("WScript.Shell")

' Get the username.
strUsername = UCase(objShell.ExpandEnvironmentStrings("%USERNAME%"))
strHomePath = objShell.ExpandEnvironmentStrings("%HOMEDRIVE%") & objShell.ExpandEnvironmentStrings("%HOMEPATH%")

' Check for the control file, quit if it exists. 
Set objFSO = CreateObject("Scripting.FileSystemObject")
if objFSO.FileExists(strHomePath & "UpdateGAL.txt") then
	'WScript.Echo strHomePath & "UpdateGAL.txt Exists, quitting."
	WScript.Quit
Else
	Set objFile = objFSO.CreateTextFile(strHomePath & "UpdateGAL.txt", True)
	objFile.WriteLine(Date())
	objFile.WriteLine("If this file is deleted, you will be prompted to update your contact information the next time you log into Windows.")
	objFile.Close
End If

' Get the user's LDAP Distinguished Name.
strUserDN = GetDN(strUsername)
'WScript.Echo "LDAP://" & strUserDN

' Create a user object
Set objUser = GetObject("LDAP://" & strUserDN)
' Get the user's information. 
objUser.GetInfo

strChoice = CurrentDirInfo(objUser)
' 6 = Yes was clicked, quit script.
' 7 = No was clicked, update information. 
if strChoice = 6 then
	WScript.Quit(0)
Else
	UpdateDirInfo ' Prompt for new information. 
End If

Sub UpdateDirInfo
	On Error Resume Next
	For Each strConfigKey in arrConfigKeys
		if (objConfig.Item(strConfigKey) = TRUE) then
			'WScript.Echo "DEBUG: Updating " & strConfigKey
			strTemp1 = "Update " & getFriendly(strConfigKey) & ": "
			strTemp2 = objUser.Get(strConfigKey)
			' Check to see if objUser.Get worked. If not, use a blank value for strTemp2
			If (CheckError) then
				strTemp2 = ""
			End If
			strInput = InputBox(strTemp1, strTemp1,strTemp2)
			'WScript.Echo strInput
			' objUser.Put field, value
			' objUser.PutEx ADS_PROPERTY_UPDATE, "otherTelephone", Array("555-1214")
			if strInput <> "" then
				if strConfigKey = "otherTelephone" then			
					'WSCript.Echo "DEBUG: Updating " & strConfigKey
					objUser.PutEx ADS_PROPERTY_UPDATE, "otherTelephone", Array(strInput)
				else
					'WScript.Echo "DEBUG: Updating " & strConfigKey
					objUser.Put strConfigKey, strInput
				end if
			end if
		end if
		strInput = ""
	Next
	objUser.SetInfo
	CheckError
End Sub

Function CurrentDirInfo(objUser)
	On Error Resume Next
	Global objUser
	strOutput = "Current Directory Information:" & VBCr & VBCr

	' General Tab
	' First Name: givenName
	strOutput = strOutput & "First Name: " & objUser.Get("givenName") & VBCr
	' Initials: initials
	'strOutput = strOutput & "Middle Initial: " & objUser.Get("initials") & VBCr
	' Last Name: sn
	strOutput = strOutput & "Last Name: " & objUser.Get("sn") & VBCr
	' Office: physicalDeliveryOfficeName
	'strOutput = strOutput & "Office: " & objUser.Get("physicalDeliveryOfficeName") & VBCr
	' Telephone number: telephoneNumber
	strOutput = strOutput & "Office Phone Number: " & objUser.Get("telephoneNumber") & VBCr

	' Address Tab
	' Street: streetAddress
	'strOutput = strOutput & "Street Address: " & objUser.Get("streetAddress") & VBCr
	' P.O. Box: postOfficeBox
	'strOutput = strOutput & "P.O. Box: " & objUser.Get("postOfficeBox") & VBCr
	' City: l
	'strOutput = strOutput & "City: " & objUser.Get("l") & VBCr
	' State/province: st
	'strOutput = strOutput & "State: " & objUser.Get("st") & VBCr
	' Zip/Postil Code: postalCode
	'strOutput = strOutput & "Zip/Postal Code: " & objUser.Get("postalCode") & VBCr
	' Country/region: C, co, countryCode
	'strOutput = strOutput & "Country Code: " & objUser.Get("C") & VBCr

	' Telephones Tab
	' Home: homePhone
	strOutput = strOutput & "Home Phone: " & objUser.Get("homePhone") & VBCr
	' Pager: pager
	strOutput = strOutput & "Pager: " & objUser.Get("pager") & VBCr
	' Mobile: mobile
	strOutput = strOutput & "Mobile Phone: " & objUser.Get("mobile") & VBCr
	' Fax: facsimileTelephoneNumber
	'strOutput = strOutput & "Fax: " & objUser.Get("facsimileTelephoneNumber") & VBCr
	' Other Phones: otherTelephone
	' strOutput = strOutput & "First Name: " & objUser.GetEx("")

	' Orginization Tab
	' Title: Title
	strOutput = strOutput & "Title: " & objUser.Get("Title") & VBCr
	' Department: Department
	strOutput = strOutput & "Department: " & objUser.Get("Department") & VBCr
	' Company: Company
	'strOutput = strOutput & "Company: " & objUser.Get("Company") & VBCr

	' Other Phone numbers are an extended field and needs to use the GetEx method.
	'arrOtherPhone = objUser.GetEx("otherTelephone")
	'strOutput = strOutput & "Other Phone Numbers: " & VBCr
	'intCount = 0
	'For Each strOtherPhone in arrOtherPhone
	'	intCount = intCount +1
	'	strOutput = strOutput & VBTab & intCount & ": " & strOtherPhone & VBCr
	'	'WScript.Echo strOtherPhone 
	'Next

	' Display current directory information
	strOutput = strOutput & VBCr & "Is this information correct?"
	CurrentDirInfo = MsgBox(strOutput,260,"Update Directory Information?") ' 260 = 256 + 4. 4 for Yes No, 256 sets no as default option.
End Function

Function EnableField(strField)
	'WScript.Echo "DEBUG: Enabled " & strField
	objConfig.Remove strField
	objConfig.Add strField, TRUE
End Function

Function UpdateField(strField, strNewValue)
	objUser.Put strField, strNewValue
	objUser.SetInfo
End Function

Function GetDN(UserName)
	Const ADS_NAME_INITTYPE_GC = 3
	Const ADS_NAME_TYPE_1779   = 1
	Const ADS_NAME_TYPE_NT4    = 3

	Dim NameTranslate, Result

	Set NameTranslate = CreateObject("NameTranslate")
	NameTranslate.Init ADS_NAME_INITTYPE_GC, ""

	' If a domain name is not specified, use the current domain.
	If InStr(UserName, "\") = 0 Then
		UserName = CreateObject("WScript.Network").UserDomain _
		& "\" & UserName
	End If

	On Error Resume Next
	NameTranslate.Set ADS_NAME_TYPE_NT4, UserName
	If Err.Number = 0 Then
		Result = NameTranslate.Get(ADS_NAME_TYPE_1779)
	Else
		Result = ""
	End If

	GetDN = Result
End Function

' Returns the friendly name for an LDAP field.
Function getFriendly(strField)
	select case strField
		case "givenName"
			getFriendly = "First Name"
		case "initials"
			getFriendly = "Middle Initial"
		case "sn"
			getFriendly = "Last Name"
		case "physicalDeliveryOfficeName"
			getFriendly = "Office"
		case "telephoneNumber"
			getFriendly = "Office Telephone number"
		case "streetAddress"
			getFriendly = "Street"
		case "postOfficeBox"
			getFriendly = "P.O. Box"
		case "l"
			getFriendly = "City"
		case "st"
			getFriendly = "State/province"
		case "postalCode"
			getFriendly = "Zip/Postal Code"
		case "C"
			getFriendly = "Country/region"
		case "co"
			getFriendly = "Country/region"
		case "countryCode"
			getFriendly = "Country/region"
		case "homePhone"
			getFriendly = "Home Phone"
		case "pager"
			getFriendly = "Pager"
		case "mobile"
			getFriendly = "Mobile"
		case "facsimileTelephoneNumber"
			getFriendly = "Fax"
		case "title"
			getFriendly = "Title"
		case "Department"
			getFriendly = "Department"
		case "Company"
			getFriendly = "Company"
		case "otherTelephone"
			getFriendly = "Phone Extension"
	end select
End Function

Function CheckError
	If Err.number = 0 Then
			CheckError = FALSE
	ElseIf Err.number = "-2147463155" Then ' No value error. 
		'WScript.Echo "Error Description: " & Err.Description ' DEBUG
		' The directory property cannot be found in the cache.
		Err.Clear
		CheckError = TRUE
	Else 
		WScript.echo " Unknown Error Number: " & Err.Number
		WScript.Echo "Error Description: " & Err.Description
		WScript.Quit
	End If
end Function

'==== End of Script =======================================================