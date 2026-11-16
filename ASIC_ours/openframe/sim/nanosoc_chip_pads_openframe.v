// =====================================================================
// nanosoc_chip_pads_openframe.v -- the OpenFrame wrapper behind the pad-level
// port list of nanosoc_chip_pads, for gate-level simulation.
//
// The SoC Labs testbench instantiates a module called nanosoc_chip_pads and
// talks to its pads (CLK, NRST, P0, P1, SWDIO, SWDCK, TEST, SE). This file
// provides that module: it holds the gate netlist of openframe_project_wrapper
// (instance u_openframe) and a model of what ChipFoundry's frame does around
// it: the 44 GPIO pads, the loopback constants, the reset pad and the
// power-on reset. The testbench is used unchanged.
//
// It also
//   - preloads the instruction memory (the memory macro models) from image.hex,
//     as the RTL simulation's IMEM_0_RAM_PRELOAD does with a ROM;
//   - checks, once reset is over, that every pad's static configuration is
//     what ../README.md's pad map says.
//
// The memory instances' names come from openframe_gl_paths.vh, which
// run_gl_sim.sh writes from the netlist, each a path below this module:
//   OF_MEM_DFFRAM defined: ChipFoundry's DFFRAM blocks (dffram_pg_models.v),
//                 OF_IMEM_LO and OF_IMEM_HI (512 words each), OF_DMEM (256),
//                 OF_EXPRAM_L and OF_EXPRAM_H (128 each);
//   OF_MEM_COMPILER defined: blocks from the DFFRAM compiler (same file), OF_IMEM
//                 (1024 words), OF_DMEM, OF_EXPRAM_L and OF_EXPRAM_H (512 each);
//   otherwise:    the OpenRAM macro, OF_IMEM, OF_DMEM, OF_EXPRAM_L, OF_EXPRAM_H
//                 (2048 words each).
//   OF_MEM_GATES defined as well as OF_MEM_DFFRAM: the DFFRAM blocks are their
//                 gate netlists (OL-DFFRAM hdl/gl), not models. The backdoor is
//                 then a deposit into each storage latch, through the tasks of
//                 openframe_mem_preload.vh (dffram_gl_preload.py), and with
//                 OF_SDF each block gets ChipFoundry's SDF for it (OF_SDF_512,
//                 OF_SDF_256, OF_SDF_128 in openframe_gl_paths.vh).
// Defines: OF_SDF annotates the netlist with openframe_project_wrapper.sim.flat.sdf
//          (looked for in the directory the simulation runs in), taking the
//          corner OF_SDF_MTM names: "MINIMUM" fast, "TYPICAL", "MAXIMUM" slow
//          (the default; write_sim_netlist.tcl writes the three);
//          OF_ZERO_RAM starts the three data memories at 0 and not X;
//          OF_TIMEOUT_NS=<n> ends the run with an error after n ns;
//          OF_HEARTBEAT_NS=<n> prints the simulation time every n ns;
//          OF_PADLOG writes every change on the P1[7:0] pads (the host link) and
//          their output enables to padlog.txt, for comparing two runs.
// =====================================================================
`timescale 1ns/1ps
`include "openframe_gl_paths.vh"

// One frame pad, reduced to what the wrapper uses of sky130_fd_io gpiov2:
// drive modes 000 (analog, output off), 001 (input only), 110 (strong
// push-pull) and 111 (weak drive: the pull-down of an input, which anything
// else on the pad overrides); the input buffer reads 0 when it is disabled.
module openframe_gpio_pad_model (
  inout  wire PAD,
  input  wire out,
  input  wire oeb,
  input  wire inp_dis,
  input  wire dm2,
  input  wire dm1,
  input  wire dm0,
  output wire in
);
  wire weak  = ({dm2, dm1, dm0} === 3'b111);
  wire drive = (oeb === 1'b0) && ({dm2, dm1, dm0} !== 3'b000) && ({dm2, dm1, dm0} !== 3'b001);
  bufif1                (PAD, out, drive && !weak);
  bufif1 (weak1, weak0) (PAD, out, drive && weak);
  assign in = (inp_dis === 1'b0) ? PAD : 1'b0;
endmodule

module nanosoc_chip_pads (
`ifdef POWER_PINS
  inout  wire          VDDIO,
  inout  wire          VSSIO,
  inout  wire          VDD,
  inout  wire          VSS,
  inout  wire          VDDACC,
`endif
  input  wire          SE,
  input  wire          CLK,
  input  wire          TEST,
  input  wire          NRST,   // active low
  inout  wire  [15:0]  P0,
  inout  wire  [15:0]  P1,
  inout  wire          SWDIO,
  input  wire          SWDCK
);

  // ---------------------------------------------------------------- frame
  wire [43:0] gpio_in, gpio_out, gpio_oeb, gpio_inp_dis;
  wire [43:0] gpio_ib_mode_sel, gpio_vtrip_sel, gpio_slow_sel, gpio_holdover;
  wire [43:0] gpio_analog_en, gpio_analog_sel, gpio_analog_pol;
  wire [43:0] gpio_dm2, gpio_dm1, gpio_dm0;
  wire [43:0] analog_io, analog_noesd_io;
  wire [43:0] pad;                      // the pads that the testbench does not reach

  supply1 vpwr;
  supply0 vgnd;

  // power-on reset of the frame: released well before the testbench's NRST
  reg porb;
  initial begin porb = 1'b0; #53 porb = 1'b1; end

  // The testbench's own pull-ups and pull-downs (pull strength) override these.
  // They stand for the board: a pad nothing drives must not float into the logic.
  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : g_weak
      pullup (weak1) (P0[i]);
      pullup (weak1) (P1[i]);
    end
  endgenerate
  pullup (weak1) (SWDIO);

  // ------------------------------------------------------------- the pads
  // pad map: ../README.md
  `define OF_PAD(inst, n, net) \
    openframe_gpio_pad_model inst ( .PAD(net), .out(gpio_out[n]), .oeb(gpio_oeb[n]), \
      .inp_dis(gpio_inp_dis[n]), .dm2(gpio_dm2[n]), .dm1(gpio_dm1[n]), .dm0(gpio_dm0[n]), .in(gpio_in[n]) );

  // input-only pads: the pad is an input of this module, so it is read directly
  // (TEST, SE and SWDCK also have the pad's weak pull-down, which the testbench's
  // driver overrides)
  `define OF_PAD_IN(n, net) \
    assign gpio_in[n] = (gpio_inp_dis[n] === 1'b0) ? net : 1'b0;

  // the host link and UART2: P1[7:0]
  `OF_PAD(u_pad0, 0, P1[ 0])    `OF_PAD(u_pad7, 7, P1[ 1])    `OF_PAD(u_pad8, 8, P1[ 2])    `OF_PAD(u_pad9, 9, P1[ 3])
  `OF_PAD(u_pad5, 5, P1[ 4])    `OF_PAD(u_pad6, 6, P1[ 5])    `OF_PAD(u_pad10, 10, P1[ 6])  `OF_PAD(u_pad11, 11, P1[ 7])
  `OF_PAD(u_pad12, 12, P1[ 8])  `OF_PAD(u_pad13, 13, P1[ 9])  `OF_PAD(u_pad14, 14, P1[10])  `OF_PAD(u_pad22, 22, P1[11])
  `OF_PAD(u_pad23, 23, P1[12])  `OF_PAD(u_pad36, 36, P1[13])  `OF_PAD(u_pad37, 37, P1[14])  `OF_PAD(u_pad43, 43, P1[15])

  `OF_PAD(u_pad24, 24, P0[ 0])  `OF_PAD(u_pad25, 25, P0[ 1])  `OF_PAD(u_pad26, 26, P0[ 2])  `OF_PAD(u_pad27, 27, P0[ 3])
  `OF_PAD(u_pad28, 28, P0[ 4])  `OF_PAD(u_pad29, 29, P0[ 5])  `OF_PAD(u_pad30, 30, P0[ 6])  `OF_PAD(u_pad31, 31, P0[ 7])
  `OF_PAD(u_pad32, 32, P0[ 8])  `OF_PAD(u_pad33, 33, P0[ 9])  `OF_PAD(u_pad34, 34, P0[10])  `OF_PAD(u_pad35, 35, P0[11])
  `OF_PAD(u_pad1, 1, P0[12])    `OF_PAD(u_pad2, 2, P0[13])    `OF_PAD(u_pad3, 3, P0[14])    `OF_PAD(u_pad4, 4, P0[15])

  `OF_PAD(u_pad21, 21, SWDIO)

  `OF_PAD_IN(38, CLK)
  `OF_PAD_IN(20, SWDCK)
  `OF_PAD_IN(18, TEST)
  `OF_PAD_IN(19, SE)

  // analog pads (15 reference, 16/17 ADC inputs) and unused pads (39-42)
  `OF_PAD(u_pad15, 15, pad[15])  `OF_PAD(u_pad16, 16, pad[16])  `OF_PAD(u_pad17, 17, pad[17])
  `OF_PAD(u_pad39, 39, pad[39])  `OF_PAD(u_pad40, 40, pad[40])  `OF_PAD(u_pad41, 41, pad[41])  `OF_PAD(u_pad42, 42, pad[42])

  // ------------------------------------------------------------ the design
  openframe_project_wrapper u_openframe (
    .vdda (vpwr), .vdda1 (vpwr), .vdda2 (vpwr), .vssa (vgnd), .vssa1 (vgnd), .vssa2 (vgnd),
    .vccd (vpwr), .vccd1 (vpwr), .vccd2 (vpwr), .vssd (vgnd), .vssd1 (vgnd), .vssd2 (vgnd),
    .vddio (vpwr), .vssio (vgnd),
    .porb_h             (porb),
    .porb_l             (porb),
    .por_l              (~porb),
    .resetb_h           (NRST),
    .resetb_l           (NRST),
    .mask_rev           (32'h0),
    .gpio_in            (gpio_in),
    .gpio_in_h          (gpio_in),
    .gpio_out           (gpio_out),
    .gpio_oeb           (gpio_oeb),
    .gpio_inp_dis       (gpio_inp_dis),
    .gpio_ib_mode_sel   (gpio_ib_mode_sel),
    .gpio_vtrip_sel     (gpio_vtrip_sel),
    .gpio_slow_sel      (gpio_slow_sel),
    .gpio_holdover      (gpio_holdover),
    .gpio_analog_en     (gpio_analog_en),
    .gpio_analog_sel    (gpio_analog_sel),
    .gpio_analog_pol    (gpio_analog_pol),
    .gpio_dm2           (gpio_dm2),
    .gpio_dm1           (gpio_dm1),
    .gpio_dm0           (gpio_dm0),
    .analog_io          (analog_io),
    .analog_noesd_io    (analog_noesd_io),
    .gpio_loopback_one  ({44{1'b1}}),
    .gpio_loopback_zero ({44{1'b0}})
  );

`ifdef OF_SDF
`ifndef OF_SDF_MTM
`define OF_SDF_MTM "MAXIMUM"
`endif
  initial $sdf_annotate("openframe_project_wrapper.sim.flat.sdf", u_openframe, , "sdf_annotate.log", `OF_SDF_MTM);
`ifdef OF_MEM_GATES
  // The memory blocks' own delays: one SDF per block and corner, each value in
  // it given three times, so the choice of column does not matter here.
  initial begin
    $sdf_annotate(`OF_SDF_512, `OF_IMEM_LO , , "sdf_imem_lo.log", "MAXIMUM");
    $sdf_annotate(`OF_SDF_512, `OF_IMEM_HI , , "sdf_imem_hi.log", "MAXIMUM");
    $sdf_annotate(`OF_SDF_256, `OF_DMEM , , "sdf_dmem.log", "MAXIMUM");
    $sdf_annotate(`OF_SDF_128, `OF_EXPRAM_L , , "sdf_expram_l.log", "MAXIMUM");
    $sdf_annotate(`OF_SDF_128, `OF_EXPRAM_H , , "sdf_expram_h.log", "MAXIMUM");
  end
`endif
`endif

`ifdef OF_TIMEOUT_NS
  initial begin
    #(`OF_TIMEOUT_NS);
    $display("[OPENFRAME] ERROR: no end of test after %0d ns", `OF_TIMEOUT_NS);
    $finish;
  end
`endif
`ifdef OF_HEARTBEAT_NS
  always #(`OF_HEARTBEAT_NS) $display("[OPENFRAME] t = %0t", $time);
`endif

`ifdef OF_PADLOG
  // P1[7:0] are GPIO 11, 10, 6, 5, 9, 8, 7, 0; oeb low = the chip drives the pad
  integer of_padlog;
  wire [7:0] of_p1_oeb = {gpio_oeb[11], gpio_oeb[10], gpio_oeb[6], gpio_oeb[5], gpio_oeb[9], gpio_oeb[8], gpio_oeb[7], gpio_oeb[0]};
  wire [7:0] of_p1_out = {gpio_out[11], gpio_out[10], gpio_out[6], gpio_out[5], gpio_out[9], gpio_out[8], gpio_out[7], gpio_out[0]};
  initial of_padlog = $fopen("padlog.txt", "w");
  always @(P1[7:0] or of_p1_oeb or of_p1_out)
    $fdisplay(of_padlog, "%0t pad=%b oeb=%b out=%b", $time, P1[7:0], of_p1_oeb, of_p1_out);
`endif

  // --------------------------------------------------------------- memories
  // image.hex: one byte per line, little-endian words (as sl_ahb_rom reads it).
  // An image that does not fit the instruction memory is an error here: the
  // RTL simulation would run it, in a 16 kbyte ROM model.
`ifdef OF_MEM_COMPILER
  localparam integer IMEM_WORDS = 1024;    // one 1024-word block
`elsif OF_MEM_DFFRAM
  localparam integer IMEM_WORDS = 1024;    // two 512-word blocks
`else
  localparam integer IMEM_WORDS = 2048;    // one OpenRAM macro; the region's top address bit is unconnected
  // The OpenRAM model prints every access unless VERBOSE is 0.
  defparam `OF_IMEM .VERBOSE     = 0;
  defparam `OF_DMEM .VERBOSE     = 0;
  defparam `OF_EXPRAM_L .VERBOSE = 0;
  defparam `OF_EXPRAM_H .VERBOSE = 0;
`endif
  localparam integer IMG_BYTES = 1 << 14;
  reg [7:0]  of_image [0:IMG_BYTES-1];
  reg [31:0] of_word;
  integer k, of_last;
`ifdef OF_MEM_GATES
  // of_dep_<block>(word, data) and of_peek_<block>(word, data) for each block
  `include "openframe_mem_preload.vh"
  reg [31:0] of_rb;
  integer    of_bad_img;
`endif
  initial begin
    for (k = 0; k < IMG_BYTES; k = k + 1) of_image[k] = 8'hxx;
    $readmemh("image.hex", of_image);
    of_last = -1;
    for (k = 0; k < IMG_BYTES; k = k + 1) if (of_image[k] !== 8'hxx) of_last = k;
    for (k = 0; k < IMG_BYTES; k = k + 1) if (of_image[k] === 8'hxx) of_image[k] = 8'h00;
`ifdef OF_MEM_GATES
    // A value deposited into a latch stays only while the latch's write clock is
    // idle, and the blocks' clock gates start unknown. So wait until every
    // block's write enables are low and its clock has run, which is the case
    // during reset, long before the boot code hands over to this program.
    wait ((`OF_IMEM_LO .WE0 === 4'b0) && (`OF_IMEM_HI .WE0 === 4'b0) && (`OF_DMEM .WE0 === 4'b0)
          && (`OF_EXPRAM_L .WE0 === 4'b0) && (`OF_EXPRAM_H .WE0 === 4'b0));
    repeat (8) @(posedge `OF_IMEM_LO .CLK);
    #1;
`endif
    for (k = 0; k < IMEM_WORDS; k = k + 1) begin
      of_word = {of_image[4*k+3], of_image[4*k+2], of_image[4*k+1], of_image[4*k]};
`ifdef OF_MEM_COMPILER
      `OF_IMEM .m.RAM[k] = of_word;
`elsif OF_MEM_GATES
      if (k < 512) of_dep_OF_IMEM_LO(k, of_word); else of_dep_OF_IMEM_HI(k - 512, of_word);
`elsif OF_MEM_DFFRAM
      if (k < 512) `OF_IMEM_LO .m.RAM[k] = of_word; else `OF_IMEM_HI .m.RAM[k-512] = of_word;
`else
      `OF_IMEM .mem[k] = of_word;
`endif
    end
    $display("[OPENFRAME] image.hex: %0d bytes loaded into the instruction memory (%0d available)", of_last + 1, 4 * IMEM_WORDS);
`ifdef OF_MEM_GATES
    #1;
    of_bad_img = 0;
    for (k = 0; k < IMEM_WORDS; k = k + 1) begin
      of_word = {of_image[4*k+3], of_image[4*k+2], of_image[4*k+1], of_image[4*k]};
      if (k < 512) of_peek_OF_IMEM_LO(k, of_rb); else of_peek_OF_IMEM_HI(k - 512, of_rb);
      if (of_rb !== of_word) of_bad_img = of_bad_img + 1;
    end
    if (of_bad_img == 0) $display("[OPENFRAME] the image is in the instruction memory's latches at %0t", $time);
    else $display("[OPENFRAME] ERROR: %0d words of the image did not stay in the instruction memory's latches", of_bad_img);
`endif
    if (of_last >= 4 * IMEM_WORDS)
      $display("[OPENFRAME] ERROR: the image is larger than the %0d byte instruction memory", 4 * IMEM_WORDS);
`ifdef OF_ZERO_RAM
`ifdef OF_MEM_COMPILER
    for (k = 0; k < 512; k = k + 1) begin
      `OF_DMEM .m.RAM[k]     = 32'h0;
      `OF_EXPRAM_L .m.RAM[k] = 32'h0;
      `OF_EXPRAM_H .m.RAM[k] = 32'h0;
    end
`elsif OF_MEM_GATES
    for (k = 0; k < 256; k = k + 1) of_dep_OF_DMEM(k, 32'h0);
    for (k = 0; k < 128; k = k + 1) begin
      of_dep_OF_EXPRAM_L(k, 32'h0);
      of_dep_OF_EXPRAM_H(k, 32'h0);
    end
`elsif OF_MEM_DFFRAM
    for (k = 0; k < 256; k = k + 1) `OF_DMEM .m.RAM[k] = 32'h0;
    for (k = 0; k < 128; k = k + 1) begin
      `OF_EXPRAM_L .m.RAM[k] = 32'h0;
      `OF_EXPRAM_H .m.RAM[k] = 32'h0;
    end
`else
    for (k = 0; k < 2048; k = k + 1) begin
      `OF_DMEM .mem[k]     = 32'h0;
      `OF_EXPRAM_L .mem[k] = 32'h0;
      `OF_EXPRAM_H .mem[k] = 32'h0;
    end
`endif
`endif
  end

  // ------------------------------------------------- pad configuration check
  // kind: 0 = bidirectional (strong push-pull, input on), 1 = input only,
  //       2 = analog or unused (output off, input buffer off),
  //       3 = input with the pad's pull-down (weak drive of 0, input on)
  function [0:0] of_cfg_ok (input integer n, input integer kind);
    reg [2:0] dm;
    begin
      dm = {gpio_dm2[n], gpio_dm1[n], gpio_dm0[n]};
      case (kind)
        0: of_cfg_ok = (dm === 3'b110) && (gpio_inp_dis[n] === 1'b0) && (gpio_analog_en[n] === 1'b0);
        1: of_cfg_ok = (dm === 3'b001) && (gpio_inp_dis[n] === 1'b0) && (gpio_oeb[n] === 1'b1)
                                       && (gpio_analog_en[n] === 1'b0);
        3: of_cfg_ok = (dm === 3'b111) && (gpio_inp_dis[n] === 1'b0) && (gpio_oeb[n] === 1'b0)
                                       && (gpio_out[n] === 1'b0) && (gpio_analog_en[n] === 1'b0);
        default: of_cfg_ok = (dm === 3'b000) && (gpio_inp_dis[n] === 1'b1) && (gpio_oeb[n] === 1'b1)
                                             && (gpio_analog_en[n] === 1'b0);
      endcase
    end
  endfunction

  integer p, of_bad;
  initial begin
    @(posedge NRST);
    #100;
    of_bad = 0;
    for (p = 0; p < 44; p = p + 1) begin : chk
      integer kind;
      if (p == 38)                                           kind = 1;
      else if (p >= 18 && p <= 20)                           kind = 3;
      else if ((p >= 15 && p <= 17) || (p >= 39 && p <= 42)) kind = 2;
      else                                                   kind = 0;
      if (!of_cfg_ok(p, kind)) begin
        of_bad = of_bad + 1;
        $display("[OPENFRAME] ERROR: pad %0d configuration: dm=%b%b%b inp_dis=%b oeb=%b analog_en=%b (expected kind %0d)",
                 p, gpio_dm2[p], gpio_dm1[p], gpio_dm0[p], gpio_inp_dis[p], gpio_oeb[p], gpio_analog_en[p], kind);
      end
    end
    if (of_bad == 0) $display("[OPENFRAME] pad configuration check PASSED for all 44 pads at %0t", $time);
    else             $display("[OPENFRAME] pad configuration check FAILED for %0d pads", of_bad);
  end

endmodule
