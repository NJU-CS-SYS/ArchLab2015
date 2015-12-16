`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NJU_CS_COD_2015
// Engineer: Yueqi Chen (yueqichen.0x0@gmail.com)
// 
// Create Date: 2015/12/16 11:00:22
// Design Name: test register write generater
// Module Name: test_reg_w_gen
// Project Name: pipeline cpu 
// Target Devices: xc7a100tcsg324-1 
// Tool Versions: 0.0
// Description: test register write signal signal generator
// 
// Dependencies: reg_w_gen
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_reg_w_gen();
	reg of;
	reg zf;
	reg idex_movz;
	reg idex_movnz;
	reg idex_reg_w;
	reg idex_of_w_disen;
	wire new_reg_w;

	reg_w_gen t1(
		.of(of),
		.zf(zf),
		.idex_movz(idex_movz),
		.idex_movnz(idex_movnz),
		.idex_reg_w(idex_reg_w),
		.idex_of_w_disen(idex_of_w_disen),
		.new_reg_w(new_reg_w)
	);

	initial begin
		idex_reg_w = 1'b1;

		of = 1'b0;
		zf = 1'b0;
		idex_movz = 1'b0;
		idex_movnz = 1'b0;
		idex_of_w_disen = 1'b0;
		//idex_reg_w

		#1
		of = 1'b0;
		zf = 1'b1;
		idex_movz = 1'b0;
		idex_movnz = 1'b0;
		idex_of_w_disen = 1'b0;
		//idex_reg_w

		#1
		of = 1'b1;
		zf = 1'b0;
		idex_movz = 1'b0;
		idex_movnz = 1'b1;
		idex_of_w_disen = 1'b0;
		//idex_reg_w

		#1
		of = 1'b0;
		zf = 1'b1;
		idex_movz = 1'b0;
		idex_movnz = 1'b1;
		idex_of_w_disen = 1'b0;
		//0

		#1
		of = 1'b0;
		zf = 1'b0;
		idex_movz = 1'b1;
		idex_movnz = 1'b1;
		idex_of_w_disen = 1'b0;
		//0

		#1 
		of = 1'b1;
		zf = 1'b0;
		idex_movz = 1'b0;
		idex_movnz = 1'b1;
		idex_of_w_disen = 1'b1;
		//0
		
		#1
		$stop;

	end
endmodule
