`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.11.2026 16:09:45
// Design Name: 
// Module Name: floating_point
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


module floating_point(input logic [31:0] A,B,input logic op,output logic [31:0] result,input logic [2:0] rounding_mode);
logic sign_a,sign_b,eff_sign_a,eff_sign_b;
logic [7:0] exp_a,exp_b,exp_large,exp_diff,exp_result;
logic [22:0] frac_a,frac_b;
logic [23:0] sig_a,sig_b,significand;
logic [26:0] sig_a_ext,sig_b_ext,sig_large,sig_small,sig_aligned;
logic [27:0] arithmetic_result;
logic [24:0] rounded_sig;
logic sign_large,result_sign,perform_sub;
logic sticky,guard_bit,round_bit,sticky_bit,round_inc;
logic [22:0] final_frac;
logic [7:0] effective_exp_a,effective_exp_b;
integer i;
always_comb begin
result=32'b0;
sign_a=A[31];
sign_b=B[31];
exp_a=A[30:23];
exp_b=B[30:23];
frac_a=A[22:0];
frac_b=B[22:0];
eff_sign_a=sign_a;
eff_sign_b=sign_b^op;
sig_a={(exp_a!=0),frac_a};
sig_b={(exp_b!=0),frac_b};
sig_a_ext={sig_a,3'b000};
sig_b_ext={sig_b,3'b000};
effective_exp_a=(exp_a==0)?8'd1:exp_a;
effective_exp_b=(exp_b==0)?8'd1:exp_b;
exp_diff=0;
exp_large=0;
sig_large=0;
sig_small=0;
sig_aligned=0;
sign_large=0;
sticky=0;
perform_sub=0;
arithmetic_result=0;
result_sign=0;
exp_result=0;
significand=0;
rounded_sig=0;
guard_bit=0;
round_bit=0;
sticky_bit=0;
round_inc=0;
final_frac=0;
if((exp_a==8'hFF && frac_a!=0)||(exp_b==8'hFF && frac_b!=0)) begin
result=32'h7FC00000;
end
else if(exp_a==8'hFF || exp_b==8'hFF) begin
if(exp_a==8'hFF && exp_b==8'hFF && eff_sign_a!=eff_sign_b)
result=32'h7FC00000;
else if(exp_a==8'hFF)
result={eff_sign_a,8'hFF,23'b0};
else
result={eff_sign_b,8'hFF,23'b0};
end
else if((exp_a==0 && frac_a==0)&&(exp_b==0 && frac_b==0)) begin
result={(rounding_mode==3'b010),31'b0};
end
else begin
if(effective_exp_a>effective_exp_b || (effective_exp_a==effective_exp_b && sig_a_ext>=sig_b_ext)) begin
exp_large=effective_exp_a;
exp_diff=effective_exp_a-effective_exp_b;
sig_large=sig_a_ext;
sig_small=sig_b_ext;
sign_large=eff_sign_a;
end
else begin
exp_large=effective_exp_b;
exp_diff=effective_exp_b-effective_exp_a;
sig_large=sig_b_ext;
sig_small=sig_a_ext;
sign_large=eff_sign_b;
end
if(exp_diff==0) begin
sig_aligned=sig_small;
end
else if(exp_diff<27) begin
sig_aligned=sig_small>>exp_diff;
for(i=0;i<27;i=i+1) begin
if(i<exp_diff)
sticky=sticky|sig_small[i];
end
sig_aligned[0]=sig_aligned[0]|sticky;
end
else begin
sig_aligned=0;
sticky=|sig_small;
sig_aligned[0]=sticky;
end
perform_sub=eff_sign_a^eff_sign_b;
if(perform_sub==0)
arithmetic_result={1'b0,sig_large}+{1'b0,sig_aligned};
else
arithmetic_result={1'b0,sig_large}-{1'b0,sig_aligned};
result_sign=sign_large;
exp_result=exp_large;
if(arithmetic_result==0) begin
result_sign=(rounding_mode==3'b010);
result={result_sign,31'b0};
end
else begin
if(arithmetic_result[27]) begin
sticky=arithmetic_result[1]|arithmetic_result[0];
arithmetic_result=arithmetic_result>>1;
arithmetic_result[0]=sticky;
exp_result=exp_result+1'b1;
end
else begin
for(i=0;i<27;i=i+1) begin
if(arithmetic_result[26]==0 && arithmetic_result!=0 && exp_result>1) begin
arithmetic_result=arithmetic_result<<1;
exp_result=exp_result-1'b1;
end
end
end
significand=arithmetic_result[26:3];
guard_bit=arithmetic_result[2];
round_bit=arithmetic_result[1];
sticky_bit=arithmetic_result[0];
case(rounding_mode)
3'b000:round_inc=guard_bit&&(round_bit||sticky_bit||significand[0]);
3'b001:round_inc=1'b0;
3'b010:round_inc=result_sign&&(guard_bit||round_bit||sticky_bit);
3'b011:round_inc=!result_sign&&(guard_bit||round_bit||sticky_bit);
3'b100:round_inc=guard_bit;
default:round_inc=guard_bit&&(round_bit||sticky_bit||significand[0]);
endcase
rounded_sig={1'b0,significand}+round_inc;
if(rounded_sig[24]) begin
significand=rounded_sig[24:1];
exp_result=exp_result+1'b1;
end
else begin
significand=rounded_sig[23:0];
end
if(exp_result>=255) begin
if(rounding_mode==3'b001 || (rounding_mode==3'b010 && !result_sign) || (rounding_mode==3'b011 && result_sign))
result={result_sign,8'hFE,23'h7FFFFF};
else
result={result_sign,8'hFF,23'b0};
end
else if(exp_result==1 && significand[23]==0) begin
result={result_sign,8'b0,significand[22:0]};
end
else begin
final_frac=significand[22:0];
result={result_sign,exp_result,final_frac};
end
end
end
end
endmodule
