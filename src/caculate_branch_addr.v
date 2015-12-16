`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NJU_CS_COD_2015
// Engineer: Yueqi Chen (yueqichen.0x0@gmail.com)
// 
// Create Date: 2015/12/05 12:21:19
// Design Name: caculate branch address 
// Module Name: caculate_branch_addr
// Project Name: pipeline cpu
// Target Devices:  xc7a100tcsg324-1
// Tool Versions: 0.0
// Description: caculate branch address with extended immediate and pc + 4
// 
// Dependencies: none
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module caculate_branch_addr(
	input [31:0] A_in, B_in,
	output reg [31:0] C_in
);

	always@(*)
	begin
		C_in = A_in << 2 + B_in;
	end
endmodule
