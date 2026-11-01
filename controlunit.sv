`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2026 20:40:53
// Design Name: 
// Module Name: controlunit
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


module main_control(
    input  logic [6:0] opcode,
    input  logic [2:0] fn3,

    output logic [1:0] memtoreg,
    output logic branch,
    output logic mux_inp,
    output logic memread,
    output logic memwrite,
    output logic alusrc,
    output logic reg_write,
    output logic [2:0] aluop
);

always_comb begin

   
    memtoreg = 2'b00;
    branch   = 1'b0;
    mux_inp  = 1'b0;
    memread  = 1'b0;
    memwrite = 1'b0;
    alusrc   = 1'b0;
    reg_write = 1'b0;
    aluop    = 3'b000;

    case (opcode)

        // R-type instructions: ADD, SUB, AND, OR, XOR, etc.
        7'b0110011: begin
            reg_write = 1'b1;
            alusrc    = 1'b0;
            memtoreg  = 2'b00;
            aluop     = 3'b10;
        end

        // I-type arithmetic: ADDI, ANDI, ORI, etc.
        7'b0010011: begin
            reg_write = 1'b1;
            alusrc    = 1'b1;
            memtoreg  = 2'b00;
            aluop     = 3'b011;
        end

        // Load instructions: LB, LH, LW, LBU, LHU
        7'b0000011: begin
            reg_write = 1'b1;
            alusrc    = 1'b1;
            memread   = 1'b1;
            memtoreg  = 2'b01;
            aluop     = 3'b000;
        end

        // Store instructions: SB, SH, SW
        7'b0100011: begin
            alusrc    = 1'b1;
            memwrite  = 1'b1;
            aluop     = 3'b000;
        end

        // Branch instructions: BEQ, BNE, BLT, BGE, BLTU, BGEU
        7'b1100011: begin
            branch = 1'b1;
            alusrc = 1'b0;
            aluop  = 3'b001;
        end

        // JAL
        7'b1101111: begin
            reg_write = 1'b1;
            memtoreg  = 2'b10;
        end

        // JALR
        7'b1100111: begin
            reg_write = 1'b1;
            alusrc    = 1'b1;
            memtoreg  = 2'b10;
            mux_inp   = 1'b1;
        end

        // LUI
        7'b0110111: begin
            reg_write = 1'b1;
            memtoreg  = 2'b11;
        end

        // AUIPC
        7'b0010111: begin
            reg_write = 1'b1;
            memtoreg  = 2'b11;
            alusrc    = 1'b1;
        end

        default: begin
         end
         endcase
end
endmodule

