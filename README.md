hostio4
========

Verilog implementation of soclabs HOSTIO interface, multiplexing 4 virtual byte wide channels over a 7-pin interface (4-bit bidirectional packet data bus)


## Status ##
The core is ready for production stage, validateg with RP2040/RP2350 PIO driver


## Introduction ##

The hostio4 interface supports 4 8-bit Arm-AXI-streams:
 * channel 0 : TX byte stream (conventionally 'stdout')
 * channel 0 : RX byte stream (conventionally 'stdin')
 * channel 1 : TX byte stream (data output stream - e.g. CSV data file)
 * channel 1 : RX byte stream (data input stream - e.g. CSV data file)
 
The physical interface serializes the 8-bit data as 4-bit nibbles with a 4-bit command packet to inicate direction and virtual channel number, which is sequenced to manage driver turnaround betweem initiator and target.

The interface is fully hardware-handshaked, with a pair of "Request" lines sequenced from the Initiator, and a single "Acknowledge" signal that supports  handshaking across clock domains.

While the interface is quiescent (both Request signals de-asserted) the target device will indicate readyness to transfer for each virtual channel on the 4-bit bidirectional bus, and the initiator will only initiate a transfer when there is data to transfer and the virtual channel is not "busy".


#### Initiator (SoC) port interface

Control
 + IOREQ1_o
 + IOREQ2_o
 + IOACK_i   // asynchronous

Data
 + IODATA4_i[3:0] // input status (asynchronous)/read-data (synchronous)
 + IODATA4_o[3:0] // output command/write-data
 + IODATA4_e[3:0] // output enable control (output drive enable)
 + IODATA4_t[3:0] // output tristate control (output drive disable)

#### Target (testbench,FPGA) port interface

Control
 + IOREQ1_i  // asynchronous
 + IOREQ2_i  // asynchronous
 + IOACK_o

Data
 + IODATA4_i[3:0] // input command/write-data
 + IODATA4_o[3:0] // output status/read-data
 + IODATA4_e[3:0] // output enable control (output drive enable)
 + IODATA4_t[3:0] // output tristate control (output drive disable)


## Protocol



#### Xilinx
- Tool: Vivado 2019.2
- Device: Kintex-7 (7k70tfbv676-1)
- master:
  - LUTs: -
  - FFs: -
  - Fmax: - MHz


## Core Usage


## FuseSoC
This core is supported by the
[FuseSoC](https://github.com/olofk/fusesoc) core package manager and
build system. Some quick  FuseSoC instructions:

install FuseSoC
~~~
pip install fusesoc
~~~

Create and enter a new workspace
~~~
mkdir workspace && cd workspace
~~~

Register hostio4 as a library in the workspace
~~~
fusesoc library add hostio4 https://git.soton.ac.uk/soclabs/hostio4.git
~~~
fusesoc library list
~~~
fusesoc core list
~~~

To run lint (assuming Synopsys SpyGlass in this example)
~~~
fusesoc run --target=lint soclabs:nanosoc:hostio4:1
~~~

Run tb_hostio4_axis testbench with vcs
~~~
fusesoc run --target=sim --tool=vcs soclabs:nanosoc:hostio4:1
~~~
OR, if other python vesrions or libraries installed:

/usr/bin/python3.8 /usr/local/bin/fusesoc --verbose run --target=sim --tool=vcs soclabs:nanosoc:hostio4:1


Run with modelsim instead of default tool (vcs)
~~~
fusesoc run --target=sim --tool=modelsim soclabs:nanosoc:hostio4:1
~~~

Run tb_hostio4_axis testbench with vcs and Verdi GUI
~~~
fusesoc run --target=sim_gui --tool=vcs soclabs:nanosoc:hostio4:1
~~~

List all targets
~~~
fusesoc core show soclabs:nanosoc:hostio4:1
~~~


## Implementation results - ASIC ##

TBC

### TSMC 65 nm ###
Target frequency: 250 MHz
Complete flow from RTL to placed gates. Automatic clock gating and scan
insertion. TBC


## Implementation results - FPGA ##

The core has been implemented in Xilinx FPGA devices.

### Xilinx xc7vx485tffg1157-1 ###
- 115 slice LUTs
- 99 slice Registers
- 2 F7 Muxes
- 100 MHz target

+----------+------+---------------------+
| Ref Name | Used | Functional Category |
+----------+------+---------------------+
| FDCE     |   91 |        Flop & Latch |
| LUT6     |   55 |                 LUT |
| LUT5     |   38 |                 LUT |
| OBUF     |   34 |                  IO |
| IBUF     |   28 |                  IO |
| LUT4     |   16 |                 LUT |
| LUT3     |   12 |                 LUT |
| FDPE     |    8 |        Flop & Latch |
| LUT2     |    5 |                 LUT |
| LUT1     |    3 |                 LUT |
| MUXF7    |    2 |               MuxFx |
| BUFG     |    1 |               Clock |
+----------+------+---------------------+
