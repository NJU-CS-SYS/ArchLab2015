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
// modified by Yaoyang Zhou, 9:30, 2015.12.24
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
	output [31:0] Cp0_data,
	output reg [31:0] Cp0_epc,
	output Cp0_intr
);
    reg [31:0] cp0_data_reg;
    reg cp0_intr_reg;
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
	always @(*) begin
		if(status[0] == 1'b1)//snoop interrupt
        begin
			interrupt_detect[7:0] = status[15:8] & cause[15:8];
			i = (interrupt_detect[0] | interrupt_detect[1] | interrupt_detect[2] | interrupt_detect[3] | interrupt_detect[4] | interrupt_detect[5] | interrupt_detect[6] | interrupt_detect[7]);
			if(i == 1)// if there is a interrupt and interrupt is allowed
				cp0_intr_reg = 1'b1;// generate interrupt signal
            else
			cp0_intr_reg = 1'b0;
		end
		else// if interrupted is not allowed
			cp0_intr_reg = 1'b0;
		if(Id_cp0_src_addr == 12)//MFC0
			cp0_data_reg = status;
		else if(Id_cp0_src_addr == 13)
			cp0_data_reg = cause;
		else if(Id_cp0_src_addr == 14)
			cp0_data_reg = Cp0_epc;
		else if(Id_cp0_src_addr == 9)
			cp0_data_reg = count;
        else
			cp0_data_reg = 32'd0;
	end
	
	always@(negedge Clk)
	begin
		count <= count + 1;
        /*
		if(count == 32'hffffffff)//time counter + 1
			count = 32'h0;
		else
			count = count + 1;
		if(Cu_cp0_eret == 1'b1)//system call and eret not enabled at the same time
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
		else begin
            if(Wb_cp0_w_en == 1'b1) begin   //MTC0
                if(Wb_cp0_dst_addr == 13)   //cause ,assume that prio(mtc0) >prio(intr)
					cause <= Ex_data;
                else if(Wb_cp0_dst_addr == 12)//status
					status <= Ex_data;
				else if(Wb_cp0_dst_addr == 14)//epc
				    Cp0_epc <= Ex_data;
			    else if(Wb_cp0_dst_addr == 9)//count
				    count <= Ex_data;
			end
            else if(cp0_intr_reg) begin
                cause[15:8] <= Interrupt;
				status[0] <= 1'b0;//mask interrupt
				Cp0_epc <= Epc;//fill epc
            end
		end
	end

    assign Cp0_intr = cp0_intr_reg;
    assign Cp0_data = cp0_data_reg;

endmodule
