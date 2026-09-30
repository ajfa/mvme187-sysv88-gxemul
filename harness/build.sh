#!/bin/bash
# build.sh: unpack GXemul 0.7.0, apply the patches and build it.
#   GXEMUL_TAR  gxemul-0.7.0.tar.gz (default: ./gxemul-0.7.0.tar.gz)
#   DEST        build directory (default: ./gxemul-0.7.0)
# GXemul 0.7.0 needs -fgnu89-inline with a current gcc.
set -e
repo=$(cd "$(dirname "$0")/.." && pwd)
GXEMUL_TAR=$(realpath "${GXEMUL_TAR:-gxemul-0.7.0.tar.gz}")
DEST=${DEST:-gxemul-0.7.0}
if [ ! -d "$DEST" ]; then
	command -v patch > /dev/null || { echo "patch is needed" >&2; exit 1; }
	rm -rf "$DEST.tmp"
	mkdir -p "$DEST.tmp"
	tar -C "$DEST.tmp" --strip-components=1 -xzf "$GXEMUL_TAR"
	cat "$repo"/patches/*.patch | patch -d "$DEST.tmp" -p1 -s
	mv "$DEST.tmp" "$DEST"
	echo "patches applied"
fi
cd "$DEST"
CC="gcc -fgnu89-inline" ./configure > configure.log 2>&1
make -j"${JOBS:-4}" > make.log 2>&1
ls -l "$PWD"/gxemul "$PWD"/gxemul.exe 2>/dev/null || true
