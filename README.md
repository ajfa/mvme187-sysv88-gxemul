# Motorola MVME187 with UNIX System V/88 R4 in GXemul

Patches to GXemul 0.7.0 that make its MVME187 (Motorola 88100 VME board) run
the real 187Bug 2.2 monitor and Motorola's UNIX System V/88 Release 4
(R40V4.4) from a SCSI disk, to the console login, with networking. Before
them, GXemul ran the MVME187 without its ROM and only as far as OpenBSD
needed.

No Motorola software is included here. The system comes from tenox's
preinstalled image
<https://tenox.pdp-11.net/os/motorola/Motorola_m88k_SYSVR4_FH40.44.preinstalled.img.lz>,
and the ROM is a dump of 187Bug 2.2 (01/14/94) from a real board, which you
have to supply.

    Autoboot in progress... To abort hit <BREAK>
    Booting from: VME187, Controller 0, Drive 0
    Loading: Operating System
    ...
    Console Login: root
    # uname -a
    UNIX_System_V moto 4.0 R40V4.4 m88k mc88100
    # ping gateway
    gateway is alive

## What works

- 187Bug 2.2: its board data and environment in a battery backed NVRAM file,
  I/O inquiry, auto boot from the SCSI disk.
- SVR4 R40V4.4 in multiuser: login, the compiler, `ps`, `df`, and a clean
  `shutdown`. A reboot from SVR4 restarts the emulator.
- The Ethernet interface, with GXemul's user mode network: SVR4 reaches the
  Internet through the host, DNS included, with no host setup.

## What it took

About thirty changes: the 88100 CPU, the 88200 MMU, bus errors, the 53C710
SCSI controller running SVR4's own SCRIPTS, the CD2401 serial controller,
PCC2, VMEchip2, the MK48T08 NVRAM and clock, and a new 82596 Ethernet device.
They are in [docs/HARDWARE.md](docs/HARDWARE.md).

## Layout

    patches/    changes to GXemul 0.7.0, by area
    harness/    build, disk preparation, boot test, run
    pack/       launcher and README of the Windows pack
    docs/       what was worked out

## Building

Get <https://gavare.se/gxemul/src/gxemul-0.7.0.tar.gz> and:

    GXEMUL_TAR=gxemul-0.7.0.tar.gz harness/build.sh

It unpacks GXemul into `gxemul-0.7.0/`, applies the patches and builds it.
GXemul 0.7.0 needs `-fgnu89-inline` with a current gcc; the script sets it.
For Windows, see `harness/build-windows.sh` (MSYS2).

## The disk

With `expect` and `lzip` installed, the 187Bug image as `187bug2.2.bin` and
the preinstalled image downloaded:

    harness/prepare-disk.sh

It fills a new NVRAM (board data, environment, auto boot), then boots the
image three times: SVR4 rebuilds its kernel for the MVME187, `/etc/vfstab` is
fixed in single user, and in multiuser the network is set up for GXemul's
gateway. The result is `work/svr4-187.img` and `work/nvram.bin`. Root has no
password.

    harness/boot-test.sh
    harness/run.sh

`boot-test.sh` boots a copy headless, logs in, pings the gateway and shuts
down. `run.sh` runs it with the console in your terminal. To shut down, as
root:

    cd /; shutdown -y -g0 -i0

## Windows pack

[pack/](pack) has the launcher and the README of a Windows pack: `gxemul.exe`
from `build-windows.sh` with `msys-2.0.dll` in `emulator/`, the ROM in `rom/`,
and the disk and NVRAM in `disk/`.

## License

BSD-3-Clause, see [LICENSE](LICENSE), the same as GXemul, whose files the
patches change.
