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

module PAD_INOUT8MA_OE (
   // Inouts
   PAD, 
   // Outputs
   O, 
   // Inputs
   I,
   OE
   );
   inout PAD;
   output I;
   input O;
   input OE;
`ifdef BEHAVIORAL_PADS
   assign I = PAD;
   assign PAD = OE ? O : 1'bz; 
`else
   bufif1 #2 (PAD, O, OE);
   buf #1 (I, PAD);

   always @(PAD)
     begin
       if (($countdrivers(PAD) > 1) && (PAD === 1'bx))
         $display("%t ++BUS CONFLICT++ : %m", $realtime);
     end
`endif // ifdef BEHAVIORAL_PADS
endmodule // PAD_INOUT8MA_OE
