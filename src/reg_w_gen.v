`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NJU_CS_COD_2015
// Engineer: Yueqi Chen (yueqichen.0x0@gmail.com)
// 
// Create Date: 2015/12/16 10:42:23
// Design Name: register write generater
// Module Name: reg_w_gen
// Project Name: pipeline cpu
// Target Devices: xc7a100tcsg324-1
// Tool Versions: 0.0
// Description: generate register write signal
// 
// Dependencies: none
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module reg_w_gen(
	input of,
	input zf,
	input idex_movz,
	input idex_movnz,
	input idex_reg_w,
	input idex_of_w_disen,
	output reg new_reg_w
);
	always@(*) 
	begin
	if((idex_movnz && zf) || (idex_movz && ~zf) || (idex_of_w_disen && of) == 1)
		new_reg_w = 1'b0;
	else
		new_reg_w = idex_reg_w;
	end

endmodule
