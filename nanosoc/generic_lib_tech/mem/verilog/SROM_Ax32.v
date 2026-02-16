//-----------------------------------------------------------------------------
//
// Synthesizable byte-write addressible R/W (random-access) memory
//
// Synchronous data write, flow-though (non-pipeline registered) read data
//
// Auto-gernerates a synthesizable verilog ROM design
// and binary text file for custom ROM via programming
//
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright � 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module SROM_Ax32
  #(parameter ADDRWIDTH = 10,
    parameter filename = "rom32.hex",
    parameter romgen = 0
   )
   (input  wire CLK,
    input  wire [ADDRWIDTH-1:0] ADDR, //Address Input
    input  wire SEL,                  //Select (active-high)
    output wire [31:0] RDATA);        //Read Data
    
   localparam MEMDEPTH = (1 << (ADDRWIDTH)-1)-1;
   localparam romgenfile = "bootrom/verilog/bootrom.v";
   localparam bingenfile = "bootrom/bintxt/bootrom.bintxt";

   // Reg declarations
   reg  [7:0] rombyte0 [0:MEMDEPTH];
   reg  [7:0] rombyte1 [0:MEMDEPTH];
   reg  [7:0] rombyte2 [0:MEMDEPTH];
   reg  [7:0] rombyte3 [0:MEMDEPTH];

   reg  [ADDRWIDTH-1:0] addr_r;  // registered Address for read access

// optional simulation RAM_INIT option to suppress 'X' initial contents
`ifdef MEM_INIT
  reg [7:0] fileimage [((4<<ADDRWIDTH)-1):0];
  function [31:0] NoX32; input [31:0] n; NoX32 = (((^n) === 1'bx) ? 32'h0 : n); endfunction
  integer fd; // file descriptor for file output
  integer fd2; // file descriptor for file 2 output
  integer i;
  reg [39:0] today [0:1];
  
initial
  begin
    $system("date +%y%m%d%H%M >date_file"); //format yymmdd
    $readmemh("date_file", today);
    $display("data_file: %x", today[0]);
    
    for (i=0; i<= MEMDEPTH; i=i+1) begin
      rombyte0[i] <= 8'he5;
      rombyte1[i] <= 8'he5;
      rombyte2[i] <= 8'he5;
      rombyte3[i] <= 8'he5;
      end
    if (filename != "") begin
      $readmemh(filename, fileimage);
      for (i = 0; i <= MEMDEPTH; i=i+1) begin
        rombyte0[i] <= fileimage[(i<<2)+0];
        rombyte1[i] <= fileimage[(i<<2)+1];
        rombyte2[i] <= fileimage[(i<<2)+2];
        rombyte3[i] <= fileimage[(i<<2)+3];
        end
      end
    if (romgen != 0)
      begin
       fd = $fopen(romgenfile);
       fd2 = $fopen(bingenfile);
       if ((fd == 0) || (fd2 == 0)) begin
         $display("rom32gen: Error, zero returned in response to $fopen\n");
       end
       else begin
         $display(fd,"rom32gen: Generating output file\n");
         $fwrite(fd,"//------------------------------------------------------------------------------------\n");
         $fwrite(fd,"// customised auto-generated synthesizable ROM module abstraction\n");
         $fwrite(fd,"// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.\n");
         $fwrite(fd,"//\n");
         $fwrite(fd,"// Contributors\n");
         $fwrite(fd,"//\n");
         $fwrite(fd,"// David Flynn (d.w.flynn@soton.ac.uk)\n");
         $fwrite(fd,"//    Date:    %x\n", today[0]);
         $fwrite(fd,"// Copyright (c) 2021-3, SoC Labs (www.soclabs.org)\n");
         $fwrite(fd,"//------------------------------------------------------------------------------------\n");
         $fwrite(fd,"module bootrom (\n");
         $fwrite(fd,"  input  wire CLK,\n");
         $fwrite(fd,"  input  wire EN,\n");
         $fwrite(fd,"  input  wire [%0d:2] ADDR,\n", ADDRWIDTH+1);
         $fwrite(fd,"  output reg [31:0] RDATA );\n");
         $fwrite(fd,"reg [%0d:2] addr_r;\n", ADDRWIDTH+1);
         $fwrite(fd,"always @(posedge CLK) if (EN) addr_r <= ADDR;\n");
         $fwrite(fd,"always @(addr_r)\n");
         $fwrite(fd,"  case(addr_r[%0d:2]) \n", ADDRWIDTH+1);
         if (ADDRWIDTH > 8)
           for (i = 0; i < 4 << (ADDRWIDTH); i=i+4) begin
             $fwrite(fd,"    %2d'h%3x : RDATA <= 32'h%8x; // 0x%04x\n", ADDRWIDTH, i>>2, NoX32({fileimage[i+3],fileimage[i+2],fileimage[i+1],fileimage[i+0]}), i );
             $fwrite(fd2,"%32b\n",NoX32({fileimage[i+3],fileimage[i+2],fileimage[i+1],fileimage[i+0]}));
             end
         else
           for (i = 0; i < 4 << (ADDRWIDTH); i=i+4) begin
             $fwrite(fd,"    %2d'h%2x : RDATA <= 32'h%8x; // 0x%04x\n", ADDRWIDTH, i>>2, NoX32({fileimage[i+3],fileimage[i+2],fileimage[i+1],fileimage[i+0]}), i );
             $fwrite(fd2,"%32b\n",NoX32({fileimage[i+3],fileimage[i+2],fileimage[i+1],fileimage[i+0]}));
             end
         $fwrite(fd,"    default : RDATA <=32'h0;\n");
         $fwrite(fd,"  endcase\n");
         $fwrite(fd,"endmodule\n");
         $fclose(fd);
         $fclose(fd2);
       end
      end
  end
`endif

// synchonous address and control
   
  always @(posedge CLK) // update on any byte lane read
    if (SEL)
      addr_r <= ADDR[ADDRWIDTH-1:0];

  assign RDATA = {rombyte3[addr_r],rombyte2[addr_r],rombyte1[addr_r],rombyte0[addr_r]};
   
endmodule
