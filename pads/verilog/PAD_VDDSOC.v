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

// core logic supply rails (1V0, 0V)
module PAD_VDDSOC (
   PAD
   );
   inout PAD;
   assign PAD = 1'b1;
endmodule // PAD_VDDSOC
