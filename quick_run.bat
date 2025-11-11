@echo off
echo ============================================
echo RAPTOR.FITT V2 - QUICK RUN
echo ============================================
echo.

cd /d "C:\Users\tejbr\code\raptor.fitt.v2"

echo [1/4] Installing dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Flutter pub get failed
    pause
    exit /b 1
)

echo.
echo [2/4] Generating Hive adapters...
del /f /q lib\features\models\*.g.dart >nul 2>&1
flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo [ERROR] Build runner failed
    pause
    exit /b 1
)

echo.
echo [3/4] Checking for devices...
flutter devices

echo.
echo [4/4] Running app...
echo.
flutter run

pause
