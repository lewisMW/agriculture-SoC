#!/usr/bin/env python3
#------------------------------------------------------------------------------------
# Verilog and Binary Bootrom Generation Script
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
# Copyright (c) 2023, SoC Labs (www.soclabs.org)
#------------------------------------------------------------------------------------

import argparse
import math
from string import Template
from datetime import datetime

v_template_head = f"""//------------------------------------------------------------------------------------
// Auto-generated synthesizable Bootrom
//
// Generated from bootrom_gen.py
//
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//    Date:    $date
// Copyright (c) 2021-3, SoC Labs (www.soclabs.org)
//------------------------------------------------------------------------------------
module bootrom (
  input  wire CLK,
  input  wire EN,
  input  wire [$word_address_width:0] W_ADDR,
  output reg [31:0] RDATA );
always @(posedge CLK) begin
if (EN) begin
  case(W_ADDR)
"""

v_template_foot = """       default : RDATA <= 32'd0;
      endcase
    end
  end
endmodule"""


def bootrom_gen(args):
    # Extract Data from Parsed Arguments
    input_hex = args.input_hex
    address_width = args.address_width
    output_verilog = args.verilog_output
    output_binary = args.binary_output
    
    # Create Binary and Verilog Outputs
    print(f"Generating Bootrom {input_hex}")
    bootrom_verilog, bootrom_binary = output_construct(input_hex, address_width)

    # Write Out Verilog File
    f_verilog = open(output_verilog, "w")
    f_verilog.write(bootrom_verilog)
    f_verilog.close()

    # Write Out Binary File
    f_binary = open(output_binary, "w")
    f_binary.write(bootrom_binary)
    f_binary.close()

def output_construct(input_hex, address_width):
    # Read in Hex File
    f = open(input_hex, "r")
    hex_bytes = f.readlines()
    f.close()

    # Number of bytes expected depending on address_width
    address_bytes = 1 << (address_width + 2)

    # Fill hex_bytes with zeros for addresses than aren't in the hex file
    while (len(hex_bytes) < address_bytes): hex_bytes.append("00")
    hex_words = math.ceil(len(hex_bytes)/4)
    hex_data = []

    # Combine bytes into words
    for i in range(hex_words):
        temp_hex_word= f"{hex_bytes[i*4+3].rstrip()}{hex_bytes[(i*4)+2].rstrip()}{hex_bytes[(i*4)+1].rstrip()}{hex_bytes[(i*4)].rstrip()}"
        hex_data.append(int(temp_hex_word, 16))

    # Get Date and Time to put in Generated Header
    date_str = datetime.today().strftime('%Y-%m-%d %H:%M:%S')

     # Generate Verilog Header from Template
    temp_bootrom_obj = Template(v_template_head)
    temp_verilog = temp_bootrom_obj.substitute(
        address_width=address_width+1,
        word_address_width=address_width-1,
        date=date_str
    )
    bootrom_verilog = temp_verilog

    bootrom_binary = ""

    # Append Hex Data to File
    for i, word in enumerate(hex_data):
        if address_width > 8:
            temp_verilog = f"""       {address_width:d}'h{i:03x} : RDATA <= 32'h{word:08x}; // 0x{i*4:04x}\n"""
        else:
            temp_verilog = f"""       {address_width:d}'h{i:02x} : RDATA <= 32'h{word:08x}; // 0x{i*4:04x}\n"""
        temp_binary = f"""{word:032b}\n"""
        bootrom_verilog += temp_verilog
        bootrom_binary  += temp_binary

    # Append footer to Verilog file
    bootrom_verilog += v_template_foot

    return bootrom_verilog, bootrom_binary

if __name__ == "__main__":
    # Capture Arguments from Command Line
    parser = argparse.ArgumentParser(description='Generates NanoSoC CPU Bootrom File')
    parser.add_argument("-i", "--input_hex", type=str, help="Input Hex File to Generate Bootrom from")
    parser.add_argument("-a", "--address_width", type=int, help="Address Width (In 32bit Words) of Bootrom")
    parser.add_argument("-v", "--verilog_output", type=str, help="Output Bootrom verilog file")
    parser.add_argument("-b", "--binary_output", type=str, help="Output Bootrom binary file")
    args = parser.parse_args()
    bootrom_gen(args)