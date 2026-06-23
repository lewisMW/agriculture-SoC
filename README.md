# ASIC Flow repository
This repository contains flows for ASIC implementation of System on chip. Flows currently implemented are listed below.

- [Synopsys Fusion Compiler](#synopsys-fusion-compiler)
- [Synopsys DC + ICC2](#synopsys-dc--icc2)
- [Cadence Genus + Innovus](#cadence-genus--innovus)
- [Open Source flow](#open-source-flow)

## Using the flows (general instruction)
All of the flows are organised in a similar way and you have to make sure that your working environment is setup to use these flows.

The directory structure to use these is as follows:
- TOP
    - inputs
        - Constraints files, saif, etc
    - logs
        - Empty directory
    - outputs
        - Empty directory
    - reports
        - Empty directory
    - scripts
        - Design specific tcl files
    - work
        - Empty directory

The logs, outputs, and reports directories are used for placing log files, outputs like netlist and gds, and reports (timing, power, etc.).

The work directory is where you should invoke whichever tool you are using from (this is important as the tcl scripts are called relatively e.g. ../scripts/setup.tcl)

Specific instructions for different toolchains are below.

## Synopsys Fusion Compiler
Fusion compiler is a RTL to GDS tool from Synopsys. Providing a unified environment for both front and backend (synthesis and PnR) for ASIC implementation. The Synopsys_Fusion flow contains the following steps

- Design Setup
- Synthesis
- Clock tree synthesis and optimisation
- Routing and optimisation
- Signoff
- Formality checks

## Synopsys DC + ICC2
TODO: currently no flow for this

## Cadence Genus + Innovus
TODO: convert flow from the nanosoc TSMC 65nm flow

## Open Source flow
TODO: Create an open source flow