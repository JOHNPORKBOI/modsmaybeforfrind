@echo off
setlocal EnableDelayedExpansion
title Move Undertale to Documents
set "APPID=391540"

echo This will move UNDERTALE from Steam into your Documents folder.
choice /c YN /m "Continue"
if errorlevel 2 exit /b

echo Closing Steam...
taskkill /f /im steam.exe >nul 2>&1
timeout /t 3 /nobreak >nul

rem Find Steam folder
set "STEAM="
for /f "tokens=2,*" %%a in ('reg query "HKCU\Software\Valve\Steam" /v SteamPath 2^>nul') do set "STEAM=%%b"
if not defined STEAM set "STEAM=%ProgramFiles(x86)%\Steam"
set "STEAM=%STEAM:/=\%"

rem Find Documents folder (works with OneDrive too)
for /f "delims=" %%d in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('MyDocuments')"') do set "DOCS=%%d"

set "FOUND=0"
call :check "%STEAM%"

rem Check all other Steam library folders
if exist "%STEAM%\steamapps\libraryfolders.vdf" (
    for /f "tokens=1,*" %%a in ('findstr /i /c:"\"path\"" "%STEAM%\steamapps\libraryfolders.vdf"') do call :check %%b
)

echo.
if "%FOUND%"=="1" (
    echo Done! Undertale is now in your Documents folder: Documents\Undertale
) else (
    echo Undertale was not found in any Steam library.
)
pause
exit /b

:check
set "LIB=%~1"
set "LIB=!LIB:\\=\!"
set "MAN=!LIB!\steamapps\appmanifest_%APPID%.acf"
if not exist "!MAN!" goto :eof
set "FOUND=1"
set "DIR=Undertale"
for /f "tokens=1,*" %%x in ('findstr /i /c:"installdir" "!MAN!"') do set "DIR=%%~y"
echo Found in: !LIB!
set "DEST=%DOCS%\Undertale"
if exist "!LIB!\steamapps\common\!DIR!" (
    echo Moving game to !DEST! ...
    robocopy "!LIB!\steamapps\common\!DIR!" "!DEST!" /E /MOVE /NFL /NDL /NJH /NJS >nul
    if errorlevel 8 (
        echo ERROR: Could not move the game. Nothing was removed from Steam.
        goto :eof
    )
    if exist "!LIB!\steamapps\common\!DIR!" rd /s /q "!LIB!\steamapps\common\!DIR!"
)
rem Keep Steam's install file in the backup too, so you can put it back later
move /y "!MAN!" "!DEST!\" >nul
goto :eof
