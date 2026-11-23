`timescale 1ns/1ps

// =============================================================================
// Stage 1: Instruction Fetch  +  IF/ID pipeline register
//
//   address      -> instruction memory address (current FETCH pc)
//   instruction_in <- instruction memory data for that address
//
//   instruction  -> instruction sitting in the IF/ID register (goes to stage 2)
//   pc_id        -> PC of that instruction   (used for branch target / AUIPC)
//   return_addr  -> pc_id + 4                (used for JAL / JALR link value)
//
// Redirect (and_out) comes from stage 2 (EX).  When it is asserted:
//   * the PC is loaded with the target
//   * the instruction being fetched this cycle is on the wrong path, so the
//     IF/ID register is loaded with a NOP instead  (1-cycle branch penalty)
// =============================================================================
module if_stage (
    input  logic        clk,
    input  logic        reset,              // Asynchronous active-high reset

    // input logic      stall,

    // Redirect from stage 2
    input  logic        and_out,
    input  logic [31:0] pc_signed_offset,

    // Instruction memory interface
    input  logic [31:0] instruction_in,
    output logic [31:0] address,            // fetch PC

    // IF/ID register outputs (to stage 2)
    output logic [31:0] instruction,
    output logic [31:0] pc_id,
    output logic [31:0] return_addr
);

    localparam logic [31:0] RESET_PC = 32'h8000_0000;
    localparam logic [31:0] NOP      = 32'h0000_0013;   // addi x0, x0, 0

    logic [31:0] pc_plus4;
    logic [31:0] pc_next;
    logic [31:0] pc4_id;

    assign pc_plus4    = address + 32'd4;
    assign pc_next     = and_out ? pc_signed_offset : pc_plus4;
    assign return_addr = pc4_id;

    // ---------------- PC register ----------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            address <= RESET_PC;
        // else if (!stall)
        else
            address <= pc_next;
    end

    // ---------------- IF/ID register ----------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            instruction <= NOP;
            pc_id       <= RESET_PC;
            pc4_id      <= RESET_PC + 32'd4;
        end
        // else if (!stall)
        else begin
            instruction <= and_out ? NOP : instruction_in;   // flush on redirect
            pc_id       <= address;
            pc4_id      <= pc_plus4;
        end
    end

endmodule