//-----------------------------------------------------------------------------
// SoCDebug ASCII Debug Protocol Controller
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (C) 2021-3, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

//`define ADPBASIC 1
`define ADPFSMDESIGN 1

module socdebug_adp_control #(
  parameter PROMPT_CHAR = "]"
)(  
  // AHB-lite interface
  input  wire        HCLK,
  input  wire        HRESETn,
  output wire [31:0] HADDR32_o,
  output wire [ 2:0] HBURST3_o,
  output wire        HMASTLOCK_o,
  output wire [ 3:0] HPROT4_o,
  output wire [ 2:0] HSIZE3_o,
  output wire [ 1:0] HTRANS2_o,
  output wire [31:0] HWDATA32_o,
  output wire        HWRITE_o,
  input  wire [31:0] HRDATA32_i,
  input  wire        HREADY_i,
  input  wire        HRESP_i,
  
  // GPIO Interface
  output wire [ 7:0] GPO8_o,
  input  wire [ 7:0] GPI8_i,
  
  // COMIO interface
  input  wire [ 7:0] COMRX_TDATA_i,
  input  wire        COMRX_TVALID_i,
  output wire        COMRX_TREADY_o,
  output wire [ 7:0] COMTX_TDATA_o,
  output wire        COMTX_TVALID_o,
  input  wire        COMTX_TREADY_i,
  
  // STDIO interface
  input  wire [ 7:0] STDRX_TDATA_i,
  input  wire        STDRX_TVALID_i,
  output wire        STDRX_TREADY_o,
  output wire [ 7:0] STDTX_TDATA_o,
  output wire        STDTX_TVALID_o,
  input  wire        STDTX_TREADY_i
);

wire COM_RXE_i = !COMRX_TVALID_i;
wire COM_TXF_i = !COMTX_TREADY_i;

//wire adp_rx_req = COMRX_TVALID_i & COMRX_TREADY_o;
//wire std_rx_req = STDRX_TVALID_i & STDRX_TREADY_o;


wire STD_TXF_i = !STDTX_TREADY_i;
wire STD_RXE_i = !STDRX_TVALID_i;

`ifdef ADPBASIC
  localparam BANNERHEX = 32'h50c1ab01;
`else
  localparam BANNERHEX = 32'h50c1ab04;
`endif

//localparam CMD_NUL   = 4'b0000;
localparam CMD_A   = 4'b0001;  // set Address
localparam CMD_C   = 4'b0010;  // Control
localparam CMD_R   = 4'b0011;  // Read word, addr++
localparam CMD_S   = 4'b0100;  // Status/STDIN
localparam CMD_W   = 4'b0101;  // Write word, addr++
localparam CMD_X   = 4'b0110;  // eXit
`ifndef ADPBASIC
localparam CMD_F   = 4'b1000;  // Fill (wordocunt) from addr++
localparam CMD_M   = 4'b1001;  // set read Mask
localparam CMD_P   = 4'b1010;  // Poll hardware  (count)
localparam CMD_U   = 4'b1011;  // (Binary) Upload (wordocunt) from addr++
localparam CMD_V   = 4'b1100;  // match Value
`endif


function FNvalid_adp_entry; // Escape char
input [7:0] char8;
  FNvalid_adp_entry = (char8[7:0] ==  8'h1b);
endfunction

function [3:0] FNvalid_cmd;
input [7:0] char8;
case (char8[7:0])
"A": FNvalid_cmd = CMD_A;
"a": FNvalid_cmd = CMD_A;
"C": FNvalid_cmd = CMD_C;
"c": FNvalid_cmd = CMD_C;
"R": FNvalid_cmd = CMD_R;
"r": FNvalid_cmd = CMD_R;
"S": FNvalid_cmd = CMD_S;
"s": FNvalid_cmd = CMD_S;
"W": FNvalid_cmd = CMD_W;
"w": FNvalid_cmd = CMD_W;
"X": FNvalid_cmd = CMD_X;
"x": FNvalid_cmd = CMD_X;
`ifndef ADPBASIC
"F": FNvalid_cmd = CMD_F;
"f": FNvalid_cmd = CMD_F;
"M": FNvalid_cmd = CMD_M;
"m": FNvalid_cmd = CMD_M;
"P": FNvalid_cmd = CMD_P;
"p": FNvalid_cmd = CMD_P;
"U": FNvalid_cmd = CMD_U;
"u": FNvalid_cmd = CMD_U;
"V": FNvalid_cmd = CMD_V;
"v": FNvalid_cmd = CMD_V;
`endif
default:
      FNvalid_cmd = 4'b0000;
endcase
endfunction

function FNvalid_space; // space or tab char
input [7:0] char8;
  FNvalid_space = ((char8[7:0] == 8'h20) || (char8[7:0] == 8'h09));
endfunction

//function FNnull; // space or tab char
//input [7:0] char8;
//  FNnull = (char8[7:0] == 8'h00);
//endfunction

function FNexit; // EOF
input [7:0] char8;
  FNexit = ((char8[7:0] == 8'h04) || (char8[7:0] == 8'h00));
endfunction

function FNvalid_EOL; // CR or LF
input [7:0] char8;
  FNvalid_EOL = ((char8[7:0] == 8'h0a) || (char8[7:0] == 8'h0d));
endfunction


function [2:0] FNsize_inc;
// top 2 bits encode 01 (byte), 10 (halfword), 11 (word) 00 - no parameter
input [2:0] cnt8;
case (cnt8[2:0])
3'b000: FNsize_inc = 3'b010;
3'b010: FNsize_inc = 3'b011;
3'b011: FNsize_inc = 3'b100;
3'b100: FNsize_inc = 3'b101;
default:
  FNsize_inc = 3'b111;
endcase
endfunction

function [1:0] FNparam2size;
// top 2 bits encode 01 (byte), 10 (halfword), 11 (word) 00 - no parameter
input [1:0] parm2;
case (parm2[1:0])
2'b01: FNparam2size = 2'b00; // 8-bit
2'b10: FNparam2size = 2'b01; // 16-bit
2'b11: FNparam2size = 2'b10; // 32-bit
default:
  FNparam2size = 2'b10;// default to 32-bit
endcase
endfunction

function [34:0] FNBuild_size3_param32_hexdigit;
input [34:0] param32;
input [7:0] char8;
case (char8[7:0])
"\t":FNBuild_size3_param32_hexdigit = {35{1'b0}}; // tab starts new (zeroed) param32
" ": FNBuild_size3_param32_hexdigit = {35{1'b0}}; // space starts new (zeroed) param32
"x": FNBuild_size3_param32_hexdigit = {35{1'b0}}; // hex prefix starts new (zeroed) param32
"X": FNBuild_size3_param32_hexdigit = {35{1'b0}}; // hex prefix starts new (zeroed) param32
"0": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b0000};
"1": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b0001};
"2": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b0010};
"3": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b0011};
"4": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b0100};
"5": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b0101};
"6": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b0110};
"7": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b0111};
"8": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b1000};
"9": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b1001};
"A": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b1010};
"B": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b1011};
"C": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b1100};
"D": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b1101};
"E": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b1110};
"F": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b1111};
"a": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b1010};
"b": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b1011};
"c": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b1100};
"d": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b1101};
"e": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b1110};
"f": FNBuild_size3_param32_hexdigit = {FNsize_inc(param32[34:32]),param32[27:0],4'b1111};
default: FNBuild_size3_param32_hexdigit = param32; // EOL etc returns param32 unchanged
endcase
endfunction


function [7:0] FNmap_hex_digit;
input [3:0] nibble;
case (nibble[3:0])
4'b0000: FNmap_hex_digit = "0" & 8'hff;
4'b0001: FNmap_hex_digit = "1" & 8'hff;
4'b0010: FNmap_hex_digit = "2" & 8'hff;
4'b0011: FNmap_hex_digit = "3" & 8'hff;
4'b0100: FNmap_hex_digit = "4" & 8'hff;
4'b0101: FNmap_hex_digit = "5" & 8'hff;
4'b0110: FNmap_hex_digit = "6" & 8'hff;
4'b0111: FNmap_hex_digit = "7" & 8'hff;
4'b1000: FNmap_hex_digit = "8" & 8'hff;
4'b1001: FNmap_hex_digit = "9" & 8'hff;
4'b1010: FNmap_hex_digit = "a" & 8'hff;
4'b1011: FNmap_hex_digit = "b" & 8'hff;
4'b1100: FNmap_hex_digit = "c" & 8'hff;
4'b1101: FNmap_hex_digit = "d" & 8'hff;
4'b1110: FNmap_hex_digit = "e" & 8'hff;
4'b1111: FNmap_hex_digit = "f" & 8'hff;
//default: FNmap_hex_digit = "0" & 8'hff;
endcase
endfunction

// as per Vivado synthesis mapping
`ifdef ADPFSMDESIGN
localparam   ADP_WRITEHEX = 6'b000000 ;
localparam  ADP_WRITEHEXS = 6'b000001 ;
localparam  ADP_WRITEHEX9 = 6'b000010 ;
localparam  ADP_WRITEHEX8 = 6'b000011 ;
localparam  ADP_WRITEHEX7 = 6'b000100 ;
localparam  ADP_WRITEHEX6 = 6'b000101 ;
localparam  ADP_WRITEHEX5 = 6'b000110 ;
localparam  ADP_WRITEHEX4 = 6'b000111 ;
localparam  ADP_WRITEHEX3 = 6'b001000 ;
localparam  ADP_WRITEHEX2 = 6'b001001 ;
localparam  ADP_WRITEHEX1 = 6'b001010 ;
localparam  ADP_WRITEHEX0 = 6'b001011 ;
localparam    ADP_LINEACK = 6'b001100 ;
localparam   ADP_LINEACK2 = 6'b001101 ;
localparam     ADP_PROMPT = 6'b001110 ;
localparam      ADP_IOCHK = 6'b001111 ;
localparam     ADP_STDOUT = 6'b010000 ;
localparam    ADP_STDOUT1 = 6'b010001 ;
localparam    ADP_STDOUT2 = 6'b010010 ;
localparam    ADP_STDOUT3 = 6'b010011 ;
localparam      ADP_RXCMD = 6'b010100 ;
localparam    ADP_RXPARAM = 6'b010101 ;
localparam     ADP_ACTION = 6'b010110 ;
localparam     ADP_SYSCTL = 6'b010111 ;
localparam       ADP_READ = 6'b011000 ;
localparam     ADP_SYSCHK = 6'b011001 ;
localparam      ADP_STDIN = 6'b011010 ;
localparam      ADP_WRITE = 6'b011011 ;
localparam       ADP_EXIT = 6'b011100 ;
localparam      STD_IOCHK = 6'b011101 ;
localparam       STD_RXD1 = 6'b011110 ;
localparam       STD_RXD2 = 6'b011111 ;
localparam       STD_TXD1 = 6'b100000 ;
localparam       STD_TXD2 = 6'b100001 ;
localparam      ADP_UCTRL = 6'b100010 ;
localparam     ADP_UREADB = 6'b100011 ;
localparam     ADP_UWRITE = 6'b100100 ;
localparam      ADP_POLL0 = 6'b100101 ;
localparam      ADP_POLL1 = 6'b100110 ;
localparam      ADP_POLL2 = 6'b100111 ;
localparam      ADP_FCTRL = 6'b101000 ;
localparam     ADP_FWRITE = 6'b101001 ;
localparam    ADP_ECHOCMD = 6'b101010 ;
localparam    ADP_ECHOBUS = 6'b101011 ;
localparam    ADP_UNKNOWN = 6'b101100 ;
reg  [5:0] adp_state   ;
`else
// one-hot encoded explicitly
localparam   ADP_WRITEHEX = 45'b000000000000000000000000000000000000000000001 ; // = 6'b000000 ;
localparam  ADP_WRITEHEXS = 45'b000000000000000000000000000000000000000000010 ; // = 6'b000001 ;
localparam  ADP_WRITEHEX9 = 45'b000000000000000000000000000000000000000000100 ; // = 6'b000010 ;
localparam  ADP_WRITEHEX8 = 45'b000000000000000000000000000000000000000001000 ; // = 6'b000011 ;
localparam  ADP_WRITEHEX7 = 45'b000000000000000000000000000000000000000010000 ; // = 6'b000100 ;
localparam  ADP_WRITEHEX6 = 45'b000000000000000000000000000000000000000100000 ; // = 6'b000101 ;
localparam  ADP_WRITEHEX5 = 45'b000000000000000000000000000000000000001000000 ; // = 6'b000110 ;
localparam  ADP_WRITEHEX4 = 45'b000000000000000000000000000000000000010000000 ; // = 6'b000111 ;
localparam  ADP_WRITEHEX3 = 45'b000000000000000000000000000000000000100000000 ; // = 6'b001000 ;
localparam  ADP_WRITEHEX2 = 45'b000000000000000000000000000000000001000000000 ; // = 6'b001001 ;
localparam  ADP_WRITEHEX1 = 45'b000000000000000000000000000000000010000000000 ; // = 6'b001010 ;
localparam  ADP_WRITEHEX0 = 45'b000000000000000000000000000000000100000000000 ; // = 6'b001011 ;
localparam    ADP_LINEACK = 45'b000000000000000000000000000000001000000000000 ; // = 6'b001100 ;
localparam   ADP_LINEACK2 = 45'b000000000000000000000000000000010000000000000 ; // = 6'b001101 ;
localparam     ADP_PROMPT = 45'b000000000000000000000000000000100000000000000 ; // = 6'b001110 ;
localparam      ADP_IOCHK = 45'b000000000000000000000000000001000000000000000 ; // = 6'b001111 ;
localparam     ADP_STDOUT = 45'b000000000000000000000000000010000000000000000 ; // = 6'b010000 ;
localparam    ADP_STDOUT1 = 45'b000000000000000000000000000100000000000000000 ; // = 6'b010001 ;
localparam    ADP_STDOUT2 = 45'b000000000000000000000000001000000000000000000 ; // = 6'b010010 ;
localparam    ADP_STDOUT3 = 45'b000000000000000000000000010000000000000000000 ; // = 6'b010011 ;
localparam      ADP_RXCMD = 45'b000000000000000000000000100000000000000000000 ; // = 6'b010100 ;
localparam    ADP_RXPARAM = 45'b000000000000000000000001000000000000000000000 ; // = 6'b010101 ;
localparam     ADP_ACTION = 45'b000000000000000000000010000000000000000000000 ; // = 6'b010110 ;
localparam     ADP_SYSCTL = 45'b000000000000000000000100000000000000000000000 ; // = 6'b010111 ;
localparam       ADP_READ = 45'b000000000000000000001000000000000000000000000 ; // = 6'b011000 ;
localparam     ADP_SYSCHK = 45'b000000000000000000010000000000000000000000000 ; // = 6'b011001 ;
localparam      ADP_STDIN = 45'b000000000000000000100000000000000000000000000 ; // = 6'b011010 ;
localparam      ADP_WRITE = 45'b000000000000000001000000000000000000000000000 ; // = 6'b011011 ;
localparam       ADP_EXIT = 45'b000000000000000010000000000000000000000000000 ; // = 6'b011100 ;
localparam      STD_IOCHK = 45'b000000000000000100000000000000000000000000000 ; // = 6'b011101 ;
localparam       STD_RXD1 = 45'b000000000000001000000000000000000000000000000 ; // = 6'b011110 ;
localparam       STD_RXD2 = 45'b000000000000010000000000000000000000000000000 ; // = 6'b011111 ;
localparam       STD_TXD1 = 45'b000000000000100000000000000000000000000000000 ; // = 6'b100000 ;
localparam       STD_TXD2 = 45'b000000000001000000000000000000000000000000000 ; // = 6'b100001 ;
localparam      ADP_UCTRL = 45'b000000000010000000000000000000000000000000000 ; // = 6'b100010 ;
localparam     ADP_UREADB = 45'b000000000100000000000000000000000000000000000 ; // = 6'b100011 ;
localparam     ADP_UWRITE = 45'b000000001000000000000000000000000000000000000 ; // = 6'b100100 ;
localparam      ADP_POLL0 = 45'b000000010000000000000000000000000000000000000 ; // = 6'b100101 ;
localparam      ADP_POLL1 = 45'b000000100000000000000000000000000000000000000 ; // = 6'b100110 ;
localparam      ADP_POLL2 = 45'b000001000000000000000000000000000000000000000 ; // = 6'b100111 ;
localparam      ADP_FCTRL = 45'b000010000000000000000000000000000000000000000 ; // = 6'b101000 ;
localparam     ADP_FWRITE = 45'b000100000000000000000000000000000000000000000 ; // = 6'b101001 ;
localparam    ADP_ECHOCMD = 45'b001000000000000000000000000000000000000000000 ; // = 6'b101010 ;
localparam    ADP_ECHOBUS = 45'b010000000000000000000000000000000000000000000 ; // = 6'b101011 ;
localparam    ADP_UNKNOWN = 45'b100000000000000000000000000000000000000000000 ; // = 6'b101100 ;
reg [44:0] adp_state   ;
`endif

reg [31:0] adp_bus_data;
reg        banner      ;
reg        com_tx_req  ;
reg  [7:0] com_tx_byte ;
reg        com_rx_ack  ;
reg        std_tx_req  ;
reg [ 7:0] std_tx_byte;
reg        std_rx_ack  ;
reg        adp_bus_req ;
reg        adp_bus_write ;
reg        adp_bus_err ;
reg  [7:0] adp_cmd     ;
reg [34:0] adp_param   ;
reg [31:0] adp_addr    ;
reg  [1:0] adp_size    ;
reg        adp_addr_inc;
reg [ 7:0] adp_sys     ;

assign GPO8_o = adp_sys[7:0];

// ADP RX stream
wire        com_rx_req = COMRX_TVALID_i;
wire [ 7:0] com_rx_byte = COMRX_TDATA_i;
assign      COMRX_TREADY_o = com_rx_ack;
// ADP TX stream
wire        com_tx_ack = COMTX_TREADY_i;
assign      COMTX_TDATA_o = com_tx_byte;
assign      COMTX_TVALID_o = com_tx_req;
// STD RX stream (from STDOUT)
wire        std_rx_req  = STDRX_TVALID_i;
wire [ 7:0] std_rx_byte = STDRX_TDATA_i;
assign      STDRX_TREADY_o = std_rx_ack;
// STD TX stream (to STDIN)
wire         std_tx_ack = STDTX_TREADY_i;
assign       STDTX_TDATA_o = std_tx_byte;
assign       STDTX_TVALID_o = std_tx_req;

//AMBA AHB master as "stream" interface
reg        ahb_dphase;
wire       ahb_aphase = adp_bus_req & !ahb_dphase;
wire       adp_bus_ack = ahb_dphase & HREADY_i;
// control pipe
always @(posedge HCLK or negedge HRESETn)
begin
  if(!HRESETn)
    begin ahb_dphase    <= 1'b0; end
  else if (HREADY_i)
    begin ahb_dphase    <= (ahb_aphase); end
end

wire [1:0] byteaddr;

assign byteaddr =  (adp_size[1]) ? 2'b00 :  (adp_size[0]) ? {adp_addr[1], 1'b0} : adp_addr[1:0];

assign HADDR32_o[31:2] =  adp_addr[31:2];
assign HADDR32_o[ 1:0] =  byteaddr[1:0];
assign HBURST3_o     =  3'b001; // "INCR" burst signalled whenever transfer;
assign HMASTLOCK_o   =  1'b0;
assign HPROT4_o[3:0] = {1'b0, 1'b0, 1'b1, 1'b1};
assign HSIZE3_o[2:0] = {1'b0, adp_size};
assign HTRANS2_o     = {ahb_aphase,1'b0}; // non-seq
assign HWDATA32_o    =  (adp_size[1]) ? adp_bus_data
                                     : (adp_size[0]) ? {2{adp_bus_data[15:0]}}
                                     : {4{adp_bus_data[7:0]}} ;
assign HWRITE_o      =  adp_bus_write;


`ifndef ADPBASIC
reg  [34:0] adp_val;
reg  [31:0] adp_mask;
reg  [31:0] adp_count;
reg         adp_count_dec ;
`endif

// commnon interface handshake terms
wire com_rx_done   = COMRX_TVALID_i & COMRX_TREADY_o;
wire com_tx_done   = COMTX_TVALID_o & COMTX_TREADY_i;
wire std_rx_done   = STDRX_TVALID_i & STDRX_TREADY_o;
wire std_tx_done   = STDTX_TVALID_o & STDTX_TREADY_i;
wire adp_bus_done  = (adp_bus_req & adp_bus_ack);

// common task to set up for next state
task ADP_LINEACK_next; // prepare newline TX (and cancel any startup banner)
  begin com_tx_req <= 1'b1; com_tx_byte <= 8'h0A; adp_state <= ADP_LINEACK; end
endtask
task ADP_BUSWRITEINC_next; // prepare bus write and addr++ on completion
  begin adp_bus_req <= 1'b1; adp_bus_write <= 1'b1; adp_addr_inc <= 1'b1; end
endtask
task ADP_BUSREADINC_next; // prepare bus read and addr++ on completion
  begin adp_bus_req <= 1'b1; adp_bus_write <= 1'b0; adp_addr_inc <= 1'b1; end
endtask

task ADP_hexdigit_next; // output nibble
input [3:0] nibble;
  begin com_tx_req <= 1'b1; com_tx_byte <= FNmap_hex_digit(nibble[3:0]); end
endtask
task ADP_txchar_next; // output char
input [7:0] octet;
  begin com_tx_req <= 1'b1; com_tx_byte <= octet; end
endtask

function FNcount_down_zero_next; // param about to be zero
input [31:0] counter;
  FNcount_down_zero_next = (counter[31:0] >> 1) == 32'h00000000;
endfunction

always @(posedge HCLK or negedge HRESETn)
begin
  if(!HRESETn) begin
      adp_state    <= ADP_WRITEHEX ;
      adp_bus_data <= {32{1'b0}};
      banner       <= 1'b1; // start-up HEX message
      com_tx_req   <= 1'b0; // default no TX req
      com_rx_ack   <= 1'b0; // default no RX ack
      std_tx_req   <= 1'b0; // default no TX req
      std_rx_ack   <= 1'b0; // default no RX ack
      com_tx_byte  <= 8'h00;
      std_tx_byte  <= 8'h00;
      adp_bus_req  <= 1'b0; // default no bus transaction
      adp_bus_err  <= 1'b0; // default no bus error
      adp_cmd      <= {8{1'b0}};
      adp_param    <= {35{1'b0}};
      adp_size     <= 2'b00; // default to 32-bit word size
      adp_addr     <= {32{1'b0}};
      adp_addr_inc <= 1'b0;
      adp_bus_write<= 1'b0;
`ifndef ADPBASIC
      adp_count    <= {32{1'b0}};
      adp_count_dec<= 1'b0;
      adp_val      <= {35{1'b0}};
      adp_mask     <= {32{1'b0}};
      adp_sys      <= {8{1'b0}};
`endif
  end else begin // default states
      if (banner) begin adp_bus_data <= BANNERHEX; adp_size     <= 2'b10; end
      adp_state    <= adp_state; // default to hold current state
      com_tx_req   <= 1'b0; // default no TX req
      com_rx_ack   <= 1'b0; // default no RX ack
      std_tx_req   <= 1'b0; // default no TX req
      std_rx_ack   <= 1'b0; // default no RX ack
      adp_bus_req  <= 1'b0; // default no bus transaction
      adp_addr     <= (adp_addr_inc && adp_bus_done) ? adp_addr + (1 << adp_size) : adp_addr; // address++
      adp_addr_inc <= 1'b0;
`ifndef ADPBASIC
      adp_count    <= (adp_count_dec && adp_bus_done && (adp_count[31:0] != 32'h00000000)) ? (adp_count - 32'h00000001) : adp_count; // param--
      adp_count_dec<= 1'b0;
`endif
    case (adp_state)
// >>>>>>>>>>>>>>>> STDIO BYPASS >>>>>>>>>>>>>>>>>>>>>>
       STD_IOCHK:  // check for commsrx or STDOUT and not busy service, else loop back
         if (com_rx_req) begin com_rx_ack <= 1'b1; adp_state <= STD_RXD1; end // input char pending for STDIN
//         else if (com_tx_ack & std_rx_req) begin std_rx_ack <= 1'b1; adp_state <= STD_TXD1; end // STDOUT char pending and not busy
         else if (std_rx_req) begin std_rx_ack <= 1'b1; adp_state <= STD_TXD1; end // STDOUT char pending
       STD_TXD1:  // get STD out char
         if (std_rx_done)
           begin com_tx_byte <= std_rx_byte; com_tx_req <= 1'b1; adp_state <= STD_TXD2; end
         else begin std_rx_ack <= 1'b1; end // extend
       STD_TXD2:  // output char to ADP channel
         if (com_tx_done) begin adp_state <= STD_IOCHK; end
         else begin com_tx_req <= 1'b1; end // extend
       STD_RXD1:  // read rx char and check for ADP entry else STDIN **
         if (com_rx_done) begin
           if (FNvalid_adp_entry(com_rx_byte))
             begin ADP_txchar_next(8'h0A); adp_state <= ADP_LINEACK; end // ADP prompt
           else if (std_tx_ack)
             begin std_tx_byte <= com_rx_byte; std_tx_req <= 1'b1; adp_state <= STD_RXD2; end
           else begin adp_state <= STD_IOCHK; end // otherwise discard STDIN char and process OP data if blocked
         end else begin com_rx_ack <= 1'b1; end // extend
       STD_RXD2:  // get STD in char
         if (std_tx_done) begin adp_state <= STD_IOCHK; end
         else begin std_tx_req <= 1'b1; end // extend

// >>>>>>>>>>>>>>>> ADP Monitor >>>>>>>>>>>>>>>>>>>>>>
       ADP_PROMPT:  // transition after reset deassertion
         if (com_tx_done) begin adp_state <= ADP_IOCHK; end
         else begin com_tx_req <= 1'b1; end // extend

       ADP_IOCHK:  // check for commsrx or STDOUT and not busy service, else loop back
         if (std_rx_req) begin com_tx_byte <= "<"; com_tx_req <= 1'b1; adp_state <= ADP_STDOUT; end
         else if (com_rx_req) begin com_rx_ack <= 1'b1; adp_state <= ADP_RXCMD; end

// >>>>>>>>>>>>>>>> ADP <STDOUT> >>>>>>>>>>>>>>>>>>>>>>
       ADP_STDOUT:  // output "<"
         if (com_tx_done) begin std_rx_ack <= 1'b1; adp_state <= ADP_STDOUT1; end
         else begin com_tx_req <= 1'b1; end // extend stream request if not ready
       ADP_STDOUT1:  // get STD out char
         if (std_rx_done) begin com_tx_byte <= std_rx_byte; com_tx_req <= 1'b1; adp_state <= ADP_STDOUT2; end
         else begin std_rx_ack <= 1'b1; end // else extend
       ADP_STDOUT2:  // output char
         if (com_tx_done) begin com_tx_byte <= ">"; com_tx_req <= 1'b1; adp_state <= ADP_STDOUT3; end
         else begin com_tx_req <= 1'b1; end // else extend
       ADP_STDOUT3:  // output ">"
         if (com_tx_done) begin
            if (com_rx_req) begin com_rx_ack <= 1'b1; adp_state <= ADP_RXCMD; end else begin adp_state <= ADP_IOCHK; end
         end
         else begin com_tx_req <= 1'b1; end // else extend

// >>>>>>>>>>>>>>>> ADP COMMAND PARSING >>>>>>>>>>>>>>>>>>>>>>
       ADP_RXCMD:  // read and save ADP command
         if (com_rx_done) begin
           if (FNexit(com_rx_byte)) begin adp_state <= STD_IOCHK; end // immediate exit
           else if (FNvalid_space(com_rx_byte)) begin com_rx_ack <= 1'b1; end // retry for a command
           else if (FNvalid_EOL(com_rx_byte)) begin adp_cmd <= "?"; adp_state <= ADP_LINEACK; end // no command, skip param
           else begin adp_cmd <= com_rx_byte; adp_param <= 35'h0_00000000; com_rx_ack <= 1'b1; adp_state <= ADP_RXPARAM; end // get optional parameter
         end
         else begin com_rx_ack <= 1'b1; end // extend stream request if not ready
       ADP_RXPARAM:  // read and build hex parameter
         if (com_rx_done) begin  // RX byte
           if (FNexit(com_rx_byte)) begin adp_state <= STD_IOCHK; end // exit
           else if (FNvalid_EOL(com_rx_byte))
`ifndef ADPBASIC
            begin adp_count <= adp_param[31:0]; adp_state <= ADP_ACTION;
                  adp_size  <= FNparam2size(adp_param[34:33]); end // parameter complete on EOL
`else
            begin adp_state <= ADP_ACTION;
                  adp_size  <= FNparam2size(adp_param[34:33]); end // parameter complete on EOL
`endif
           else
             begin adp_param <= FNBuild_size3_param32_hexdigit(adp_param[34:0], com_rx_byte); com_rx_ack <= 1'b1; end // build parameter
           end
         else begin com_rx_ack <= 1'b1; end

       ADP_ACTION:  // parse command and action with parameter
         if (FNexit(com_rx_byte))
           begin adp_state <= STD_IOCHK; end
         else if (FNvalid_cmd(adp_cmd) == CMD_A)
           begin if (|adp_param[34:32]) begin adp_addr <= adp_param[31:0]; end else begin adp_param <= {3'b111, adp_addr}; end
             adp_state <= ADP_ECHOCMD; end
         else if (FNvalid_cmd(adp_cmd) == CMD_C) begin
           if (|adp_param[34:32] == 1'b0) // report GPO
             begin adp_state <= ADP_SYSCTL; end
           else if (adp_param[31:8] == 24'h000001) // clear selected bits in GPO
             begin adp_sys[7:0] <= adp_sys[7:0] & ~adp_param[7:0]; adp_state <= ADP_SYSCTL; end
           else if (adp_param[31:8] == 24'h000002) // set selected bits in GPO
             begin adp_sys[7:0] <= adp_sys[7:0] | adp_param[7:0]; adp_state <= ADP_SYSCTL; end
           else if (adp_param[31:8] == 24'h000003) // overwrite bits in GPO
             begin adp_sys[7:0] <= adp_param[7:0]; adp_state <= ADP_SYSCTL; end
           else // 4 etc, report GPO
             begin adp_state <= ADP_SYSCTL; end
           end
         else if (FNvalid_cmd(adp_cmd) == CMD_R)
           begin adp_size <= FNparam2size(adp_param[34:33]); ADP_BUSREADINC_next; adp_state <= ADP_READ;
`ifndef ADPBASIC
             adp_count_dec <= 1'b1; // optional loop param
`endif
           end // no param required
         else if (FNvalid_cmd(adp_cmd) == CMD_S)
           begin adp_state <= ADP_SYSCHK; end
         else if (FNvalid_cmd(adp_cmd) == CMD_W)
           begin adp_size <= FNparam2size(adp_param[34:33]); adp_bus_data <= adp_param[31:0]; ADP_BUSWRITEINC_next; adp_state <= ADP_WRITE; end
         else if (FNvalid_cmd(adp_cmd) == CMD_X)
           begin com_tx_byte <= 8'h0a; com_tx_req <= 1'b1; adp_state <= ADP_EXIT; end
`ifndef ADPBASIC
         else if (FNvalid_cmd(adp_cmd) == CMD_U) begin
             if (FNcount_down_zero_next(adp_param[31:0])) begin adp_state <= ADP_ECHOCMD; end else begin adp_state <= ADP_UCTRL; end// non-zero count
           end
         else if (FNvalid_cmd(adp_cmd) == CMD_M)
           begin if (|adp_param[34:32]) begin adp_mask <= adp_param[31:0]; end else begin adp_param <= {3'b111,adp_mask}; end
             adp_state <= ADP_ECHOCMD; end
         else if (FNvalid_cmd(adp_cmd) == CMD_P)
           begin
             if (FNcount_down_zero_next(adp_param[31:0])) begin adp_state <= ADP_ECHOCMD; end else begin adp_state <= ADP_POLL0; end// non-zero count
           end
         else if (FNvalid_cmd(adp_cmd) == CMD_V)
           begin if (|adp_param[34:32]) begin adp_size <= FNparam2size(adp_param[34:33]); adp_val <= adp_param[34:0]; end
                 else begin adp_param <= adp_val; end
             adp_state <= ADP_ECHOCMD; end
         else if (FNvalid_cmd(adp_cmd) == CMD_F)
           begin
             if (FNcount_down_zero_next(adp_param[31:0])) begin adp_state <= ADP_ECHOCMD; end else begin adp_state <= ADP_FCTRL; end // non-zero count
           end
`endif
         else
           begin ADP_txchar_next("?"); adp_state <= ADP_UNKNOWN; end // unrecognised/invald

// >>>>>>>>>>>>>>>> ADP BUS WRITE and READ >>>>>>>>>>>>>>>>>>>>>>

       ADP_WRITE:  // perform bus write at current address pointer (and auto increment)
         if (adp_bus_done) begin adp_state <= ADP_ECHOCMD; adp_bus_err <= HRESP_i; end
         else begin ADP_BUSWRITEINC_next; end // extend request

       ADP_READ:  // perform bus read at current adp address (and auto increment)  - and report in hex
         if (adp_bus_done) begin adp_bus_data <= (byteaddr[1:0] == 2'b01) ? {HRDATA32_i[ 7: 0],HRDATA32_i[31: 8]} 
                                               : (byteaddr[1:0] == 2'b10) ? {HRDATA32_i[15: 0],HRDATA32_i[31:16]} 
                                               : (byteaddr[1:0] == 2'b11) ? {HRDATA32_i[23: 0],HRDATA32_i[31:24]}
                                               : HRDATA32_i;
                                 adp_bus_err <= HRESP_i; ADP_txchar_next("R"); adp_state <= ADP_ECHOBUS;
                           end
         else begin
             ADP_BUSREADINC_next;
`ifndef ADPBASIC
           adp_count_dec<= 1'b1;
`endif
         end // extend request

`ifndef ADPBASIC

// >>>>>>>>>>>>>>>> ADP BINARY UPLOAD >>>>>>>>>>>>>>>>>>>>>>
       ADP_UCTRL:  // set control value
         begin com_rx_ack <= 1'b1; adp_size <= 2'b00; adp_state <= ADP_UREADB; end  // read next byte
       ADP_UREADB: // read raw binary byte
         if (com_rx_done)
           begin adp_bus_data[31:0] <= {4{com_rx_byte}}; ADP_BUSWRITEINC_next; adp_count_dec <= 1'b1; adp_state <= ADP_UWRITE; end
         else begin com_rx_ack <= 1'b1; end // extend stream request if not ready
       ADP_UWRITE:  // Write word to Addr++
         if (adp_bus_done) begin // auto address++, count--
           if (FNcount_down_zero_next(adp_count)) begin adp_size <= 2'b10; adp_state <= ADP_ECHOCMD; end else begin adp_state <= ADP_UREADB; adp_bus_err <= adp_bus_err | HRESP_i; end
         end else begin  ADP_BUSWRITEINC_next; adp_count_dec <= 1'b1; end // extend request

// >>>>>>>>>>>>>>>> ADP BUS READ LOOP >>>>>>>>>>>>>>>>>>>>>>
       ADP_POLL0:  // set poll value
         begin adp_bus_req <= 1'b1; adp_bus_write <= 1'b0; adp_state <= ADP_POLL1; end
       ADP_POLL1:  // wait for read data, no addr++
         if (adp_bus_done) begin adp_bus_data <= HRDATA32_i; adp_count_dec <= 1'b1; adp_state <= ADP_POLL2; adp_bus_err <= adp_bus_err | HRESP_i; end
         else begin adp_bus_req <= 1'b1; adp_count_dec <= 1'b1; end
       ADP_POLL2:
         if (FNcount_down_zero_next(adp_count)) begin adp_state <= ADP_ECHOCMD; adp_bus_err <= 1'b1; end // timeout
         else if (((adp_bus_data  & adp_mask) ^ adp_val[31:0]) == 0)
           begin adp_state <= ADP_ECHOCMD; adp_param[34:32] <= 3'b000; adp_param[31:0] <= (adp_param[31:0] - adp_count); end // exact match
         else begin adp_state <= ADP_POLL0; end

// >>>>>>>>>>>>>>>> ADP (ZERO) FILL MEMORY >>>>>>>>>>>>>>>>>>>>>>
       ADP_FCTRL:  // set control value
           begin adp_size <= FNparam2size(adp_val[34:33]); adp_bus_data <= adp_val[31:0]; ADP_BUSWRITEINC_next; adp_count_dec <= 1'b1; adp_state <= ADP_FWRITE; end
       ADP_FWRITE:  // Write word to Addr++
         if (adp_bus_done) begin // auto address++, count--
           if (FNcount_down_zero_next(adp_count)) begin adp_state <= ADP_ECHOCMD; end else begin adp_state <= ADP_FCTRL;  adp_bus_err <= adp_bus_err | HRESP_i; end
         end else begin  ADP_BUSWRITEINC_next; adp_count_dec <= 1'b1; end // extend request
`endif

        // >>>>>>>>>>>>>>>> ADP MISC >>>>>>>>>>>>>>>>>>>>>>

       ADP_UNKNOWN:  // output "?"
         if (com_tx_done) begin ADP_LINEACK_next; end
         else begin com_tx_req <= 1'b1; end // extend stream request if not ready

       ADP_EXIT:  // exit ADP mode
         if (com_tx_done) begin adp_state <= STD_IOCHK; end
         else begin com_tx_req <= 1'b1; end // extend stream request if not ready

       ADP_SYSCHK:  // check STDIN fifo
         begin // no upper flags so STDIN char
           if (std_tx_ack) begin std_tx_req <= 1'b1; std_tx_byte <= adp_param[7:0]; adp_state <= ADP_STDIN; end
           else begin adp_bus_err <= 1'b1; adp_state <= ADP_ECHOCMD; end // signal error then echo comand
         end
       ADP_STDIN:  // push char into STDIN
         if (std_tx_done) begin adp_bus_data <= {{24{1'b0}},adp_param[7:0]}; ADP_txchar_next("S"); adp_state <= ADP_ECHOBUS;  end
         else begin std_tx_req <= 1'b1; end // extend

       ADP_SYSCTL:  // read current status - and report in hex
         begin adp_bus_data <= {GPI8_i[7:0],adp_sys[7:0],adp_param[15:0]}; ADP_txchar_next("C"); adp_state <= ADP_ECHOBUS;  end

       ADP_ECHOCMD:  // output command and (param) data
         begin ADP_txchar_next(adp_cmd & 8'h5f); adp_bus_data <= adp_param[31:0]; adp_state <= ADP_ECHOBUS; end // output command char
       ADP_ECHOBUS:  // output command space and (bus) data
         if (com_tx_done) begin adp_state <= ADP_WRITEHEXS; ADP_txchar_next(adp_bus_err ? "!" : " "); end // output space char, or "!" on bus error
         else begin com_tx_req <= 1'b1;  end // extend

       ADP_WRITEHEX:  // output hex word with prefix
         begin adp_state <= ADP_WRITEHEXS; ADP_txchar_next(adp_bus_err ? "!" : " "); end // output space char, or "!" on bus error

       ADP_WRITEHEXS:
         if (com_tx_done) begin adp_state <= ADP_WRITEHEX9; ADP_txchar_next("0"); end // output "0" hex prefix
         else begin com_tx_req <= 1'b1; end // extend
       ADP_WRITEHEX9:
         if (com_tx_done) begin
           ADP_txchar_next("x"); // output "x" hex prefix
           adp_state <= (adp_size[1]) ? ADP_WRITEHEX8 
                      : (adp_size[0]) ? ADP_WRITEHEX4 
                      : ADP_WRITEHEX2;
         end else begin com_tx_req <= 1'b1; end // extend
       ADP_WRITEHEX8:
         if (com_tx_done) begin adp_state <= ADP_WRITEHEX7; ADP_hexdigit_next(adp_bus_data[31:28]); end // hex nibble 7
         else begin com_tx_req <= 1'b1; end // extend
       ADP_WRITEHEX7:  // output hex nibble 7
         if (com_tx_done) begin adp_state <= ADP_WRITEHEX6; ADP_hexdigit_next(adp_bus_data[27:24]); end // hex nibble 6
         else begin com_tx_req <= 1'b1; end // extend
       ADP_WRITEHEX6:  // output hex nibble 6
         if (com_tx_done) begin adp_state <= ADP_WRITEHEX5; ADP_hexdigit_next(adp_bus_data[23:20]); end // hex nibble 5
         else begin com_tx_req <= 1'b1; end // extend
       ADP_WRITEHEX5:  // output hex nibble 5
         if (com_tx_done) begin adp_state <= ADP_WRITEHEX4; ADP_hexdigit_next(adp_bus_data[19:16]); end // hex nibble 4
         else begin com_tx_req <= 1'b1; end // extend
       ADP_WRITEHEX4:  // output hex nibble 4
         if (com_tx_done) begin adp_state <= ADP_WRITEHEX3; ADP_hexdigit_next(adp_bus_data[15:12]); end // hex nibble 3
         else begin com_tx_req <= 1'b1; end // extend
       ADP_WRITEHEX3:  // output hex nibble 3
         if (com_tx_done) begin adp_state <= ADP_WRITEHEX2; ADP_hexdigit_next(adp_bus_data[11: 8]); end // hex nibble 2
         else begin com_tx_req <= 1'b1; end // extend
       ADP_WRITEHEX2:  // output hex nibble 2
         if (com_tx_done) begin adp_state <= ADP_WRITEHEX1; ADP_hexdigit_next(adp_bus_data[ 7: 4]); end // hex nibble 1
         else begin com_tx_req <= 1'b1; end // extend
       ADP_WRITEHEX1:  // output hex nibble 1
         if (com_tx_done) begin adp_state <= ADP_WRITEHEX0; ADP_hexdigit_next(adp_bus_data[ 3: 0]); end // hex nibble 0
         else begin com_tx_req <= 1'b1; end // extend
       ADP_WRITEHEX0:  // output hex nibble 0 (if not startup banner then scan to end of line before lineack
         if (com_tx_done) begin
           adp_bus_err <= 1'b0; // clear sticky bus error flag
           if (banner) begin ADP_LINEACK_next; end
           else begin ADP_txchar_next(8'h0A); adp_state <= ADP_LINEACK; end // newline and prompt
         end else begin com_tx_req <= 1'b1; end  // extend

       ADP_LINEACK:  // write EOLN
         if (com_tx_done) begin
           begin ADP_txchar_next(8'h0D); adp_state <= ADP_LINEACK2; end
         end else begin com_tx_req <= 1'b1; end // extend
       ADP_LINEACK2: // CR
         if (com_tx_done) begin
           if (banner) begin banner <= 1'b0; adp_state <= STD_IOCHK; end
`ifndef ADPBASIC
           else if ((FNvalid_cmd(adp_cmd) == CMD_R) && (adp_count != 32'h00000000)) //// non-zero count
             begin ADP_BUSREADINC_next; adp_count_dec <= 1'b1; adp_state <= ADP_READ; end //
`endif
           else begin ADP_txchar_next(PROMPT_CHAR); adp_state <= ADP_PROMPT; end
         end else begin com_tx_req <= 1'b1; end // extend
      default:
        begin ADP_txchar_next("#"); adp_state <= ADP_UNKNOWN; end // default error
    endcase
  end
end

endmodule
