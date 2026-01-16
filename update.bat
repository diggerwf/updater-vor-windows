@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 🎨 Konfiguration
set "REPO_URL=https://github.com/diggerwf/updater-vor-windows.git"
set "BRANCH=main"
set "REPO_DIR=%~dp0"
cd /d "%REPO_DIR%"

echo 🔎 Suche nach Updates...

:: 🛠️ 1. GIT CHECK
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git nicht gefunden!
    pause
    exit /b
)

:: 🔄 2. UPDATE LOGIK
if exist ".git\" (
    :: Sicherstellen, dass wir auf dem richtigen Branch sind
    git checkout %BRANCH% --quiet
    
    :: Remote-Infos holen
    git fetch origin %BRANCH% --quiet

    :: Hashes vergleichen
    for /f "tokens=*" %%a in ('git rev-parse HEAD') do set "LOCAL_HASH=%%a"
    for /f "tokens=1" %%a in ('git ls-remote origin %BRANCH%') do set "REMOTE_HASH=%%a"

    if "!LOCAL_HASH!" neq "!REMOTE_HASH!" (
        echo 🆕 Update gefunden! Versionen werden angeglichen... 📥
        
        :: ALLES überschreiben und aufräumen
        git reset --hard origin/%BRANCH% --quiet
        git clean -fd >nul
        
        echo ✅ Update erfolgreich installiert!
        echo 🔄 Starte in 3 Sekunden neu...
        timeout /t 3
        
        :: Neustart
        start "" "%~f0"
        exit /b
    ) else (
        echo ✅ Alles aktuell! ✨
    )
) else (
    echo 🏗️ Ersteinrichtung: Klone Repository... 🔧
    git init --quiet
    git remote add origin %REPO_URL% >nul 2>&1
    git fetch --quiet
    git reset --hard origin/%BRANCH% --quiet
    git clean -fd >nul
    echo 🔗 Verbunden! 📦
)

echo.
echo 🚀 Das Programm ist jetzt bereit.
pause
