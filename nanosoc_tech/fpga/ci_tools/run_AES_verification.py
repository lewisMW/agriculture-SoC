
from pynq.overlays.base import BaseOverlay
overlay = BaseOverlay("base.bit")
import os, warnings
from pynq import PL
from pynq import Overlay

ol = Overlay("/home/xilinx/pynq/overlays/soclabs/design_1.bit")

if not os.path.exists(PL.bitfile_name):
    warnings.warn('There is no overlay loaded after boot.', UserWarning)

ol = Overlay(PL.bitfile_name)
ol.download()
ol.timestamp
## 2. Examining the overlay
print(PL.bitfile_name)
print(PL.timestamp)

#PL.ip_dict
### Interrogate the HWH database for interface addresses
ADP_address = PL.ip_dict['cmsdk_socket/axi_stream_io_0']['phys_addr']
print("ADPIO stream interface: ",hex(ADP_address))
UART2_address = PL.ip_dict['cmsdk_socket/axi_uartlite_0']['phys_addr']
print("UART(2) interface: ",hex(UART2_address))
### Set up interface functions for ADP
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

    def wbyte(self, b, timeout=1):
        # Write bytes via UART
        while (self.uart.read(STAT_REG) & 1 << TX_FULL):
            pass
        self.uart.write_reg(TX_FIFO,int(b))
        return

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

    
adp = ADPIO(ADP_address)
# Setup AXI UART register
adp.setupCtrlReg()
print(adp.read(100))
### Enter ADP monitor mode ('ESC' char)
adp.monitorModeEnter()
print(adp.read(4))
uart = ADPIO(UART2_address)
# Setup AXI UART register
uart.setupCtrlReg()
uart.read(50)
adp.monitorModeEnter()
print(adp.read(4))
import os
file_name= "arm_tests/aes128_tests.bin"
file_stats= os.stat(file_name)
file_len_in_bytes = file_stats.st_size
print(f'file size in bytes is {file_len_in_bytes}')
bytecount_hex=hex(file_len_in_bytes)
print(f'file size in bytes is {bytecount_hex}')
print(f'U '+bytecount_hex+'\n')
adp.write('A 0x20000000\n')
adp.write('U '+bytecount_hex+'\n')
count = file_len_in_bytes
print(count)
with open(file_name, mode='rb') as file:
  while (count>0) :
    b=file.read(1)
    adp.wbyte(ord(b))
    count-=1
print(count)
print(adp.read(100))
adp.write('A 0x20000000\n')
adp.write('R 40\n')
print(adp.read(10000))
adp.write('C 0x200\n')
adp.write('C 0x201\n')
print(adp.read(10000))
