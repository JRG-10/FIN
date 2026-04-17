@echo off
setlocal enabledelayedexpansion

echo ============================================================
echo           ECOFIN ENTERPRISE - GERADOR DE RELEASES
echo ============================================================
echo.

REM 1. Criar pasta de destino
set RELEASE_DIR=RELEASE_PACKAGES
if not exist "%RELEASE_DIR%" mkdir "%RELEASE_DIR%"

echo [1/4] Gerando Web Build Otimizada...
call npm run build
if %errorlevel% neq 0 (
    echo [ERRO] Falha no build web.
    pause
    exit /b %errorlevel%
)

echo.
echo [2/4] Gerando Instalador Desktop (Windows .exe)...
echo Isso pode levar alguns minutos...
call npm run build:electron
if %errorlevel% equ 0 (
    echo [OK] Electron Packaged.
    for /r "dist_electron" %%f in (*.exe) do (
        copy "%%f" "%RELEASE_DIR%\ECOFIN_Setup_Windows.exe"
    )
) else (
    echo [AVISO] Falha ao gerar Electron. Verifique dependencias.
)

echo.
echo [3/4] Sincronizando Nucleo Mobile (Capacitor)...
call npx cap sync
if %errorlevel% neq 0 (
    echo [AVISO] Falha no sync do Capacitor.
)

echo.
echo [4/4] Preparando APK Android...
echo Nota: Requer Android Studio / Gradlew configurado.
cd android
call gradlew assembleDebug
if %errorlevel% equ 0 (
    echo [OK] APK Gerado com Sucesso.
    copy "app\build\outputs\apk\debug\app-debug.apk" "..\RELEASE_PACKAGES\ECOFIN_Android_v1.apk"
) else (
    echo [AVISO] Falha ao gerar APK. Necessario Android SDK no PATH.
)
cd ..

echo.
echo ============================================================
echo                BUILD FINALIZADO COM SUCESSO!
echo ============================================================
echo Arquivos disponiveis em: %CD%\RELEASE_PACKAGES
echo.
echo NOTA SOBRE iOS:
echo O Xcode (exclusivo Mac) e necessario para compilar o .ipa final.
echo Os arquivos fonte ja estao na pasta /ios.
echo ============================================================
pause
