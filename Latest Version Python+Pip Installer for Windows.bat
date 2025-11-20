@echo off
setlocal EnableDelayedExpansion

echo.
echo ========================================
echo    Python Auto Installer Batch Script
echo ========================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Please run this script as Administrator!
    echo Right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo [INFO] Running as administrator - proceeding with installation...
echo.

:: Set variables
set "PYTHON_URL=https://www.python.org/ftp/python/latest/python-3.x-amd64.exe"
set "INSTALL_DIR=C:\Python39"
set "TEMP_FILE=%TEMP%\python_installer.exe"

:: Get latest Python download URL
echo [INFO] Fetching latest Python version...
powershell -Command "try { $response = Invoke-WebRequest 'https://www.python.org/downloads/windows/' -UseBasicParsing; $matches = [regex]::Matches($response.Content, 'https://www.python.org/ftp/python/(\d+\.\d+\.\d+)/python-\d+\.\d+\.\d+-amd64\.exe'); if ($matches.Count -gt 0) { $latest = $matches[0].Value; Write-Output $latest } else { Write-Output 'https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe' } } catch { Write-Output 'https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe' }" > "%TEMP%\python_url.txt"
set /p PYTHON_URL=<"%TEMP%\python_url.txt"
del "%TEMP%\python_url.txt"

echo [INFO] Downloading Python from: %PYTHON_URL%
echo.

:: Download Python installer
powershell -Command "Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile '%TEMP_FILE%'" >nul 2>&1

if not exist "%TEMP_FILE%" (
    echo [ERROR] Failed to download Python installer
    pause
    exit /b 1
)

echo [SUCCESS] Python installer downloaded successfully!
echo.

:: Install Python with silent mode and add to PATH
echo [INFO] Installing Python... This may take a few minutes.
echo [INFO] Installation directory: %INSTALL_DIR%
echo.

start /wait "" "%TEMP_FILE%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 TargetDir=%INSTALL_DIR%

:: Clean up installer
del "%TEMP_FILE%" >nul 2>&1

echo.
echo [INFO] Verifying installation...

:: Check if Python is installed
python --version >nul 2>&1
if %errorLevel% equ 0 (
    python -c "import sys; print('[SUCCESS] Python version: ' + sys.version.split()[0])"
) else (
    echo [WARNING] Python not found in PATH, trying to add manually...
    
    :: Try to find Python installation directory
    if exist "%INSTALL_DIR%\python.exe" (
        set "PYTHON_PATH=%INSTALL_DIR%"
    ) else (
        :: Search for Python in common locations
        for /d %%i in (C:\Python*) do (
            if exist "%%i\python.exe" (
                set "PYTHON_PATH=%%i"
                goto :found_python
            )
        )
        echo [ERROR] Python installation not found!
        pause
        exit /b 1
    )
    :found_python
)

:: Add to system PATH if not already there
echo.
echo [INFO] Configuring system environment variables...

set "PYTHON_DIR=%PYTHON_PATH%"
set "SCRIPT_DIR=%PYTHON_DIR%\Scripts"

:: Check if Python is already in PATH
echo %PATH% | find /i "%PYTHON_DIR%" >nul
if %errorLevel% neq 0 (
    echo [INFO] Adding Python to system PATH...
    setx PATH "%PATH%;%PYTHON_DIR%;%SCRIPT_DIR%" /M >nul
) else (
    echo [INFO] Python is already in PATH
)

:: Verify pip installation
echo.
echo [INFO] Verifying pip installation...
pip --version >nul 2>&1
if %errorLevel% equ 0 (
    pip --version
    echo.
    echo [SUCCESS] Python and pip installed successfully!
) else (
    echo [WARNING] Pip not working, trying to ensure pip...
    python -m ensurepip --default-pip >nul 2>&1
    python -m pip install --upgrade pip >nul 2>&1
    
    pip --version >nul 2>&1
    if %errorLevel% equ 0 (
        pip --version
        echo.
        echo [SUCCESS] Python and pip installed successfully!
    ) else (
        echo [ERROR] Pip installation failed!
    )
)

:: Final instructions
echo.
echo ========================================
echo         INSTALLATION COMPLETE
echo ========================================
echo.
echo [IMPORTANT] You may need to restart your command prompt
echo             or computer for PATH changes to take effect.
echo.
echo [QUICK TEST] Open a NEW command prompt and run:
echo             python --version
echo             pip --version
echo.

pause