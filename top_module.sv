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

    // From data memory
    input logic [31:0] read_data,

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

    output logic [31:0] rs1_data, rs2_data,
    output logic [31:0] imm_output,

    output logic branch, mux_inp, memread, memwrite,
    output logic alusrc, reg_write,
    output logic [1:0] memtoreg,
    output logic [2:0] aluop,

    output logic [31:0] alu_out,
    output logic zero,

    // WB output (also useful for debug)
    output logic [31:0] wb_data
);

logic [4:0]  alu_ctrl;
logic [31:0] alu_inp;
logic [31:0] address, pc_new;   // were undeclared (implicit 1-bit nets!)

// ... ID1, MC1, IMM1 unchanged ...

// 4. REGISTER FILE (now fed by WB)
register_file RF1 (
    .rs1_sel(rs1),
    .rs2_sel(rs2),
    .rd_sel(rd),              // was wb_rd
    .wb_data(wb_data),        // from WB stage below
    .reg_write(reg_write),    // was wb_reg_write
    .clk(clk),
    .reset(reset),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data)
);

// ... ALU_CONTROL, alu_inp mux, ALU, u_if unchanged ...

// 9. WRITE BACK
write_back_data WB1 (
    .alu_out(alu_out),
    .return_address(pc_new),  // must be PC+4, check below
    .imm_out(imm_output),
    .PC_exe(address),
    .read_data(read_data),
    .opcode(opcode),
    .memtoreg(memtoreg),
    .wb_data(wb_data)
);

endmodule
