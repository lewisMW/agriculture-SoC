#-----------------------------------------------------------------------------
# SoCLabs ADP Cocotb Drivers
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
#
# Copyright 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------
import cocotb
import os

# Class for ADP AXI Stream Interface
class ADP():
    def __init__(self, dut, send, recieve):
        self.dut         = dut
        self.log         = self.dut.log
        # Send Stream to NanoSoC
        self.send         = send
        # Send Recieve to NanoSoC
        self.recieve      = recieve
        self.monitor_mode = False
    
    # Logging Function
    def info(self, str):
        self.log.info(str.strip())
                
    # Reads Byte from ADP AXI Stream
    @cocotb.coroutine
    async def read8(self):
        # Read Byte from ADP AXI Stream
        data = await self.recieve.read()
        return chr(data[0])

    #Reads the echo'ed response from the ADP, after sending a command
    @cocotb.coroutine
    async def readecho(self, debug = False):
        received_str = ""
        while True:
            curr_char = await self.read8()
            received_str += curr_char
            if '\n\r]' in received_str:
                break
        if debug == True:
            self.info(repr(received_str))
        return repr(received_str)

    #Write to the ADP, and read the echo'ed feedback from the ADP
    @cocotb.coroutine
    async def command(self, buf, debug = False):
        #Writes the input string, buf, to the ADP
        for i in buf:
                await self.write8(ord(i))
        #Reads the echo'ed response from the ADP
        received_str = ""
        while True:
            curr_char = await self.read8()
            received_str += curr_char
            if '\n\r]' in received_str:
                break
        if debug == True:
            self.info(repr(received_str))
        return repr(received_str)

    # Writes Byte from ADP AXI Stream
    @cocotb.coroutine
    async def write8(self, val):
        await self.send.write([val])

    # Read ADP String
    @cocotb.coroutine
    async def readLine(self):
        read_str = ""
        while True:
            curr_char = await self.read8()
            # Combine Bytes into String
            if (curr_char not in ['\n',"\r"]):
                read_str += curr_char
            else:
                # Return on Newline/Carrige Return
                return read_str
                              
    # Write ADP String
    @cocotb.coroutine
    async def write_bytes(self, buf):
        for i in buf:      
            await self.write8(ord(i))
        
    # Enter Monitor Mode
    @cocotb.coroutine
    async def monitorModeEnter(self):
        self.dut.log.info("Entering ADP Monitor Mode")
        await self.write8(0x1b)
        await self.readecho()
        self.monitor_mode = True
        
    # Exit Monitor Mode
    @cocotb.coroutine
    async def monitorModeExit(self):
        self.dut.log.info("Exiting ADP Monitor Mode")
        await self.write8(0x04)
        self.monitor_mode = False
        
    # Read Block from ADP
    @cocotb.coroutine
    async def wait_response(self, debug=False):
        read_str = ""
        while read_str in ["", "]]"]:
            read_str = await self.readLine()
            if debug == True:
                self.info(read_str)
        return read_str

    # Read Block from ADP
    @cocotb.coroutine
    async def wait_string(self, string, debug=False):
        read_str = ""
        while read_str != string:
            read_str = await self.readLine()
            if debug == True:
                self.info(read_str)
        return read_str
        
    # Set ADP Address Pointer
    @cocotb.coroutine
    async def set_address(self, address):
        address_string = f"A {hex(address)}"
        await self.write_bytes(address_string)
        resp = await self.wait_response()
        # Ensure Address Read Back Matches that of what was sent
        assert resp.split()[1] == hex(address)
        self.info(f"ADP Address Pointer Set: {hex(address)}")
    
    # Write to the ADP
    @cocotb.coroutine
    async def w_command(self, message):
        await self.write_bytes(message)
        resp = await self.wait_response(debug = True)
        
    # Get ADP Current Address Pointer
    @cocotb.coroutine
    async def get_address(self):
        address_string = f"A"
        await self.write_bytes(address_string)
        resp = await self.wait_response(debug = True)
        # Ensure Address Read Back Matches that of what was sent
        assert resp.split()[0] == "]A"
        self.info(f"ADP Address Pointer: {resp.split()[1]}")
        return int(resp.split()[1],16)
        
    # Set Address to Read From
    @cocotb.coroutine
    async def read_bytes(self, reads):
        read_string = f"R {str(int(reads))}\n"
        await self.write_bytes(read_string)
        for i in range(reads):
            resp = await self.wait_response()
            self.info(resp)
        self.info(f"Performing {hex(reads)} Reads")
    
    # Write Hex File into System
    @cocotb.coroutine
    async def writeHex(self, file_name, address=0x20000000):
        self.dut.log.info(f"Writing {file_name} to {hex(address)}")
        file_stats = os.stat(file_name)
        file_len_in_bytes = round(file_stats.st_size/3)
        bytecount_hex=hex(file_len_in_bytes)
        await self.set_address(address)
        await self.write_bytes(f'U {str(bytecount_hex)}\n')
        count = file_len_in_bytes
        with open(file_name, mode='r') as file:
            for i in range(count) :
                b=file.readline()
                await self.write8(int(str.strip(b),16))
        await self.write8(0x0a)
        self.info(await self.wait_response())
        self.info("Finished Send Code")


