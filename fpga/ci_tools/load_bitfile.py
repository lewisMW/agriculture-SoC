import os, warnings
from pynq import PL
from pynq import Overlay

ol = Overlay("/home/xilinx/pynq/overlays/soclabs/nanosoc_design.bit")

if not os.path.exists(PL.bitfile_name):
    warnings.warn('There is no overlay loaded after boot.', UserWarning)

ol = Overlay(PL.bitfile_name)

ol.download()

if ol.is_loaded():
	print("Overlay Loaded")
else:
	print("Overlay failed to load")
