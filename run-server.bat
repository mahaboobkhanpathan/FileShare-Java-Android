@echo off
echo ============================================
echo   Launching FileShare Server GUI
echo ============================================

java -cp "lib/*;bin" server.Server %*
