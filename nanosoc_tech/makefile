

#-----------------------------------------------------------------------------
# NanoSoC Top-Level Makefile 
# - Includes other Makefiles in flow directory
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Flynn (d.w.flynn@soton.ac.uk)
#
# Copyright (C) 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------
include $(SOCLABS_PROJECT_DIR)/nanosoc.config

#-------------------------------------
# - Commonly Overloaded Variables
#-------------------------------------
# Name of test directory - Default Test is Hello World
TESTNAME   ?= hello

# Simulator type (mti/vcs/xm)
SIMULATOR   = mti

# Is an accelerator subsystem present in the design?
ACCELERATOR ?= yes

# Is the Arm QuickStart being used?
QUICKSTART ?= no

# IS this for an ASIC Flow?
ASIC ?= no

# Are simulations to be run in fast mode? (i.e. RAMs preloaded)
FAST_SIM ?= yes

#-------------------------------------
# - Directory Setups
#-------------------------------------
# Directory of Testcodes
TESTCODES_DIR    := $(SOCLABS_NANOSOC_TECH_DIR)/testcodes

# Project System Directory
FPGA_IMP_DIR     := $(SOCLABS_PROJECT_DIR)/imp/fpga
PROJ_SYS_DIR     := $(SOCLABS_PROJECT_DIR)/system
PROJ_SW_DIR      ?= $(PROJ_SYS_DIR)/testcodes

# Directory to put simulation files
SIM_TOP_DIR ?= $(SOCLABS_PROJECT_DIR)/simulate/sim
SIM_DIR      = $(SIM_TOP_DIR)/$(TESTNAME)

#-------------------------------------
# - Test List Variables
#-------------------------------------
# List of all tests (this is used when running 'make all/clean')
TEST_LIST_FILE   ?= $(TESTCODES_DIR)/software_list.txt
TEST_LIST_FILE   += $(PROJ_SW_DIR)/software_list.txt
TEST_LIST         = $(shell cat $(TEST_LIST_FILE) | while read line || [ -n "$$line" ]; do echo $$line; done)

# List of Tests to Exclude from Regression
EXCLUDE_LIST_FLIE = $(PROJ_SW_DIR)/regression_exclude.txt

#-------------------------------------
# - Verilog Defines and Filelists
#-------------------------------------
# Simulator/Lint Defines
DEFINES_VC  += +define+CORTEX_M0 +define+USE_TARMAC 

# Set Variables depending on whether Accelerator is in System
ifeq ($(ACCELERATOR),yes)
	DEFINES_VC += +define+ACCELERATOR_SUBSYSTEM
	NANOSOC_DEFINES += ACCELERATOR_SUBSYSTEM
endif

# Set variables for tesbench if fast simulation
ifeq ($(FAST_SIM),yes)
	DEFINES_VC += +define+FAST_SIM
	NANOSOC_DEFINES += FAST_SIM
endif

ifdef DMA_DMA350_INCLUDE
	ifdef DMA350_SMALL
		NANOSOC_DEFINES += DMAC_DMA350
		FLIST_INCLUDES += $(SOCLABS_SLDMA350_TECH_DIR)/flist/sldma350_ahb_small.flist
	endif
	ifdef DMA350_DEFAULT
		NANOSOC_DEFINES += DMAC_DMA350 DMA350_STREAM_2
		FLIST_INCLUDES += $(SOCLABS_SLDMA350_TECH_DIR)/flist/sldma350_ahb.flist
	endif
	ifdef DMA350_BIG
		NANOSOC_DEFINES += DMAC_DMA350 DMA350_STREAM_2 DMA350_STREAM_3
		FLIST_INCLUDES += $(SOCLABS_SLDMA350_TECH_DIR)/flist/sldma350_ahb_big.flist
	endif
else 
	ifdef DMA_0_PL230_INCLUDE
		NANOSOC_DEFINES += DMAC_0_PL230
		FLIST_INCLUDES +=$(SOCLABS_SLDMA230_TECH_DIR)/flist/sldma230_ip.flist
	endif 
	ifdef DMA_1_PL230_INCLUDE
		NANOSOC_DEFINES += DMAC_1_PL230
		FLIST_INCLUDES +=$(SOCLABS_SLDMA230_TECH_DIR)/flist/sldma230_ip.flist
	endif
endif

ifdef ADC_0_INCLUDE
	AMS = yes
	NANOSOC_DEFINES += AMS_PERIPHERALS ADC_0_INCLUDE
	FLIST_INCLUDES += $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/sl_ams_tech/SL_ADC_8bits/flist/sl_adc_8bits_ip.flist
endif

ifdef ADC_1_INCLUDE
	AMS = yes
	NANOSOC_DEFINES += AMS_PERIPHERALS ADC_1_INCLUDE
	FLIST_INCLUDES += $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/sl_ams_tech/SL_ADC_8bits/flist/sl_adc_8bits_ip.flist
endif

ifdef ADC_2_INCLUDE
	AMS = yes
	NANOSOC_DEFINES += AMS_PERIPHERALS ADC_2_INCLUDE
	FLIST_INCLUDES += $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/sl_ams_tech/SL_ADC_8bits/flist/sl_adc_8bits_ip.flist
endif

ifdef ADC_3_INCLUDE
	AMS = yes
	NANOSOC_DEFINES += AMS_PERIPHERALS ADC_3_INCLUDE
	FLIST_INCLUDES += $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/sl_ams_tech/SL_ADC_8bits/flist/sl_adc_8bits_ip.flist
endif

ifdef SNPS_PVT_TS_0_INCLUDE
	NANOSOC_DEFINES += SNPS_PVT_MONITORING SNPS_PVT_TS_0_INCLUDE
	FLIST_INCLUDES  += $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/synopsys_28nm_slm_integration/flist/synopsys_pvt_ip.flist
endif

ifdef SNPS_PVT_TS_1_INCLUDE
	NANOSOC_DEFINES += SNPS_PVT_MONITORING SNPS_PVT_TS_1_INCLUDE
	FLIST_INCLUDES  += $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/synopsys_28nm_slm_integration/flist/synopsys_pvt_ip.flist
endif

ifdef SNPS_PVT_TS_2_INCLUDE
	NANOSOC_DEFINES += SNPS_PVT_MONITORING SNPS_PVT_TS_2_INCLUDE
	FLIST_INCLUDES  += $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/synopsys_28nm_slm_integration/flist/synopsys_pvt_ip.flist
endif

ifdef SNPS_PVT_TS_3_INCLUDE
	NANOSOC_DEFINES += SNPS_PVT_MONITORING SNPS_PVT_TS_3_INCLUDE
	FLIST_INCLUDES  += $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/synopsys_28nm_slm_integration/flist/synopsys_pvt_ip.flist
endif

ifdef SNPS_PVT_TS_4_INCLUDE
	NANOSOC_DEFINES += SNPS_PVT_MONITORING SNPS_PVT_TS_4_INCLUDE
	FLIST_INCLUDES  += $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/synopsys_28nm_slm_integration/flist/synopsys_pvt_ip.flist
endif

ifdef SNPS_PVT_TS_5_INCLUDE
	NANOSOC_DEFINES += SNPS_PVT_MONITORING SNPS_PVT_TS_5_INCLUDE
	FLIST_INCLUDES  += $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/synopsys_28nm_slm_integration/flist/synopsys_pvt_ip.flist
endif

ifdef SNPS_PVT_PD_0_INCLUDE
	NANOSOC_DEFINES += SNPS_PVT_MONITORING SNPS_PVT_PD_0_INCLUDE
	FLIST_INCLUDES  += $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/synopsys_28nm_slm_integration/flist/synopsys_pvt_ip.flist
endif

ifdef SNPS_PVT_VM_0_INCLUDE
	NANOSOC_DEFINES += SNPS_PVT_MONITORING SNPS_PVT_VM_0_INCLUDE
	FLIST_INCLUDES  += $(SOCLABS_NANOSOC_TECH_DIR)/nanosoc/synopsys_28nm_slm_integration/flist/synopsys_pvt_ip.flist
endif


# System Design Filelist
ifeq ($(QUICKSTART),yes)
	DESIGN_VC            ?= $(SOCLABS_PROJECT_DIR)/flist/project/top_qs.flist
	TBENCH_VC            ?= $(SOCLABS_PROJECT_DIR)/flist/project/top_qs.flist
	ARM_CORSTONE_101_DIR ?= $(ARM_IP_LIBRARY_PATH)/latest/Cortex-M0-QS/Corstone-101-logical
	ARM_CORTEX_M0_DIR    ?= $(ARM_IP_LIBRARY_PATH)/latest/Cortex-M0-QS/Cortex-M0-logical
	TB_TOP               ?= nanosoc_tb_qs
else 
	ifeq ($(ASIC),yes)
		DESIGN_VC            ?= $(SOCLABS_PROJECT_DIR)/flist/project/top_ASIC.flist
		ARM_CORSTONE_101_DIR ?= $(ARM_IP_LIBRARY_PATH)/latest/Corstone-101/logical
		ARM_CORTEX_M0_DIR    ?= $(ARM_IP_LIBRARY_PATH)/latest/Cortex-M0/logical
		NANOSOC_DEFINES      += ASIC_TEST_PORTS POWER_PINS
	else
		DESIGN_VC            ?= $(SOCLABS_PROJECT_DIR)/flist/project/top.flist
		TBENCH_VC            ?= $(SOCLABS_PROJECT_DIR)/flist/project/top.flist
		TB_TOP               ?= nanosoc_tb
	endif
endif

# Make variables visible to target shells
export ARM_CORTEX_M0_DIR
export ARM_CORSTONE_101_DIR
export FLIST_INCLUDES
export AMS
# Location of Defines File
DEFINES_DIR   := $(SOCLABS_PROJECT_DIR)/system/src/defines/
DEFINES_FILE  := $(DEFINES_DIR)/gen_defines.v

#------------------------------------------
# - Include Makefiles for Specific Flows
#------------------------------------------
# Include Software Compilation Makefile
include $(SOCLABS_NANOSOC_TECH_DIR)/flows/makefile.software

# Include Linting Makefile
include $(SOCLABS_NANOSOC_TECH_DIR)/flows/makefile.lint

# Include Simulation Makefile
include $(SOCLABS_NANOSOC_TECH_DIR)/flows/makefile.simulate

# Include Regression Simulation Makefile
include $(SOCLABS_NANOSOC_TECH_DIR)/flows/makefile.regression

# Include FPGA Makefile
include $(SOCLABS_NANOSOC_TECH_DIR)/flows/makefile.fpga

# Include Synthesis Makefile
include $(SOCLABS_NANOSOC_TECH_DIR)/flows/makefile.asic

#------------------------------------------
# - Common Targets Across Flows
#------------------------------------------
# Generate Defines File for NanoSoC
gen_defs:
	@mkdir -p $(DEFINES_DIR)
	@$(SOCLABS_SOCTOOLS_FLOW_DIR)/bin/defines_compile.py -d $(NANOSOC_DEFINES) -o $(DEFINES_FILE)
	
TEST_AMS:
	$(info AMS is $(AMS))
	$(info VCS OPTIONS is $(VCS_OPTIONS))
# Remove RTL compile files, log files, software compile files
clean : clean_all_code
	@rm -rf $(SIM_TOP_DIR)
