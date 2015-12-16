`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NJU_CS_COD_2015
// Engineer: Yueqi Chen (yueqichen.0x0@gmail.com)
// 
// Create Date: 2015/12/04 23:21:54
// Design Name: selector21_5
// Module Name: selector21_5
// Project Name: pipeline cpu
// Target Devices: xc7a100tcsg324-1
// Tool Versions: 0.0
// Description: selector 2 to 1 by 5 bits
// 
// Dependencies: none
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module selector21_5(
	input [4:0] Choice_0 , Choice_1,
	input Select,
	output reg [4:0] Select_out
);
	
	always@(*)
	begin
		case(Select)
			1'b0: Select_out = Choice_0;
			1'b1: Select_out = Choice_1;
		endcase
	end
endmodule
