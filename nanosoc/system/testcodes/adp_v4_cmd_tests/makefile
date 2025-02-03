#-----------------------------------------------------------------------------
# The confidential and proprietary information contained in this file may
# only be used by a person authorised under and to the extent permitted
# by a subsisting licensing agreement from Arm Limited or its affiliates.
#
#            (C) COPYRIGHT 2010-2013 Arm Limited or its affiliates.
#                ALL RIGHTS RESERVED
#
# This entire notice must be reproduced on all copies of this file
# and copies of this file may only be made by a person if such person is
# permitted to do so under the terms of a subsisting license agreement
# from Arm Limited or its affiliates.
#
#      SVN Information
#
#      Checked In          : $Date: 2017-10-10 15:55:38 +0100 (Tue, 10 Oct 2017) $
#
#      Revision            : $Revision: 371321 $
#
#      Release Information : Cortex-M System Design Kit-r1p1-00rel0
#-----------------------------------------------------------------------------
#
# Cortex-M System Design Kit software compilation make file
#
#-----------------------------------------------------------------------------
#
#  Configurations
#
# Choose the core instantiated, can be
#  - CORTEX_M0
#  - CORTEX_M0PLUS
CPU_PRODUCT = CORTEX_M0

# Shared software directory
SOFTWARE_DIR = $(SOCLABS_NANOSOC_TECH_DIR)/software
CMSIS_DIR    = $(SOFTWARE_DIR)/cmsis
CORE_DIR     = $(CMSIS_DIR)/CMSIS/Include

ifeq ($(CPU_PRODUCT),CORTEX_M0PLUS)
  DEVICE_DIR   = $(CMSIS_DIR)/Device/ARM/CMSDK_CM0plus
else
  DEVICE_DIR   = $(CMSIS_DIR)/Device/ARM/CMSDK_CM0
endif

# Program file
TESTNAME     = adp_v4_cmd_tests

# Endian Option
COMPILE_BIGEND = 0

# Configuration
ifeq ($(CPU_PRODUCT),CORTEX_M0PLUS)
  USER_DEFINE    = -DCORTEX_M0PLUS
else
  USER_DEFINE    = -DCORTEX_M0
endif

DEPS_LIST       = makefile

# Tool chain : ds5 / gcc / keil
TOOL_CHAIN      = ds5

ifeq ($(TOOL_CHAIN),ds5)
  ifeq ($(CPU_PRODUCT),CORTEX_M0PLUS)
    CPU_TYPE        = --cpu Cortex-M0plus
  else
    CPU_TYPE        = --cpu Cortex-M0
  endif
endif

ifeq ($(TOOL_CHAIN),gcc)
  ifeq ($(CPU_PRODUCT),CORTEX_M0PLUS)
    CPU_TYPE        = -mcpu=cortex-m0plus
  else
    CPU_TYPE        = -mcpu=cortex-m0
  endif
endif

# Startup code directory for DS-5
ifeq ($(TOOL_CHAIN),ds5)
 STARTUP_DIR  = $(DEVICE_DIR)/Source/ARM
endif

# Startup code directory for gcc
ifeq ($(TOOL_CHAIN),gcc)
 STARTUP_DIR  = $(DEVICE_DIR)/Source/GCC
endif

ifeq ($(CPU_PRODUCT),CORTEX_M0PLUS)
  STARTUP_FILE = startup_CMSDK_CM0plus
  SYSTEM_FILE  = system_CMSDK_CM0plus
else
  STARTUP_FILE = startup_CMSDK_CM0
  SYSTEM_FILE  = system_CMSDK_CM0
endif

# ---------------------------------------------------------------------------------------
# DS-5 options

# MicroLIB option
COMPILE_MICROLIB = 0

# Small Multiply (Cortex-M0/M0+ has small multiplier option)
COMPILE_SMALLMUL = 0

ARM_CC_OPTIONS   = -c -O3 -Ospace -I $(DEVICE_DIR)/Include  -I $(CORE_DIR) \
		   -I $(SOFTWARE_DIR)/common/retarget -I $(SOFTWARE_DIR)/drivers $(USER_DEFINE)
ARM_ASM_OPTIONS  = 
ARM_LINK_OPTIONS = "--keep=$(STARTUP_FILE).o(RESET)" "--first=$(STARTUP_FILE).o(RESET)" \
		   --no_debug --rw_base 0x30000000 --ro_base 0x00000000 --map  --info sizes

ifeq ($(COMPILE_BIGEND),1)
 # Big Endian
 ARM_CC_OPTIONS   += --bigend
 ARM_ASM_OPTIONS  += --bigend
 ARM_LINK_OPTIONS += --be8
endif

ifeq ($(COMPILE_MICROLIB),1)
 # MicroLIB
 ARM_CC_OPTIONS   += --library_type=microlib
 ARM_ASM_OPTIONS  += --library_type=microlib --pd "__MICROLIB SETA 1"
 ARM_LINK_OPTIONS += --library_type=microlib
endif

ifeq ($(COMPILE_SMALLMUL),1)
 # In Cortex-M0, small multiply takes 32 cycles
 ARM_CC_OPTIONS   += --multiply_latency=32
endif

# ---------------------------------------------------------------------------------------
# gcc options

GNG_CC      = arm-none-eabi-gcc
GNU_OBJDUMP = arm-none-eabi-objdump
GNU_OBJCOPY = arm-none-eabi-objcopy

LINKER_SCRIPT_PATH = $(SOFTWARE_DIR)/common/scripts
LINKER_SCRIPT = $(LINKER_SCRIPT_PATH)/cmsdk_cm0.ld

GNU_CC_FLAGS = -g -O3 -mthumb $(CPU_TYPE)

ifeq ($(COMPILE_BIGEND),1)
 # Big Endian
 GNU_CC_FLAGS   += -mbig-endian
endif

# ---------------------------------------------------------------------------------------
all: all_$(TOOL_CHAIN)

# ---------------------------------------------------------------------------------------
# DS-5
all_ds5 : $(TESTNAME).hex $(TESTNAME).lst

$(TESTNAME).o :  $(TESTNAME).c $(DEPS_LIST)
	armcc $(ARM_CC_OPTIONS) $(CPU_TYPE) $< -o  $@

$(SYSTEM_FILE).o : $(DEVICE_DIR)/Source/$(SYSTEM_FILE).c $(DEPS_LIST)
	armcc $(ARM_CC_OPTIONS) $(CPU_TYPE) $< -o  $@

retarget.o : $(SOFTWARE_DIR)/common/retarget/retarget.c $(DEPS_LIST)
	armcc $(ARM_CC_OPTIONS) $(CPU_TYPE) $< -o  $@

uart_stdout.o : $(SOFTWARE_DIR)/common/retarget/uart_stdout.c $(DEPS_LIST)
	armcc $(ARM_CC_OPTIONS) $(CPU_TYPE) $< -o  $@

$(STARTUP_FILE).o : $(STARTUP_DIR)/$(STARTUP_FILE).s $(DEPS_LIST)
	armasm $(ARM_ASM_OPTIONS) $(CPU_TYPE) $< -o  $@

$(TESTNAME).ELF : $(TESTNAME).o $(SYSTEM_FILE).o $(STARTUP_FILE).o retarget.o uart_stdout.o
	armlink $(ARM_LINK_OPTIONS) -o $@ $(TESTNAME).o $(SYSTEM_FILE).o $(STARTUP_FILE).o retarget.o uart_stdout.o

$(TESTNAME).hex : $(TESTNAME).ELF
	fromelf --vhx --8x1 $< --output $@

$(TESTNAME).lst : $(TESTNAME).ELF
	fromelf -c -d -e -s -z -v $< --output $@

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
		-I $(SOFTWARE_DIR)/drivers \
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

# Note:
# If the version of object copy you are using does not support verilog hex file output,
# you can generate the hex file from binary file using the following command
#       od -v -A n -t x1 --width=1  $(TESTNAME).bin > $(TESTNAME).hex


# ---------------------------------------------------------------------------------------
# Keil MDK

all_keil:
	@echo "Please compile your project code and press ENTER when ready"
	@read dummy

# ---------------------------------------------------------------------------------------
# Binary

all_bin: $(TESTNAME).bin
	# Generate hex file from binary
	od -v -A n -t x1 --width=1  $(TESTNAME).bin > $(TESTNAME).hex

# ---------------------------------------------------------------------------------------
# Clean
clean :
	@rm -rf *.o
	@if [ -e $(TESTNAME).hex ] ; then \
	  rm -rf $(TESTNAME).hex ; \
	fi
	@if [ -e $(TESTNAME).lst ] ; then \
	  rm -rf $(TESTNAME).lst ; \
	fi
	@if [ -e $(TESTNAME).ELF ] ; then \
	  rm -rf $(TESTNAME).ELF ; \
	fi
	@if [ -e $(TESTNAME).bin ] ; then \
	  rm -rf $(TESTNAME).bin ; \
	fi
	@rm -rf *.crf
	@rm -rf *.plg
	@rm -rf *.tra
	@rm -rf *.htm
	@rm -rf *.map
	@rm -rf *.dep
	@rm -rf *.d
	@rm -rf *.lnp
	@rm -rf *.bak
	@rm -rf *.lst
	@rm -rf *.axf
	@rm -rf *.sct
	@rm -rf *.__i
	@rm -rf *._ia
