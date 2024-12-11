import os, warnings
from pynq import PL
from pynq import Overlay
import os
from drivers.NanoSoC_Verification import NanoSoC_APD

log = open("verification_log",'w')
tests = open("fpga_tests",'r')
ol = Overlay("/home/xilinx/pynq/overlays/soclabs/nanosoc_design.bit")

if not os.path.exists(PL.bitfile_name):
    warnings.warn('There is no overlay loaded after boot.', UserWarning)

ol = Overlay(PL.bitfile_name)

ol.download()

if ol.is_loaded():
	print("Overlay Loaded")
	log.write("Overlay Load Test: PASSED\n")
	NanoSoC = NanoSoC_APD()
	for lines in tests:
		ol.download()
		NanoSoC = NanoSoC_APD()
		li=lines.strip()
		li = li.split('/')
		testname = li[2]
		testfile = li[3]
		print("Running test: " + testfile)
		NanoSoC.writeHex("binaries/" + testfile)
		print(NanoSoC.adp.read(500))
		NanoSoC.adp.write('C 0x200\n')
		NanoSoC.adp.write('C 0x201\n')
		buf = (NanoSoC.adp.read(1000000))
		print(buf)
		if "PASSED" in buf:
			log.write(testfile + ": PASSED\n")
		elif "SKIPPED" in buf:
			log.write(testfile + ": SKIPPED\n")
		else:
			log.write(testfile + ": FAILED\n")
else:
	print("Overlay failed to load")
	log.write("Overlay Load Test: FAILED\n")
print("ALL TESTS FINISHED")
log.close()



