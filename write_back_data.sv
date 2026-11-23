`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.11.2026 15:39:04
// Design Name: 
// Module Name: write_back_data
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



module write_back_data(
    input logic [31:0] alu_out, return_address, imm_out, PC_exe, read_data,
    input logic [6:0] opcode,
    input logic [1:0] memtoreg,
    output logic [31:0] wb_data
);
always_comb begin
    wb_data = 32'b0;
    case (memtoreg)
        2'b00: begin// ALU output
            wb_data = alu_out;
        end
        2'b01: begin// Load instruction
            wb_data = read_data;
        end
        2'b10: begin// JAL / JALR / LUI / AUIPC
            case (opcode)
                7'b1101111: begin// JAL
                    wb_data = return_address;
                end
                7'b1100111: begin// JALR
                    wb_data = return_address;
                end
                7'b0110111: begin// LUI
                    wb_data = imm_out;
                end
                7'b0010111: begin// AUIPC
                    wb_data = PC_exe + imm_out;
                end
                default: begin
                    wb_data = 32'b0;
                end
            endcase
        end
        2'b11: begin// Store instruction - no write-back
            wb_data = 32'b0;
        end
        default: begin
            wb_data = 32'b0;
        end
    endcase
end
endmodule
