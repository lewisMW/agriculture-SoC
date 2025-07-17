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
        await ClockCycles(self.dut.HCLK,30)
            



async def wait_reg0_write(dut, tb):
    tb.log.info("Wait for write ack reg0")
    reg1 = await tb.config_ahb_master.read(0x04,4)
    reg1 = int(reg1[0]['data'],16)
    while ((reg1 & (1<<16))==0):
        await ClockCycles(dut.HCLK,2)
        reg1 = await tb.config_ahb_master.read(0x04,4)
        reg1 = int(reg1[0]['data'],16)

    tb.log.info("Wait for write ack low reg0")
    while ((reg1 & (1<<16))!=0):
        await ClockCycles(dut.HCLK,2)
        reg1 = await tb.config_ahb_master.read(0x04,4)
        reg1 = int(reg1[0]['data'],16)

async def wait_reg2_write(dut, tb):
    tb.log.info("Wait for write ack reg2")
    reg1 = await tb.config_ahb_master.read(0x04,4)
    reg1 = int(reg1[0]['data'],16)
    while ((reg1 & (1<<24))==0):
        await ClockCycles(dut.HCLK,2)
        reg1 = await tb.config_ahb_master.read(0x04,4)
        reg1 = int(reg1[0]['data'],16)
        
    tb.log.info("Wait for write ack low reg2")
    while ((reg1 & (1<<24))!=0):
        await ClockCycles(dut.HCLK,2)
        reg1 = await tb.config_ahb_master.read(0x04,4)
        reg1 = int(reg1[0]['data'],16)

async def VM_read_APB_regs(dut, tb):
    reg0 = await tb.config_ahb_master.read(0x00,4)
    reg1 = await tb.config_ahb_master.read(0x04,4)
    reg2 = await tb.config_ahb_master.read(0x08,4)
    reg3 = await tb.config_ahb_master.read(0x0C,4)

    tb.log.info("Reg 0: 0x%0x", int(reg0[0]['data'],16))
    tb.log.info("Reg 1: 0x%0x", int(reg1[0]['data'],16))
    tb.log.info("Reg 2: 0x%0x", int(reg2[0]['data'],16))
    tb.log.info("Reg 3: 0x%0x", int(reg3[0]['data'],16))

async def VM_enable_clk(dut,tb):
    tb.log.info("Enabling VM clock and power up")
    reg0 = await tb.config_ahb_master.read(0x00,4)
    reg0 = int(reg0[0]['data'],16)
    reg0 = reg0 ^ 2
    await tb.config_ahb_master.write(0x00,reg0)
    await wait_reg0_write(dut,tb)
    reg0 = await tb.config_ahb_master.read(0x00,4)
    tb.log.info("Reg 0: 0x%0x", int(reg0[0]['data'],16))
    await ClockCycles(dut.HCLK,5000)

    tb.log.info("Releasing VM reset")
    reg0 = int(reg0[0]['data'],16)
    reg0 = reg0 ^ (1<<16)
    await tb.config_ahb_master.write(0x00,reg0)
    await wait_reg0_write(dut,tb)
    reg0 = await tb.config_ahb_master.read(0x00,4)
    tb.log.info("Reg 0: 0x%0x", int(reg0[0]['data'],16))


async def VM_run_once(dut,tb):
    tb.log.info("Running VM")
    reg0 = await tb.config_ahb_master.read(0x00,4)
    reg0 = int(reg0[0]['data'],16)
    reg0 = reg0 ^ 1
    await tb.config_ahb_master.write(0x00,reg0)
    await wait_reg0_write(dut,tb)

    reg0 = reg0 ^ 1
    await tb.config_ahb_master.write(0x00,reg0)
    await wait_reg0_write(dut,tb)

    tb.log.info("Wait for conversion")
    reg0 = await tb.config_ahb_master.read(0x00,4)
    reg0 = int(reg0[0]['data'],16)
    while ((reg0 &(1<<24))==0):
        reg0 = await tb.config_ahb_master.read(0x00,4)
        reg0 = int(reg0[0]['data'],16)
    tb.log.info("Conversion finished")
    
    reg1 = await tb.config_ahb_master.read(0x04,4)
    reg1 = int(reg1[0]['data'],16)

    v_out = 1.224*(reg1+1)/256
    tb.log.info("Output is: 0x%x - %f",reg1, v_out)
    
    reg0 = await tb.config_ahb_master.read(0x00,4)
    reg0 = int(reg0[0]['data'],16)
    reg0 = reg0 ^ (1<<3)
    await tb.config_ahb_master.write(0x00,reg0)
    await wait_reg0_write(dut,tb)
    reg0 = await tb.config_ahb_master.read(0x00,4)
    reg0 = int(reg0[0]['data'],16)
    reg0 = reg0 ^ (1<<3)
    await tb.config_ahb_master.write(0x00,reg0)
    await wait_reg0_write(dut,tb)


async def VM_run_once_irq(dut,tb):
    tb.log.info("Running VM with irq")
    reg0 = await tb.config_ahb_master.read(0x00,4)
    reg0 = int(reg0[0]['data'],16)
    reg0 = reg0 ^ 1
    await tb.config_ahb_master.write(0x00,reg0)
    await wait_reg0_write(dut,tb)

    reg0 = reg0 ^ 1
    await tb.config_ahb_master.write(0x00,reg0)
    await wait_reg0_write(dut,tb)

    tb.log.info("Wait for conversion")
    while dut.irq_vm_rdy.value==0:
        await ClockCycles(dut.HCLK,30)
    tb.log.info("Conversion finished")
    
    reg1 = await tb.config_ahb_master.read(0x04,4)
    reg1 = int(reg1[0]['data'],16)

    v_out = 1.224*(reg1+1)/256
    tb.log.info("Output is: 0x%x - %f",reg1, v_out)
    
    reg0 = await tb.config_ahb_master.read(0x00,4)
    reg0 = int(reg0[0]['data'],16)
    reg0 = reg0 ^ (1<<3)
    await tb.config_ahb_master.write(0x00,reg0)
    await wait_reg0_write(dut,tb)
    reg0 = await tb.config_ahb_master.read(0x00,4)
    reg0 = int(reg0[0]['data'],16)
    reg0 = reg0 ^ (1<<3)
    await tb.config_ahb_master.write(0x00,reg0)
    await wait_reg0_write(dut,tb)

async def VM_set_an(dut,tb,n):
    tb.log.info("Set voltage input to %d",n)
    reg2 = await tb.config_ahb_master.read(0x08,4)
    reg2 = int(reg2[0]['data'],16)
    reg2 = reg2 & 0xFFFFFFF0
    reg2 = reg2 | (1<<3) 
    reg2 = reg2 | (n)   
    await tb.config_ahb_master.write(0x08,reg2)
    await wait_reg2_write(dut,tb)

@cocotb.test()
async def VM_test1(dut):
    tb = TB(dut)
    await tb.cycle_reset()
    VM_ID = await tb.config_ahb_master.read(0x0C,4)
    tb.log.info("VM_ID: 0x%0x", int(VM_ID[0]['data'],16))
    assert int(VM_ID[0]['data'],16) == 0x736E766D
    
    await VM_read_APB_regs(dut, tb)
    await VM_enable_clk(dut,tb)
    await VM_run_once(dut,tb)
    await VM_run_once_irq(dut,tb)
    await VM_set_an(dut,tb,0)
    await VM_run_once_irq(dut,tb)
    await VM_set_an(dut,tb,1)
    await VM_run_once_irq(dut,tb)
    await VM_set_an(dut,tb,2)
    await VM_run_once_irq(dut,tb)
