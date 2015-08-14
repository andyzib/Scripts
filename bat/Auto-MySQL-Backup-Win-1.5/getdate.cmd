@ECHO off
   SETLOCAL
   IF [%1]==[] goto s_start

   ECHO GETDATE.cmd
   ECHO Returns the date independent of regional settings
   ECHO Creates the environment variables %v_year% %v_month% %v_day%
   ECHO.
   ECHO SYNTAX
   ECHO       GETDATE
   ECHO.
   ECHO.
   GOTO :eof

   :s_start

   FOR /f "tokens=2-4 skip=1 delims=(-)" %%G IN ('echo.^|date') DO (
      FOR /f "tokens=2 delims= " %%A IN ('date /t') DO (
         SET v_first=%%G
         SET v_second=%%H
         SET v_third=%%I
         SET v_all=%%A
      )
   )

      SET %v_first%=%v_all:~0,2%
      SET %v_second%=%v_all:~3,2%
      SET %v_third%=%v_all:~6,4%

   ECHO Today is Year: [%yy%] Month: [%mm%] Day: [%dd%]

   ENDLOCAL & SET v_year=%yy%& SET v_month=%mm%& SET v_day=%dd%