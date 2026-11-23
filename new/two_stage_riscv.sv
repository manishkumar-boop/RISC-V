`timescale 1ns/1ps

// =============================================================================
// 2-stage RV32I
//
//   Stage 1 (IF)        : PC, instruction fetch  -> IF/ID register
//   Stage 2 (ID/EX/MEM/WB): decode, reg read, ALU, data memory, write back
//
// No data hazards: register read and write both happen in stage 2.
// Control hazard: taken branch/jump flushes the IF/ID register (1 bubble).
// =============================================================================
module two_stage_riscv (
    input  logic        clk,
    input  logic        reset,
    //input  logic        stall,

    // Instruction memory interface
    input  logic [31:0] instruction,        // from IMEM (data for 'address')
    output logic [31:0] address,            // to IMEM   (fetch PC)

    // Data memory interface
    input  logic [31:0] mem_out,
    output logic [31:0] rs2_data,
    output logic [31:0] alu_out,
    output logic        mem_write,
    output logic        mem_read,
    output logic [2:0]  fn3,
    output logic [6:0]  opcode
);

    logic [31:0] instruction_id;            // instruction in stage 2
    logic [31:0] pc_id;                     // its PC
    logic [31:0] return_addr;               // its PC + 4

    logic [31:0] rs1_data;
    logic [31:0] imm_out;
    logic [31:0] wb_data;
    logic [31:0] pc_signed_offset;

    logic        and_out_ex;
    logic        branch;
    logic        alu_src;
    logic [1:0]  memtoreg;
    logic [2:0]  aluop;
    logic        fn7_5;
    logic        mux_inp;
    logic [6:0]  imm11_5;

    // ---------------- Stage 1 ----------------
    if_stage if_st (
        .clk              (clk),
        .reset            (reset),
        //.stall          (stall),
        .and_out          (and_out_ex),
        .pc_signed_offset (pc_signed_offset),
        .instruction_in   (instruction),
        .address          (address),
        .instruction      (instruction_id),
        .pc_id            (pc_id),
        .return_addr      (return_addr)
    );

    // ---------------- Stage 2 ----------------
    id_stage id_st (
        .clk          (clk),
        .reset        (reset),
        .instruction  (instruction_id),
        .wb_data      (wb_data),
        .rs1_data     (rs1_data),
        .rs2_data     (rs2_data),
        .imm_out      (imm_out),
        .opcode_out_d (opcode),
        .imm11_5      (imm11_5),
        .fn3_out_d    (fn3),
        .fn7_5        (fn7_5),
        .aluop        (aluop),
        .memtoreg     (memtoreg),
        .branch       (branch),
        .mem_write    (mem_write),
        .mem_read     (mem_read),
        .alu_src      (alu_src),
        .mux_inp      (mux_inp)
    );

    ex_stage ex_st (
        .rs1_data   (rs1_data),
        .rs2_data   (rs2_data),
        .imm_out    (imm_out),
        .address    (pc_id),                // PC of the instruction in stage 2
        .branch     (branch),
        .alu_src    (alu_src),
        .fn7_5      (fn7_5),
        .mux_inp    (mux_inp),
        .fn3        (fn3),
        .imm11_5    (imm11_5),
        .aluop      (aluop),
        .opcode     (opcode),
        .and_out_ex (and_out_ex),
        .alu_out    (alu_out),
        .pc_ex_out  (pc_signed_offset)
    );

    wb_stage wb_st (
        .mem_out          (mem_out),
        .alu_out          (alu_out),
        .return_addr      (return_addr),
        .imm_out          (imm_out),
        .pc_signed_offset (pc_signed_offset),
        .memtoreg         (memtoreg),
        .opcode_out_d     (opcode),
        .wb_data          (wb_data)
    );

endmodule