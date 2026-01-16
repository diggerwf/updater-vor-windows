@echo off
setlocal enabledelayedexpansion

:: GitHub-Repository-URL und Branch definieren
set "REPO_URL=https://github.com/diggerwf/Updupdater-vor-windows.git"
set "BRANCH=main"

:: Pfad zum Repository (Ordner, in dem das Script liegt)
set "REPO_DIR=%~dp0"
cd /d "%REPO_DIR%"

:: Dateien
set "UPDATE_SCRIPT=%REPO_DIR%update.bat"
set "TEMP_UPDATE_SCRIPT=%REPO_DIR%update.bat.tmp"

:: 1. PRÜFEN OB GIT INSTALLIERT IST
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Git wurde nicht gefunden. Starte automatische Installation via winget...
    :: Installiert Git ohne weitere Abfragen (Silent)
    winget install Git.Git --silent --accept-package-agreements --accept-source-agreements
    
    if %errorlevel% equ 0 (
        echo.
        echo Git wurde erfolgreich installiert! 
        echo Damit Git im System erkannt wird, muss dieses Fenster einmal geschlossen 
        echo und das Script neu gestartet werden.
    ) else (
        echo Installation fehlgeschlagen. Bitte installiere Git manuell.
    )
    pause
    exit /b
)

:: 2. UPDATE LOGIK
if exist ".git\" (
    echo Repository gefunden. Pruefe auf Updates...

    :: Lokale Änderungen verwerfen
    git reset --hard

    :: Nur fetch
    git fetch origin %BRANCH%

    :: Hashes abrufen
    for /f "tokens=*" %%a in ('git rev-parse HEAD') do set "LOCAL_HASH=%%a"
    for /f "tokens=1" %%a in ('git ls-remote "%REPO_URL%" "%BRANCH%"') do set "REMOTE_HASH=%%a"

    if "!LOCAL_HASH!" neq "!REMOTE_HASH!" (
        echo Update fuer update.bat erkannt.

        :: Falls das Script sich selbst überschreibt, kurz umkopieren
        copy /y "%UPDATE_SCRIPT%" "%TEMP_UPDATE_SCRIPT%" >nul

        :: Pull ausführen
        git pull origin %BRANCH%

        echo Update heruntergeladen. Starte neu...
        
        :: Temporäre Datei löschen
        if exist "%TEMP_UPDATE_SCRIPT%" del "%TEMP_UPDATE_SCRIPT%"
        
        :: Neustart des Scripts
        start "" "%UPDATE_SCRIPT%"
        exit /b
    ) else (
        echo Das Repository ist bereits aktuell.
    )
) else (
    echo Repository nicht gefunden. Klone es...
    git clone "%REPO_URL%" .
)

echo Update abgeschlossen oder kein Update erforderlich.
pause