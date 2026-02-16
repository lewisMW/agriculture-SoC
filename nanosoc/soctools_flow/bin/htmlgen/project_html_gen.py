#!/usr/bin/env python3
#------------------------------------------------------------------------------------
# HTML Project Generation Script
# - Generates HTML based on all filelist in SOCLABS_PROJECT_DIR/flist/project
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
# Copyright (c) 2023, SoC Labs (www.soclabs.org)
#------------------------------------------------------------------------------------

import argparse
import subprocess
import os

def top_mod_find(filelist):
    # Open Filelist
    f = open(filelist, "r")
    filelines = f.readlines()
    f.close()
    # Iterate over file and find first match for DESIGN_TOP in file comments
    for line in filelines:
        line_list = line.strip().split()
        if len(line_list) > 2:
            if (line_list[0] == "//") and (line_list[1] == "DESIGN_TOP"):
                return line_list[2]

def bootrom_gen():
    # Runs Bootrom generation script in NanoSoC Directory
    bootrom_scipt_dir = os.getenv("SOCLABS_NANOSOC_TECH_DIR")
    subprocess.run(["make","-C",bootrom_scipt_dir,"bootrom"])

def html_gen(filelist_path):
    filelist = os.path.basename(filelist_path)
    filelist_name = os.path.splitext(filelist)[0]
    print("Generating HTML for: "+filelist_name)
    # Find Top-level module name
    top_mod = top_mod_find(filelist_path)
    print(f"Top-level Module is: {top_mod}")
    # Work out output Directory
    outdir = os.getenv("SOCLABS_PROJECT_DIR")+"/html/"+filelist_name
    html_scipt_dir = os.getenv("SOCLABS_SOCTOOLS_FLOW_DIR")+"/bin/htmlgen"
    subprocess.run(["make","-C",html_scipt_dir,"gen_html","TOP_MODULE="+top_mod,"OUT_DIR="+outdir,"FILELIST="+filelist_path])

def project_gen(args):
    # Has filelist option been passed to script
    if args.filelist == None:
        # Generate bootrom
        bootrom_gen()
        # Find all filelist in project filelist directory
        # for filelist in os.listdir(os.getenv("SOCLABS_PROJECT_DIR")+"/flist/project"):
        filelist_path = os.getenv("SOCLABS_PROJECT_DIR")+"/flist/project/"+"top.flist"
        html_gen(filelist_path)
    else:
        if args.bootrom is True:
            # Generate bootrom
            bootrom_gen()
        # Generate HTML for given filelist
        html_gen(args.filelist)
        
if __name__ == "__main__":
    # Capture Arguments from Command Line
    parser = argparse.ArgumentParser(description='Generates HTML based on all filelist in SOCLABS_PROJECT_DIR/flist/project')
    parser.add_argument("-f", "--filelist", type=str, help="Generate only from this List", required=False)
    parser.add_argument("-b", "--bootrom", action='store_true', help="Generate Bootrom first", required=False)
    parser.add_argument("-o", "--output", type=str, help="Output Filelist location", required=False)
    args = parser.parse_args()
    project_gen(args)