# SoCDebug Tech
---

## Introduction
SoCDebug is a Debug Controller to enable low-level debug within SoCs. SoCDebug runs over both FT1248 and USRT allowing for access to the internal system bus. Currently we have only supported an AHB interface but we may expand this in the future.

## RTL Structure
This repo will contain the Verilog RTL for the USRT, FT1248 Controller and the ADP Controller. These components communicate with each other over AXI-Stream Interfaces which allow for the addition of other AXI-Stream compatable Debug Communication interfaces to interact with the ADP Controller.

## FPGA Debug Infrastructure
### RTL
Socket Debug interface IP is also contained within the repo to allow for debug access even within and FPGA environemnt without needing to directly memory map your SoC - this can be useful when considering an ASIC tapeout for your SoC. We have packaged this up for use within Vivado and this is something we are looking to publish to this repo.

### Python Interface
As well as this, a python library to allow access to the Socket will be provided which will allow Memory reads and writes to occur from a Host Python computer over a UART connection to the FPGA board. The plan is for these libraries to be compatable with an ASIC tester board.
