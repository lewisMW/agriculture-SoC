import os, sys
from progress.bar import Bar
if os.environ["BOARD"] == 'MPS3':
    from .ADP_UART_driver import ADP
elif os.environ["BOARD"] == "ZCU104":
    from .ADP_PYNQ_driver import ADP

class NanoSoC_APD:
    def __init__(self):
        self.adp = ADP(0x80020000)
        print(self.adp.read(100))
        self.adp.setupCtrlReg()
        print(self.adp.read(100))
        self.adp.monitorModeEnter()
        print(self.adp.read(10))

    ##################################################################
    # writeHex: write a hex file to iRAM
    ##################################################################       
    def writeHex(self,file_name):
        file_stats = os.stat(file_name)
        file_len_in_bytes = round(file_stats.st_size/3)
        print(f'file size in bytes is {file_len_in_bytes}')
        bytecount_hex=hex(file_len_in_bytes)
        self.adp.write('A 0x20000000\n')
        print(self.adp.read(100))
        self.adp.write('U ' +bytecount_hex+'\n')
        print(self.adp.read(100))
        count = file_len_in_bytes
        with open(file_name, mode='r') as file:
            with Bar('Uploading...', max=count) as bar:
                for i in range(count) :
                    b=file.readline()
                    self.adp.write8(int(str.strip(b),16))
                    bar.next()
        print(self.adp.read(100))

