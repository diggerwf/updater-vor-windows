@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 🎨 Konfiguration
set "REPO_URL=https://github.com/diggerwf/updater-vor-windows.git"
set "BRANCH=main"
set "REPO_DIR=%~dp0"
cd /d "%REPO_DIR%"

:: Name der Datei (muss exakt so im Repo heißen!)
set "FILE_NAME=update.bat"

:: 🛠️ 1. GIT CHECK
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git fehlt! Installiere...
    winget install Git.Git --silent --accept-package-agreements --accept-source-agreements
    exit /b
)

:: 🔄 2. UPDATE LOGIK
if exist ".git\" (
    echo 🔍 Prüfe auf Updates... 📡
    
    :: Remote-Infos laden
    git fetch origin %BRANCH% --quiet

    :: Hashes vergleichen
    for /f "tokens=*" %%a in ('git rev-parse HEAD') do set "LOCAL_HASH=%%a"
    for /f "tokens=1" %%a in ('git ls-remote origin %BRANCH%') do set "REMOTE_HASH=%%a"

    if "!LOCAL_HASH!" neq "!REMOTE_HASH!" (
        echo 🆕 Update gefunden! Versionen werden angeglichen... 📥
        
        :: Erzwinge den Stand von GitHub (überschreibt lokale Änderungen)
        git reset --hard origin/%BRANCH% --quiet
        
        echo 🚀 Update durchgeführt! Starte neu... 🔄
        timeout /t 2 >nul
        
        :: Verhindert Endlosschleife: Startet die neue Version und beendet diese hier sofort
        start "" "%~f0"
        exit /b
    ) else (
        echo ✅ Alles aktuell! ✨
    )
) else (
    echo 🏗️ Initialisiere Repository... 🔧
    git init --quiet
    git remote add origin %REPO_URL%
    git fetch --quiet
    git reset --hard origin/%BRANCH% --quiet
    echo 🔗 Verbunden! 📦
)

echo.
echo ✨ Programm wird jetzt ausgeführt... 🥳
:: HIER KANNST DU DEIN EIGENTLICHES PROGRAMM STARTEN
pause
