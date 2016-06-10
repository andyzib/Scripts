$ffmpeg = "C:\ffmpeg\bin\ffmpeg.exe"

$files = Get-ChildItem E:\Scratch\*.* -Include *.m4v

foreach ($file in $files) {
    $infile = $file.FullName
    $outfile = $file.FullName.Replace(".m4v","_trimmed.m4v")
    & $ffmpeg -i "$infile" -ss 23 -vcodec copy -acodec copy "$outfile" 

}