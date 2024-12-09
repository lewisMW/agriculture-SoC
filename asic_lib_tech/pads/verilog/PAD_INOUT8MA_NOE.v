// from GLIB_PADLIB.v
//-----------------------------------------------------------------------------
// soclabs generic IO pad model
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright � 2022, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

`timescale 1ns/1ps

module PAD_INOUT8MA_NOE (
   // Inouts
   PAD, 
   // Outputs
   O, 
   // Inputs
   I,
   NOE
   );
   inout PAD;
   output I;
   input O;
   input NOE;

   bufif1 #2 (PAD, O, ~NOE);
   buf #1 (I, PAD);
endmodule // PAD_INOUT8MA_NOE
