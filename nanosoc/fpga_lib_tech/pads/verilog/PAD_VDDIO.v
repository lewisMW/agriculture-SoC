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

module PAD_VDDIO (
   // Inouts
   PAD
   );
   inout PAD;

  IOBUF #(
    .IOSTANDARD ("LVCMOS33"),
    .DRIVE(8)
  ) IOBUF3V3 (
    .O( ),
    .IO(PAD),
    .I(1'b1),
    .T(1'b1)
  );
   
endmodule // PAD_VDDIO
