//-----------------------------------------------------------------------------
// NanoSoC Blackbox Lint Design Info File
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright � 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract : HAL Design Info File for Blackboxing NanoSoC IP Generated from Arm Scripts
//-----------------------------------------------------------------------------

bb_list
{
    // Exclude Bus Matrix as Generated from Arm IP
    designunit = nanosoc_busmatrix_lite;
    file = $SOCLABS_NANOSOC_TECH_DIR/nanosoc/nanosoc_busmatrix/verilog/nanosoc_busmatrix/nanosoc_busmatrix_lite.v;
    
    // Temporarily Exclude SoCDebug
    designunit = socdebug_ahb;
    file = $SOCLABS_NANOSOC_TECH_DIR/nanosoc/socdebug_tech/controller/verilog/socdebug_ahb.v;
    
    // Temporarily Exclude Accelerator Subsystem (just linting NanoSoC)
    designunit = accelerator_subsystem;
    file = $SOCLABS_PROJECT_DIR/system/src/accelerator_subsystem.v;
    
    // Exclude Pads
    designunit = PAD_INOUT8MA_NOE;
    file = $SOCLABS_GENERIC_LIB_TECH_DIR/pads/verilog/PAD_INOUT8MA_NOE.v;
}