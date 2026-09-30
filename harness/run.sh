#!/bin/bash
# run.sh: UNIX System V/88 R40V4.4 on the MVME187 with the real 187Bug, console in this
# terminal. A reboot from SVR4 makes GXemul exit with status 3 and it is started again;
# "shutdown -y -g0 -i0" ends it. Ctrl-C gives GXemul's debugger prompt ("quit" leaves).
#   GXEMUL, ROM, WORK as for prepare-disk.sh
#   GXEMUL_NAMESERVER  DNS server the emulated gateway forwards to (default: the host's)
GXEMUL=$(realpath "${GXEMUL:-gxemul-0.7.0/gxemul}")
ROM=$(realpath "${ROM:-187bug2.2.bin}")
cd "${WORK:-work}"
export GXEMUL_NVRAM=nvram.bin GXEMUL_EXIT_ON_HALT=1
if [ -z "$GXEMUL_NAMESERVER" ]; then
	export GXEMUL_NAMESERVER=$(awk '/^nameserver/ { print $2; exit }' /etc/resolv.conf 2>/dev/null)
fi
while :; do
	"$GXEMUL" -q -Q -e mvme187 -d svr4-187.img 0xff800000:0:0:"$ROM" 0:0:0:"$ROM"
	[ $? -eq 3 ] || break
	echo; echo "the MVME187 restarts..."; echo
done
