`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NJU_CS_COD_2015
// Engineer: Yueqi Chen (yueqichen.0x0@gmail.com)
// 
// Create Date: 2015/12/05 00:00:07
// Design Name: alu controller
// Module Name: alu_controller
// Project Name: pipeline cpu
// Target Devices: xc7a100tcsg324-1
// Tool Versions: 0.0
// Description: provider alu with alu controller signal according to alu op
// 
// Dependencies: none
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_controller(
	input [3:0] Alu_op,
	output reg [2:0] Alu_ctr

);

	always@(*)
	begin
		Alu_ctr[2] = ((~Alu_op[3]) & (~Alu_op[1])) | ((~Alu_op[3]) & Alu_op[2] & Alu_op[0]) | (Alu_op[3] & Alu_op[1]);
	    Alu_ctr[1] = ((~Alu_op[3]) & (~Alu_op[2]) & (~Alu_op[1])) | (Alu_op[3] & (~Alu_op[2]) & ( ~Alu_op[0])) | (Alu_op[2] & Alu_op[1] & (~Alu_op[0])) | (Alu_op[3] & Alu_op[1]);
	    Alu_ctr[0] = ((~Alu_op[2]) & (~Alu_op[1])) | ((~Alu_op[3]) & Alu_op[2] & Alu_op[0]) | (Alu_op[3] & Alu_op[2] & Alu_op[1]);
	end
endmodule
