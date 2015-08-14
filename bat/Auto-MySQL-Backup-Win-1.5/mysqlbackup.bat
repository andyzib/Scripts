:: Auto MySQL Backup For Windows Servers By Matt Moeller  v.1.5
:: RED OLIVE INC.  - www.redolive.com

:: Follow us on twitter for updates to this script  twitter.com/redolivedesign
:: coming soon:  email admin a synopsis of the backup with total file size(s) and time it took to execute

:: FILE HISTORY ----------------------------------------------
:: UPDATE 11.7.2012  Added setup all folder paths into variables at the top of the script to ease deployment
:: UPDATE 7.16.2012  Added --routines, fix for dashes in filename, and fix for regional time settings
:: UPDATE 3.30.2012  Added error logging to help troubleshoot databases backup errors.   --log-error="c:\MySQLBackups\backupfiles\dumperrors.txt"
:: UPDATE 12.29.2011 Added time bug fix and remote FTP options - Thanks to Kamil Tomas 
:: UPDATE 5.09.2011  v 1.0 


:: If the time is less than two digits insert a zero so there is no space to break the filename

:: If you have any regional date/time issues call this include: getdate.cmd  credit: Simon Sheppard for this cmd - untested
:: call getdate.cmd

set year=%DATE:~10,4%
set day=%DATE:~7,2%
set mnt=%DATE:~4,2%
set hr=%TIME:~0,2%
set min=%TIME:~3,2%

IF %day% LSS 10 SET day=0%day:~1,1%
IF %mnt% LSS 10 SET mnt=0%mnt:~1,1%
IF %hr% LSS 10 SET hr=0%hr:~1,1%
IF %min% LSS 10 SET min=0%min:~1,1%

set backuptime=%year%-%day%-%mnt%-%hr%-%min%
echo %backuptime%



:: SETTINGS AND PATHS 
:: Note: Do not put spaces before the equal signs or variables will fail

:: Name of the database user with rights to all tables
set dbuser=root

:: Password for the database user
set dbpass=youradminpassword

:: Error log path - Important in debugging your issues
set errorLogPath="c:\MySQLBackups\backupfiles\dumperrors.txt"

:: MySQL EXE Path
set mysqldumpexe="C:\Program Files\MySQL\MySQL Server 5.5\bin\mysqldump.exe"

:: Error log path
set backupfldr=c:\MySQLBackups\backupfiles\

:: Path to data folder which may differ from install dir
set datafldr="C:\ProgramData\MySQL\MySQL Server 5.5\data"

:: Path to zip executable
set zipper="c:\MySQLBackups\zip\7za.exe"

:: Number of days to retain .zip backup files 
set retaindays=5

:: DONE WITH SETTINGS



:: GO FORTH AND BACKUP EVERYTHING!

:: Switch to the data directory to enumerate the folders
pushd %datafldr%

echo "Pass each name to mysqldump.exe and output an individual .sql file for each"

:: Thanks to Radek Dolezel for adding the support for dashes in the db name
:: Added --routines thanks for the suggestion Angel

:: turn on if you are debugging
@echo off

FOR /D %%F IN (*) DO (

IF NOT [%%F]==[performance_schema] (
SET %%F=!%%F:@002d=-!
%mysqldumpexe% --user=%dbuser% --password=%dbpass% --databases --routines --log-error=%errorLogPath% %%F > "%backupfldr%%%F.%backuptime%.sql"
) ELSE (
echo Skipping DB backup for performance_schema
)
)

echo "Zipping all files ending in .sql in the folder"


:: .zip option clean but not as compressed
%zipper% a -tzip "%backupfldr%FullBackup.%backuptime%.zip" "%backupfldr%*.sql"


echo "Deleting all the files ending in .sql only"
 
del "%backupfldr%*.sql"

echo "Deleting zip files older than 30 days now"
Forfiles -p %backupfldr% -s -m *.* -d -%retaindays% -c "cmd /c del /q @path"


::FOR THOSE WHO WISH TO FTP YOUR FILE UNCOMMENT THESE LINES AND UPDATE - Thanks Kamil for this addition!

::cd\[path to directory where your file is saved]
::@echo off
::echo user [here comes your ftp username]>ftpup.dat
::echo [here comes ftp password]>>ftpup.dat
::echo [optional line; you can put "cd" command to navigate through the folders on the ftp server; eg. cd\folder1\folder2]>>ftpup.dat
::echo binary>>ftpup.dat
::echo put [file name comes here; eg. FullBackup.%backuptime%.zip]>>ftpup.dat
::echo quit>>ftpup.dat
::ftp -n -s:ftpup.dat [insert ftp server here; eg. myserver.com]
::del ftpup.dat

echo "done"

::return to the main script dir on end
popd