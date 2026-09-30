@echo off
echo ============================================
echo   Building FileShare Application
echo ============================================

if not exist bin mkdir bin
if not exist shared mkdir shared
if not exist downloads mkdir downloads
if not exist database mkdir database

echo Compiling Java source files...
javac -encoding UTF-8 -cp "lib/*" -d bin src/common/*.java src/database/*.java src/server/*.java src/client/*.java src/test/*.java

if %ERRORLEVEL% equ 0 (
    echo.
    echo [SUCCESS] Build completed successfully!
    echo Compiled class files placed in bin/
) else (
    echo.
    echo [ERROR] Compilation failed with error code %ERRORLEVEL%
)
pause
