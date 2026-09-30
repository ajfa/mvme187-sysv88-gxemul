MVME187 WITH UNIX SYSTEM V/88 RELEASE 4
=======================================

A Motorola MVME187 board (Motorola 88100 processor, 64 MB of RAM, NCR53C710
SCSI, Intel 82596 Ethernet) emulated by GXemul 0.7.0 with its own ROM,
187Bug, and with Motorola's UNIX installed on its disk:

  UNIX System V/88 Release 4, version R40V4.4 (copyright Motorola
  1991-1994; based on AT&T's System V Release 4, 1988-1990).
  187Bug 2.2, the board's ROM, from 14 January 1994.

Everything is inside the pack: there is nothing to install.


STARTING IT
-----------

Double click RUN.cmd.

That window is the MVME187's console. First the ROM (187Bug) shows up and
boots the disk by itself after 3 seconds; in less than a minute SVR4
reaches:

    Console Login:

  User:      root
  Password:  none (press Enter if it asks)

and you get the # prompt.


WHAT YOU CAN DO
---------------

- uname -a, ls, cc (the C compiler: it compiles and runs). No X Window.
- NETWORK: the board is 10.0.0.1 and reaches the Internet through GXemul
  (gateway 10.0.0.254). Names are resolved with the DNS server Windows
  uses. Try:

      ping www.netbsd.org 5
      telnet www.netbsd.org 80

  Connections go OUT only: Windows cannot connect to the MVME187.


SHUTTING DOWN (without damaging the disk)
-----------------------------------------

1. At the # prompt type:

       cd /; shutdown -y -g0 -i0

2. SVR4 stops its services (about 20 seconds) and ends with:

       NOTICE: System Halt Requested
       NOTICE: System secured for powering down.
       [ CPU halted: GXemul exits ]

   GXemul exits by itself and the window says "GXemul has exited
   (status 0)". Press a key and the window closes.

If you type just "shutdown", SVR4 asks "Do you want to continue? (y or n)"
and waits ONE MINUTE before it starts (the warning for other users). It
has not hung. With -y -g0 it neither asks nor waits.

Do not close the window with the X while SVR4 is running: the disk would
be left dirty and the next boot would have to repair it.


RESTARTING
----------

       cd /; shutdown -y -g0 -i6

At the end "[ VMEchip2: system reset ]" and "The MVME187 restarts..." show
up: the launcher powers the board on again and it boots by itself.


EMERGENCY EXIT (if SVR4 hangs)
------------------------------

Press Ctrl-C: the "GXemul>" prompt shows up. Type quit and Enter. Windows
asks "Terminate batch job (Y/N)?": answer Y. The next boot repairs the
disk (see below).


MESSAGES THAT SOUND LIKE ERRORS AND ARE NOT
-------------------------------------------

From the ROM, at power on:

  WARNING: Can not calculate MPU Clock Speed, RTC not operating
      NOT AN ERROR. 187Bug tries to measure the processor speed against
      the board's clock and in the emulator the numbers do not add up.
      Nothing depends on it.

  Autoboot in progress... To abort hit <BREAK>
      It is the automatic boot. There is no BREAK key in this window, so
      it cannot be stopped: there is no need to.

From SVR4, when it starts:

  WARNING: No holiday file in /etc/acct/database for year 2026
  WARNING: Linking to last holiday file in database
  TO FIX: Please check your system date or ask your
  TO FIX: system administrator to create a new database
  TO FIX: file for /etc/acct/database/holiday.2026
      NOT ERRORS. SVR4's accounting has no holiday calendar for the
      current year and uses the last one it has.

  you have mail
      There is mail for root on the disk. Read it with: mail

Only after an emergency exit, or closing with the X:

  ***** FILE SYSTEM WAS MODIFIED *****
  *** ROOT REMOUNTED ***
  SUMMARY INFORMATION BAD
      NOT ERRORS. It is fsck repairing the disk that was not closed
      properly. The boot goes on by itself.

The messages in brackets, like "[ VMEchip2: system reset ]" or
"[ CPU halted: GXemul exits ]", come from GXemul, not from SVR4.


WHAT IS IN THE PACK
-------------------

RUN.cmd                 the launcher
emulator\gxemul.exe     GXemul 0.7.0 with the MVME187 patches, built for
                        Windows with MSYS2
emulator\msys-2.0.dll   MSYS2's runtime library
rom\187bug2.2.bin       the MVME187's ROM (187Bug 2.2)
disk\svr4-187.img       the hard disk (SCSI 0) with SVR4 installed, 520 MB
disk\nvram.bin          the board's non-volatile memory (187Bug's
                        settings, with the automatic boot enabled)
licenses\               licenses and the patches to GXemul
