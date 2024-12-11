#-----------------------------------------------------------------------------
# HTML Generatoration Makefile 
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
#
# Copyright � 2021-3, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------

# Top-level module of Hierarchy
TOP_MODULE      ?= nanosoc_chip

# Filelist to give to v2html
FILELIST        ?= $(SOCLABS_PROJECT_DIR)/flist/project/top.flist

# Directory to store generated HTML
OUT_DIR         ?= $(SOCLABS_PROJECT_DIR)/html

# Name of generated filelist by python script
OUTPUT_FILELIST := $(OUT_DIR)/filelist.flist

gen_html:
	@echo building HTML tree
	@mkdir -p $(OUT_DIR)/build
	@echo Output Directory is $(OUT_DIR)/build
	@echo Filelist is $(FILELIST)
	$(MAKE) -C $(SOCLABS_NANOSOC_TECH_DIR) gen_defs
	$(MAKE) -C $(SOCLABS_NANOSOC_TECH_DIR) bootrom
	@(cd $(OUT_DIR)/build; \
	rm *.html; rm *.gif; \
	$(SOCLABS_SOCTOOLS_FLOW_DIR)/bin/filelist_compile.py -eanv -f $(FILELIST) -o $(OUTPUT_FILELIST) ; \
	$(SOCLABS_SOCTOOLS_FLOW_DIR)/bin/htmlgen/v2html/v2html -f $(OUTPUT_FILELIST) -ht $(TOP_MODULE) ; )
