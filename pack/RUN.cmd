@echo off
title MVME187 - UNIX System V/88 Release 4 (GXemul 0.7.0)
cd /d "%~dp0"
set GXEMUL_NVRAM=disk/nvram.bin
set GXEMUL_EXIT_ON_HALT=1
set GXEMUL_NAMESERVER=
for /f "usebackq delims=" %%a in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "$r = Get-NetRoute -DestinationPrefix 0.0.0.0/0 -ErrorAction SilentlyContinue | Sort-Object RouteMetric | Select-Object -First 1; if ($r) { (Get-DnsClientServerAddress -InterfaceIndex $r.ifIndex -AddressFamily IPv4).ServerAddresses | Select-Object -First 1 }"`) do set GXEMUL_NAMESERVER=%%a
:start
emulator\gxemul.exe -q -Q -e mvme187 -d disk/svr4-187.img 0xff800000:0:0:rom/187bug2.2.bin 0:0:0:rom/187bug2.2.bin
if %errorlevel%==3 (
  echo.
  echo The MVME187 restarts...
  echo.
  goto start
)
echo.
echo GXemul has exited (status %errorlevel%). Press a key to close this window.
pause >nul
