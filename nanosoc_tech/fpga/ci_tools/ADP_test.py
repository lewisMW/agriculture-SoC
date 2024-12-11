import sys
from drivers/ADP_UART_driver import ADP

adp = ADP("COM7", 0x80020000)
adp.write32(adp.CTRL_REG,0x00)
print(adp.read(adp.RX_FIF0,100))

adp.write32(adp.TX_FIFO,0x1b)
print(adp.read(adp.RX_FIF0,500))
adp.write(adp.TX_FIFO,'A 0x00000000\nR 4\n')
print(adp.read(adp.RX_FIF0,500))
adp.write(adp.TX_FIFO,'A 0x10000000\nR 4\n')
print(adp.read(adp.RX_FIF0,500))
adp.write(adp.TX_FIFO,'A 0x20000000\nR 4\n')
print(adp.read(adp.RX_FIF0,100))
adp.write(adp.TX_FIFO,'A 0x20000000\nW 0x11223344\n')
print(adp.read(adp.RX_FIF0,100))
adp.write(adp.TX_FIFO,'A 0x20000000\nR 4\n')
print(adp.read(adp.RX_FIF0,100))


