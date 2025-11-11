@echo off
echo ========================================
echo   Raptor.fitt v2 - Build and Run
echo ========================================
echo.

echo [1/4] Cleaning previous builds...
call flutter clean

echo.
echo [2/4] Getting dependencies...
call flutter pub get

echo.
echo [3/4] Generating code (Hive adapters)...
call flutter pub run build_runner build --delete-conflicting-outputs

echo.
echo [4/4] Running app...
call flutter run

echo.
echo ========================================
echo   Build complete!
echo ========================================
pause
