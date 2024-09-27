import sys
import os
from drivers.NanoSoC_Verification import NanoSoC_APD


NanoSoC = NanoSoC_APD()
NanoSoC.writeHex('binaries/uart_tests.hex')
print(NanoSoC.adp.read(500))
NanoSoC.adp.write('C 0x200\n')
NanoSoC.adp.write('C 0x201\n')
print(NanoSoC.adp.read(100000))
NanoSoC.adp.write('C 0x200\n')
NanoSoC.adp.write('C 0x201\n')
