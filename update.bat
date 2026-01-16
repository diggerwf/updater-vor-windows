@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: 🎨 Konfiguration
set "REPO_URL=https://github.com/diggerwf/updater-vor-windows.git"
set "BRANCH=main"
set "REPO_DIR=%~dp0"
cd /d "%REPO_DIR%"

echo 🔍 Prüfe auf Updates für: !REPO_URL! 📡

:: 🛠️ 1. GIT CHECK
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git nicht gefunden! Bitte installiere Git.
    pause
    exit /b
)

:: 🔄 2. UPDATE & URL-SYNC LOGIK
if exist ".git\" (
    :: Sicherstellen, dass die Remote-URL korrekt ist
    git remote set-url origin !REPO_URL!
    
    :: Remote-Informationen abrufen
    git fetch origin %BRANCH% --quiet

    :: Hashes vergleichen
    for /f "tokens=*" %%a in ('git rev-parse HEAD') do set "LOCAL_HASH=%%a"
    for /f "tokens=1" %%a in ('git ls-remote origin %BRANCH%') do set "REMOTE_HASH=%%a"

    echo 🏠 Lokal:  !LOCAL_HASH:~0,7!
    echo 🌐 Online: !REMOTE_HASH:~0,7!

    if "!LOCAL_HASH!" neq "!REMOTE_HASH!" (
        echo 🆕 Update gefunden! Synchronisiere alles... 📥
        
        :: Hart auf Online-Stand setzen
        git reset --hard origin/%BRANCH% --quiet
        :: Löscht alles, was nicht auf GitHub ist (Add/Remove Logik)
        git clean -fd >nul
        
        echo ✅ Update erfolgreich! 🚀
        timeout /t 2 >nul
        start "" "%~f0"
        exit /b
    ) else (
        echo ✅ Alles aktuell! 😎
    )
) else (
    echo 🏗️ Ersteinrichtung läuft... 🔧
    git init --quiet
    git remote add origin !REPO_URL! 2>nul
    git fetch --all --quiet
    git reset --hard origin/%BRANCH% --quiet
    git clean -fd >nul
    echo 🔗 Erfolgreich mit neuem Repo verbunden! 📦
)

echo.
echo ✨ Fertig! Dein Ordner ist jetzt mit !REPO_URL! synchron. 🥳

echo.
echo ✨ Fertig! Dein Ordner ist jetzt mit !REPO_URL! synchron. 🥳

echo.
echo ✨ Fertig! Dein Ordner ist jetzt synchron. 🥳 

:: 🚀 Programm nach dem Update / Check starten
if exist "!START_FILE!" (
    echo 🚀 Starte !START_FILE!...
    start "" "!START_FILE!"
)

pause
