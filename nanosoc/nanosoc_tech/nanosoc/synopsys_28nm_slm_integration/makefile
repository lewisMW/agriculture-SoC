
#-------------------------------------
# - Commonly Overloaded Variables
#-------------------------------------
# Simulator type (mti/vcs/xm)
SIMULATOR   = vcs

GATE_SIM ?= no

IP ?= PLL

#-------------------------------------
# - Directory Setups
#-------------------------------------
# Directory to put simulation files
SIM_TOP_DIR ?= $(SOCLABS_SNPS_28NM_IP_DIR)/simulate/sim
SIM_DIR ?= $(SIM_TOP_DIR)

ifeq ($(IP),PLL)
	COCOTB_IP_DIR = PLL_integration
	ifeq ($(GATE_SIM),yes)
		DESIGN_VC ?= $(SOCLABS_SNPS_28NM_IP_DIR)/flist/VIP/synopsys_PLL_VIP_gate.flist
	else
		DESIGN_VC ?= $(SOCLABS_SNPS_28NM_IP_DIR)/flist/VIP/synopsys_PLL_VIP.flist
	endif
else ifeq ($(IP),PD)
	COCOTB_IP_DIR = PD_integration
	ifeq ($(GATE_SIM),yes)
		DESIGN_VC ?= $(SOCLABS_SNPS_28NM_IP_DIR)/flist/VIP/synopsys_PD_VIP_gate.flist
	else
		DESIGN_VC ?= $(SOCLABS_SNPS_28NM_IP_DIR)/flist/VIP/synopsys_PD_VIP.flist
	endif
else ifeq ($(IP),TS)
	COCOTB_IP_DIR = TS_integration
	ifeq ($(GATE_SIM),yes)
		DESIGN_VC ?= $(SOCLABS_SNPS_28NM_IP_DIR)/flist/VIP/synopsys_TS_VIP_gate.flist
	else
		DESIGN_VC ?= $(SOCLABS_SNPS_28NM_IP_DIR)/flist/VIP/synopsys_TS_VIP.flist
	endif
else ifeq ($(IP),VM)
	COCOTB_IP_DIR = VM_integration
	ifeq ($(GATE_SIM),yes)
		DESIGN_VC ?= $(SOCLABS_SNPS_28NM_IP_DIR)/flist/VIP/synopsys_VM_VIP_gate.flist
	else
		DESIGN_VC ?= $(SOCLABS_SNPS_28NM_IP_DIR)/flist/VIP/synopsys_VM_VIP.flist
	endif

endif


include ./flows/makefile.simulate
include ./flows/makefile.ASIC