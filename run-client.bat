@echo off
echo ============================================
echo   Launching FileShare Client GUI
echo ============================================

java -cp "lib/*;bin" client.ClientGUI %*
