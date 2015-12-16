`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:NJU_CS_COD_2015 
// Engineer: Yueqi Chen yueqichen.0x0@gmail.com
// 
// Create Date: 2015/12/02 21:44:12
// Design Name: cp0(coprocessor 0)
// Module Name: cp0
// Project Name: pipeline cpu 
// Target Devices: xc7a100tcsg324-1 
// Tool Versions: 0.0
// Description: simple coprocessor to deal with interrupts and system call 
// 
// Dependencies: none
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// if an interrupts or an exception ended, cu getted eret signal should
	// generate a signal to cp0, tells cp0 to cancer interrupt mask
//////////////////////////////////////////////////////////////////////////////////


module cp0
(
	input Wb_cp0_w_en,
	input Cu_cp0_w_en,
	input [31:0] Epc,
	input [4:0] Id_cp0_src_addr,
	input [4:0] Wb_cp0_dst_addr,
	input [31:0] Ex_data,
	input [4:0] Cu_exec_code,
	input [7:0] Interrupt,
//	input Cu_cp0_eret,
	input Clk,
	output reg [31:0] Cp0_data,
	output reg [31:0] Cp0_epc,
	output reg Cp0_intr
);

	reg [31:0] status;
	reg [31:0] cause;
	reg [31:0] count;
	reg [7:0] interrupt_detect;
	integer i;

	initial begin
		status = 32'h1;
		cause = 32'h1;
		Cp0_epc = 32'h0;
		count = 32'h0;
		interrupt_detect = 8'h0;
		i = 0;
	end
	
	always@(negedge Clk)
	begin
		if(count == 32'hffffffff)//time counter + 1
			count = 32'h0;
		else
			count = count + 1;
/*		if(Cu_cp0_eret == 1'b1)//system call and eret not enabled at the same time
		begin
			status[0] <= 1'b1;
		end
		*/
		if(Cu_cp0_w_en == 1'b1)//system call
		begin
			cause[6:2] <= Cu_exec_code;//fill the exec code
			status[0] <= 1'b0;//mask interrupt
			Cp0_epc <= Epc;//fill the epc
		end
		else
		begin
			if(Wb_cp0_w_en == 1'b1)//MTC0
			begin
				if(Wb_cp0_dst_addr == 12)//status
					status = Ex_data;
				else if(Wb_cp0_dst_addr == 13)//cause
					cause = Ex_data;
				else if(Wb_cp0_dst_addr == 14)//epc
					Cp0_epc = Ex_data;
				else if(Wb_cp0_dst_addr == 9)//count
					count = Ex_data;
				else
					;
			end
		end
	end

	always@(*)
	begin
		cause[15:8] <= Interrupt;
		if(status[0] == 1'b1)//snoop interrupt
		begin
			interrupt_detect[0] = status[8] & cause[8];
			interrupt_detect[1] = status[9] & cause[9];
			interrupt_detect[2] = status[10] & cause[10];
			interrupt_detect[3] = status[11] & cause[11];
			interrupt_detect[4] = status[12] & cause[12];
			interrupt_detect[5] = status[13] & cause[13];
			interrupt_detect[6] = status[14] & cause[14];
			interrupt_detect[7] = status[15] & cause[15];
			i = (interrupt_detect[0] | interrupt_detect[1] | interrupt_detect[2] | interrupt_detect[3] | interrupt_detect[4] | interrupt_detect[5] | interrupt_detect[6] | interrupt_detect[7]);

			if(i == 1)// if there is a interrupt and interrupt is allowed
			begin
				    Cp0_intr = 1'b1;// generate interrupt signal
				    status[0] <= 1'b0;//mask interrupt
				    Cp0_epc <= Epc;//fill epc
			end
			else
				Cp0_intr = 1'b0;
		end
		else// if interrupted is not allowed
			Cp0_intr = 1'b0;

		if(Id_cp0_src_addr == 12)//MFC0
			Cp0_data = status;
		else if(Id_cp0_src_addr == 13)
			Cp0_data = cause;
		else if(Id_cp0_src_addr == 14)
			Cp0_data = Cp0_epc;
		else if(Id_cp0_src_addr == 9)
			Cp0_data = count;
		else
			;
	end
endmodule
