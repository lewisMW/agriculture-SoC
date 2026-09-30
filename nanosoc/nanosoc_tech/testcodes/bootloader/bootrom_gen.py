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
import os
from jinja2 import Environment, FileSystemLoader
from datetime import datetime

TEMPLATE_NAME = 'bootrom_templ.sv.jinja'
DATA_WIDTH    = 32
ADDRESS_WIDTH = 9

def bootrom_gen(args):
    # Extract Data from Parsed Arguments
    input_hex = args.input_hex
    address_width = args.address_width
    output_verilog = args.verilog_output
    output_binary = args.binary_output
    
    # Create Binary and Verilog Outputs
    print(f"Generating Bootrom {input_hex}")
    if(args.tool_chain=='gcc'):
        bootrom_verilog, bootrom_binary = output_construct_gcc(input_hex, address_width)
    else:
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
    ## NEW LINE ADDED
    # hex_bytes = f.readlines()
    hex_bytes = [line.strip() for line in f.readlines()]
    f.close()

    # Number of bytes expected depending on address_width
    address_bytes = 1 << (address_width + 2)
    print(len(hex_bytes))
    # Fill hex_bytes with zeros for addresses than aren't in the hex file
    while (len(hex_bytes) < address_bytes): hex_bytes.append("00")
    hex_words = math.ceil(len(hex_bytes)/4)
    hex_data = []

    # Combine bytes into words and prepare data for template
    hex_data_for_template = []
    for i in range(hex_words):
        temp_hex_word= f"{hex_bytes[i*4+3].rstrip()}{hex_bytes[(i*4)+2].rstrip()}{hex_bytes[(i*4)+1].rstrip()}{hex_bytes[(i*4)].rstrip()}"
        word_value = int(temp_hex_word, 16)
        hex_data.append(word_value)
        hex_data_for_template.append({'index': i, 'word': word_value})

    # Get Date and Time to put in Generated Header
    date_str = datetime.today().strftime('%Y-%m-%d %H:%M:%S')

    # Set up Jinja2 environment and load template
    template_dir = os.path.dirname(os.path.abspath(__file__))
    env = Environment(loader=FileSystemLoader(template_dir))
    template = env.get_template(TEMPLATE_NAME)
    
    # Generate complete Verilog module using Jinja2 template
    bootrom_verilog = template.render(
        word_address_width=address_width,
        data_width=32,
        date=date_str,
        hex_data=hex_data_for_template
    )

    bootrom_binary = ""

    # Append Hex Data to File
    #
    # Size the case-label constant to the actual number of words rather than a
    # fixed `address_width` bits. When the image has more than 2**address_width
    # words, indices past that overflow an `address_width`-bit literal, which
    # iverilog flags as "extra digits / truncated" and silently aliases the high
    # entries onto low addresses. Widening the literal to hold the largest index
    # keeps every label distinct (the over-depth entries stay unreachable, since
    # W_ADDR is only address_width bits, but no longer collide). For images that
    # fit, label_bits == address_width so the output is unchanged.
    label_bits = max(1, address_width, (len(hex_data) - 1).bit_length())
    hex_digits = (label_bits + 3) // 4
    for i, word in enumerate(hex_data):
        temp_verilog = f"""       {label_bits:d}'h{i:0{hex_digits}x} : RDATA <= 32'h{word:08x}; // 0x{i*4:04x}\n"""
        temp_binary = f"""{word:032b}\n"""
        bootrom_binary += temp_binary

    return bootrom_verilog, bootrom_binary

def output_construct_gcc(input_hex, address_width):
    # Read in Hex File
    f = open(input_hex, "r")
    hex_lines = f.readlines()
    f.close()

    hex_counter = 0
    hex_bytes = []
    for lines in hex_lines:
        line = lines.strip()
        if(line[0]!='@'):
            hex = line.split(' ')
            for byte in hex:
                hex_bytes.append(byte)
                hex_counter+=1
        else:
            addr = int(line[1:], 16)
            if(addr!=hex_counter):
                print("ERROR")
                break
            
    # Number of bytes expected depending on address_width
    address_bytes = 1 << (address_width + 2)

    # Fill hex_bytes with zeros for addresses than aren't in the hex file
    while (len(hex_bytes) < address_bytes): hex_bytes.append("00")
    hex_words = math.ceil(len(hex_bytes)/4)
    hex_data = []

    # Combine bytes into words and prepare data for template
    hex_data_for_template = []
    for i in range(hex_words):
        temp_hex_word= f"{hex_bytes[i*4+3].rstrip()}{hex_bytes[(i*4)+2].rstrip()}{hex_bytes[(i*4)+1].rstrip()}{hex_bytes[(i*4)].rstrip()}"
        word_value = int(temp_hex_word, 16)
        hex_data.append(word_value)
        hex_data_for_template.append({'index': i, 'word': word_value})
    
    # Get Date and Time to put in Generated Header
    date_str = datetime.today().strftime('%Y-%m-%d %H:%M:%S')

    # Set up Jinja2 environment and load template
    template_dir = os.path.dirname(os.path.abspath(__file__))
    env = Environment(loader=FileSystemLoader(template_dir))
    template = env.get_template(TEMPLATE_NAME)
    
    # Generate complete Verilog module using Jinja2 template
    bootrom_verilog = template.render(
        word_address_width=ADDRESS_WIDTH,
        data_width=DATA_WIDTH,
        date=date_str,
        hex_data=hex_data_for_template
    )

    bootrom_binary = ""

    # Generate binary data
    for word in hex_data:
        temp_binary = f"""{word:032b}\n"""
        bootrom_binary += temp_binary

    return bootrom_verilog, bootrom_binary

if __name__ == "__main__":
    # Capture Arguments from Command Line
    parser = argparse.ArgumentParser(description='Generates NanoSoC CPU Bootrom File')
    parser.add_argument("-i", "--input_hex", type=str, help="Input Hex File to Generate Bootrom from")
    parser.add_argument("-a", "--address_width", type=int, help="Address Width (In 32bit Words) of Bootrom")
    parser.add_argument("-v", "--verilog_output", type=str, help="Output Bootrom verilog file")
    parser.add_argument("-b", "--binary_output", type=str, help="Output Bootrom binary file")
    parser.add_argument("-t", "--tool_chain", type=str, help="Tool Chain used to generate binary")

    args = parser.parse_args()
    bootrom_gen(args)