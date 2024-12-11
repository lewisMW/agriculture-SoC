# Accelerator System Project

This repo is the top-level repository which contains all the relavant IP for integrating your custom hardware accelerator with the SoC Labs provided nanosoc chip design IP in forms of git subrepositories.

### Fork this repository

In order to use this repository for your own project, we recommend that you fork a version of this repository first. In your forked version of the project you can add you accelerator as a subrepo if you are already using repositories, or alternatively add the source for you accelerator directly to your forked repository.

### Cloning this repository
---

This Repository contains multiple sub-repositories. In order to clone them with this repository, please use the following command:

`git clone --recurse https://git.soton.ac.uk/soclabs/accelerator-project.git`

At this stage you can also add your submodule with: 
`git submodule add`

After doing this you should update the projbranch file to include your repository name (as it appears in .gitmodules) and the branch. This will allow the set_env.sh script to pull in your repository when updates are made

At this point you may also like to edit the /env/dependency_env.sh to include your accelerator directory for example:

`export ACCELERATOR_DIR="$SOCLABS_PROJECT_DIR/accelerator"`


## Setting up the Project Environment
---

In order to checkout all the sub-repositories in your project to their branches and set up your local environment variables, from the top-level of this project run:

`source set_env.sh`

### Setting up the Project Environment
---

Every time you wish to run commands in this project, you will need to make sure the set environment script has been run for your current terminal session. This is done by moving to the top-level of the project and running:

`source set_env.sh` 

This sets the environment variables related to this project and creates visability to the scripts in the flow directory. 

### Updating Subrepositories
---

Once you have run a `source set_env.sh` in your current terminal, you are then able to update all your repositories to their latest version by running:

`socpull`

This runs a git pull on all repositories in your project.

## Project Structure
---

The core of the SoC is NanoSoC. This is an example, configurable system that is the main framework. It has many different memory-mapped regions, one of which is designed for the connection of accelerator subsystems called the expansion region.

The expansion region is able to instantiate an accelerator_subsystem by default. This means that anyone using NanoSoC as a platform for accelerator experimentation will need to build an `accelerator_subsystem` rtl module.

There is an example file in `/system/src/accelerator_subsystem.v`. You will need to add an instantiation of your top level to this file. The connections at this level are an AHB subordinate, DMA data requist signals, and CPU interupt signals.

### Using the makefiles and FLISTS

Simulation, FPGA implementation, and ASIC synthesis can all be performed from the main makefile in the nanosoc_tech repository. In order for these to work correctly you must make sure the flist files include your accelerator source code.
You can add these to `/flist/project/accelerator`. It is recommended here to use environment variables, the top level of your project will be `$SOCLABS_PROJECT_DIR`. You can include files directly, or include other flists with the `-f` command at the start of the line. 


### htmlgen design visualisation
---
A tool is provided to generate an html documentation tree to traverse and explore the design hierarchy:

`htmlgen -f $SOCLABS_PROJECT_DIR/flist/project/top.flist`
or
 `htmlgen`
populates the html/top/build/ directiory. Open `nanosoc_tb.html` to explore from the testbench down in to the design.


### Accelerator Subsystem
---
`accelerator_subsystem` can either directly contain an accelerator (or multiple) or can instantiate accelerator wrappers which in turn instantiate accelerators.

This module is expected to be found in `system/src/accelerator_subsystem.v`.

### Accelerator Wrapper
---
Accelerator wrappers are located in `wrapper/src`. These should instantiate accelerators and can use wrapper components within the `accelerator_wrapper_tech` repository to allow a conversion of valid//ready interfaces to a memory-mapped AHB interface.

## Running the simulation
---

This design instantiates a custom (AMBA-AHB) wrapper around the AES core to implement a memory-mapped 128-bit AES encrypt/decrypt accelerator that can be used as a software-driven peripheral or a semi-autonomous DMA subystem when 128-bit keys and variable length data payloads can be set up as scatter/gather descriptor chains for background processing.

To run the simulation the 'socsim' command executes the makefile in the 'nanosoc_tech' microcontroller framework. (Edit the simulator target in nanosoc_tech/system/makefile for the simulator EDA tool used). Then use the:

`socsim test_nanosoc TESTNAME=hello`

This runs the integration test program on the Arm Cortex-M0 processor using the 'test_nanosoc.sh' script provided in the simulate/socsim directory and the logs are produced in the simulate/sim/test_nanosoc/logs directory.

This will only run simulations on nanosoc, without the accelerator instantiated, you can also run simulations with your accelerator using

`socsim test_accelerator TESTNAME=xx`

Replacing the xx with the chosen test you want to run

## Adding testcodes

To add your own testcodes to be run from the Arm Cortex-M0 processor, it is recommnded these are added in the `/system/testcodes/$TESTNAME` directory.
To enable the makefiles to find your testcode, you should also add the name of your test to the `/system/testcodes/software_list.txt` file.

It is recommended that you copy and edit one of the makefiles for compiling your software into .hex files. (for example in `/system/testcodes/adp_v4_cmd_tests/makefile`) You will have to edit the TESTNAME (line 46) and may also need to change some of the compiler options depending on your code.
You can then either simulate using the `socim test_accelerator TESTNAME=x` or alternatively from the `/nanosoc_tech` directory you can run `make run_%SIM% TESTNAME=x ACCELERATOR=yes`

The currently supported simulators are VCS, Excelium and Questa Sim. Currently we mostly use Quest Sim (run_mti)

You can also run `sim_%SIMULATOR%` and this will run the simulation from the GUI.

When using the makefile, you must include the `ACCELERATOR=yes` directive to include your accelerator

## FPGA Builds

We currently have build files for the ARM MPS3, PYNQ ZCU104, PYNQ Z2, KRIA KR260 and KRIA KV260. To build the bitfiles you can run the `make build_fpga FPGA=%target% ACCELERATOR=yes` from the `/nanosoc_tech/` directory. 
The acceptable targets are defined in the `/nanosoc_tech/fpga/makefile.targets` and are `mps3, zcu104, z2, kr260, kv260`

This script will run the vivado build scripts. The output from this will be in the `/imp/FPGA` directory. 

## ASIC Synthesis

To run the ASIC synthesis you will first need to define a `$PHYS_IP` environment variable. This should point to the uncompressed Arm bundles for the TSMC 65nm LP node. 

For a Cadence synthesis flow use:
1. Run `make gen_memories` this will generate the bootrom, and SRAMS using the artisan memory compilers
2. Run `make flist_genus_nanosoc ACCELERATOR=yes ASIC=yes` which will generate the top flist for the genus synthesiser tool
3. Run `make syn_genus ACCELERATOR=yes ASIC=yes` which will run the synthesis

The output from the synthesis will be in the `/imp/ASIC` directory.
