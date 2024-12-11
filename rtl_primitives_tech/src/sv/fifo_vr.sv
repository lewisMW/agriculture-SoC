//-----------------------------------------------------------------------------
// SoC Labs Basic Parameterisable Valid-Ready FIFO
// A joint work commissioned on behalf of SoC Labs, under Arm Academic Access license.
//
// Contributors
//
// David Mapstone (d.a.mapstone@soton.ac.uk)
//
// Copyright  2022, SoC Labs (www.soclabs.org)
//-----------------------------------------------------------------------------
module fifo_vr #(
    parameter  DEPTH  = 4,                 // FIFO Row Depth
    parameter  DATA_W = 32,                // FIFO Row Width
    localparam PTR_W  = $clog2(DEPTH) + 1  // Read/Write Pointer Width
)(
    input logic clk,
    input logic nrst,
    input logic en,
    
    // Synchronous, localised reset
    input logic sync_rst,
    
    // In (Write) Control
    input  logic [DATA_W-1:0] data_in,
    input  logic data_in_last,
    input  logic data_in_valid,
    output logic data_in_ready,
    
    // Out (Read) Control
    output logic [DATA_W-1:0] data_out,
    output logic data_out_last,
    input  logic data_out_ready,
    output logic data_out_valid,

    // Status 
    output logic [PTR_W-1:0] status_ptr_dif
);

    logic data_in_shake;    // Successful Write Handshake
    logic data_out_shake;   // Successful Read Handshake
    
    assign data_in_shake  = (data_in_valid  == 1'b1) && (data_in_ready  == 1'b1);
    assign data_out_shake = (data_out_valid == 1'b1) && (data_out_ready == 1'b1);
    
    logic [DATA_W:0]   fifo [DEPTH-1:0]; // FIFO Memory Structure
    logic [PTR_W-1:0]  write_ptr;        // FIFO Write Pointer
    logic [PTR_W-1:0]  read_ptr;         // FIFO Read Pointer
    logic [PTR_W-1:0]  ptr_dif;          // Difference between Write and Read Pointers
    
    assign ptr_dif = write_ptr - read_ptr;
    
    assign status_ptr_dif = ptr_dif;
    
    // EXAMPLE: Conditions to write and read from FIFO's
    // Write Ptr  | Read Ptr  | Ptr_Dif | Valid Write | Valid Read
    //    000     -    000    =   000   |      Y      |     N
    //    001     -    000    =   001   |      Y      |     Y
    //    010     -    000    =   010   |      Y      |     Y
    //    011     -    000    =   011   |      Y      |     Y
    //    100     -    000    =   100   |      N      |     Y
    //    101     -    000    =   101   |      N      |     N
    //    110     -    000    =   110   |      N      |     N
    //    111     -    000    =   111   |      N      |     N
    // WriteValid: WritePtr - ReadPtr < 3'd4
    // ReadValid:  WritePtr - ReadPtr - 1 < 3'd4
    
    assign {data_out,data_out_last} = fifo [read_ptr[PTR_W-2:0]]; // Output Data is dereferenced value of the Read Pointer
    
    always_ff @(posedge clk, negedge nrst) begin
        if ((!nrst) || sync_rst) begin
            // Under Reset
            // - Pointers reset to 0 (FIFO is empty without needing to reset the memories)
            // - Control taken low
            write_ptr    <= 0;
            read_ptr     <= 0;
            data_in_ready     <= 1'b0;
            data_out_valid    <= 1'b0;
            // Ensure FIFO Values are Known
            for (int i = 0; i < DEPTH; i++) begin
                fifo[i] <= 'b0;
            end
        end else if (en == 1'b1) begin
            // Enable signal is High
            // Write Logic
            if (ptr_dif < DEPTH) begin 
                // Empty Rows in FIFO in FIFO
                if (data_in_shake) begin 
                    // Successful Handshake store data in FIFO and increment Write Pointer 
                    fifo [write_ptr[PTR_W-2:0]] <= {data_in,data_in_last};
                    write_ptr                   <= write_ptr + 1;
                    if ((ptr_dif + {{(PTR_W-1){1'b0}},(1'b1 - data_out_shake)}) < DEPTH) begin 
                        // Still space in FIFO after latest write
                        // If theres a successful read on this clock cycle, 
                        // there will be an additional space in the FIFO next clock cycle
                        // (number of pieces of data in the FIFO won't have changed)
                        data_in_ready <= 1'b1;
                    end else begin 
                        // FIFO is now full
                        data_in_ready <= 1'b0;
                    end
                end else begin 
                    // Unsuccessful handshake but space in FIFO
                    // If there's write space now, next cc it will be the same or more 
                    // (more if a succesful read has been carried out in this cc)
                    data_in_ready <= 1'b1;
                end
            end else begin
                if ((ptr_dif - {{(PTR_W-1){1'b0}}, data_out_shake}) < DEPTH) begin 
                    // If there is a successful read this clock cycle, 
                    // there will be space for another piece of data in the FIFO 
                    // (number of pieces of data in FIFO will have decremented by 1) 
                    data_in_ready <= 1'b1;
                end else begin 
                    // FIFO still Full
                    data_in_ready <= 1'b0;
                end
            end
            // Read Logic
            if ((ptr_dif - 1) < DEPTH) begin 
                // Data in FIFO - atleast one Piece of Data in FIFO
                // -> the  "-1" causes dif of 0 to wrap where (dif - 1) becomes > DEPTH
                if (data_out_shake) begin 
                    // Successful Handshake Increment Read Pointer
                    read_ptr       <= read_ptr + 1;
                    if (((ptr_dif - 1) + {{(PTR_W-1){1'b0}},data_in_shake}) - 1 < DEPTH) begin
                        // Still Data in FIFO after latest Read
                        // If there is a successful write this clock cycle, 
                        // there will be one more piece of data in the FIFO 
                        // (number of pieces of data in FIFO wont have changed) 
                        data_out_valid <= 1'b1;
                    end else begin 
                        // FIFO empty after latest Read
                        data_out_valid <= 1'b0;
                    end
                end else begin 
                    // Unsuccessful handshake but Data in FIFO
                    // If there's read data now, next cc it will be the same or more 
                    // (more if a succesful write has been carried out in this cc)
                    data_out_valid <= 1'b1;
                end
            end else begin
                if (((ptr_dif - 1) + {{(PTR_W-1){1'b0}},data_in_shake}) < DEPTH) begin 
                    // If there is a successful write this clock cycle, 
                    // there will be one more piece of data in the FIFO 
                    // (number of pieces of data in FIFO will have incremented by 1) 
                    data_out_valid <= 1'b1;
                end else begin 
                    // FIFO still empty
                    data_out_valid <= 1'b0;
                end
            end
        end else begin
            // If Enable is Low, set Control Low
            data_in_ready  <= 1'b0;
            data_out_valid <= 1'b0;
        end
    end
    
    // Verif Notes to Check behaiour:
    // 1) Fill FIFO up with Data
    // 2) Read & Write in same clock cycle 
endmodule
