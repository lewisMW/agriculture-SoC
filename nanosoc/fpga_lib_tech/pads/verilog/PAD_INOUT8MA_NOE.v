// from GLIB_PADLIB.v
//-----------------------------------------------------------------------------
// soclabs generic IO pad model
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright © 2022, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module PAD_INOUT8MA_NOE (
   // Inouts
   PAD, 
   // Outputs
   I, 
   // Inputs
   O,
   NOE
   );
   inout PAD;
   output I;
   input O;
   input NOE;

  IOBUF #(
    .IOSTANDARD ("LVCMOS33"),
    .DRIVE(8)
  ) IOBUF3V3 (
    .O(I),
    .IO(PAD),
    .I(O),
    .T(NOE)
  );
    
endmodule // PAD_INOUT8MA_NOE
