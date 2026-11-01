`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2026 12:06:25
// Design Name: 
// Module Name: top_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module top_ID(
    input logic clk, reset,
    input logic [31:0] instruction,

    // Writeback inputs
    input logic [31:0] wb_data,
    input logic [4:0] wb_rd,
    input logic wb_reg_write,

    // Pipeline control
    input logic stall,
    input logic pc_src,
    input logic [31:0] pc_signed_offset,

    // ID outputs
    output logic [4:0] rs1, rs2, rd,
    output logic [6:0] opcode, imm11_5,
    output logic [2:0] fn3,
    output logic [12:0] imm,
    output logic func7_5,
    output logic [19:0] imm_uj,

    // Register file outputs
    output logic [31:0] rs1_data, rs2_data,

    // Immediate generator output
    output logic [31:0] imm_output,

    // Main control outputs
    output logic branch, mux_inp, memread, memwrite,
    output logic alusrc, reg_write,
    output logic [1:0] memtoreg,
    output logic [2:0] aluop,

    // ALU outputs
    output logic [31:0] alu_out,
    output logic zero
);

// Internal signals
logic [4:0] alu_ctrl;
logic [31:0] alu_inp;


// 1. INSTRUCTION DECODE

instruction_decoder ID1 (
    .instruction(instruction),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .opcode(opcode),
    .imm11_5(imm11_5),
    .func3(fn3),
    .imm(imm),
    .func7_5(func7_5),
    .imm_uj(imm_uj)
);


// 2. MAIN CONTROL

main_control MC1 (
    .opcode(opcode),
    .branch(branch),
    .mux_inp(mux_inp),
    .memread(memread),
    .memwrite(memwrite),
    .alusrc(alusrc),
    .reg_write(reg_write),
    .memtoreg(memtoreg),
    .aluop(aluop)
);


// 3. IMMEDIATE GENERATOR

immgenerator IMM1 (
    .imm_input(imm[11:0]),
    .fn3(fn3),
    .opcode(opcode),
    .imm_input_uj(imm_uj),
    .imm_output(imm_output)
);


// 4. REGISTER FILE

register_file RF1 (
    .rs1_sel(rs1),
    .rs2_sel(rs2),
    .rd_sel(wb_rd),
    .wb_data(wb_data),
    .reg_write(wb_reg_write),
    .clk(clk),
    .reset(reset),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);


// 5. ALU CONTROL

alu_control ALU_CONTROL (
    .alu_op(aluop),
    .fn3(fn3),
    .fn7_5(func7_5),
    .imm11_5(imm11_5),
    .control_out(alu_ctrl)
);


// 6. ALU INPUT SELECTION

assign alu_inp = alusrc ? imm_output : rs2_data;


// 7. ALU

alu ALU (
    .alu_control(alu_ctrl),
    .rs1_data(rs1_data),
    .rs2_data(alu_inp),
    .alu_out(alu_out),
    .zero(zero)
);


// 8. INSTRUCTION FETCH

instruction_fetch u_if (
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .pc_src(pc_src),
    .pc_signed_offset(pc_signed_offset),
    .address(address),
    .pc_new(pc_new)
);

endmodule
