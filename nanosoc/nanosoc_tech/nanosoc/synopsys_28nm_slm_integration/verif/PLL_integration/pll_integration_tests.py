import itertools
import logging
import os
from numpy import random
import numpy as np

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer, ClockCycles
from cocotb.regression import TestFactory

from cocotbext.ahb import AHBLiteMaster, AHBBus

class TB:
    def __init__(self,dut):
        self.dut = dut
        
        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)
        cocotb.start_soon(Clock(dut.HCLK, 10, units="ns").start())
        self.config_ahb_master = AHBLiteMaster(AHBBus.from_prefix(dut,"config", optional_signals = {"hsel":"HSEL", "hready_in":"HREADY_IN", "hburst":"HBURST"}), dut.HCLK, dut.HRESETn)

    async def cycle_reset(self):
        self.dut.HRESETn.setimmediatevalue(0)
        await ClockCycles(self.dut.HCLK,20)
        self.dut.HRESETn.setimmediatevalue(1)
        await ClockCycles(self.dut.HCLK,10)
            

async def PLL_internal_reg_test(dut, tb):
    tb.log.info("Testing PLL Internal regs")
    
    lower_regs = [0x44, 0x00, 0x00, 0x00, 0x05]
    
    for x in range(len(lower_regs)):
        addr = 0x200 + x*4
        PLL_int_reg = await tb.config_ahb_master.read(addr,4)
        assert int(PLL_int_reg[0]['data'],0) == lower_regs[x]
    
    upper_regs = [0x02, 0x01, 0xFF, 0x07, 0x02, 0x02, 0x32, 0x32]
    
    for x in range(len(upper_regs)):
        addr = 0x240 + x*4
        PLL_int_reg = await tb.config_ahb_master.read(addr,4)
        assert int(PLL_int_reg[0]['data'],0) == upper_regs[x]

    await tb.config_ahb_master.write(addr, 0x35)
    PLL_int_reg = await tb.config_ahb_master.read(addr,4)
    assert int(PLL_int_reg[0]['data'],0) == 0x35

    tb.log.info("Internal reg checks successful")

async def PLL_change_fb_div(dut, tb):
    tb.log.info("Test changing fb divider")
    tb.log.info("Set pwr off")
    await tb.config_ahb_master.write(0, 0x00)

    curr_settings = await tb.config_ahb_master.read(0x08,4)
    curr_settings = int(curr_settings[0]['data'],0)
    curr_settings = curr_settings ^ 0x01
    await tb.config_ahb_master.write(0x08, curr_settings)
    await PLL_enable(dut,tb)
    
    
async def PLL_enable(dut, tb):
    # set pwron and gear shift reg
    tb.log.info("Set pwron and gear shift reg")
    tmp = 1<<8
    tmp += 1<<7
    await tb.config_ahb_master.write(0, tmp)
    
    tb.log.info("Wait before releasing reset...")
    await ClockCycles(dut.HCLK,4000)
    tb.log.info("...release reset")
    tmp += 1<<9
    await tb.config_ahb_master.write(0, tmp)
    
    tb.log.info("Wait to enable PLL")
    await ClockCycles(dut.HCLK,4000)
    tb.log.info("... enabling PLL")
    tmp += 1<<4
    tmp += 1<<5
    await tb.config_ahb_master.write(0, tmp)
    
    tb.log.info("Wait for PLL lock...")
    PLL_LOCK = await tb.config_ahb_master.read(24,4)
    tb.log.info(PLL_LOCK[0]['data'])
    while (int(PLL_LOCK[0]['data'],0) == 0):
        await ClockCycles(dut.HCLK,50)
        PLL_LOCK = await tb.config_ahb_master.read(24,4)
    
    tb.log.info("... PLL locked")

    
@cocotb.test()
async def PLL_test1(dut):  
    tb = TB(dut)
    await tb.cycle_reset()
    PLL_ID = await tb.config_ahb_master.read(20,4)
    print(PLL_ID[0]['data'])

    await PLL_enable(dut, tb)
    
    await PLL_internal_reg_test(dut, tb)
    await PLL_change_fb_div(dut, tb)