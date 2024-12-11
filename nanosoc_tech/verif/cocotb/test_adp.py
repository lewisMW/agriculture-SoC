#-----------------------------------------------------------------------------
# SoCLabs Cocotb ADP Testcases
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
#
# Copyright 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------
from random import randint, randrange, getrandbits, shuffle
from collections.abc import Iterable

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
    adp_driver = setup_adp(dut)
    cocotb.start_soon(Clock(dut.CLK, *CLK_PERIOD).start())
    dut.NRST.value = 0
    await ClockCycles(dut.CLK, 2)
    dut.NRST.value = 1
    await ClockCycles(dut.CLK, 2)
    return adp_driver

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

@cocotb.coroutine
async def wait_prompt(dut, driver):
    bootcode_last = "]"
    while True:
        read_str = await driver.readLine()
        dut.log.info(read_str)
        if read_str == "bootcode_last":
            break

            
# Wait for bootcode to finish
@cocotb.coroutine
async def wait_hello(dut, driver):
    while True:
        read_str = await driver.readLine()
        dut.log.info(read_str)
        if chr(0x04) in read_str:
            dut.log.info(read_str)
            break

# Basic Test Clocks Test
@cocotb.test()
async def test_clocks(dut):
    """Tests Clocks and Resets in Cocotb"""
    log = logging.getLogger(f"cocotb.test")
    adp_driver = await setup_dut(dut, adp_driver)
    log.info("Setup Complete")

# Basic Test Reading from ADP
@cocotb.test()
async def test_adp_read(dut):
    adp_driver = await setup_dut(dut)
    dut.log.info("Setup Complete")
    dut.log.info("Starting Test")
    await wait_bootcode(dut, adp_driver)
    dut.log.info("ADP Read Test Complete")

@cocotb.test()
async def test_address_pointer(dut):
    adp_driver = await setup_dut(dut)
    dut.log.info("Setup Complete")
    dut.log.info("Starting Test")
    await wait_bootcode(dut, adp_driver)
    dut.log.info("Bootcode Finished")
    await adp_driver.monitorModeEnter()
    await adp_driver.write_bytes("A" + "0x30000000" "\n")
    await adp_driver.readecho(debug = True)
    await adp_driver.write_bytes("W" + "0x11" +"\n")
    await adp_driver.readecho(debug = True)

# Basic Test Write to ADP
@cocotb.test()
async def test_adp_write(dut):
    adp_driver = await setup_dut(dut)
    dut.log.info("Setup Complete")
    dut.log.info("Starting Test")
    await wait_bootcode(dut, adp_driver)
    dut.log.info("Bootcode Finished")
    await adp_driver.monitorModeEnter()
    test_str = "\n\r]"
    read_str = await adp_driver.read8()
    while read_str != test_str:
        read_str += await adp_driver.read8()
    dut.log.info(repr(read_str))
    
    dut.log.info(await adp_driver.wait_response())
    dut.log.info("Setting Address")
    await adp_driver.set_address(0x10000000)
    await adp_driver.get_address()
    await adp_driver.set_address(0x10000000)
    await adp_driver.read_bytes(4)
    adp_driver.info(await adp_driver.wait_response())
    await adp_driver.write_bytes('A 0x10000000\n')
    adp_driver.info(await adp_driver.wait_response())
    await adp_driver.write_bytes('A\n')
    adp_driver.info(await adp_driver.wait_response())
    await adp_driver.write('R 4\n')
    for i in range(2):
        dut.log.info(await adp_driver.readLine())
    dut.log.info("ADP Write Test Complete")
    
# Basic Software Load Test
@cocotb.test()
async def test_adp_hello(dut):
    hello_hex = os.environ.get("SOCLABS_PROJECT_DIR")+"/simulate/sim/hello/image.hex"
    adp_driver = await setup_dut(dut)
    dut.log.info("Setup Complete")
    dut.log.info("Starting Test")
    await wait_bootcode(dut, adp_driver)
    dut.log.info("Bootcode Finished")
    await adp_driver.monitorModeEnter()
    await adp_driver.writeHex(hello_hex, 0x20000000)
    adp_driver.info("Writen the hex")
    await adp_driver.monitorModeEnter()
    await adp_driver.get_address()
    await adp_driver.set_address(0x20000000)
    await adp_driver.read_bytes("R 4")
    await adp_driver.monitorModeExit()
    dut.NRST.value = 0
    await ClockCycles(dut.CLK, 2)
    dut.NRST.value = 1
    for i in range(4):
        adp_driver.info(adp_driver.readLine())
    await wait_hello(dut, adp_driver)
    dut.log.info("ADP Write Test Complete")



