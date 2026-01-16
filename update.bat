@echo off
:: 🌐 Setzt die Konsole auf UTF-8, damit Emojis korrekt angezeigt werden
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 🎨 Konfiguration
set "REPO_URL=https://github.com/diggerwf/updater-vor-windows.git"
set "BRANCH=main"
set "REPO_DIR=%~dp0"
cd /d "%REPO_DIR%"

:: 📄 Dateien
set "UPDATE_SCRIPT=%REPO_DIR%update.bat"
set "TEMP_UPDATE_SCRIPT=%REPO_DIR%update.bat.tmp"

echo 🔍 Prüfe Systemvoraussetzungen...

:: 🛠️ 1. GIT CHECK
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git fehlt! Starte Installation... 🚀
    winget install Git.Git --silent --accept-package-agreements --accept-source-agreements
    if %errorlevel% equ 0 (
        echo ✅ Git installiert! Starte neu... 🔄
        timeout /t 3 >nul
        start "" "%UPDATE_SCRIPT%"
        exit /b
    )
    pause
    exit /b
) else (
    for /f "tokens=*" %%a in ('git --version') do set "GIT_VER=%%a"
    echo ✅ Git ist bereit: !GIT_VER! ✨
)

:: 🔄 2. UPDATE LOGIK
if exist ".git\" (
    echo 📂 Repository gefunden. Prüfe auf Updates... 📡
    git reset --hard >nul
    git fetch origin %BRANCH% >nul

    for /f "tokens=*" %%a in ('git rev-parse HEAD') do set "LOCAL_HASH=%%a"
    for /f "tokens=1" %%a in ('git ls-remote "%REPO_URL%" "%BRANCH%"') do set "REMOTE_HASH=%%a"

    if "!LOCAL_HASH!" neq "!REMOTE_HASH!" (
        echo 🆕 Update gefunden! Lade neue Version... 📥
        copy /y "%UPDATE_SCRIPT%" "%TEMP_UPDATE_SCRIPT%" >nul
        
        :: Pull mit Rebase, um sauber zu bleiben
        git pull origin %BRANCH% --quiet
        
        echo 🚀 Update erfolgreich! Script startet neu... 🔄
        if exist "%TEMP_UPDATE_SCRIPT%" del "%TEMP_UPDATE_SCRIPT%"
        timeout /t 2 >nul
        start "" "%UPDATE_SCRIPT%"
        exit /b
    ) else (
        echo ✅ Alles aktuell! Keine Updates nötig. 😎
    )
) else (
    echo 🏗️ Initialisiere neues Repository... 🔧
    git init >nul
    git remote add origin %REPO_URL% >nul
    git fetch >nul
    git reset --hard origin/%BRANCH% >nul
    echo 🔗 Verbunden und Dateien geladen! 📦
)

echo.
echo ✨ Fertig! Viel Spaß! 🥳
pause
