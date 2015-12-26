`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/09/19 21:16:05
// Design Name: 
// Module Name: leadingz
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


module leadingz(
input [31:0] A,
output [4:0] res
);
wire [15:0] val16;
wire [7:0] val8;
wire [3:0] val4;
wire [1:0] val2;

assign res[4] = A[31:16] == 16'd0;
assign val16 = res[4] ? A[15:0] : A[31:16];
assign res[3] = val16[15:8] == 8'd0;
assign val8 = res[3] ? val16[7:0] : val16[15:8];
assign res[2] = val8[7:4] == 4'd0;
assign val4 = res[2] ? val8[3:0] : val8[7:4];
assign res[1] = val4[3:2] == 2'd0;
assign val2 = res[1] ? val4[1:0] : val4[3:2];
assign res[0] = val2[1] == 1'd0;
//assign res[0] = res[1] ? ~val4[1] : ~val4[3];

endmodule
