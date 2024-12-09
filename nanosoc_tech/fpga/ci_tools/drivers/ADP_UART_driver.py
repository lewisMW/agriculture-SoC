import serial
from time import time

class ADP:
    def __init__(self, base_addr = 0x80020000, iface = '/dev/ttyUSB2', baud = 115200):
        self.interface  = iface
        self.baud       = baud
        self.uart       = None
        self.prog_cb    = None
        self.CMD_WRITE  = 0x10
        self.CMD_READ   = 0x11
        self.MAX_SIZE   = 255
        self.BLOCK_SIZE = 128
        self.GPIO_ADDR  = 0xF0000000
        self.STS_ADDR   = 0xF0000004
        self.BASE_ADDR  = base_addr
        self.RX_FIFO    = 0x00
        self.TX_FIFO    = 0x04
        self.STAT_REG   = 0x08
        self.CTRL_REG   = 0x0C
        self.RX_VALID   = 0
        self.TX_FULL    = 3

    ##################################################################
    # connect: Open serial connection
    ##################################################################
    def connect(self):
        self.uart = serial.Serial(
            port=self.interface,
            baudrate=self.baud,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            bytesize=serial.EIGHTBITS
        )
        self.uart.isOpen()

        # Check status register
        value = self.checkStatus()
        if ((value & 0xFFFF0000) != 0xcafe0000):
            raise Exception("Target not responding correctly, check interface / baud rate...")
        
    ##################################################################
    # checkStatus: Read status of the UART to AXI 
    ##################################################################     
    def checkStatus(self):
        addr = self.STS_ADDR
        cmd = bytearray([self.CMD_READ, 
                         4, 
                        (addr >> 24) & 0xFF, 
                        (addr >> 16) & 0xFF, 
                        (addr >> 8) & 0xFF, 
                        (addr >> 0) & 0xFF])
        self.uart.write(cmd)

        value = 0
        idx   = 0
        while (idx < 4):
            b = self.uart.read(1)
            value |= (ord(b) << (idx * 8))
            idx += 1

        return value
    ##################################################################
    # read8: Read a byte from the RX_FIFO
    ##################################################################
    def read8(self):
        offset = self.RX_FIFO;
        # Connect if required
        if self.uart == None:
            self.connect()

        addr = self.BASE_ADDR+offset
        # Send read command
        cmd = bytearray([self.CMD_READ, 
                         4, 
                        (addr >> 24) & 0xFF, 
                        (addr >> 16) & 0xFF, 
                        (addr >> 8) & 0xFF, 
                        (addr >> 0) & 0xFF])
        self.uart.write(cmd)

        value = 0
        idx   = 0
        while (idx < 4):
            b = self.uart.read(1)
            value |= (ord(b) << (idx * 8))
            idx += 1

        return value

    ##################################################################
    # write8: Write a byte to a the Tx FIFO
    ##################################################################
    def write8(self, value):
        offset = self.TX_FIFO
        # Connect if required
        if self.uart == None:
            self.connect()

        addr = self.BASE_ADDR + offset

        # Send write command
        cmd = bytearray([self.CMD_WRITE,
                         4, 
                        (addr >> 24)  & 0xFF, 
                        (addr >> 16)  & 0xFF, 
                        (addr >> 8)   & 0xFF, 
                        (addr >> 0)   & 0xFF, 
                        (value >> 0)  & 0xFF, 
                        (0)  & 0xFF, 
                        (0)  & 0xFF, 
                        (0)  & 0xFF])
        self.uart.write(cmd)

    ##################################################################
    # write: Write a block of data to the Tx FIFO
    ##################################################################
    def write(self, buf):
        timeout = 1
        # Connect if required
        if self.uart == None:
            self.connect()

        stop_time = time() + timeout
        wr_count = 0
        for i in buf:
            while (self.checkReg(self.STAT_REG) & 1 << self.TX_FULL) and (time() < stop_time):
                pass
            if time() > stop_time:
                wr_count = -1
                break
            self.write8(ord(i))
            wr_count += 1
        return wr_count

    ##################################################################
    # read: Read a block from the Rx FIFO
    ##################################################################
    def read(self, length):
        addr = self.RX_FIFO
        # Connect if required
        if self.uart == None:
            self.connect()

        buf = ""
        timeout = 1
        stop_time = time() + timeout
        for i in range(length):
            while(not(self.checkReg(self.STAT_REG) & 1 << self.RX_VALID) and (time() < stop_time)):
                pass
            if time() > stop_time:
                break
            buf += chr(self.read8())
            stop_time = time() + timeout

        return buf
    
    ##################################################################
    # readLine: Read a block from the Rx FIFO until newline character
    ##################################################################
    def readLine(self):
        if self.uart == None:
            self.connect()

        buf = ""
        timeout = 1
        stop_time = time() + timeout
        stop=False
        while(not(stop)):
            while(not(self.checkReg(self.STAT_REG) & 1 << self.RX_VALID) and (time() < stop_time)):
                pass
            if time() > stop_time:
                break
            next_chr = chr(self.read8())
            buf += next_chr
            stop_time = time() + timeout
            if (next_chr == '\n'):
                stop = True
        return buf
    
    ##################################################################
    # checkReg: Read char from offset (self.CTRL_REG or self.STAT_REG)
    ##################################################################
    def checkReg(self,offset):
        # Connect if required
        if self.uart == None:
            self.connect()

        addr = self.BASE_ADDR+offset
        # Send read command
        cmd = bytearray([self.CMD_READ, 
                         4, 
                        (addr >> 24) & 0xFF, 
                        (addr >> 16) & 0xFF, 
                        (addr >> 8) & 0xFF, 
                        (addr >> 0) & 0xFF])
        self.uart.write(cmd)

        value = 0
        idx   = 0
        while (idx < 4):
            b = self.uart.read(1)
            value |= (ord(b) << (idx * 8))
            idx += 1

        return value

    ##################################################################
    # writeReg: Write char to offset (self.CTRL_REG or self.STAT_REG)
    ##################################################################  
    def writeReg(self,offset,value):
        # Connect if required
        if self.uart == None:
            self.connect()

        addr = self.BASE_ADDR + offset

        # Send write command
        cmd = bytearray([self.CMD_WRITE,
                         4, 
                        (addr >> 24)  & 0xFF, 
                        (addr >> 16)  & 0xFF, 
                        (addr >> 8)   & 0xFF, 
                        (addr >> 0)   & 0xFF, 
                        (value >> 0)  & 0xFF, 
                        (0)  & 0xFF, 
                        (0)  & 0xFF, 
                        (0)  & 0xFF])
        self.uart.write(cmd)

    def setupCtrlReg(self):
        self.writeReg(self.CTRL_REG,0x00)

    def monitorModeEnter(self):
        self.writeReg(self.TX_FIFO,0x1b)

    def monitorModeExit(self):
        self.writeReg(self.TX_FIFO,0x04)