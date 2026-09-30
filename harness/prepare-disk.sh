#!/bin/bash
# prepare-disk.sh: make the MVME187 disk from tenox's preinstalled R40V4.4 image.
#   GXEMUL  the patched gxemul (default: ./gxemul-0.7.0/gxemul)
#   ROM     the 187Bug 2.2 image, 4 MB or less (default: ./187bug2.2.bin)
#   IMAGE   Motorola_m88k_SYSVR4_FH40.44.preinstalled.img.lz, or the image already unpacked
#   WORK    where svr4-187.img, nvram.bin and prepare.log go (default: ./work)
# Needs expect, and lzip to unpack the image.
set -e
here=$(cd "$(dirname "$0")" && pwd)
export GXEMUL=$(realpath "${GXEMUL:-gxemul-0.7.0/gxemul}")
export ROM=$(realpath "${ROM:-187bug2.2.bin}")
IMAGE=$(realpath "${IMAGE:-Motorola_m88k_SYSVR4_FH40.44.preinstalled.img.lz}")
WORK=${WORK:-work}
mkdir -p "$WORK"
cd "$WORK"
case "$IMAGE" in
	*.lz) lzip -dc "$IMAGE" > svr4-187.img ;;
	*) cp "$IMAGE" svr4-187.img ;;
esac
rm -f nvram.bin
export DISK=svr4-187.img GXEMUL_NVRAM=nvram.bin
expect -f "$here/prepare-disk.exp" > prepare.log 2>&1 && ok=1 || ok=0
grep -a '^\*\*\* ' prepare.log
[ $ok = 1 ] && echo "ready: $WORK/svr4-187.img and $WORK/nvram.bin"
