#-----------------------------------------------------------------------------
# SoC Labs Environment Setup Script
# A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
#
# Contributors
#
# David Mapstone (d.a.mapstone@soton.ac.uk)
#
# Copyright  2023, SoC Labs (www.soclabs.org)
#-----------------------------------------------------------------------------
#!/bin/bash

# Source set_env script from soctools_flow
source soctools_flow/bin/project_setup.sh $@
if [ ! -f .dma350_configured ]; then
    if [ ! -f $ARM_IP_LIBRARY_PATH/DMA-350/CG096-r0p0-00rel0/CG096-BU-50000-r0p0-00rel0/dma350/logical/models/modules/generic/address_map_m1_nanosoc.sv ]; then
        cp nanosoc_tech/nanosoc/sldma350_tech/config/address_map_m1_nanosoc.sv $ARM_IP_LIBRARY_PATH/DMA-350/CG096-r0p0-00rel0/CG096-BU-50000-r0p0-00rel0/dma350/logical/models/modules/generic/address_map_m1_nanosoc.sv
    fi
    make -C nanosoc_tech/nanosoc/sldma350_tech/ config_dma_ahb
    touch .dma350_configured
fi
