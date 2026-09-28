#!/usr/bin/env python3
#------------------------------------------------------------------------------------
# Verilog Filelist compilation script
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
# Copyright (c) 2023, SoC Labs (www.soclabs.org)
#------------------------------------------------------------------------------------

import argparse
import os
    
def filelist_checker(args):
    input_filelist = args.input
    print("Checking Filelist")
    
    f_inlist = open(input_filelist, "r")
    filelist_lines = f_inlist.readlines()
    f_inlist.close()
    
    for lines in filelist_lines:
        if(not (lines.startswith("//"))):
            if(lines.startswith("/")):
                if( not (os.path.exists(lines.strip()))):
                    print(f'ERROR: file {lines} does not exist')

if __name__ == "__main__":
    # Capture Arguments from Command Line
    parser = argparse.ArgumentParser(description='Compiles Filelist to Read')
    parser.add_argument("-i", "--input", type=str, help="Input Filelist to Read")
    args = parser.parse_args()
    filelist_checker(args)
