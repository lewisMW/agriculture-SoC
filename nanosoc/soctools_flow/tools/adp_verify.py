#-----------------------------------------------------------------------------
# ADP Command File Verification Script
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
#
# Copyright � 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

class address_region():
    def __init__(self, base, size):
        self.base = base
        self.size = size
        self.end = base + size - 4

class read_word():
    def __init__(self, index, region, address, read_data = 0,exp_data = 0):
        self.index = index
        self.region = region
        self.address = int(str(address), 16)
        self.read_data = int(str(read_data), 16)
        self.exp_data = int(str(exp_data), 16)
    
    def validate(self):
        if (self.address >= self.region.base and self.address <= self.region.end):
            return True
        else:
            return False
    
    def check_address(self, address):
        # print(f"self: {hex(self.address)} test: {address}")
        if (self.address == int(str(address), 16)):
            return True
        else:
            return False
    
    def set_read_data(self, read_data):
        self.read_data = int(read_data, 16)

    def set_exp_data(self, exp_data):
        self.exp_data = int(exp_data, 16)
    
    def verify(self):
        assert (self.read_data == self.exp_data)

def adp_verify(adp_input, adp_output, out_log):
    # Create Input Region for Accelerator
    accel_input_port  = address_region(base = 0x6001_0000, size = 0x0000_0800)
    accel_output_port = address_region(base = 0x6001_0800, size = 0x0000_0800)

    word_list = []
    temp_address_buf = 0x0

    # Read in adp input
    adp_input_lines = open(adp_input, "r").readlines()
    idx = 0
    for line in adp_input_lines:
        line_split = str(line).split()
        if len(line_split) > 1:
            if line_split[0].lower() == "a":
                # Capture Address
                temp_address_buf = line_split[1]
            if line_split[0].lower() == "r":
                temp_read_word = read_word(idx, accel_output_port, temp_address_buf, exp_data = line_split[1])
                if temp_read_word.validate():
                    word_list.append(temp_read_word)
                    idx += 1

    # Read in adp output
    adp_output_lines = open(adp_output, "r").readlines()
    idx = 0
    temp_address_buf = 0x0
    for line in adp_output_lines:
        line_split = str(line).split()
        if len(line_split) > 1:
            if line_split[0] == "]A":
                # Capture Address
                temp_address_buf = line_split[1]
            if line_split[0] == "]R":
                if word_list[idx].check_address(temp_address_buf):
                    word_list[idx].set_read_data(line_split[1])
                    idx += 1

    # Perform Verification
    for word in word_list:
        word.verify()
    print(f"Tests Passed on {len(word_list)} reads")

if __name__ == "__main__":
    adp_input = "ft1248_ip.log"
    adp_output = "ft1248_op.log"
    output_log = "verify.log"
    adp_verify(adp_input,adp_output,output_log)
