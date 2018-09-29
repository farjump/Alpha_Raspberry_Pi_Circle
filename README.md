<a href="https://farjump.io/" target="_blank"><img alt="Farjump Logo" src="https://cdn.rawgit.com/farjump/raspberry-pi/master/doc/img/logo-farjump.svg" width="50%" /></a>

Alpha <img alt="Alpha Logo" src="https://cdn.rawgit.com/farjump/raspberry-pi/master/doc/img/logo-alpha.svg" width="28" style="display: inline-block" />
======================

[GDB] offers the best embedded software development experience by
allowing you to remotely load, debug and test your programs and
hardware/software interfaces. It feels like native programming thanks
to a similar smooth "Edit-Compile-Run" cycle.

[Alpha] is a system-level [GDB] server (aka "gdbstub" and "gdb stubs")
allowing you to dynamically debug anything running in your hardware
target, from bare metal software to OS-backed programs, including
their threads, the underlying drivers, etc. All with a single GDB
session and **without any JTAG probe**.

This repository contains the freemium distribution of [Alpha] for any
version of the Raspberry Pi and can be used to debug Circle Software.


# Using Alpha for Circle software


## setup Raspberry

Connect an serial to usb converter to Rapsberry Pin 8, 10
and pin 6 for ground

## installing Alpha on rpi SDCARD.

Copy at the root filesystem of the sdcard at the same level as
bootcode.bin the two files :
config.txt and
Alpha.bin taken in the directory of your RPI model

## using Alpha

Clone [Circle] then copy load.gdb and armv6-core.xml file in
sample directory of [Circle]

It is recommanded to recompile Circle with a reasonable level of
optimization like -O1 or -Og or -O0 to ease debugging.

Then go to sample directory and launch command 
arm-none-eabi-gdb --nx 12-pwmsound/kernel.elf  --ex "so load.gdb"

And DEBUG your software.

It can also be interesting to add a cmdline.txt at root of the sdcard
with "logdev=ttyS1".
In this case Circle should use Raspberry Pi Uart to log info.
But because of Alpha, the log will be redirect to gdb console.

# Support

Support is provided through this repository's [issue board](https://github.com/farjump/raspberry-pi/issues).
Feel free to also [contact us][contact-us].


# Licensing

See [LICENSE](LICENSE) for the full license text.


[Alpha]: https://farjump.io
[GDB]: https://sourceware.org/gdb/current/onlinedocs/gdb/Summary.html
[newlib]: https://sourceware.org/newlib/
[write]: https://sourceware.org/gdb/current/onlinedocs/gdb/Assignment.html
[read]: https://sourceware.org/gdb/onlinedocs/gdb/Memory.html
[time-to-blink-a-led]: https://www.youtube.com/watch?v=niSBhjHa22I
[contact-us]: https://farjump.io/contact-us
[img-gdb-fileio]: https://cdn.rawgit.com/farjump/raspberry-pi/master/doc/img/gdb-fileio.svg
[img-rpi-embedded-dev]: https://cdn.rawgit.com/farjump/raspberry-pi/master/doc/img/rpi-embedded-dev.svg
[arm-toolchain]: https://developer.arm.com/open-source/gnu-toolchain/gnu-rm
[Circle]: https://github.com/rsta2/circle