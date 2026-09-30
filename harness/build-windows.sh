#!/bin/bash
# build-windows.sh: Windows build with MSYS2, from an MSYS2 "MSYS" shell (gcc, make and
# patch from the msys repository, not mingw64: pacman -S gcc make patch):
#   bash harness/build-windows.sh
# The result, gxemul.exe, needs msys-2.0.dll from MSYS2's /usr/bin next to it.
# Same variables as build.sh.
set -e
here=$(cd "$(dirname "$0")" && pwd)
bash "$here/build.sh"

