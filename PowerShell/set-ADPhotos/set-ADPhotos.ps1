<#
	.SYNOPSIS
		Import photos into Active Directory
		
	.DESCRIPTION
		- Source files are collected in bulk from network location and filtered on Last Modified Date
		- Source files must be in the format username.jpg and will be checked against valid AD users
		- The files are copied and processed in a temporary working directory
		- The files are resized (retaining proportions) and imported into AD
		- Both the original and new files are date stamped and backed up (see Exported and Imported folders)
		- Optional:
			- Lync Address book is updated
			- A report is emailed summarising the events

	.PARAMETER SourcePath
		Specifies the location of the original photos

	.PARAMETER Days
		Specifies the number days to match against the Modified Date (age of file), for inclusion in the import
		Optional - The default is '1' day if not specified
		
	.SYNTAX
		Set-ADPhotos <SourcePath> <Days>

	.EXAMPLE
		.\Set-ADPhotos '\\Server1\sharename' 1

	.AUTHOR
		TheAgreeableCow July 2013
		
	.NOTES	
		If setting a sheduled task, ensure to match the schedule with the <Days> parameter. 
			eg In the default example, run the schedule daily.
		
		Microsoft recommend photo sizes:
			- AD thumbnail size max of 96 x 96 pixels and no larger that 10kb
#>


	Function Set-ADPhotos{
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName = $true)]
		[String] $SourcePath="",
		[String] $Days=""
	)
	
	Begin{
		#Working Variables
		$WorkingPath = "C:\Scripts\set-ADPhotos"
		$Logfile = "$WorkingPath\ADPhotos.log"
		$TypeFilter = "*.jpg"
		$ModifiedAge = (get-date).Adddays(-$Days)
		$WidthPx = 96 
		$HeightPx = 96

		#Email Log
		$SendEmailLog = $TRUE
		$SmtpServer = "email.example.com"
		$EmailTo = "corpsys-alerts@example.com"
		$EmailCc = "hr@example.com"

		#Lync Address Book
		$UpdateAddressBook = $FALSE
		$LyncServer = "lync1.mydomain.com"

		#Set files count to 0
		$LocalFilesCount = 0
		$NetworkFilesCount = 0
		$AllFilesCount = 0
		$SucessCount = 0
		$FailCount = 0
		
		#Load required powershell Sessions and arrays
		[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
		#if ((Get-PSSnapin -Name Lync -ErrorAction SilentlyContinue) -eq $null ){
		#	import-module Lync
		#}

		if ((Get-PSSnapin -Name ActiveDirectory -ErrorAction SilentlyContinue) -eq $null ){
			import-module ActiveDirectory
		}
		#Create working directories
		if (!(Test-Path -PathType Container $WorkingPath)){
			New-Item $WorkingPath -type Directory
			New-Item "$WorkingPath\Exported" -type Directory
			New-Item "$WorkingPath\Imported" -type Directory
			New-Item "$WorkingPath\Failed" -type Directory
		}

		#Gather Local files
		$LocalFiles = get-childitem -Path $WorkingPath -filter $TypeFilter | where {!$_.PSIsContainer} | where-object {$_.LastWriteTime -gt $ModifiedAge}
		$LocalCount = $LocalFiles | measure-object
		$LocalFilesCount = $LocalCount.count

		if ($LocalFilesCount -gt 0){
			foreach ($LocalFile in $LocalFiles){
				$LocalName = [io.path]::GetFileNameWithoutExtension($LocalFile)
				$LocalFilesNames += "$LocalName, "
			}
		}

		#Gather Network Files
		$NetworkFiles = get-childitem -Path $SourcePath -filter $TypeFilter | where {!$_.PSIsContainer} | where-object {$_.LastWriteTime -gt $ModifiedAge}
		$NetworkCount = $NetworkFiles | measure-object
		$NetworkFilesCount = $NetworkCount.count
		if ($NetworkFilesCount -gt 0){
			foreach ($NetworkFile in $NetworkFiles){
				$NetworkName = [io.path]::GetFileNameWithoutExtension($NetworkFile)
				$NetworkFilesNames += "$NetworkName, "
				}
			$NetworkFiles | copy-item -destination $WorkingPath
		}
	}
	
	Process{
		$AllFilesCount = $LocalFilesCount + $NetworkFilesCount
		
		if ($AllFilesCount -gt 0){
			$AllFiles = get-childitem -Path $WorkingPath -filter $TypeFilter | where {!$_.PSIsContainer}
			
			foreach ($File in $AllFiles){
				#Confirm Photos match Active Directory Username
				$Name = [io.path]::GetFileNameWithoutExtension($File)
				$User = Get-ADUser -Filter {SamAccountName -eq $Name}

				if ($user -ne $null){
					#Export existing photo as a backup
					$Export = Get-ADUser $Name -properties SamAccountName, ThumbnailPhoto
					if ($Export.ThumbnailPhoto -ne $null){
						$FileStamp = "$Name $(get-date -f yyyy-MM-dd-HH-mm-ss).jpg"
						$Export.thumbnailphoto | Set-Content ("$WorkingPath\Exported\$FileStamp") -Encoding byte
					}

					#Determine new dimensions (ensuring to keep proportions)
					$OldImage = new-object System.Drawing.Bitmap "$WorkingPath\$File"
					$OldWidth = $OldImage.Width
					$OldHeight = $OldImage.Height

					if($OldWidth -lt $OldHeight){
						$NewWidth = $WidthPx
						[int]$NewHeight = [Math]::Round(($NewWidth*$OldHeight)/$OldWidth)

						if($NewHeight -gt $HeightPx){
							$NewHeight = $HeightPx
							[int]$NewWidth = [Math]::Round(($NewHeight*$OldWidth)/$OldHeight)
						}
					}
					else{
						$NewHeight = $HeightPx
						[int]$NewWidth = [Math]::Round(($NewHeight*$OldWidth)/$OldHeight)

						if($NewWidth -gt $WidthPx){
							$NewWidth = $WidthPx
							[int]$NewHeight = [Math]::Round(($NewWidth*$OldHeight)/$OldWidth)
						}     
					}
					
					#Resize Working Image
					$NewImage = new-object System.Drawing.Bitmap $NewWidth,$NewHeight
					$Graphics = [System.Drawing.Graphics]::FromImage($NewImage)
					$Graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
					$Graphics.DrawImage($OldImage, 0, 0, $NewWidth, $NewHeight)

					#Save Working Image
					$ImageFormat = $OldImage.RawFormat
					$OldImage.Dispose()  
					$NewImage.Save("$WorkingPath\$File",$ImageFormat)
					$NewImage.Dispose()

					#Import into AD
					$Photo = [byte[]](Get-Content "$WorkingPath\$File" -Encoding byte)
					Set-ADUser $Name -Replace @{thumbnailPhoto=$Photo}

					#Save a copy as Imported
					$FileStamp = "$Name $(get-date -f yyyy-MM-dd-HH-mm-ss).jpg"
					move-item "$WorkingPath\$File" "$WorkingPath\imported\$FileStamp" -force

					#Logging
					$SucessCount = $SucessCount +1
					$SucessFilesNames += "$Name, "
				}
				Else{
					#Logging
					$FailCount = $FailCount +1
					$FailedFilesNames += "$Name, "

					#Delete Working Image
					$FileStamp = "$Name $(get-date -f yyyy-MM-dd-HH-mm-ss).jpg"
					move-item "$WorkingPath\$File" "$WorkingPath\failed\$FileStamp" -force
				}
			}
		}
	}
	
	End{ 
		#Update Lync Address Book
		if ($UpdateAddressBook -eq $TRUE){
			write-host "Updating Lync address book..."
			Update-CsAddressBook -fqdn $LyncServer
		}
		else{
			write-host "Lync address book NOT set to update"
		}

		#Logging
		Add-Content $Logfile "-------------------------------------------"
		Add-Content $Logfile "New job started $(get-date)"
		Add-Content $Logfile "Local Path: $WorkingPath"
		Add-Content $Logfile "Network Path: $SourcePath"
		Add-Content $Logfile "Modified Age: $ModifiedAge"
		Add-Content $Logfile "Filter: $TypeFilter"
		Add-Content $Logfile "Fixed Dimensions: $WidthPx(w) x $HeightPx(h)"
		Add-Content $Logfile "Local Files Found ($LocalFilesCount): $LocalFilesNames"
		Add-Content $Logfile "Network Files Found ($NetworkFilesCount): $NetworkFilesNames"
		Add-Content $Logfile "Import SUCCESS ($SucessCount): $SucessFilesNames"
		Add-Content $Logfile "Import FAILED ($FailCount): $FailedFilesNames"
		
		if ($UpdateAddressBook -eq $TRUE){
			Add-Content $Logfile "Lync Address book was updated"
		}
		else{
			Add-Content $Logfile "Lync Address book was NOT updated"
		}
		
		if ($SendEmailLog -eq $TRUE){
			Add-Content $Logfile "Email log was sent"
		}
		else{
		Add-Content $Logfile "Email log was NOT sent"
		}

		#Load Email Variables
		$EmailFrom = "robotb9@example.com"
		$EmailSubject = "[AUTO] AD Photos Processed $(get-date -f yyyy-MM-dd)"
		If ($AllFilesCount -gt 0){
		$EmailBody = "An Active Directory photo sync was completed on $(get-date). `
`
$AllFilesCount new photo(s) found for processing (modified since $ModifiedAge). `
`
$SucessCount photo(s) imported sucessfully: $SucessFilesNames `
$FailCount photo(s) NOT imported (file name did not match a user in AD): $FailedFilesNames `
`
Please see the attached log for full details `
`
Regards, `
`
Admin Scripts"
		}
		else{
		$EmailBody = "An Active Directory photo sync was completed on $(get-date). `
`
There were no new photos found in $WorkingPath or $SourcePath (modified since $ModifiedAge). `
`
Regards, `
`
Admin Scripts" 
		}

		#Send Email Log
		if ($SendEmailLog -eq $TRUE){
			write-host "Sending email log..."
			Send-MailMessage -To $EmailTo -Cc $EmailCc -From $EmailFrom -Subject $EmailSubject -SmtpServer $SmtpServer -body $EmailBody -attachment $Logfile
		}
		else{
			write-host $EmailBody
		}
	}
}

#Load Arguments and call Function
$HelpText = @"
Missing or invalid arguments. Correct syntax is Set-ADPhotos <SourcePath> <Days>

For example .\Set-ADPhotos.ps1 '\\Server1\sharename' 1
"@

if ($args[0] -ne $NULL){
	$SourcePath = $args[0]
}
else{
	write-host $HelpText
	exit
}
if ($args[1] -ne $NULL){
	$Days = $args[1]
}
else{
	$Days = 1
}

Set-ADPhotos $SourcePath $Days
