#//-----------------------------------------------------------------------------
#// customised Cortex-M0 'nanosoc' controller
#// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#//
#// Contributors
#//
#// David Flynn (d.w.flynn@soton.ac.uk)
#//
#// Copyright � 2021-3, SoC Labs (www.soclabs.org)
#//-----------------------------------------------------------------------------

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
include makefile.defs

all: all_$(TOOL_CHAIN)

# ---------------------------------------------------------------------------------------
# DS-5
all_ds5 : $(SOFTWARE_NAME)/$(SOFTWARE_NAME).hex $(SOFTWARE_NAME)/$(SOFTWARE_NAME).lst
all_ds6 : $(SOFTWARE_NAME)/$(SOFTWARE_NAME).hex $(SOFTWARE_NAME)/$(SOFTWARE_NAME).lst


$(SOFTWARE_NAME)/$(SOFTWARE_NAME).o :  $(SOFTWARE_DIR)/common/bootloader/$(SOFTWARE_NAME).c $(DEPS_LIST)
	$(CC_TOOL) $(ARM_CC_OPTIONS) $(CPU_TYPE) $< -o  $@

$(SOFTWARE_NAME)/$(SYSTEM_FILE).o : $(DEVICE_DIR)/Source/$(SYSTEM_FILE).c $(DEPS_LIST)
	$(CC_TOOL) $(ARM_CC_OPTIONS) $(CPU_TYPE) $< -o  $@

$(SOFTWARE_NAME)/$(STARTUP_FILE).o : $(STARTUP_DIR)/$(STARTUP_FILE).s $(DEPS_LIST)
	$(ASM_TOOL) $(ARM_ASM_OPTIONS) $(CPU_TYPE) $< -o  $@

$(SOFTWARE_NAME)/$(SOFTWARE_NAME).ELF : $(SOFTWARE_NAME)/$(SOFTWARE_NAME).o $(SOFTWARE_NAME)/$(SYSTEM_FILE).o $(SOFTWARE_NAME)/$(STARTUP_FILE).o $(DEPS_LIST)
	armlink $(ARM_LINK_OPTIONS) $(SOFTWARE_NAME)/$(SOFTWARE_NAME).o $(SOFTWARE_NAME)/$(SYSTEM_FILE).o  $(SOFTWARE_NAME)/$(STARTUP_FILE).o -o $@

$(SOFTWARE_NAME)/$(SOFTWARE_NAME).hex : $(SOFTWARE_NAME)/$(SOFTWARE_NAME).ELF $(DEPS_LIST)
	fromelf --vhx --8x1 $< --output $@

$(SOFTWARE_NAME)/$(SOFTWARE_NAME).lst : $(SOFTWARE_NAME)/$(SOFTWARE_NAME).ELF $(DEPS_LIST)
	fromelf -c -d -e -s $< --output $@

# ---------------------------------------------------------------------------------------
# gcc

all_gcc:
	$(GNG_CC) $(GNU_CC_FLAGS) $(STARTUP_DIR)/$(STARTUP_FILE).s \
		$(SOFTWARE_DIR)/common/bootloader/$(SOFTWARE_NAME).c \
		$(DEVICE_DIR)/Source/$(SYSTEM_FILE).c \
		-I $(DEVICE_DIR)/Include -I $(CORE_DIR) \
		-L $(LINKER_SCRIPT_PATH) \
		-D__STACK_SIZE=0x200 \
		-D__HEAP_SIZE=0x1000 \
		$(USER_DEFINE) -T $(LINKER_SCRIPT) -o $(SOFTWARE_NAME)/$(SOFTWARE_NAME).o
	# Generate disassembly code
	$(GNU_OBJDUMP) -S $(SOFTWARE_NAME)/$(SOFTWARE_NAME).o > $(SOFTWARE_NAME)/$(SOFTWARE_NAME).lst
	# Generate binary file
	$(GNU_OBJCOPY) -S $(SOFTWARE_NAME)/$(SOFTWARE_NAME).o -O binary $(SOFTWARE_NAME)/$(SOFTWARE_NAME).bin
	# Generate hex file
	$(GNU_OBJCOPY) -S $(SOFTWARE_NAME)/$(SOFTWARE_NAME).o --adjust-vma -0x10000000 -O verilog $(SOFTWARE_NAME)/$(SOFTWARE_NAME).hex

# Note:
# Objcopy use --adjust-vma so that the Verilog hex address start at address 0 instead of actual address 0x10000000
#
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

all_bin: $(SOFTWARE_NAME)/$(SOFTWARE_NAME).bin
	# Generate hex file from binary
	od -v -A n -t x1 --width=1  $(SOFTWARE_NAME)/$(SOFTWARE_NAME).bin > $(SOFTWARE_NAME)/$(SOFTWARE_NAME).hex

# ---------------------------------------------------------------------------------------
# Clean
clean :
	@rm -rf *.o
	@if [ -e $(SOFTWARE_NAME)/$(SOFTWARE_NAME).hex ] ; then \
	  rm -rf $(SOFTWARE_NAME)/$(SOFTWARE_NAME).hex ; \
	fi
	@if [ -e $(SOFTWARE_NAME)/$(SOFTWARE_NAME).lst ] ; then \
	  rm -rf $(SOFTWARE_NAME)/$(SOFTWARE_NAME).lst ; \
	fi
	@if [ -e $(SOFTWARE_NAME)/$(SOFTWARE_NAME).ELF ] ; then \
	  rm -rf $(SOFTWARE_NAME)/$(SOFTWARE_NAME).ELF ; \
	fi
	@if [ -e $(SOFTWARE_NAME)/$(SOFTWARE_NAME).bin ] ; then \
	  rm -rf $(SOFTWARE_NAME)/$(SOFTWARE_NAME).bin ; \
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

