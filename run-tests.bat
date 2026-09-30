@echo off
echo ============================================
echo   Running FileShare Automated Tests
echo ============================================

java -cp "lib/*;bin" test.ComprehensiveTestSuite
pause
