//-----------------------------------------------------------------------------
// SLDMA230 Arm DMA230 Lint Design Info File
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright � 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract : HAL Design Info File for Blackboxing Arm IP for DMA230
//-----------------------------------------------------------------------------

bb_list
{
    // Exclude PL230 as Arm IP
    designunit = pl230_udma;
    file = $ARM_IP_LIBRARY_PATH/latest/DMA-230/logical/pl230_udma.v;
}