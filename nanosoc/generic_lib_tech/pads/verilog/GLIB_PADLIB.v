// GLIB_PADLIB.v
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

module PAD_VDDIO (
   PAD
   );
   inout PAD;
endmodule // PAD_VDDIO

module PAD_VSSIO (
   PAD
   );
   inout PAD;
endmodule // PAD_VSSSIO

// core logic supply rails (1V0, 0V)
module PAD_VDDSOC (
   PAD
   );
   inout PAD;
endmodule // PAD_VDDSOC

module PAD_VSS (
   PAD
   );
   inout PAD;
endmodule // PAD_VSS

// VDDISOL
module PAD_ANALOG (
   PAD
   );
   inout PAD;
endmodule // PAD_ANALOG

`ifdef TSMC_PADS

// VDDSOC
module PVDD1CDG (
   inout wire VDD
   );
endmodule // PVDD1CDG

//VDDIO
module PVDD2CDG (
   inout wire VDDPST
   );
endmodule // PVDD2CDG

module PVDD2POC (
   inout wire VDDPST
   );
endmodule // PVDD2CDG

module PVSS3CDG (
   inout wire VSS
   );
endmodule // PVSS3CDG

// VDDISOL
module PVDD1ANA (
   inout wire AVDD
   );
endmodule // PVDD1ANA


module PCORNER     ( ); endmodule
module PFILLER20   ( ); endmodule
module PFILLER1    ( ); endmodule
module PFILLER0005 ( ); endmodule

module PAD60LU     ( ); endmodule

`endif
