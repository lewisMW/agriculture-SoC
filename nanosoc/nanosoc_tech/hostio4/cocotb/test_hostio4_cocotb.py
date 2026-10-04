##-----------------------------------------------------------------------------
## 4 channel 8-bit hostio transfer over 4-bit data bus
##
##  SoC Testbench
##
## A joint work commissioned on behalf of SoC Labs,
## under Arm Academic Access license.
##
## Contributors
##
## Design: David Flynn (dwflynn@soton.ac.uk)
##
## Packaging: Microsoft CoPilot AI agent support
##
## Copyright (c) 2024-6, SoC Labs (www.soclabs.org)
##-----------------------------------------------------------------------------

import cocotb
from cocotb.triggers import RisingEdge
from cocotb.clock import Clock
import random


async def reset(dut):
    dut.resetn.value = 0
    for _ in range(15):
        await RisingEdge(dut.clk)
    dut.resetn.value = 1
    for _ in range(5):
        await RisingEdge(dut.clk)

async def axis_write(clk, tvalid, tready, tdata, data_list):
    """Drive AXI4-Stream slave interface."""
    await RisingEdge(clk)
    for data in data_list:
        tdata.value = data
        tvalid.value = 1
        await RisingEdge(clk)
        # Wait until valid & ready
        while not tready.value:
            await RisingEdge(clk)
        tvalid.value = 0
    return

async def axis_read(clk, tvalid, tready, tdata, expected_count):
    """Read from AXI4-Stream master interface."""
    received = []
    await RisingEdge(clk)
    while len(received) < expected_count:
        tready.value = 1
        await RisingEdge(clk)
        if tvalid.value:
            received.append(int(tdata.value))
    tready.value = 0
    return received


async def axis_send(clk, tvalid, tready, tdata, byte, max_wait=10000):
    tdata.value = byte
    tvalid.value = 1
    for _ in range(max_wait):
        await RisingEdge(clk)
        if int(tready.value) == 1:
            await RisingEdge(clk)
            tvalid.value = 0
            return
    raise TimeoutError('Send timed out waiting for tready')


async def axis_sink(clk, tvalid, tready, tdata, max_wait=10000):
    tready.value = 1
    for _ in range(max_wait):
        await RisingEdge(clk)
        if int(tvalid.value) == 1:
            await RisingEdge(clk)
            byte = tdata.value
            tready.value = 0
            return byte
    raise TimeoutError('Sink timed out waiting for tvalid')


async def monitor_status_bits_active_high(dut, cycles=80000):
    fsm = dut.u_hostio4_target.u_hostio4_target_fsm
    while int(dut.resetn.value) == 0:
        await RisingEdge(dut.clk)
    for _ in range(cycles):
        await RisingEdge(dut.clk)
        if int(fsm.vcs_state.value):
            tx1 = int(fsm.tx1_xfer_pending.value)
            rx1 = int(fsm.rx1_xfer_pending.value)
            tx0 = int(fsm.tx0_xfer_pending.value)
            rx0 = int(fsm.rx0_xfer_pending.value)
            exp = (tx1 << 3) | (rx1 << 2) | (tx0 << 1) | rx0
            obs = int(dut.iodata4.value) & 0xF
            assert obs == exp, f"iodata4 status mismatch: obs={obs:04b} exp={exp:04b} (tx1 rx1 tx0 rx0)"


@cocotb.test()
async def hostio4_concurrent_buffer_test(dut):
    dut.resetn.value = 0
    print("**************************************************************************")
    print("* run 1000 bytes through 4 concurrent channels")
    print("* set top nibble to the channel number in order to catch misdirected data")
    print("* use 256 +/-1,2 varied buffer sizes")
    print("* calibrate number of clocks for synchronization across host/SoC interface")
    print("* Use inverted clock to Host/target to check domain crossing")
    print("* and determine number of protocol transitions per byte transfer")
    print("**************************************************************************")
    # avoid X's on stream ports at start of simulation
    dut.C_axis_rx0_tvalid.value = 0
    dut.C_axis_rx1_tvalid.value = 0
    dut.T_axis_rx0_tvalid.value = 0
    dut.T_axis_rx1_tvalid.value = 0
    dut.C_axis_tx0_tready.value = 0
    dut.C_axis_tx1_tready.value = 0
    dut.T_axis_tx0_tready.value = 0
    dut.T_axis_tx1_tready.value = 0
    # dummy values to check not transferred
    dut.C_axis_rx0_tdata8.value = 0xf0
    dut.C_axis_rx1_tdata8.value = 0xf1
    dut.T_axis_rx0_tdata8.value = 0xf2
    dut.T_axis_rx1_tdata8.value = 0xf3
    cocotb.start_soon(Clock(dut.clk, 10, units='ns').start())
## fill payloads, top nibble is test channel
    payload0 = [random.randrange(0x00, 0x10) for _ in range(248)]
    payload1 = [random.randrange(0x10, 0x20) for _ in range(249)]
    payload2 = [random.randrange(0x20, 0x30) for _ in range(251)]
    payload3 = [random.randrange(0x30, 0x40) for _ in range(252)]
    await reset(dut)

    cocotb.start_soon(monitor_status_bits_active_high(dut, cycles=20000))

    # Start AXI stream reader coroutines
    read_task0 = cocotb.start_soon(axis_read(dut.clk, dut.T_axis_tx0_tvalid, dut.T_axis_tx0_tready, dut.T_axis_tx0_tdata8, len(payload0)))
    read_task1 = cocotb.start_soon(axis_read(dut.clk, dut.T_axis_tx1_tvalid, dut.T_axis_tx1_tready, dut.T_axis_tx1_tdata8, len(payload1)))
    read_task2 = cocotb.start_soon(axis_read(dut.clk, dut.C_axis_tx0_tvalid, dut.C_axis_tx0_tready, dut.C_axis_tx0_tdata8, len(payload2)))
    read_task3 = cocotb.start_soon(axis_read(dut.clk, dut.C_axis_tx1_tvalid, dut.C_axis_tx1_tready, dut.C_axis_tx1_tdata8, len(payload3)))    # Start reader coroutines

    # Start AXI stream writer coroutines
    cocotb.start_soon(axis_write(dut.clk, dut.C_axis_rx0_tvalid, dut.C_axis_rx0_tready, dut.C_axis_rx0_tdata8, payload0))
    cocotb.start_soon(axis_write(dut.clk, dut.C_axis_rx1_tvalid, dut.C_axis_rx1_tready, dut.C_axis_rx1_tdata8, payload1))
    cocotb.start_soon(axis_write(dut.clk, dut.T_axis_rx0_tvalid, dut.T_axis_rx0_tready, dut.T_axis_rx0_tdata8, payload2))
    cocotb.start_soon(axis_write(dut.clk, dut.T_axis_rx1_tvalid, dut.T_axis_rx1_tready, dut.T_axis_rx1_tdata8, payload3))
    
    idle_count = 0
    cycle_count = 0
    finished = 0
    
    for _ in range(40000):
        await RisingEdge(dut.clk)
        if (finished == 0):
            cycle_count = cycle_count + 1
            if ((dut.ioreq1.value == 0) and (dut.ioreq2.value == 0) and (dut.ioack.value == 0)):
               idle_count = idle_count + 1
            else:
                idle_count = 0
            if (idle_count > 16) :
               finished = cycle_count - 10 - 8

    print("** Complete by cycle : ",finished)
    print("** clocks per byte transfer : ",finished/1000)
    print("** handshake transitions per byte transfer : ",finished/1000/3)

    print("* Inspect transferred payloads...")
    read_payload0 = await read_task0.join()
    read_payload1 = await read_task1.join()
    read_payload2 = await read_task2.join()
    read_payload3 = await read_task3.join()

    errors = 0

    assert read_payload0 == payload0, f"Mismatch: sent {payload0}, got {read_payload0}"
    assert read_payload1 == payload1, f"Mismatch: sent {payload1}, got {read_payload1}"
    assert read_payload2 == payload2, f"Mismatch: sent {payload2}, got {read_payload2}"
    assert read_payload3 == payload3, f"Mismatch: sent {payload3}, got {read_payload3}"

#    formatted_hex = list(map("{:02x}".format, payload0))
#    dut._log.info(f"AXI4-Stream C2H0 random transfer successful: {formatted_hex}")
#    formatted_hex = list(map("{:02x}".format, payload1))
#    dut._log.info(f"AXI4-Stream  random transfer successful: {formatted_hex}")
#    formatted_hex = list(map("{:02x}".format, payload2))
#    dut._log.info(f"AXI4-Stream random transfer successful: {formatted_hex}")
#    formatted_hex = list(map("{:02x}".format, payload3))
#    dut._log.info(f"AXI4-Stream random transfer successful: {formatted_hex}")
    
    if (payload0 != read_payload0):
        print("***FAIL*** C0->T0:",payload0,"->",read_payload0)
        errrors = errors +1
    if (payload1 != read_payload1):
        print("***FAIL*** C1->T1:",payload1,"->",read_payload1)
        errrors = errors +2
    if (payload2 != read_payload2):
        print("***FAIL*** T0->C0:",payload2,"->",read_payload2)
        errrors = errors +4
    if (payload3 != read_payload3):
        print("***FAIL*** T1->C1:",payload3,"->",read_payload3)
        errrors = errors +8
   
    if (errors == 0):
      print("*** PAYLOADS TEST PASSED OK ***")
      
