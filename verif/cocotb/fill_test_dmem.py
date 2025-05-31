import random
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
async def test_fill(dut):
    adp = await setup_dut(dut)
    dut.log.info("Setup Complete")
    dut.log.info("Starting Test")
    await wait_bootcode(dut, adp)
    dut.log.info("Bootcode Finished")
    await adp.monitorModeEnter()

    #setup complete, can interface with the design
    
    def count_substring_occurrences(full_string, substring):
        return full_string.count(substring)

    address = 0x30000000
    address_increment = 0x4
    iteration = 1
    fill_value = random.randint(0, 0xFFFFFFFF)
    
    while address <= (0x30000000 + 4*address_increment):
        fill_value = hex(random.randint(0, 0xFFFFFFFF))
        fill_value = fill_value[:2] + fill_value[2:].rjust(8, '0')

        v = await adp.command('V' + fill_value + '\n', debug = True)

        a = await adp.command('A'+ hex(address) + '\n', debug = True)

        f = await adp.command('F' + repr(address_increment) + '\n', debug = True)

        a = await adp.command('A'+ hex(address) + '\n', debug = True)

        r = await adp.command('R'+ '0x00000000'+ repr(address_increment) +'\n', debug = True)

        c = count_substring_occurrences(r, f"R {fill_value}")

        assert hex(c) == hex(address_increment), f'range {hex(address + address_increment)} to {hex(address)} failed the test, count = {c} '
        address += address_increment
        iteration += 1
