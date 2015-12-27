`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/09/19 17:15:43
// Design Name: 
// Module Name: adder
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


module adder(
    input [31:0] A,
    input [31:0] B,
    input cin,
    output ZF,
    output CF,
    output OF,
    output NF,
    output [31:0] S
);

wire [32:0] M;
assign M = {1'b0,A} + {1'b0,B} + cin;
assign ZF = M[31:0] == 32'd0;
assign CF = M[32];
assign OF = A[31]==B[31] && A[31]!=M[31];
assign NF = M[31];
assign S = M[31:0];


endmodule
