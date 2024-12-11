from random import randint, randrange, getrandbits, shuffle
from collections.abc import Iterable

import numpy as np
import os
import logging
import cocotb
from cocotb.clock import Clock
from cocotb.regression import TestFactory
from cocotb.result import TestFailure
from cocotb.triggers import ClockCycles, Combine, Join, RisingEdge

from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamMonitor
from adp_cocotb_driver import ADP

CLK_PERIOD = (10, "ns")

# Control ADP AXI Stream bus and create ADP Driver Object
def setup_adp(dut):
    logging.getLogger("cocotb.nanosoc_tb.rxd8").setLevel(logging.WARNING)
    logging.getLogger("cocotb.nanosoc_tb.txd8").setLevel(logging.WARNING)
    adp_sender = AxiStreamSource(AxiStreamBus.from_prefix(dut, "txd8"), dut.CLK, dut.NRST, reset_active_level=False)
    adp_reciever = AxiStreamSink(AxiStreamBus.from_prefix(dut, "rxd8"), dut.CLK, dut.NRST, reset_active_level=False)
    driver = ADP(dut, adp_sender, adp_reciever)
    driver.write8(0x00)
    return driver

# Start Clocks and Reset System
@cocotb.coroutine
async def setup_dut(dut):
    adp = setup_adp(dut)
    cocotb.start_soon(Clock(dut.CLK, *CLK_PERIOD).start())
    dut.NRST.value = 0
    await ClockCycles(dut.CLK, 2)
    dut.NRST.value = 1
    await ClockCycles(dut.CLK, 2)
    return adp

# Wait for bootcode to finish
@cocotb.coroutine
async def wait_bootcode(dut, driver):
    bootcode_last = "** Remap->IMEM0"
    received_str = ""
    while True:
        read_char = await driver.read8()
        received_str += read_char
        if bootcode_last in received_str:
            break
    dut.log.info(received_str)

@cocotb.test()
async def random_address_read_write(dut):
    adp = await setup_dut(dut)
    dut.log.info("Setup Complete")
    dut.log.info("Starting Test")
    await wait_bootcode(dut, adp)
    dut.log.info("Bootcode Finished")
    await adp.monitorModeEnter()

    #setup complete, can interface with the design

    length = 0xF

    test_vector_data = np.random.randint(0, 0xFFFFFFFF, size = length)
    test_vector_address = np.random.randint(0x30000000, 0x3FFFFFFF, size = length)

    read_values = []
    i = 1

    for address, data in zip(test_vector_address, test_vector_data):
        await adp.command('A'+ hex(address) + '\n',debug = True) #Set base address
        await adp.command('W' + hex(data) + '\n', debug = True) #Write to the specified address

    dut.log.info("Writing Complete")

    for address, data in zip(test_vector_address, test_vector_data):
        await adp.command('A'+ hex(address) + '\n', debug = True)
        b = await adp.command('R\n', debug = True)  #Start reading the data starting from the base address
        read_values.append(b[2:13]) 

    dut.log.info("Reading Complete")

    for data1, data2 in zip(test_vector_data, read_values):
        assert data1 == int(data2,16) , f"Assertion failed: {hex(data1)} is not equal to {data2} on iteration {i}" 
        i += 1
