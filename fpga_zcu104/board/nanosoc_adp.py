"""
Minimal, self-contained ADP (soclabs debug protocol) driver for the ZCU104.

Talks to the NanoSoC debug socket through the axi_stream_io block that the
FPGA build maps into the Zynq PS address space at 0x8002_0000. The register
interface is AXI-UARTLITE-shaped: byte-wide RX/TX FIFOs plus a status register.
Bytes written here come out of the ADP controller inside the NanoSoC socket,
which is an AHB *master* on the M0's system bus — so this driver can read and
write any address the Cortex-M0 can see (SRAM, the sensing peripheral at
0x6000_0000, ...) without any firmware running.

Unlike nanosoc_tech/fpga/ci_tools/drivers/, this has no dependency on the
`progress` pip package or the BOARD environment variable.

ADP command set (from socdebug_adp_tech socdebug_adp_control.v):
    A <addr>   set address pointer            C <ctrl>   system-control GPO
    R          read word at pointer, addr++   W <data>   write word, addr++
    S          status / stdin                 X          exit monitor mode
    U <count>  binary upload <count> bytes to addr++
    C encoding: 0x1NN clear GPO bits NN, 0x2NN set bits NN, 0x3NN overwrite.
The byte stream multiplexes ADP replies with the SoC's stdout; ESC (0x1b)
enters ADP monitor mode, 0x04 (EOT) leaves it.

Run on the board, as root, inside the pynq venv (see BOARD_BRINGUP.md).
"""

import re
import sys
from time import sleep, time

from pynq import MMIO

ADP_BASE = 0x80020000

# axi_stream_io register map (uartlite-compatible)
RX_FIFO = 0x00
TX_FIFO = 0x04
STAT_REG = 0x08
CTRL_REG = 0x0C
RX_VALID = 1 << 0
TX_FULL = 1 << 3

HEX_TOKEN = re.compile(r"0[xX]([0-9a-fA-F]+)")


class ADP:
    def __init__(self, address=ADP_BASE):
        self.mmio = MMIO(address, 0x10000, debug=False)
        self.mmio.write(CTRL_REG, 0)
        sleep(0.2)

    # ------------------------------------------------------------- raw I/O
    def read(self, length=4096, timeout=1.0):
        """Read up to `length` chars; returns early after `timeout` s of silence."""
        buf = ""
        deadline = time() + timeout
        while len(buf) < length:
            if self.mmio.read(STAT_REG) & RX_VALID:
                buf += chr(self.mmio.read(RX_FIFO) & 0xFF)
                deadline = time() + timeout
            elif time() > deadline:
                break
        return buf

    def write_byte(self, b, timeout=1.0):
        deadline = time() + timeout
        while self.mmio.read(STAT_REG) & TX_FULL:
            if time() > deadline:
                raise TimeoutError("ADP TX FIFO stuck full — is the overlay loaded?")
        self.mmio.write(TX_FIFO, b & 0xFF)

    def write(self, s):
        for ch in s:
            self.write_byte(ord(ch))

    # -------------------------------------------------------- monitor mode
    def monitor_enter(self):
        """ESC drops the stream into ADP monitor mode; returns the banner/echo."""
        self.write_byte(0x1B)
        return self.read(256, timeout=0.5)

    def monitor_exit(self):
        """EOT (0x04) leaves monitor mode; stdout passthrough resumes."""
        self.write_byte(0x04)

    # ----------------------------------------------------------- commands
    def cmd(self, line, timeout=1.0):
        """Send one ADP command line, return the echoed reply."""
        self.write(line + "\n")
        return self.read(512, timeout=timeout)

    def read_word(self, addr):
        self.cmd("A 0x%08X" % addr)
        reply = self.cmd("R 4")
        tokens = HEX_TOKEN.findall(reply)
        if not tokens:
            raise IOError("no data in ADP read reply: %r" % reply)
        return int(tokens[-1], 16)

    def write_word(self, addr, value):
        self.cmd("A 0x%08X" % addr)
        self.cmd("W 0x%08X" % (value & 0xFFFFFFFF))

    # ------------------------------------------------------ firmware load
    def upload_hex(self, path, base=0x20000000, log=sys.stdout):
        """Upload a byte-per-line Verilog hex file (the .hex the testcode
        makefiles emit) into memory at `base` using the binary U command.

        Counts non-empty lines instead of trusting the file size, so CRLF
        line endings (a classic Windows/zip-transfer casualty) can't skew
        the byte count the way ci_tools' size/3 heuristic does."""
        with open(path) as f:
            data = [ln.strip() for ln in f]
        data = [ln for ln in data if ln]
        nbytes = len(data)
        log.write("Uploading %d bytes to 0x%08X\n" % (nbytes, base))
        self.cmd("A 0x%08X" % base)
        self.write("U 0x%X\n" % nbytes)
        self.read(64, timeout=0.5)  # swallow the echo before raw bytes
        for i, ln in enumerate(data):
            self.write_byte(int(ln, 16))
            if i % 4096 == 4095:
                log.write("  %d / %d\n" % (i + 1, nbytes))
                log.flush()
        log.write("Upload done.\n")
        return self.read(256, timeout=0.5)

    def start_core(self):
        """Release the M0 to run the uploaded image. `C 0x200` reports/flushes
        the sys-control GPO, `C 0x201` sets bit0 — the go/boot-release signal.
        This is the exact sequence soclabs' own CI uses on this bitstream."""
        self.cmd("C 0x200")
        return self.cmd("C 0x201")

    # ----------------------------------------------------------- console
    def stream(self, seconds=60, idle=5.0, stop_tokens=("PASSED", "FAILED"),
               log=sys.stdout):
        """Relay SoC stdout for up to `seconds`, stopping early after `idle`
        seconds of silence or when a stop token has been seen. Returns the
        full captured text."""
        buf = ""
        end = time() + seconds
        deadline = time() + idle
        while time() < end:
            if self.mmio.read(STAT_REG) & RX_VALID:
                ch = chr(self.mmio.read(RX_FIFO) & 0xFF)
                buf += ch
                log.write(ch)
                log.flush()
                deadline = time() + idle
                if any(t in buf for t in stop_tokens):
                    # tail: give trailing output a moment to arrive
                    tail = self.read(4096, timeout=1.0)
                    buf += tail
                    log.write(tail)
                    log.flush()
                    break
            elif time() > deadline:
                break
        return buf
