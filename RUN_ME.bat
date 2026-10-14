@echo off
title Java Practice Programs - All In One Launcher
cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0launcher.ps1"

echo.
echo   Launcher band ho gaya.
pause