`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NJU_CS_COD_2015
// Engineer: Yueqi Chen (yueqichen.0x0@gmail.com)
// 
// Create Date: 2015/12/05 18:12:50
// Design Name: test final target
// Module Name: test_final_target
// Project Name: pipeline cpu
// Target Devices: xc7a100tcsg324-1
// Tool Versions: 0.0
// Description: test unit final target
// 
// Dependencies: final_target
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_final_target();
	reg exmem_branch;
	reg [2:0] exmem_condition;
	reg [31:0] exmem_target;
	reg [31:0] exmem_pc_4;
	reg exmem_lf;
	reg exmem_zf;
	
	wire [31:0] final_target;

	final_target t1(
		.Exmem_branch(exmem_branch),
		.Exmem_condition(exmem_condition),
		.Exmem_target(exmem_target),
		.Exmem_pc_4(exmem_pc_4),
		.Exmem_lf(exmem_lf),
		.Exmem_zf(exmem_zf),
		.Final_target(final_target)
	);

	initial begin
		exmem_branch = 1'b0;
		exmem_condition = 3'b000;
		exmem_target = 32'h12345678;
		exmem_pc_4 = 32'h87654321;
		exmem_lf = 1'b0;
		exmem_zf = 1'b0;

		#1
		exmem_branch = 1'b1;
		#1
		exmem_zf = 1'b1;
		exmem_condition = 3'b001;
		#1
		exmem_zf = 1'b0;
		exmem_condition = 3'b010;
		#1
		exmem_lf = 1'b0;
		exmem_condition = 3'b011;
		#1
		exmem_lf = 1'b0;
		exmem_zf = 1'b0;
		exmem_condition = 3'b100;
		#1
		exmem_zf = 1'b1;
		#1
		exmem_condition = 3'b101;
		#1
		exmem_lf = 1'b1;
		exmem_condition = 3'b110;
		#1
		exmem_condition = 3'b111;
		#1

		$stop;
	end
endmodule
