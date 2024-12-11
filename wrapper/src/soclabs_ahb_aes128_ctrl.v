 //-----------------------------------------------------------------------------
// top-level soclabs example AHB interface
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Flynn (d.w.flynn@soton.ac.uk)
//
// Copyright (C) 2023, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------

module soclabs_ahb_aes128_ctrl(
// -------------------------------------------------------
// MCU interface
// -------------------------------------------------------
  input  wire        ahb_hclk,      // Clock
  input  wire        ahb_hresetn,   // Reset
  input  wire        ahb_hsel,      // Device select
  input  wire [15:0] ahb_haddr16,   // Address for byte select
  input  wire  [1:0] ahb_htrans,    // Transfer control
  input  wire  [2:0] ahb_hsize,     // Transfer size
  input  wire  [3:0] ahb_hprot,     // Protection control
  input  wire        ahb_hwrite,    // Write control
  input  wire        ahb_hready,    // Transfer phase done
  input  wire [31:0] ahb_hwdata,    // Write data
  output wire        ahb_hreadyout, // Device ready
  output wire [31:0] ahb_hrdata,    // Read data output
  output wire        ahb_hresp,     // Device response
// stream data
  output wire        drq_ipdma128,  // (to) DMAC input burst request
  input  wire        dlast_ipdma128,// (from) DMAC input burst end (last transfer)
  output wire        drq_opdma128,  // (to) DMAC output dma burst request
  input  wire        dlast_opdma128,// (from) DMAC output burst end (last transfer)
  output wire        irq_key128,
  output wire        irq_ip128,
  output wire        irq_op128,
  output wire        irq_error,
  output wire        irq_merged     // combined interrrupt request (to CPU)
  );

  //----------------------------------------------------------------
  // Internal parameter definitions.
  //----------------------------------------------------------------

///typedef struct {
///     __I  uint32_t CORE_NAME[2];   /* 0x0000-0007 */
///     __I  uint32_t CORE_VERSION;   /* 0x0008-000B */
///          uint32_t RESRV0C;        /* 0x000C */
///     __IO uint32_t CTRL;           /* 0x0010 */
///     __O  uint32_t CTRL_SET;       /* 0x0014 */
///     __O  uint32_t CTRLL_CLR;      /* 0x0018 */
///     __I  uint32_t STATUS;         /* 0x001c */
///     __IO uint32_t QUAL;           /* 0x0020 */
///          uint32_t RESRV24[3];     /* 0x0024 - 2F*/
///     __IO uint32_t DRQ_MSK;        /* 0x0030 */
///     __O  uint32_t DRQ_MSK_SET;    /* 0x0034 */
///     __O  uint32_t DRQ_MSK_CLR;    /* 0x0038 */
///     __I  uint32_t DRQ_STATUS;     /* 0x003C */
///     __IO uint32_t IRQ_MSK;        /* 0x0040 */
///     __O  uint32_t IRQ_MSK_SET;    /* 0x0044 */
///     __O  uint32_t IRQ_MSK_CLR;    /* 0x0048 */
///     __I  uint32_t IRQ_STATUS;     /* 0x004C */
///          uint32_t RESRV50[4076];  /* 0x0050-0x3FFC (4096-20 words) */
///     __IO uint8_t KEY128[0x4000];   /* 0x4000-7FFF (0x3FFF is last alias) */
///     __IO uint8_t TXTIP128[0x4000]; /* 0x8000-BFFF (0x3FFF is last alias) */
///     __I  uint8_t TXTOP128[0x4000]; /* 0xC000-FFFF (0x3FFF is last alias) */
///} AES128_TypeDef;


// CORE ID
  localparam ADDR_CORE_NAME0  = 16'h0000;
  localparam ADDR_CORE_NAME1  = 16'h0004;
  localparam ADDR_CORE_VERSION= 16'h0008;
  localparam CORE_NAME0       = 32'h61657331; // "aes1"
  localparam CORE_NAME1       = 32'h32382020; // "28  "
  localparam CORE_VERSION     = 32'h302e3031; // "0.01"

// CTRL control register with bit-set/bit-clear options
  localparam ADDR_CTRL        = 16'h0010;
  localparam ADDR_CTRL_SET    = 16'h0014;
  localparam ADDR_CTRL_CLR    = 16'h0018;
  localparam CTRL_REG_WIDTH   = 8;
  localparam CTRL_BIT_MAX     = (CTRL_REG_WIDTH-1);
  localparam CTRL_KEY_REQ_BIT = 0;
  localparam CTRL_IP_REQ_BIT  = 1;
  localparam CTRL_OP_REQ_BIT  = 2;
  localparam CTRL_ERR_REQ_BIT = 3;
  localparam CTRL_KEYOK_BIT   = 4;
  localparam CTRL_VALID_BIT   = 5;
  localparam CTRL_BYPASS_BIT  = 6;
  localparam CTRL_ENCODE_BIT  = 7;
// STAT status regisyer 
  localparam ADDR_STAT        = 16'h001c;
  localparam STAT_REG_WIDTH   = 8;
  localparam STAT_BIT_MAX     = (STAT_REG_WIDTH-1);
  localparam STAT_KEYREQ_BIT  = 0;
  localparam STAT_INPREQ_BIT  = 1;
  localparam STAT_OUTREQ_BIT  = 2;
  localparam STAT_ERROR_BIT   = 3;
  localparam STAT_KEYOK_BIT   = 4;
  localparam STAT_VALID_BIT   = 5;

// QUAL qualifier field
  localparam ADDR_QUAL        = 16'h0020;
  localparam QUAL_REG_WIDTH   = 32;
  localparam QUAL_BIT_MAX     = (QUAL_REG_WIDTH-1);

// DREQ DMAC request control with bit-set/bit-clear options
  localparam ADDR_DREQ        = 16'h0030;
  localparam ADDR_DREQ_SET    = 16'h0034;
  localparam ADDR_DREQ_CLR    = 16'h0038;
  localparam ADDR_DREQ_ACT    = 16'h003c;
  localparam DREQ_REG_WIDTH   = 3;
  localparam DREQ_BIT_MAX     = (DREQ_REG_WIDTH-1);
  localparam  REQ_KEYBUF_BIT  = 0;
  localparam  REQ_IP_BUF_BIT  = 1;
  localparam  REQ_OP_BUF_BIT  = 2;

// IREQ CPU interrupt request control with bit-set/bit-clear options
  localparam ADDR_IREQ        = 16'h0040;
  localparam ADDR_IREQ_SET    = 16'h0044;
  localparam ADDR_IREQ_CLR    = 16'h0048;
  localparam ADDR_IREQ_ACT    = 16'h004c;
  localparam IREQ_REG_WIDTH   = 4;
  localparam IREQ_BIT_MAX     = (IREQ_REG_WIDTH-1);
  localparam  REQ_ERROR_BIT   = 3;

  localparam ADDR_KEY_BASE    = 16'h4000;
  localparam ADDR_KEY0        = 16'h4000;
  localparam ADDR_KEY3        = 16'h400c;
  localparam ADDR_KEY7        = 16'h401c;

  localparam ADDR_IBUF_BASE   = 16'h8000;
  localparam ADDR_IBUF_0      = 16'h8000;
  localparam ADDR_IBUF_3      = 16'h800c;

  localparam ADDR_OBUF_BASE   = 16'hc000;
  localparam ADDR_OBUF_3      = 16'hc00c;

 
 // --------------------------------------------------------------------------
  // Internal regs/wires
  // --------------------------------------------------------------------------

  reg   [15:0] addr16_r;
  reg          sel_r;
  reg          wcyc_r;
  reg          rcyc_r;
  reg    [3:0] byte4_r;

  wire         key128_load_ack;
  wire         ip128_load_ack;
  wire         op128_load_ack;

  // --------------------------------------------------------------------------
  // AHB slave byte buffer interface, support for unaligned data transfers
  // --------------------------------------------------------------------------

  wire   [1:0] byt_adr = ahb_haddr16[1:0];
  // generate next byte enable decodes for Word/Half/Byte CPU/DMA accesses
  wire   [3:0] byte_nxt;
  assign byte_nxt[0] = (ahb_hsize[1])|((ahb_hsize[0])&(!byt_adr[1]))|(byt_adr[1:0]==2'b00);
  assign byte_nxt[1] = (ahb_hsize[1])|((ahb_hsize[0])&(!byt_adr[1]))|(byt_adr[1:0]==2'b01);
  assign byte_nxt[2] = (ahb_hsize[1])|((ahb_hsize[0])&( byt_adr[1]))|(byt_adr[1:0]==2'b10);
  assign byte_nxt[3] = (ahb_hsize[1])|((ahb_hsize[0])&( byt_adr[1]))|(byt_adr[1:0]==2'b11);

  // de-pipelined registered access signals
  always @(posedge ahb_hclk or negedge ahb_hresetn)
    if (!ahb_hresetn)
    begin
      addr16_r <= 16'h0000;
      sel_r    <= 1'b0;
      wcyc_r   <= 1'b0;
      rcyc_r   <= 1'b0;
      byte4_r  <= 4'b0000;
    end else if (ahb_hready)
    begin
      addr16_r <= (ahb_hsel & ahb_htrans[1]) ?  ahb_haddr16 : addr16_r;
      sel_r    <= (ahb_hsel & ahb_htrans[1]);
      wcyc_r   <= (ahb_hsel & ahb_htrans[1]  &  ahb_hwrite);
      rcyc_r   <= (ahb_hsel & ahb_htrans[1]  & !ahb_hwrite);
      byte4_r  <= (ahb_hsel & ahb_htrans[1]) ?  byte_nxt[3:0] : 4'b0000;
    end 


// pipelined "early" last access decodes, for PL230 dma_ack timing to deassert dma requests
//  wire ahb128_last  = ahb_hsel &  ahb_htrans[1] & ahb_hready & ahb_haddr16[3] & ahb_haddr16[2] & byte_nxt[3];
//  wire ahb128_wlast = ahb_last &  ahb_hwrite & |ahb_haddr[15:14]; // address phase of last write transfer
//  wire ahb128_rlast = ahb_last & !ahb_hwrite & |ahb_haddr[15:14]; // address phase of last read transfer
  
  wire wlast128     = |ahb_haddr16[15:14] & addr16_r[3] & addr16_r[2] & byte4_r[3] & wcyc_r; // write last pulse
  wire rlast128     = &ahb_haddr16[15:14] & addr16_r[3] & addr16_r[2] & byte4_r[3] & rcyc_r; // read last pulse

  //----------------------------------------------------------------
  // API register state and wiring
  //
  //----------------------------------------------------------------

  reg   [CTRL_BIT_MAX:0] control;
  reg   [QUAL_BIT_MAX:0] param;
  reg   [DREQ_BIT_MAX:0] drq_enable;
  reg   [IREQ_BIT_MAX:0] irq_enable;

  wire  [STAT_BIT_MAX:0] status;
  wire  [DREQ_BIT_MAX:0] drq_active;
  wire  [IREQ_BIT_MAX:0] irq_active;

  wire [31:0] rd_keybuf;
  wire [31:0] rd_ipbuf;
  wire [31:0] rd_opbuf;
 
  //----------------------------------------------------------------
  // API write decoder
  //
  //----------------------------------------------------------------

  wire sel_mode   = sel_r & (addr16_r[15: 8] == 0);
  wire sel_keybuf = sel_r & (addr16_r[15:14] == 1);
  wire sel_ipbuf  = sel_r & (addr16_r[15:14] == 2);
  wire sel_opbuf  = sel_r & (addr16_r[15:14] == 3);
// add address map "last" transfer signalling when last (byte) of alias map is written 
  wire alast_key128 = sel_keybuf & wcyc_r & (&addr16_r[13:2]) & byte4_r[3];
  wire alast_ip128  = sel_ipbuf  & wcyc_r & (&addr16_r[13:2]) & byte4_r[3];
  wire alast_op128  = sel_opbuf  & rcyc_r & (&addr16_r[13:2]) & byte4_r[3];

  always @(posedge ahb_hclk or negedge ahb_hresetn)
   if (!ahb_hresetn) begin
     control    <= {CTRL_REG_WIDTH{1'b0}};
     param      <= {QUAL_REG_WIDTH{1'b0}};
     drq_enable <= {DREQ_REG_WIDTH{1'b0}};
     irq_enable <= {IREQ_REG_WIDTH{1'b0}};
     end
   else if (sel_mode & wcyc_r & byte4_r[0])
     case ({addr16_r[15:2],2'b00})
       ADDR_CTRL    : control    <=  ahb_hwdata[CTRL_BIT_MAX:0];              // overwrite ctl reg
       ADDR_CTRL_SET: control    <=  ahb_hwdata[CTRL_BIT_MAX:0] | control;    // bit set ctl mask pattern
       ADDR_CTRL_CLR: control    <= ~ahb_hwdata[CTRL_BIT_MAX:0] & control;    // bit clear ctl mask pattern
       ADDR_QUAL    : param      <=  ahb_hwdata[QUAL_BIT_MAX:0];              // write qual pattern
       ADDR_DREQ    : drq_enable <=  ahb_hwdata[DREQ_BIT_MAX:0];              // overwrite dreq reg
       ADDR_DREQ_SET: drq_enable <=  ahb_hwdata[DREQ_BIT_MAX:0] | drq_enable; // bit set dreq mask pattern
       ADDR_DREQ_CLR: drq_enable <= ~ahb_hwdata[DREQ_BIT_MAX:0] & drq_enable; // bit clear dreq mask pattern
       ADDR_IREQ    : irq_enable <=  ahb_hwdata[IREQ_BIT_MAX:0];              // overwrite ireq reg
       ADDR_IREQ_SET: irq_enable <=  ahb_hwdata[IREQ_BIT_MAX:0] | irq_enable; // bit set ireq mask pattern
       ADDR_IREQ_CLR: irq_enable <= ~ahb_hwdata[IREQ_BIT_MAX:0] & irq_enable; // bit clear ireq mask pattern
       default: ;
     endcase
   else if (sel_keybuf & wcyc_r & (dlast_ipdma128 | alast_key128)) // key terminate
     drq_enable[0] <= 1'b0;
   else if (sel_ipbuf  & wcyc_r & (dlast_ipdma128 | alast_ip128)) // ip-buffer terminate
     drq_enable[1] <= 1'b0;
   else if (sel_opbuf & rcyc_r  & (dlast_opdma128 | alast_op128)) // op-buffer complete
     drq_enable[2] <= 1'b0;

  //----------------------------------------------------------------
  // API read decoder
  //
  //----------------------------------------------------------------

reg [31:0] rdata32; // mux read data

  always @*
    begin : read_decoder
      rdata32  = 32'hbad0bad;
      if (sel_r & rcyc_r)
        case ({addr16_r[15:2],2'b00})
          ADDR_CORE_NAME0   : rdata32 = CORE_NAME0; 
          ADDR_CORE_NAME1   : rdata32 = CORE_NAME1; 
          ADDR_CORE_VERSION : rdata32 = CORE_VERSION;
          ADDR_CTRL     : rdata32 = {{(32-CTRL_REG_WIDTH){1'b0}}, control};
          ADDR_STAT     : rdata32 = {{(32-STAT_REG_WIDTH){1'b0}}, status};
          ADDR_QUAL     : rdata32 = {{(32-QUAL_REG_WIDTH){1'b0}}, param};
          ADDR_DREQ     : rdata32 = {{(32-DREQ_REG_WIDTH){1'b0}}, drq_enable};
          ADDR_DREQ_ACT : rdata32 = {{(32-DREQ_REG_WIDTH){1'b0}}, drq_active};
          ADDR_IREQ     : rdata32 = {{(32-IREQ_REG_WIDTH){1'b0}}, irq_enable};
          ADDR_IREQ_ACT : rdata32 = {{(32-DREQ_REG_WIDTH){1'b0}}, irq_active};
        default:
          if      (sel_keybuf) rdata32 = rd_keybuf;
          else if (sel_ipbuf)  rdata32 = rd_ipbuf;
          else if (sel_opbuf)  rdata32 = rd_opbuf;
        endcase
    end // read_decoder

  assign ahb_hrdata = rdata32;

  assign ahb_hreadyout = 1'b1; // zero wait state interface
  assign ahb_hresp     = 1'b0;
    
  // --------------------------------------------------------------------------
  // Key Input Buffer - keybuf
  // --------------------------------------------------------------------------

  wire [127:0] key128_be;

  soclabs_iobuf_reg128
  #(.WRITE_ONLY     (1),
    .WRITE_ZPAD     (0))
  u_reg128_key
  (
    .clk         (ahb_hclk        ), // Clock
    .rst_b       (ahb_hresetn     ), // Reset
    .sel_r       (sel_keybuf      ), // Bank decode select
    .wcyc_r      (wcyc_r          ), // Write cycle (wdata32 valid)
    .rcyc_r      (rcyc_r          ), // Read cycle (return rdata32)
    .word2_r     (addr16_r[3:2]   ), // Address for word select
    .byte4_r     (byte4_r[3:0]    ), // Byte select decoded (up to 4 enabled)
    .wdata32     (ahb_hwdata[31:0]), // Write data (byte lane qualified)
    .rdata32     (rd_keybuf       ), // Read data output
    .dma128_ack  (key128_load_ack ), // DMA burst acknowledge
    .out128_le   (                ), // Big-Endian 128-bit value
    .out128_be   (key128_be       )  // Big-Endian 128-bit value
  );

  // --------------------------------------------------------------------------
  // Data Input Buffer - ipbuf
  // --------------------------------------------------------------------------

  wire [127:0] ip128_le;
  wire [127:0] ip128_be;

  soclabs_iobuf_reg128
  #(.WRITE_ONLY     (0),
    .WRITE_ZPAD     (1))
  u_reg128_ip
  (
    .clk         (ahb_hclk        ), // Clock
    .rst_b       (ahb_hresetn     ), // Reset
    .sel_r       (sel_ipbuf       ), // Bank decode select
    .wcyc_r      (wcyc_r          ), // Write cycle (wdata32 valid)
    .rcyc_r      (rcyc_r          ), // Read cycle (return rdata32)
    .word2_r     (addr16_r[3:2]   ), // Address for word select
    .byte4_r     (byte4_r[3:0]    ), // Byte select decoded (up to 4 enabled)
    .wdata32     (ahb_hwdata[31:0]), // Write data (byte lane qualified)
    .rdata32     (rd_ipbuf        ), // Read data output
    .dma128_ack  (ip128_load_ack  ), // DMA burst acknowledge
    .out128_le   (ip128_le        ), // Big-Endian 128-bit value
    .out128_be   (ip128_be        )  // Big-Endian 128-bit value
  );

  // --------------------------------------------------------------------------
  // Data Output Buffer - opbufsel_keybuf
  // --------------------------------------------------------------------------

  wire [127:0] op128_be;
  wire [127:0] op128_muxed = (control[CTRL_BYPASS_BIT]) ? ip128_be : op128_be;
  
  wire [31:0] op_slice32 [0:3];
  assign op_slice32[3] = {op128_muxed[  7:  0],op128_muxed[ 15:  8],op128_muxed[ 23: 16],op128_muxed[ 31: 24]};
  assign op_slice32[2] = {op128_muxed[ 39: 32],op128_muxed[ 47: 40],op128_muxed[ 55: 48],op128_muxed[ 63: 56]};
  assign op_slice32[1] = {op128_muxed[ 71: 64],op128_muxed[ 79: 72],op128_muxed[ 87: 80],op128_muxed[ 95: 88]};
  assign op_slice32[0] = {op128_muxed[103: 96],op128_muxed[111:104],op128_muxed[119:112],op128_muxed[127:120]};

  // 32-bit addressed read data
  assign rd_opbuf = op_slice32[addr16_r[3:2]];

  assign op128_load_ack = (sel_opbuf & rcyc_r & addr16_r[3] & addr16_r[2] & byte4_r[3]);

  // --------------------------------------------------------------------------
  // example aes128 engine timing
  // --------------------------------------------------------------------------
  // --------------------------------------------------------------------------
  // AES-specific control interface
  // --------------------------------------------------------------------------

wire aes128_encode = control[CTRL_ENCODE_BIT];
wire aes256_keysize = 1'b0;

wire aes_keyloaded_pulse = key128_load_ack; // pulse on last byte load of key128
wire aes_dataloaded_pulse= ip128_load_ack;  // pulse on last byte load of text128
wire aes_ready;
wire aes_valid;

// state machine control
reg  aes_ready_del;
reg  aes_init;
reg  aes_next;
reg  aes_key_busy;
reg  aes_key_rdy;
reg  aes_res_busy;
reg  aes_res_rdy;
reg  aes_err;

  always @(posedge ahb_hclk or negedge ahb_hresetn)
    if (!ahb_hresetn) begin
      aes_ready_del <= 1'b0;
      aes_init      <= 1'b0;
      aes_next      <= 1'b0;
      aes_key_busy  <= 1'b0;
      aes_key_rdy   <= 1'b0;
      aes_res_busy  <= 1'b0;
      aes_res_rdy   <= 1'b0;
      aes_err       <= 1'b0;
    end else begin
      aes_ready_del <= aes_ready; // delay for rising edge detect
      aes_init      <= aes_keyloaded_pulse;
      aes_next      <= aes_dataloaded_pulse;
      aes_key_busy  <= (aes_init) | (aes_key_busy & !(aes_ready & !aes_ready_del)); // hold until key expansion done
      aes_key_rdy   <= (aes_key_busy & aes_ready & !aes_ready_del) // expanded key ready
                     | (aes_key_rdy & !(sel_keybuf & wcyc_r));     // hold until any key update
      aes_res_busy  <= (aes_next) | (aes_res_busy & !(aes_ready & !aes_ready_del)); // hold until block processing done
      aes_res_rdy   <= (aes_res_busy & aes_ready & !aes_ready_del) // block ready
                     | (aes_res_rdy & !op128_load_ack);           // hold until output transferred
      aes_err       <= (!aes_key_rdy & ((sel_ipbuf & wcyc_r) | (sel_opbuf & rcyc_r)))
                     | (aes_err & !(sel_keybuf & wcyc_r));
    end

  assign drq_active[REQ_KEYBUF_BIT] = control[CTRL_KEY_REQ_BIT] & (!aes_keyloaded_pulse & !aes_init & !aes_key_busy & !aes_key_rdy);
  assign drq_active[REQ_IP_BUF_BIT] = control[CTRL_IP_REQ_BIT] & (!aes_dataloaded_pulse & !aes_next & !aes_res_busy & !aes_res_rdy & aes_key_rdy);
  assign drq_active[REQ_OP_BUF_BIT] = control[CTRL_OP_REQ_BIT] & (!aes_res_busy &  aes_res_rdy);

// input DMA channel shared by Key and Data-In
  assign drq_ipdma128 = (drq_enable[REQ_KEYBUF_BIT] & drq_active[REQ_KEYBUF_BIT] & !wlast128) // if key DMA enabled
                      | (drq_enable[REQ_IP_BUF_BIT] & drq_active[REQ_IP_BUF_BIT] & !wlast128) // if ip128 DMA requested
                      ;
                      
// output DMA channel for Data-Out
  assign drq_opdma128 = (drq_enable[REQ_OP_BUF_BIT]  & drq_active[REQ_OP_BUF_BIT] & !rlast128); // if op128 DMA requested

// and Interrupt requests are masked out if corresponding DMA requests are enabled
  assign irq_active[REQ_KEYBUF_BIT] = drq_active[REQ_KEYBUF_BIT] & !drq_enable[REQ_KEYBUF_BIT];
  assign irq_active[REQ_IP_BUF_BIT] = drq_active[REQ_IP_BUF_BIT] & !drq_enable[REQ_IP_BUF_BIT];
  assign irq_active[REQ_OP_BUF_BIT] = drq_active[REQ_OP_BUF_BIT] & !drq_enable[REQ_OP_BUF_BIT];
  assign irq_active[REQ_ERROR_BIT ] = control[CTRL_ERR_REQ_BIT]   & aes_err; // error raised in SW

  assign irq_key128 = irq_active[REQ_KEYBUF_BIT] & irq_enable[REQ_KEYBUF_BIT];
  assign irq_ip128  = irq_active[REQ_IP_BUF_BIT] & irq_enable[REQ_IP_BUF_BIT];
  assign irq_op128  = irq_active[REQ_OP_BUF_BIT] & irq_enable[REQ_OP_BUF_BIT];
  assign irq_error  = irq_active[REQ_ERROR_BIT ] & irq_enable[REQ_ERROR_BIT ];
// merge and mask if not DRQ
  assign irq_merged = irq_key128 | irq_ip128 | irq_op128 | irq_error;
  

// wire up status port  
  assign status[2:0]            = control [2:0];
  assign status[STAT_ERROR_BIT] = (!aes_res_busy & !aes_key_rdy);
  assign status[STAT_KEYOK_BIT] = aes_key_rdy;
  assign status[STAT_VALID_BIT] = aes_res_rdy;
  assign status[7:6]            = control [7:6];

  //----------------------------------------------------------------
  // core instantiation.
  //----------------------------------------------------------------
  aes_core core(
                .clk(ahb_hclk),
                .reset_n(ahb_hresetn),

                .encdec(aes128_encode),
                .init(aes_init),
                .next(aes_next),
                .ready(aes_ready),

                .key({key128_be,key128_be}),
                .keylen(aes256_keysize),

                .block(ip128_be),
                .result(op128_be),
                .result_valid(aes_valid)
               );
                             
endmodule

module soclabs_iobuf_reg128
 #(
  parameter  WRITE_ONLY = 0,
  parameter  WRITE_ZPAD = 0
  ) (
// -------------------------------------------------------
// de-pipelined register interface
// -------------------------------------------------------
// ahb
  input  wire         clk,        // Clock
  input  wire         rst_b,      // Reset
  input  wire         sel_r,      // Bank decode select
  input  wire         wcyc_r,     // Write cycle (wdata32 valid)
  input  wire         rcyc_r,     // Read cycle (return rdata32)
  input  wire   [1:0] word2_r,    // Address for word select
  input  wire   [3:0] byte4_r,    // Byte select decoded (up to 4 enabled)
  input  wire  [31:0] wdata32,    // Write data (byte lae qualified)
  output wire  [31:0] rdata32,    // Read data output
  output wire         dma128_ack, // DMA burst acknowledge
  output wire [127:0] out128_le,  // Litte-Endian 128-bit value
  output wire [127:0] out128_be   // Big-Endian 128-bit value
) ;

  reg   [7:0] byte0 [0:3];
  reg   [7:0] byte1 [0:3];
  reg   [7:0] byte2 [0:3];
  reg   [7:0] byte3 [0:3];
  reg         ack128;

  wire zpad_cfg = (WRITE_ZPAD==0) ? 1'b0 : 1'b1;

// byte-0 array; flush on write to word-0, byte-0
// else addressed word byte-0 write
  always @(posedge clk or negedge rst_b)
    if (!rst_b)
      begin byte0[0] <= 8'h00; byte0[1] <= 8'h00; byte0[2] <= 8'h00; byte0[3] <= 8'h00; end
    else if (zpad_cfg & sel_r & wcyc_r & byte4_r[0] & !word2_r[1] & !word2_r[0]) // Z-PAD rest
      begin byte0[0] <= wdata32[ 7: 0]; byte0[1] <= 8'h00; byte0[2] <= 8'h00; byte0[3] <= 8'h00; end
    else if (sel_r & wcyc_r & byte4_r[0])
      byte0[word2_r[1:0]] <= wdata32[ 7: 0];
   
// byte-1 array; flush on write to word-0, byte-0 if byte-1 not also written
// flush rest on write to word-0, byte-0 and byte-1 also written
// else address word byte-1 write
  always @(posedge clk or negedge rst_b)
    if (!rst_b)
      begin byte1[0] <= 8'h00; byte1[1] <= 8'h00; byte1[2] <= 8'h00; byte1[3] <= 8'h00; end
    else if (zpad_cfg & sel_r & wcyc_r & !byte4_r[1] & !word2_r[1] & !word2_r[0] & byte4_r[0]) // Z-PAD
      begin byte1[0] <= 8'h00; byte1[1] <= 8'h00; byte1[2] <= 8'h00; byte1[3] <= 8'h00; end
    else if (zpad_cfg & sel_r & wcyc_r &  byte4_r[1] & !word2_r[1] & !word2_r[0] & byte4_r[0]) // Z-PAD rest
      begin byte1[0] <= wdata32[15: 8]; byte1[1] <= 8'h00; byte1[2] <= 8'h00; byte1[3] <= 8'h00; end
    else if (sel_r & wcyc_r & byte4_r[1])
      byte1[word2_r[1:0]] <= wdata32[15: 8];
   
// byte-2 array; flush on write to word-0, byte-0 if byte-2 not also written
// flush rest on write to word-0, byte-0 and byte-2 also written
// else address word byte-2 write
  always @(posedge clk or negedge rst_b)
    if (!rst_b)
      begin byte2[0] <= 8'h00; byte2[1] <= 8'h00; byte2[2] <= 8'h00; byte2[3] <= 8'h00; end
    else if (zpad_cfg & sel_r & wcyc_r & !byte4_r[2] & !word2_r[1] & !word2_r[0] & byte4_r[0]) // Z-PAD
      begin byte2[0] <= 8'h00; byte2[1] <= 8'h00; byte2[2] <= 8'h00; byte2[3] <= 8'h00; end
    else if (zpad_cfg & sel_r & wcyc_r &  byte4_r[2] & !word2_r[1] & !word2_r[0] & byte4_r[0]) // Z-PAD rest
      begin byte2[0] <= wdata32[23:16]; byte2[1] <= 8'h00; byte2[2] <= 8'h00; byte2[3] <= 8'h00; end
    else if (sel_r & wcyc_r & byte4_r[2])
      byte2[word2_r[1:0]] <= wdata32[23:16];
   
// byte-3 array; flush on write to word-0, byte-0 if byte-3 not also written
// flush rest on write to word-0, byte-0 and byte-3 also written
// else address word byte-3 write
  always @(posedge clk or negedge rst_b)
    if (!rst_b)
      begin byte3[0] <= 8'h00; byte3[1] <= 8'h00; byte3[2] <= 8'h00; byte3[3] <= 8'h00; end
    else if (zpad_cfg & sel_r & wcyc_r & !byte4_r[3] & !word2_r[1] & !word2_r[0] & byte4_r[0]) // Z-PAD
      begin byte3[0] <= 8'h00; byte3[1] <= 8'h00; byte3[2] <= 8'h00; byte3[3] <= 8'h00; end
    else if (zpad_cfg & sel_r & wcyc_r &  byte4_r[3] & !word2_r[1] & !word2_r[0] & byte4_r[0]) // Z-PAD rest
      begin byte3[0] <= wdata32[31:24]; byte3[1] <= 8'h00; byte3[2] <= 8'h00; byte3[3] <= 8'h00; end
    else if (sel_r & wcyc_r & byte4_r[3])
      byte3[word2_r[1:0]] <= wdata32[31:24];

  // ack on write to final byte [15]   
  always @(posedge clk or negedge rst_b)
    if (!rst_b)
      ack128 <= 1'b0;
    else
      ack128 <= sel_r & wcyc_r & word2_r[1] & word2_r[0] & byte4_r[3];

  assign dma128_ack = ack128;

// byte reverse per word for Big Endian AES engine
  assign out128_be = {byte0[0], byte1[0], byte2[0], byte3[0],
                      byte0[1], byte1[1], byte2[1], byte3[1],
                      byte0[2], byte1[2], byte2[2], byte3[2],
                      byte0[3], byte1[3], byte2[3], byte3[3]};
                   
// byte reverse per word for Big Endian AES engine
  assign out128_le = {byte3[3], byte2[3], byte1[3], byte0[3],
                      byte3[2], byte2[2], byte1[2], byte0[2],
                      byte3[1], byte2[1], byte1[1], byte0[1],
                      byte3[0], byte2[0], byte1[0], byte0[0]};
                   
// little-endian read data (if not Write-Only)
  assign rdata32   = (sel_r & rcyc_r & (WRITE_ONLY == 0))
                   ? {byte3[word2_r[1:0]], byte2[word2_r[1:0]],
                      byte1[word2_r[1:0]], byte0[word2_r[1:0]]}
                   : 32'h00000000;

endmodule

// include SecWorks IP but fix up default_nettype issues that breaks elsewhere

`include "aes_core.v"
`default_nettype wire
`include "aes_encipher_block.v"
`default_nettype wire
`include "aes_decipher_block.v"
`default_nettype wire
`include "aes_key_mem.v"
`default_nettype wire
`include "aes_sbox.v"
`default_nettype wire
`include "aes_inv_sbox.v"
`default_nettype wire
