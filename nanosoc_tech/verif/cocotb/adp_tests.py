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

#Bit toggle Coverage, making sure each bit on the bus can toggle at the same time
@cocotb.test()
async def bit_toggle_address(dut):
    adp = await setup_dut(dut)
    dut.log.info("Setup Complete")
    dut.log.info("Starting Test")
    await wait_bootcode(dut, adp)
    dut.log.info("Bootcode Finished")
    await adp.monitorModeEnter()
    
    debug = True
    random_value = random.getrandbits(32)
    random_value_string = format(random_value, '08x')

    set_address = await adp.command('A' + random_value_string + '\n', debug)
    read_address = await adp.command('A' + '\n', debug)
    assert set_address == read_address, f'set_address: {set_address} not equal to read_address: {read_address}'

    random_value = random_value ^ ((1 << random_value.bit_length()) - 1)
    random_value_string = format(random_value, '08x')
    
    set_address = await adp.command('A' + random_value_string + '\n', debug)
    read_address = await adp.command('A' + '\n', debug)
    assert set_address == read_address, f'set_address: {set_address} not equal to read_address: {read_address}'



#Walking-1 Coverage, to measure activity covered by bus connectivity tests, and one-hot state or bus encoding coverage
@cocotb.test()
async def address_test_walking1(dut):
    adp = await setup_dut(dut)
    dut.log.info("Setup Complete")
    dut.log.info("Starting Test")
    await wait_bootcode(dut, adp)
    dut.log.info("Bootcode Finished")
    await adp.monitorModeEnter()

    debug = True
    address = 0b00000000000000000000000000000001
    end_address = 0x9FFFFFFF

    while address <= end_address:
        address_str = hex(address)
        address_str = address_str[:2] + address_str[2:].rjust(8,'0')
        set_address = await adp.command('A' + address_str + '\n', debug)
        read_address = await adp.command('A' + '\n', debug)
        assert set_address == read_address, f'set_address: {set_address} not equal to read_address: {read_address}'
        address = address << 1

#Shifting the most significant bit to the left, with the bits below being randomized
@cocotb.test()
async def address_test_pof2(dut):
    adp = await setup_dut(dut)
    dut.log.info("Setup Complete")
    dut.log.info("Starting Test")
    await wait_bootcode(dut, adp)
    dut.log.info("Bootcode Finished")
    await adp.monitorModeEnter()

    debug = False
    power = 2
    address = 0b00000000000000000000000000000010
    end_address = 0x9FFFFFFF

    set_address = await adp.command('A' + '0x00000001' + '\n', debug)
    read_address = await adp.command('A' + '\n', debug)
    assert set_address == read_address, f'set_address: {set_address} not equal to read_address: {read_address}'

    while address <= end_address:
        dut.log.info(f"{bin(address)}")
        address_str = hex(address)
        address_str = address_str[:2] + address_str[2:].rjust(8,'0')
        set_address = await adp.command('A' + address_str + '\n', debug)
        read_address = await adp.command('A' + '\n', debug)
        assert set_address == read_address, f'set_address: {set_address} not equal to read_address: {read_address}'
        address = (2 ** power) + random.getrandbits(power - 1)
        power += 1

#Write words, half words, bytes and read back as words, half words and bytes
@cocotb.test()
async def write_read_test(dut):
    adp = await setup_dut(dut)
    dut.log.info("Setup Complete")
    dut.log.info("Starting Test")
    await wait_bootcode(dut, adp)
    dut.log.info("Bootcode Finished")
    await adp.monitorModeEnter()
    
    debug = False

    #Write a word, and read it back as bytes, half words, and a word and see if they match up
    
    random_value = format(random.getrandbits(32), '08x')
    read_word = ""
    await adp.command('A' + '0x30000000' + '\n')
    await adp.command('W'+ '0x' + str(random_value) + '\n', debug)
    
    await adp.command('A' + '0x30000000' + '\n')
    for _ in range(4):
        read_byte = await adp.command('R' + '0x01' + '\n', debug)
        read_byte = read_byte[::-1]
        read_word += read_byte[6:8]
    read_word = read_word[::-1]
    assert read_word == random_value,f'Read Word = {read_word}, Random Value = {random_value}'

    read_word = ""
    await adp.command('A' + '0x30000000' + '\n')
    for _ in range(2):
        read_hw = await adp.command('R' + '0x0001' + '\n', debug)
        read_hw = read_hw[::-1]
        read_word += read_hw[6:10]
    read_word = read_word[::-1]
    assert read_word == random_value,f'Read Word = {read_word}, Random Value = {random_value}'

    await adp.command('A' + '0x30000000' + '\n', debug)
    read_word = await adp.command('R' + '0x000000001' +'\n', debug)
    assert read_word[5:13] == random_value,f'Read Word = {read_word[5:13]}, Random Value = {random_value}'

    #Write a word as  half word, and read it back as bytes, half words, and a word and see if they match up

    random_value = format(random.getrandbits(32), '08x')
    read_word = ""
    await adp.command('A' + '0x30000000' + '\n')
    await adp.command('W'+ '0x' + str(random_value[4:8]) + '\n', debug)
    await adp.command('W'+ '0x' + str(random_value[0:4]) + '\n', debug)

    await adp.command('A' + '0x30000000' + '\n')
    for _ in range(4):
        read_byte = await adp.command('R' + '0x01' + '\n', debug)
        read_byte = read_byte[::-1]
        read_word += read_byte[6:8]
    read_word = read_word[::-1]
    assert read_word == random_value,f'Read Word = {read_word}, Random Value = {random_value}'

    read_word = ""
    await adp.command('A' + '0x30000000' + '\n')
    for _ in range(2):
        read_hw = await adp.command('R' + '0x0001' + '\n', debug)
        read_hw = read_hw[::-1]
        read_word += read_hw[6:10]
    read_word = read_word[::-1]
    assert read_word == random_value,f'Read Word = {read_word}, Random Value = {random_value}'

    await adp.command('A' + '0x30000000' + '\n', debug)
    read_word = await adp.command('R' + '0x000000001' +'\n', debug)
    assert read_word[5:13] == random_value,f'Read Word = {read_word[5:13]}, Random Value = {random_value}'

    #Write a word as bytes, and read it back as bytes, half words, and a word and see if they match up

    random_value = format(random.getrandbits(32), '08x')
    read_word = ""
    await adp.command('A' + '0x30000000' + '\n')
    await adp.command('W'+ '0x' + str(random_value[6:8]) + '\n', debug)
    await adp.command('W'+ '0x' + str(random_value[4:6]) + '\n', debug)
    await adp.command('W'+ '0x' + str(random_value[2:4]) + '\n', debug)
    await adp.command('W'+ '0x' + str(random_value[0:2]) + '\n', debug)

    await adp.command('A' + '0x30000000' + '\n')
    for _ in range(4):
        read_byte = await adp.command('R' + '0x01' + '\n', debug)
        read_byte = read_byte[::-1]
        read_word += read_byte[6:8]
    read_word = read_word[::-1]
    assert read_word == random_value,f'Read Word = {read_word}, Random Value = {random_value}'

    read_word = ""
    await adp.command('A' + '0x30000000' + '\n')
    for _ in range(2):
        read_hw = await adp.command('R' + '0x0001' + '\n', debug)
        read_hw = read_hw[::-1]
        read_word += read_hw[6:10]
    read_word = read_word[::-1]
    assert read_word == random_value,f'Read Word = {read_word}, Random Value = {random_value}'

    await adp.command('A' + '0x30000000' + '\n', debug)
    read_word = await adp.command('R' + '0x000000001' +'\n', debug)
    assert read_word[5:13] == random_value,f'Read Word = {read_word[5:13]}, Random Value = {random_value}'

