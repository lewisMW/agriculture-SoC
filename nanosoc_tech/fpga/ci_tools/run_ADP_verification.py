import os, warnings
from pynq import PL
from pynq import Overlay

from pynq import Overlay
from pynq import MMIO
import time
from time import sleep, time

# HARDWARE CONSTANTS
RX_FIFO = 0x00
TX_FIFO = 0x04
# Status Reg
STAT_REG = 0x08
RX_VALID = 0
RX_FULL = 1
TX_EMPTY = 2
TX_FULL = 3
IS_INTR = 4

# Ctrl Reg
CTRL_REG = 0x0C
RST_TX = 0
RST_RX = 1
INTR_EN = 4

class ADPIO:
    def __init__(self, address):
        # Setup axi core
        self.uart = MMIO(address, 0x10000, debug=False)
        self.address = address

    def setupCtrlReg(self):
#        # Reset FIFOs, disable interrupts
#        self.uart.write(CTRL_REG, 1 << RST_TX | 1 << RST_RX)
#        sleep(1)
        self.uart.write(CTRL_REG, 0)
        sleep(1)

    def monitorModeEnter(self):
        self.uart.write(TX_FIFO, 0x1b)

    def monitorModeExit(self):
        self.uart.write(TX_FIFO, 0x04)

    def read(self, count, timeout=1):
        # status = currentStatus(uart) bad idea
        buf = ""
        stop_time = time() + timeout
        for i in range(count):
            # Wait till RX fifo has valid data, stop waiting if timeoutpasses
            while (not (self.uart.read(STAT_REG) & 1 << RX_VALID)) and (time() < stop_time):
                pass
            if time() >= stop_time:
                break
            buf += chr(self.uart.read(RX_FIFO))
        return buf
    
    def write(self, buf, timeout=1):
        # Write bytes via UART
        stop_time = time() + timeout
        wr_count = 0
        for i in buf:
            # Wait while TX FIFO is Full, stop waiting if timeout passes
            while (self.uart.read(STAT_REG) & 1 << TX_FULL) and (time() < stop_time):
                pass
            # Check timeout
            if time() > stop_time:
                wr_count = -1
                break
            self.uart.write(TX_FIFO, ord(i))
            wr_count += 1
        return wr_count

    

ol = Overlay("/home/xilinx/pynq/overlays/soclabs/design.bit")
ol = Overlay(PL.bitfile_name)
ADP_address = PL.ip_dict['cmsdk_socket/axi_stream_io_0']['phys_addr']
print("ADPIO stream interface: ",hex(ADP_address))

adp = ADPIO(ADP_address)
# Setup AXI UART register
adp.setupCtrlReg()
print(adp.read(100))

adp.monitorModeEnter()
print(adp.read(4))

adp.write('A\n')
print(adp.read(100))

adp.write('A 0x10000000\nR 4\n')
print(adp.read(100))

adp.write('A 0x30000000\nR\nR \n')
print(adp.read(100))

adp.write('A 0x30000000\nW 0x11111111\nW22222222\n')
print(adp.read(100))

adp.write('A 0x30000000\nR 3\n')
print(adp.read(100))

adp.write('A 0x50000000\nW 0x11111111\nW22222222\n')
print(adp.read(100))

adp.write('A 0x50000000\nR 2\n')
print(adp.read(100))

adp.write('A 10000000\nM 0xF0000000\nV 0\nP 4000\n')
print(adp.read(100))
adp.write('A 10000000\nM\nV 30000000\nP 2000\n')
print(adp.read(100))

adp.write('A 90000000\nV 0x87654321\nF 400\nA\nW FFFFFFFF\n')
print(adp.read(100))

adp.write('A 0x90000000\nR 3\n')
print(adp.read(100))
adp.write('A 0x90000FFC\nr 0003\n\nA\n')
print(adp.read(100))

adp.write('S 0x31\n\n')
print(adp.read(100))

adp.monitorModeExit()
print(adp.read(100))
