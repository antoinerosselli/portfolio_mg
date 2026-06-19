@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

cd /d "%~dp0"

echo ============================================
echo   DEPLOY PORTFOLIO - Max Guillot
echo ============================================
echo.

:: Check gh CLI
where gh >nul 2>nul
if %errorlevel% neq 0 (
    "C:\Program Files\GitHub CLI\gh.exe" auth status >nul 2>nul
    if !errorlevel! neq 0 (
        echo [ERREUR] GitHub CLI non trouve. Installe-le avec: winget install GitHub.cli
        pause
        exit /b 1
    )
    set "GH=C:\Program Files\GitHub CLI\gh.exe"
) else (
    set "GH=gh"
)

:: Check gh auth
"%GH%" auth status >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERREUR] Tu n'es pas connecte a GitHub. Lance: gh auth login
    pause
    exit /b 1
)

echo [OK] GitHub CLI connecte
echo.

:: Fetch existing release assets into a temp file
echo Verification des fichiers media...
set "TMPASSETS=%TEMP%\gh_assets_%RANDOM%.txt"
"%GH%" release view v1.0-assets --json assets --jq ".assets[].name" >"%TMPASSETS%" 2>nul
if not exist "%TMPASSETS%" echo.>"%TMPASSETS%"

set "UPLOAD_LIST="
set "UPLOAD_COUNT=0"

for %%f in (*.mp4 *.zip) do (
    set "FNAME=%%~nxf"
    for %%s in ("%%f") do set "FSIZE=%%~zs"
    if !FSIZE! gtr 1000 (
        findstr /i /x "!FNAME!" "%TMPASSETS%" >nul 2>nul
        if !errorlevel! neq 0 (
            echo   [NOUVEAU] !FNAME! ^(!FSIZE! octets^)
            set "UPLOAD_LIST=!UPLOAD_LIST! "%%f""
            set /a UPLOAD_COUNT+=1
        ) else (
            echo   [DEJA EN LIGNE] !FNAME!
        )
    )
)
del "%TMPASSETS%" >nul 2>nul

if %UPLOAD_COUNT% gtr 0 (
    echo.
    echo %UPLOAD_COUNT% nouveau^(x^) fichier^(s^) a uploader sur GitHub Releases.
    echo.

    :: Create release if it doesn't exist
    "%GH%" release view v1.0-assets >nul 2>nul
    if !errorlevel! neq 0 (
        echo Creation de la release...
        "%GH%" release create v1.0-assets --title "Media Assets" --notes "Video and binary assets for the portfolio site" --latest=false
    )

    :: Upload files
    echo Upload en cours... ^(ca peut prendre un moment^)
    for %%f in (%UPLOAD_LIST%) do (
        echo   Uploading %%~nxf...
        "%GH%" release upload v1.0-assets %%f --clobber
        if !errorlevel! neq 0 (
            echo   [ERREUR] Echec de l'upload de %%~nxf
            pause
            exit /b 1
        )
        echo   [OK] %%~nxf

        :: Update HTML src if it uses a local reference
        set "BASENAME=%%~nxf"
        set "RELEASE_URL=https://github.com/antoinerosselli/portfolio_mg/releases/download/v1.0-assets/!BASENAME!"

        :: Check if index.html references this file locally
        findstr /i "src=\"!BASENAME!\"" index.html >nul 2>nul
        if !errorlevel! equ 0 (
            echo   Mise a jour du lien dans index.html...
            powershell -Command "(Get-Content 'index.html' -Raw) -replace 'src=\"!BASENAME!\"', 'src=\"!RELEASE_URL!\"' | Set-Content 'index.html' -Encoding utf8"
            echo   [OK] Lien mis a jour
        )
        findstr /i "href=\"!BASENAME!\"" index.html >nul 2>nul
        if !errorlevel! equ 0 (
            echo   Mise a jour du lien href dans index.html...
            powershell -Command "(Get-Content 'index.html' -Raw) -replace 'href=\"!BASENAME!\"', 'href=\"!RELEASE_URL!\"' | Set-Content 'index.html' -Encoding utf8"
            echo   [OK] Lien href mis a jour
        )
    )
    echo.
    echo [OK] Tous les fichiers sont uploades !
) else (
    echo   [OK] Aucun nouveau fichier media a uploader.
)

echo.
echo ============================================

:: Show git status
echo.
echo Fichiers modifies :
git status --short
echo.

:: Ask for commit message
set /p "COMMIT_MSG=Message du commit : "

if "%COMMIT_MSG%"=="" (
    echo [ANNULE] Pas de message, pas de commit.
    pause
    exit /b 0
)

:: Stage, commit, push
git add -A
git commit -m "%COMMIT_MSG%"

if %errorlevel% neq 0 (
    echo [ERREUR] Le commit a echoue.
    pause
    exit /b 1
)

echo.
echo Push en cours...
git push origin main

if %errorlevel% neq 0 (
    echo [ERREUR] Le push a echoue.
    pause
    exit /b 1
)

echo.
echo ============================================
echo   [OK] Deploy termine ! Vercel va rebuilder.
echo ============================================
echo.
pause
