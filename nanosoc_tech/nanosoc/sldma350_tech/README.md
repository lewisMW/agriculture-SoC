# SLDMA-350 Tech
Currently unverified - Use at own risk!

SLDMA-350 tech is used for configuring an ARM DMA-350 for either an AXI or AHB interface. To run the configuration excecute 'make config_ip_X' where X is either ahb or axi.

The AHB implementation uses a 32 bit data bus, and AXI uses a 128 bit. Although these can be changed by editing the cfg_dma_xxx.yaml files.
