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

`ifdef BEHAVIORAL_PADS
   assign I = PAD;
   assign PAD = ~NOE ? O : 1'bz; 
`else
   bufif1 #2 (PAD, O, ~NOE);
   buf #1 (I, PAD);
   always @(PAD)
     begin
       if (($countdrivers(PAD) > 1) && (PAD === 1'bx))
         $display("%t ++BUS CONFLICT++ : %m", $realtime);
     end
`endif // ifdef BEHAVIORAL_PADS
endmodule // PAD_INOUT8MA_NOE
