# agriculture-SoC

Our innovative SoC design for precision agriculture uses a mesh network of sensor-based devices to monitor and respond to changes in soil health, erosion, drought, and pest activity, enhancing reliability and eliminating single points of failure. Engineered for energy efficiency and continuous operation, it provides granular, real-time data directly from the field, optimizing resource use and surpassing traditional remote sensing methods for sustainable agriculture.

## Progress

Currently, the SoC implements the following architecture, using IP from the ARM CMSDK:
![System Architecture](system.png "System Architecture")

## Setup
The ARM IP used in this project is freely available under the ARM DesignStart Eval kit. Make sure to acquire the IP from ARM, along with a license. The DesignStart directory (e.g. `AT510-MN-80001-r2p0-00rel0`, etc) must be copied pointed to by the `DESIGNSTART_DIR` variable in paths.mk.

## Simulation
We have set up this project to use Verilator 5.026 as a functional RTL simulator. To simulate the system, run `make` in the `agriculture_soc_main` directory. To build software to flash the SRAM with, run `make` in an appropriate software project directory in the `software` directory.