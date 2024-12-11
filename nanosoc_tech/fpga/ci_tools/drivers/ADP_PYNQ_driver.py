from time import sleep, time
from pynq import MMIO

class ADP:
    def __init__(self, address):
        # HARDWARE CONSTANTS
        self.RX_FIFO = 0x00
        self.TX_FIFO = 0x04
        # Status Reg
        self.STAT_REG = 0x08
        self.RX_VALID = 0
        self.RX_FULL = 1
        self.TX_EMPTY = 2
        self.TX_FULL = 3
        self.IS_INTR = 4

        # Ctrl Reg
        self.CTRL_REG = 0x0C
        self.RST_TX = 0
        self.RST_RX = 1
        self.INTR_EN = 4
        # Setup axi core
        self.uart = MMIO(address, 0x10000, debug=False)
        self.address = address

    def setupCtrlReg(self):
#        # Reset FIFOs, disable interrupts
#        self.uart.write(CTRL_REG, 1 << RST_TX | 1 << RST_RX)
#        sleep(1)
        self.uart.write(self.CTRL_REG, 0)
        sleep(1)

    def monitorModeEnter(self):
        self.uart.write(self.TX_FIFO, 0x1b)

    def monitorModeExit(self):
        self.uart.write(self.TX_FIFO, 0x04)

    ##################################################################
    # read: Read a block from the Rx FIFO
    ##################################################################
    def read(self, length):
        # status = currentStatus(uart) bad idea
        buf = ""
        timeout=1
        stop_time = time() + timeout
        for i in range(length):
            # Wait till RX fifo has valid data, stop waiting if timeoutpasses
            while (not (self.uart.read(self.STAT_REG) & 1 << self.RX_VALID)) and (time() < stop_time):
                pass
            if time() >= stop_time:
                break
            buf += chr(self.uart.read(self.RX_FIFO))
            stop_time = time() + timeout

        return buf

    ##################################################################
    # write: Write a block of data to the Tx FIFO
    ##################################################################
    def write(self, buf):
        # Write bytes via UART
        timeout=1
        stop_time = time() + timeout
        wr_count = 0
        for i in buf:
            # Wait while TX FIFO is Full, stop waiting if timeout passes
            while (self.uart.read(self.STAT_REG) & 1 << self.TX_FULL) and (time() < stop_time):
                pass
            # Check timeout
            if time() > stop_time:
                wr_count = -1
                break
            self.uart.write(self.TX_FIFO, ord(i))
            wr_count += 1
            stop_time = time() + timeout
        return wr_count
    ##################################################################
    # readLine: Read a block from the Rx FIFO until newline character
    ##################################################################
    def readLine(self):
        buf = ""
        timeout = 1
        stop_time = time() + timeout
        stop=False
        while(not(stop)):
            while(not(self.checkReg(self.STAT_REG) & 1 << self.RX_VALID) and (time() < stop_time)):
                pass
            if time() > stop_time:
                break
            next_chr = chr(self.uart.read(self.RX_FIFO))
            buf += next_chr
            stop_time = time() + timeout
            if (next_chr == '\n'):
                stop = True
        return buf
    def write8(self, buf):
        # Write bytes via UART
        timeout=1
        stop_time = time() + timeout
        wr_count = 0
        while (self.uart.read(self.STAT_REG) & 1 << self.TX_FULL) and (time() < stop_time):
            pass
        # Check timeout
        if time() > stop_time:
            wr_count = -1
        self.uart.write(self.TX_FIFO, buf)
        wr_count += 1
        stop_time = time() + timeout
        return wr_count
    
    