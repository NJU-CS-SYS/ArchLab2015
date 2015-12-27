`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NJU_CS_COD_2015
// Engineer: Yueqi Chen (yueqichen.0x0@gmail.com)
// 
// Create Date: 2015/12/05 12:44:18
// Design Name: final target
// Module Name: final_target
// Project Name: pipeline cpu
// Target Devices:  xc7a100tcsg324-1 
// Tool Versions: 0.0
// Description: ouput final target with condition
// 
// Dependencies: none
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module final_target(
	input Exmem_branch,
	input [2:0] Exmem_condition,
	input [31:0] Exmem_target,
	input [31:0] Exmem_pc_4,
	input Exmem_lf,
	input Exmem_zf,
	output reg [31:0] Final_target
);

	always@(*)
	begin
		if(Exmem_branch == 1'b0)
			Final_target = Exmem_pc_4;
		else if(Exmem_condition == 3'b000)
			Final_target = Exmem_target;
		else if((Exmem_condition == 3'b001) && (Exmem_zf == 1'b1))
			Final_target = Exmem_target;
		else if((Exmem_condition == 3'b010) && (Exmem_zf == 1'b0))
			Final_target = Exmem_target;
		else if((Exmem_condition == 3'b011) && (Exmem_lf == 1'b0))
			Final_target = Exmem_target;
		else if((Exmem_condition == 3'b100) && (Exmem_zf == 1'b0) && (Exmem_lf == 1'b0))
			Final_target = Exmem_target;
		else if((Exmem_condition == 3'b101) && ((Exmem_zf == 1'b1) || (Exmem_lf == 1'b1)))
			Final_target = Exmem_target;
		else if((Exmem_condition == 3'b110) && (Exmem_lf == 1'b1))
			Final_target = Exmem_target;
		else if(Exmem_condition == 3'b111)
			Final_target = Exmem_pc_4 + 4;
		else
			Final_target = Exmem_pc_4 + 4;
	end
	
endmodule
