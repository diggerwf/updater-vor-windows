@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 🎨 Konfiguration
set "REPO_URL=https://github.com/diggerwf/Updater.git"
set "BRANCH=main"
set "REPO_DIR=%~dp0"
cd /d "%REPO_DIR%"

echo 🔍 Prüfe Systemvoraussetzungen...

:: 🛠️ 1. GIT CHECK
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git fehlt! Installiere... 🚀
    winget install Git.Git --silent --accept-package-agreements --accept-source-agreements
    echo ✅ Git installiert! Starte neu...
    timeout /t 3 >nul
    start "" "%~f0"
    exit /b
)

:: 🔄 2. UPDATE, ADD & DELETE LOGIK
if exist ".git\" (
    echo 📡 Suche nach Änderungen auf GitHub...
    
    git fetch origin %BRANCH% --quiet

    for /f "tokens=*" %%a in ('git rev-parse HEAD') do set "LOCAL_HASH=%%a"
    for /f "tokens=1" %%a in ('git ls-remote origin %BRANCH%') do set "REMOTE_HASH=%%a"

    if "!LOCAL_HASH!" neq "!REMOTE_HASH!" (
        echo 🆕 Änderungen erkannt! Synchronisiere Ordner... 📥
        
        :: Setzt alles auf den Stand von GitHub zurück
        git reset --hard origin/%BRANCH% --quiet
        
        :: Löscht ALLES Lokale, was NICHT auf GitHub ist (Add/Remove Logik)
        git clean -fd >nul
        
        echo 🚀 Synchronisation abgeschlossen! Starte neu... 🔄
        timeout /t 2 >nul
        start "" "%~f0"
        exit /b
    ) else (
        echo ✅ Alles aktuell! (Hinzufügen/Entfernen nicht nötig) 😎
    )
) else (
    echo 🏗️ Initialisiere neues Repository... 🔧
    git init --quiet
    git remote add origin %REPO_URL%
    git fetch --quiet
    git reset --hard origin/%BRANCH% --quiet
    git clean -fd >nul
    echo 🔗 Ordner erfolgreich mit GitHub verbunden! 📦
)

echo.
echo ✨ Fertig! Dein Ordner ist jetzt 1:1 wie auf GitHub. 🥳
pause
