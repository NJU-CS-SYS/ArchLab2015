`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NJU_CS_COD_2015 
// Engineer: Yuei Chen (yueqichenchen.0x0@gmail.com)
// 
// Create Date: 2015/12/04 16:11:18
// Design Name: test_cp0
// Module Name: test_cp0
// Project Name: pipeline_cpu
// Target Devices: xc7a100tcsg324-1
// Tool Versions: 0.0
// Description: test cp0
// 
// Dependencies: cp0
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_cp0();
	
	reg wb_cp0_w_en;
	reg cu_cp0_w_en;
	reg [31:0] epc;
	reg [4:0] id_cp0_src_addr;
	reg [4:0] wb_cp0_dst_addr;
	reg [31:0] ex_data;
	reg [4:0] cu_exec_code;
	reg [7:0] interrupt;
	reg clk;

	wire [31:0] cp0_data;
	wire [31:0] cp0_epc;
	wire cp0_intr;

	cp0 cp01(
		.Wb_cp0_w_en(wb_cp0_w_en),
		.Cu_cp0_w_en(cu_cp0_w_en),
		.Epc(epc),
		.Id_cp0_src_addr(id_cp0_src_addr),
		.Wb_cp0_dst_addr(wb_cp0_dst_addr),
		.Ex_data(ex_data),
		.Cu_exec_code(cu_exec_code),
		.Interrupt(interrupt),
		.Clk(clk),

		.Cp0_data(cp0_data),
		.Cp0_epc(cp0_epc),
		.Cp0_intr(cp0_intr)
	);
	
	initial begin
		wb_cp0_w_en = 1'b1;
		cu_cp0_w_en = 1'b0;//check write status
		epc = 32'h12345678;
		id_cp0_src_addr = 12;
		wb_cp0_dst_addr = 12;
		ex_data = 32'h87654321;
		cu_exec_code = 5'b01010;
		clk = 1;
		#1
		clk = 0;
		#1
		wb_cp0_w_en = 1'b0;
		cu_cp0_w_en = 1'b1;
		epc = 32'h12345678;
		id_cp0_src_addr = 14;//check read epc
		wb_cp0_dst_addr = 12;
		ex_data = 32'h87654321;//try to write status while system call is enabled
		cu_exec_code = 5'b01010;//be written into cause
		clk = 1;
		#1
		clk = 0;
		#1
		clk = 1;
		id_cp0_src_addr = 13;//check read cause
		#1
		clk = 0;
		#1
		wb_cp0_w_en = 1'b1;//write epc while cu_cp0_w_en is enabled
		wb_cp0_dst_addr = 14;
		ex_data = 32'h87654321;
		clk = 1;
		#1
		clk = 0;
		#1
		id_cp0_src_addr = 9;//read timer counter
		clk = 1;
		#1
		clk = 0;
		#1
		wb_cp0_w_en = 1'b1;
		cu_cp0_w_en = 1'b0;
		wb_cp0_dst_addr = 13;
		ex_data = 32'b111000000;//generate a interrupt while interrupt is disabled
		id_cp0_src_addr = 13;
		clk = 1;
		#1
		clk = 0;
		#1
		cu_cp0_w_en = 1'b0;
		wb_cp0_w_en = 1'b1;
		ex_data = 32'h87654321;//try to write status while system call is enabled
		wb_cp0_dst_addr = 12;
		clk = 1;
		#1
		clk = 0;
		#1
		$stop;
	end

endmodule
