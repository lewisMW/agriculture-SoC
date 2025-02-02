#-----------------------------------------------------------------------------
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from ARM Limited or its affiliates.
#
#            (C) COPYRIGHT 2010-2017 ARM Limited or its affiliates.
#                ALL RIGHTS RESERVED
#
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from ARM Limited or its affiliates.
#
#  Version and Release Control Information:
#
#  File Revision       : $Revision: 368444 $
#  File Date           : $Date: 2017-07-25 15:10:13 +0100 (Tue, 25 Jul 2017) $
#
#  Release Information : Cortex-M0 DesignStart-r2p0-00rel0
#-----------------------------------------------------------------------------
#
# Cortex-M0 DesignStart FPGA simulation make file
#
#-----------------------------------------------------------------------------
#
#  Configurations
#
include ../../paths.mk

CPU_PRODUCT = CORTEX_M0

# Shared software directory
SOFTWARE_DIR = $(DESIGNSTART_DIR)/software
CMSIS_DIR    = $(SOFTWARE_DIR)/cmsis
CORE_DIR     = $(CMSIS_DIR)/CMSIS/Include

DEVICE_DIR   = $(CMSIS_DIR)/Device/ARM/CMSDK_CM0

# Program file
TESTNAME     = adc_trigger_test

# Endian Option
COMPILE_BIGEND = 0

# Configuration
USER_DEFINE    = -DCORTEX_M0

DEPS_LIST       = makefile

TOOL_CHAIN      = gcc

ifeq ($(TOOL_CHAIN),gcc)
  CPU_TYPE        = -mcpu=cortex-m0
endif

# Startup code directory for gcc
ifeq ($(TOOL_CHAIN),gcc)
 STARTUP_DIR  = $(DEVICE_DIR)/Source/GCC
endif

STARTUP_FILE = startup_CMSDK_CM0
SYSTEM_FILE  = system_CMSDK_CM0

# ---------------------------------------------------------------------------------------
# gcc options

GNG_CC      = arm-none-eabi-gcc
GNU_OBJDUMP = arm-none-eabi-objdump
GNU_OBJCOPY = arm-none-eabi-objcopy

LINKER_SCRIPT_PATH = $(SOFTWARE_DIR)/common/scripts
LINKER_SCRIPT = ../linker_scripts/cmsdk_cm0.ld

GNU_CC_FLAGS = -g -O3 -mthumb $(CPU_TYPE)

ifeq ($(COMPILE_BIGEND),1)
 # Big Endian
 GNU_CC_FLAGS   += -mbig-endian
endif

# ---------------------------------------------------------------------------------------
all: all_$(TOOL_CHAIN)

# ---------------------------------------------------------------------------------------
# gcc
all_gcc:
	$(GNG_CC) $(GNU_CC_FLAGS) $(STARTUP_DIR)/$(STARTUP_FILE).s \
		$(TESTNAME).c \
		$(SOFTWARE_DIR)/common/retarget/retarget.c \
		$(SOFTWARE_DIR)/common/retarget/uart_stdout.c \
		$(DEVICE_DIR)/Source/$(SYSTEM_FILE).c \
		-I $(DEVICE_DIR)/Include -I $(CORE_DIR) \
                -I $(SOFTWARE_DIR)/common/retarget  \
		-L $(LINKER_SCRIPT_PATH) \
		-D__STACK_SIZE=0x200 \
		-D__HEAP_SIZE=0x1000 \
		$(USER_DEFINE) -T $(LINKER_SCRIPT) -o $(TESTNAME).o
	# Generate disassembly code
	$(GNU_OBJDUMP) -S $(TESTNAME).o > $(TESTNAME).lst
	# Generate binary file
	$(GNU_OBJCOPY) -S $(TESTNAME).o -O binary $(TESTNAME).bin
	# Generate hex file
	$(GNU_OBJCOPY) -S $(TESTNAME).o -O verilog $(TESTNAME).hex
	#od -v -A n -t x1 $(TESTNAME).bin > $(TESTNAME).hex

