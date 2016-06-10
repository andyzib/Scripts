#requires -version 3
<#
.SYNOPSIS
Uses ffmpeg (http://http://ffmpeg.org/) to remove footage from the front of movile files. 
 
.DESCRIPTION
Uses ffmpeg (http://http://ffmpeg.org/) to remove footage from the front of movile files.
Created to get rid of the Universal logo at the start of every episode of Battlestar Galatica. 
 
.PARAMETER Seconds
Number of seconds to trim from the start of the movie. DEFAULT: 23

.PARAMETER Extension
Extension (everything after the last period) of the files to be trimmed. DEFAULT: m4v

.PARAMETER Directory
Directory containing the files to be trimmed. DEFAULT: E:\Scratch

.PARAMETER ffmpeg
Full path to ffmpeg.exe. DEFAULT: C:\ffmpeg\bin\ffmpeg.exe
 
.OUTPUTS
Trimmed files will be saved in the same directory as the existing files. 
 
.NOTES
2016-06-09: Initial script development
 
.EXAMPLE
TrimMovies.ps1 -Seconds 23 -Extension m4v -Directory E:\Scratch

#>
 
#-------------[Parameters]-----------------------------------------------------
# Enable -Debug, -Verbose Parameters. Write-Debug and Write-Verbose!
[CmdletBinding()]
 
Param (
    [Parameter()]$Seconds = 23,
    [Parameter()]$Extension = "m4v",
    [Parameter()]$Directory = "E:\Scratch",
    [Parameter()]$ffmpeg = "C:\ffmpeg\bin\ffmpeg.exe"
)
 
#-------------[Parameter Validation]-------------------------------------------
# Sanitize User Input
 
# Check that ffmpeg.exe file exists.
$ffmpeg = $ffmpeg.Trim()
if (-Not (Test-Path -PathType Leaf -Path $ffmpeg)) {
    Throw "CSV not found: $ffmpeg"
}
 
# Strip trailing \ from $outdir
$Directory = $Directory.Trim()
$Directory = $Directory.TrimEnd("\")
# Check that Directory exists.
if (-Not (Test-Path -PathType Container -Path $Directory)) {
    Throw "Output directory note found: $Directory"
}
 
#-------------[Execution]------------------------------------------------------


$FilePath = $Directory + "\*.*"
$FileInclude = "*." + $Extension
$files = Get-ChildItem $FilePath -Include $FileInclude

foreach ($file in $files) {
    $infile = $file.FullName
    $outfile = $file.FullName.Replace(".$Extension","_trimmed.$Extension")
    # Call ffmpeg with the needed parameters. 
    & $ffmpeg -i "$infile" -ss $Seconds -vcodec copy -acodec copy "$outfile" 
}