@echo off
title Ultimate Python Removal Script
echo ============================================
echo      Ultimate Python Total Cleanup
echo ============================================
echo Running as Administrator required...
echo.

:: -----------------------------
:: 1. Stop Python Processes
:: -----------------------------
echo Killing Python-related processes...
taskkill /F /IM python.exe >nul 2>&1
taskkill /F /IM python3.exe >nul 2>&1
taskkill /F /IM py.exe >nul 2>&1
taskkill /F /IM conda.exe >nul 2>&1


:: -----------------------------
:: 2. Uninstall Python (WMIC)
:: -----------------------------
echo Uninstalling Python from Programs...
wmic product where "name like 'Python %%'" call uninstall /nointeractive >nul 2>&1
wmic product where "name like 'Python Launcher%%'" call uninstall /nointeractive >nul 2>&1


:: -----------------------------
:: 3. Uninstall Python via Winget
:: -----------------------------
echo Removing Python via Winget...
winget uninstall Python.Python.3 >nul 2>&1
winget uninstall Python.Python.3.11 >nul 2>&1
winget uninstall Python.Python.3.12 >nul 2>&1
winget uninstall PythonSoftwareFoundation.Python.3 >nul 2>&1


:: -----------------------------
:: 4. Remove Python from Chocolatey
:: -----------------------------
echo Removing Python via Chocolatey...
choco uninstall python -y >nul 2>&1


:: -----------------------------
:: 5. Remove Python from Scoop
:: -----------------------------
echo Removing Python via Scoop...
scoop uninstall python >nul 2>&1


:: -----------------------------
:: 6. Remove Anaconda/Miniconda
:: -----------------------------
echo Removing Anaconda/Miniconda...
rmdir /s /q "%UserProfile%\Anaconda3" 2>nul
rmdir /s /q "%UserProfile%\Miniconda3" 2>nul
rmdir /s /q "C:\Anaconda3" 2>nul
rmdir /s /q "C:\Miniconda3" 2>nul

:: Remove conda PATH shims
del /f /q "%UserProfile%\AppData\Local\conda" 2>nul
del /f /q "%UserProfile%\AppData\Local\Continuum" 2>nul


:: -----------------------------
:: 7. Delete Python folders (FULL)
:: -----------------------------
echo Cleaning Python folders...
for %%d in (
    "%LocalAppData%\Programs\Python"
    "%LocalAppData%\Python"
    "%AppData%\Python"
    "C:\Python27"
    "C:\Python37"
    "C:\Python38"
    "C:\Python39"
    "C:\Python310"
    "C:\Python311"
    "C:\Python312"
    "C:\Program Files\Python"
    "C:\Program Files (x86)\Python"
) do (
    rmdir /s /q %%d 2>nul
)


:: -----------------------------
:: 8. Remove Windows Store Python
:: -----------------------------
echo Removing Windows Store Python...
del /f /q "%LocalAppData%\Microsoft\WindowsApps\python*.exe" 2>nul
rmdir /s /q "%LocalAppData%\Microsoft\WindowsApps\PythonSoftwareFoundation.Python.3*" 2>nul


:: -----------------------------
:: 9. Remove PATH Entries
:: -----------------------------
echo Cleaning PATH from Python entries...
for /f "tokens=1,* delims==" %%a in ('setx /? ^>nul ^& set') do (
    echo %%a | findstr /i "path" >nul && (
        set "newpath=%%b"
        echo !newpath! | findstr /i "Python" >nul && (
            echo Stripping Python from PATH...
            set "newpath=!newpath:Python=!"
            setx PATH "!newpath!" >nul
        )
    )
)


:: -----------------------------
:: 10. Clean Registry (Python keys)
:: -----------------------------
echo Cleaning Python registry keys...

reg delete "HKCU\Software\Python" /f >nul 2>&1
reg delete "HKLM\Software\Python" /f >nul 2>&1
reg delete "HKLM\Software\WOW6432Node\Python" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\python.exe" /f >nul 2>&1


:: -----------------------------
:: 11. Verification
:: -----------------------------
echo.
echo Testing Python uninstall...
python --version 2>nul
py --version 2>nul
python3 --version 2>nul
if %errorlevel% neq 0 (
    echo Python is fully removed!
) else (
    echo Some Python parts may still remain.
)

echo ============================================
echo       Python Removal Completed!
echo ============================================
pause
