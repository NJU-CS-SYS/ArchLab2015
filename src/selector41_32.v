`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:NJU_CS_COD_2015 
// Engineer: Yueqi Chen (yueqichen.0x0@gmail.com)
// 
// Create Date: 2015/12/04 21:49:54
// Design Name: selector41_32
// Module Name: selector41_32
// Project Name: pipeline cpu
// Target Devices: xc7a100tcsg324-1
// Tool Versions: 0.0
// Description: selector 4 to 1 32 bits
// 
// Dependencies: none
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module selector41_32(
	input [31:0] Choice_0, Choice_1 , Choice_2 , Choice_3,
	input [1:0] Select,
	output reg [31:0] Select_out
);
	always@(*)
	begin
		case(Select)
			2'b00: Select_out = Choice_0;
			2'b01: Select_out = Choice_1;
			2'b10: Select_out = Choice_2;
			2'b11: Select_out = Choice_3;
		endcase
	end
endmodule
