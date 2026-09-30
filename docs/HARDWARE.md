# What was worked out

GXemul 0.7.0 emulated the MVME187 only as far as OpenBSD/mvme88k needs it, and
without its ROM. Running the real 187Bug 2.2 and Motorola's UNIX System V/88
Release 4 took the changes below. Most were found by booting SVR4, with the
symbols of its kernel, and following it where it stopped.

## The board and the ROM (`08-mvme187-machine.patch`, `06-pcc2-vmechip2-nvram.patch`)

- 187Bug is loaded at 0xff800000 and again at 0 (for the reset vectors), with
  `-Q` so that GXemul does not emulate a PROM of its own. The boot EPROM and the
  128 KB SRAM at 0xffe00000 are mapped.
- VMEchip2, 88200, MEMC040, PCC2, CD2401 and 53C710 stopped GXemul on any
  register they did not know; now the value is kept.
- MK48T08: multibyte accesses, the NVRAM kept in the file `$GXEMUL_NVRAM` up to
  0x1ff8 (the board data checksum is at 0x1ff0), and a clock that runs unless
  the READ or WRITE bit is set.
- PCC2 timers count emulated time. With the host clock every run was different.
- A reset from SVR4 sets the VMEchip2 SRST bit; GXemul then exits with status 3,
  and the run scripts start it again. With `GXEMUL_EXIT_ON_HALT` set, the
  halt at the end of a shutdown exits with status 0.

## 88100 (`01-m88100-cpu.patch`)

- `int`, `nint`, `sub` with overflow, scaled `ld.b`, `.wt` (ignored).
- 0x00000000 is `xmem.bu r0,...`, a no-op. SVR4's loaders jump into headers
  padded with zeros.
- `fadd`, `fsub`, `fmul`, `fdiv` in every single and double combination.
- PSR bits 27 to 4 are reserved and read as 0. SVR4 saves the PSR with the
  interrupt level ORed in and restores that level from it; with garbage in
  those bits every resumed process ran at spl7 ("trap type 3 return at spl7").

## Memory and MMU (`02-memory-bus-errors.patch`, `03-m88200-cmmu.patch`)

- A bus error outside RAM. Without it the kernel clears memory forever.
- The 88200 FLUSH line and segment commands. `resume` uses them, and
  `hat_asload` hung without them.

## 53C710 SCSI (`04-53c710-scsi.patch`)

SVR4 runs its own SCRIPTS, with far more of the chip than OpenBSD uses:
MEMORY MOVE through the physical bus; WAIT RESELECT and SIGP (CTEST2 bit 6,
cleared by reading it); register operations 5, 6 and 7 with the chip's own
register numbering, where operator 3 is XOR and 4 is AND; JUMP comparing data
and carry; SFBR with the first byte of every input phase; selection timeout;
direct MOVE; phase mismatch; CALL saving the return address in TEMP; wide
accesses to byte registers; SCRIPTS fetched from outside main RAM. And the
code GXemul has translated from pages the DMA writes has to be thrown away,
or programs loaded from `/usr` crash.

## CD2401 serial (`05-cd2401-serial.patch`)

- GFRCR, STK, STCR special characters, and MSVR with CD, DSR and CTS set:
  without carrier `/dev/console` does not open and everything goes silent.
- The interrupt context in STK (receive, transmit, modem) when the PCC2 gives
  the vector, closed by the matching EOI register.
- The acknowledge loads CAR with the interrupting channel and the EOI puts the
  old value back. Without that, when 187Bug leaves CAR on another channel the
  SVR4 console echo goes to the wrong one and the console is mute after login.

## 82596 Ethernet (`07-82596-ethernet.patch`)

A new device: the 82596CA in the linear mode SVR4 uses (transmit command
without header, the whole frame in the TBD, flexible 16-byte RFDs whose RBD
pointer the chip carries from frame to frame), on the PCC2 IE interrupt line.
It is connected to GXemul's user mode network: the guest is 10.0.0.1 and the
gateway 10.0.0.254. SVR4's `gethostbyname` wants a PTR record for every
address, so when the real server says NXDOMAIN the gateway's DNS makes one up.
`GXEMUL_NAMESERVER` chooses the DNS server the gateway forwards to.

## 187Bug with a blank NVRAM

`prepare-disk.exp` fills the NVRAM from nothing, and three things are needed:

- `cnfg;m`, the factory board data. The one that matters is "Local SCSI
  Identifier = 07": without it 187Bug finds no SCSI device and `bo 0` gives
  "Boot Logic Error, Packet Status 0200".
- `env;d` for the defaults, then `env` again with "Bug or System environment"
  set to B. In the System environment 187Bug runs its full memory self test on
  every power up, which takes many minutes in the emulator.
- Auto boot from controller 0, device 0, not only at power up. It takes effect
  at the next cold start. Setting "Probe System for Supported I/O Controllers"
  to Y makes the auto boot hang.

187Bug says "Can not calculate MPU Clock Speed, RTC not operating" at every
start; it is harmless.

## The disk

tenox's preinstalled R40V4.4 image was made on an MVME197. On its first boot
SVR4 sees the change, rebuilds `/stand/unix` for the MVME187 and reboots. The
second boot stops in single user because `/etc/vfstab` names `m197_` devices;
`prepare-disk.exp` changes them to `m187_` (the original stays as
`/etc/vfstab.m197`). The third boot reaches multiuser, where it sets up the
network for GXemul's gateway: `/etc/hosts`, `/etc/resolv.conf` and a default
route started from `/etc/rc2.d/S70defroute`.

## Tracing

`GXEMUL_DEVDEBUG` shows the device warnings, and `I596_DEBUG`, `OSIOP_DEBUG`,
`CLMPCC_DEBUG` and `PCC2_DEBUG` trace one device each. `GXEMUL_SPLWATCH` was
the watch that found the PSR problem: `GXEMUL_SPLWATCH=r1:va,va,...` keeps a
ring of reads and writes of those kernel words and dumps it when one is
written with that value of r1.
