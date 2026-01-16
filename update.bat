@echo off
setlocal enabledelayedexpansion

:: 🎨 GitHub-Repository-URL und Branch definieren
set "REPO_URL=https://github.com/diggerwf/updater-vor-windows.git"
set "BRANCH=main"

:: 📂 Pfad zum Repository (Ordner, in dem das Script liegt)
set "REPO_DIR=%~dp0"
cd /d "%REPO_DIR%"

:: 📄 Dateien
set "UPDATE_SCRIPT=%REPO_DIR%update.bat"
set "TEMP_UPDATE_SCRIPT=%REPO_DIR%update.bat.tmp"

echo 🔍 Prüfe Systemvoraussetzungen...

:: 🛠️ 1. PRÜFEN OB GIT INSTALLIERT IST
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git wurde nicht gefunden. 
    echo 📥 Starte automatische Installation via winget... 🚀
    
    winget install Git.Git --silent --accept-package-agreements --accept-source-agreements
    
    if %errorlevel% equ 0 (
        echo ✅ Git wurde erfolgreich installiert! 🎉
        echo 🔄 Starte das Script in einem neuen Fenster neu...
        timeout /t 3 >nul
        start "" "%UPDATE_SCRIPT%"
        exit /b
    ) else (
        echo ⚠️ Installation fehlgeschlagen. Bitte installiere Git manuell von git-scm.com 🌐
    )
    pause
    exit /b
) else (
    for /f "tokens=*" %%a in ('git --version') do set "GIT_VER=%%a"
    echo ✅ Git ist bereits installiert: !GIT_VER! ✨
)

:: 🔄 2. UPDATE LOGIK
if exist ".git\" (
    echo 📂 Repository gefunden. Prüfe auf Updates... 📡

    :: Lokale Änderungen verwerfen
    git reset --hard >nul

    :: Nur fetch
    git fetch origin %BRANCH% >nul

    :: Hashes abrufen
    for /f "tokens=*" %%a in ('git rev-parse HEAD') do set "LOCAL_HASH=%%a"
    for /f "tokens=1" %%a in ('git ls-remote "%REPO_URL%" "%BRANCH%"') do set "REMOTE_HASH=%%a"

    if "!LOCAL_HASH!" neq "!REMOTE_HASH!" (
        echo 🆕 Update erkannt! Lade neue Version herunter... 📥

        :: Falls das Script sich selbst überschreibt
        copy /y "%UPDATE_SCRIPT%" "%TEMP_UPDATE_SCRIPT%" >nul

        :: Pull ausführen
        git pull origin %BRANCH%

        echo 🚀 Update abgeschlossen! Starte neu... 🔄
        
        if exist "%TEMP_UPDATE_SCRIPT%" del "%TEMP_UPDATE_SCRIPT%"
        
        start "" "%UPDATE_SCRIPT%"
        exit /b
    ) else (
        echo ✅ Alles super! Das Repository ist bereits aktuell. 😎
    )
) else (
    :: 🛠️ FEHLERBEHEBUNG: Wenn Ordner nicht leer ist
    echo 🏗️ Repository-Struktur fehlt. Initialisiere Ordner... 🔧
    git init >nul
    git remote add origin %REPO_URL% >nul
    git fetch >nul
    
    :: Dateien vom Repo erzwingen
    git reset --hard origin/%BRANCH% >nul
    echo 🔗 Repository erfolgreich verknüpft und Dateien geladen! 📦
)

echo.
echo ✨ Fertig! Alles ist auf dem neuesten Stand. 🥳
pause
