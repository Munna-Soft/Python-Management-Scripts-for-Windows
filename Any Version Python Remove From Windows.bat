@echo off
title Removing Python Completely...
echo ============================================
echo    Python Complete Removal Script
echo ============================================
echo.

:: Stop Python related processes
echo Killing Python processes...
taskkill /F /IM python.exe >nul 2>&1
taskkill /F /IM python3.exe >nul 2>&1
taskkill /F /IM py.exe >nul 2>&1

:: Uninstall Python from Programs
echo Uninstalling Python from Installed Apps...
wmic product where "name like 'Python%%'" call uninstall /nointeractive >nul 2>&1
wmic product where "name like 'Python Launcher%%'" call uninstall /nointeractive >nul 2>&1

:: Delete common Python folders
echo Deleting Python folders...
rmdir /s /q "%LocalAppData%\Programs\Python" 2>nul
rmdir /s /q "%LocalAppData%\Python" 2>nul
rmdir /s /q "%AppData%\Python" 2>nul
rmdir /s /q "C:\Python27" 2>nul
rmdir /s /q "C:\Python37" 2>nul
rmdir /s /q "C:\Python38" 2>nul
rmdir /s /q "C:\Python39" 2>nul
rmdir /s /q "C:\Python310" 2>nul
rmdir /s /q "C:\Python311" 2>nul
rmdir /s /q "C:\Python312" 2>nul
rmdir /s /q "C:\Program Files\Python" 2>nul
rmdir /s /q "C:\Program Files (x86)\Python" 2>nul

:: Remove WindowsApps Python (Microsoft Store)
echo Removing Windows Store Python...
rmdir /s /q "%LocalAppData%\Microsoft\WindowsApps\Python*" 2>nul

:: Clean PATH variables
echo Cleaning PATH entries...
setx PATH "%PATH:Python=%" >nul
setx PATH "%PATH:py.exe=%" >nul

:: Remove python.exe shims from WindowsApps
del /f /q "%LocalAppData%\Microsoft\WindowsApps\python.exe" 2>nul
del /f /q "%LocalAppData%\Microsoft\WindowsApps\python3.exe" 2>nul
del /f /q "%LocalAppData%\Microsoft\WindowsApps\py.exe" 2>nul

echo.
echo ============================================
echo      Python Has Been Completely Removed!
echo ============================================
pause
