#!/bin/bash
# boot-test.sh: boot a copy of the prepared disk headless, log in, shut down.
#   GXEMUL, ROM, WORK as for prepare-disk.sh
set -e
here=$(cd "$(dirname "$0")" && pwd)
export GXEMUL=$(realpath "${GXEMUL:-gxemul-0.7.0/gxemul}")
export ROM=$(realpath "${ROM:-187bug2.2.bin}")
cd "${WORK:-work}"
cp svr4-187.img boot-test.img
cp nvram.bin boot-test-nvram.bin
export DISK=boot-test.img GXEMUL_NVRAM=boot-test-nvram.bin
expect -f "$here/boot-test.exp" > boot-test.log 2>&1 || true
rm -f boot-test.img boot-test-nvram.bin
tr -d '\r' < boot-test.log | sed -E 's/\[ [^]]*\]//g' | grep -a 'UNIX_System_V\|is alive\|^\*\*\* '
