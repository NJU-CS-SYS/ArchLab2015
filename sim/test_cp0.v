`timescale 1ns / 1ns
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
		cu_cp0_w_en = 1'b0;
		epc = 32'h12345678;
		id_cp0_src_addr = 9;		//MTC0 status
		wb_cp0_dst_addr = 12;
		ex_data = 32'h11223344;
		cu_exec_code = 5'b01010;
		interrupt = 8'h0;
		clk = 1;
		#1
		clk = 0;
		#1
		wb_cp0_w_en = 1'b1;
		cu_cp0_w_en = 1'b0;
		epc = 32'h12345678;
		id_cp0_src_addr = 9;		//MTC0 cause
		wb_cp0_dst_addr = 13;
		ex_data = 32'h22334455;
		cu_exec_code = 5'b01010;
		interrupt = 8'h0;
		clk = 1;
		#1
		clk = 0;
		#1
		wb_cp0_w_en = 1'b1;
		cu_cp0_w_en = 1'b0;
		epc = 32'h12345678;
		id_cp0_src_addr = 9;		//MTC0 epc
		wb_cp0_dst_addr = 14;
		ex_data = 32'h33445566;
		cu_exec_code = 5'b01010;
		interrupt = 8'h0;
		clk = 1;
		#1
		clk = 0;
		#1
		wb_cp0_w_en = 1'b0;
		cu_cp0_w_en = 1'b0;
		epc = 32'h12345678;
		id_cp0_src_addr = 12;		//MFC0 status
		wb_cp0_dst_addr = 12;
		ex_data = 32'h33445566;
		cu_exec_code = 5'b01010;
		interrupt = 8'h0;
		clk = 1;
		#1
		if(cp0_data != 32'h11223344)
			$stop;
		clk = 0;
		#1
		wb_cp0_w_en = 1'b0;
		cu_cp0_w_en = 1'b0;
		epc = 32'h12345678;
		id_cp0_src_addr = 13;		//MFC0 cause
		wb_cp0_dst_addr = 12;
		ex_data = 32'h33445566;
		cu_exec_code = 5'b01010;
		interrupt = 8'h0;
		clk = 1;
		#1
		if(cp0_data != 32'h22330055)
			$stop;
		clk = 0;
		#1
		wb_cp0_w_en = 1'b0;
		cu_cp0_w_en = 1'b0;
		epc = 32'h12345678;
		id_cp0_src_addr = 14;		//MFC0 epc
		wb_cp0_dst_addr = 12;
		ex_data = 32'h33445566;
		cu_exec_code = 5'b01010;
		interrupt = 8'h0;
		clk = 1;
		#1
		if(cp0_data != 32'h33445566)
			$stop;
		clk = 0;
		#1
		wb_cp0_w_en = 1'b1;
		cu_cp0_w_en = 1'b0;
		epc = 32'h12345678;
		id_cp0_src_addr = 14;		//MTC0 status
		wb_cp0_dst_addr = 12;
		ex_data = 32'hff01;
		cu_exec_code = 5'b01010;
		interrupt = 8'h01;
		clk = 1;
		#1
		clk = 0;
		#1
		wb_cp0_w_en = 1'b0;
		clk = 1;
		#1
		clk = 0;
		#1
		if(cp0_intr != 1'b1)
			$stop;
		#1
		wb_cp0_w_en = 1'b0;
		cu_cp0_w_en = 1'b1;
		epc = 32'h12345678;
		id_cp0_src_addr = 12;		//system call
		wb_cp0_dst_addr = 12;
		ex_data = 32'hff01;
		cu_exec_code = 5'b00000;
		interrupt = 8'h01;
		clk = 1;
		#1
		clk = 0;
		#1
		wb_cp0_w_en = 1'b0;
		cu_cp0_w_en = 1'b1;
		epc = 32'hfedcba99;
		id_cp0_src_addr = 12;		//system call while interrupt masked
		wb_cp0_dst_addr = 12;
		ex_data = 32'hff01;
		cu_exec_code = 5'b00000;
		interrupt = 8'h01;
		clk = 1;
		#1
		clk = 0;
		#1
		if(cp0_epc == 32'hfedcba99)
			$stop;
		#1
		wb_cp0_w_en = 1'b1;
		cu_cp0_w_en = 1'b0;
		epc = 32'hfedcba98;
		id_cp0_src_addr = 14;		//MTC0 status
		wb_cp0_dst_addr = 12;
		ex_data = 32'hff01;
		cu_exec_code = 5'b01010;
		interrupt = 8'h01;
		clk = 1;
		#1
		clk = 0;
		#1
		wb_cp0_w_en = 1'b1;
		cu_cp0_w_en = 1'b1;
		epc = 32'hfedcba98;
		id_cp0_src_addr = 14;		//system call while interrupt unmasked
		wb_cp0_dst_addr = 12;
		ex_data = 32'hff01;
		cu_exec_code = 5'b00000;
		interrupt = 8'h01;
		clk = 1;
		#1
		clk = 0;
		#1
		if(cp0_epc != 32'hfedcba98)
			$stop;
		$stop;
	end

endmodule
