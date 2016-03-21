`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NJU_CS_COD_2015
// Engineer: Yueqi Chen (yueqichen.0x0@gmail.com)
// 
// Create Date: 2015/12/30 16:03:59
// Design Name: multiple and divide unit
// Module Name: muldiv
// Project Name: pipeline cpu
// Target Devices: xc7a100tcsg324-1
// Tool Versions: 0.0
// Description: implement multiple and divide instructions and MFHI/LO
// , MTHI/LO instructions
// 
// Dependencies: 
// 
// Revision:0.0
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module muldiv
(
	input [3:0] Md_op,
	input [31:0] Rs_in,
	input [31:0] Rt_in,
	input Clk,
	output reg [31:0] Res_out,
	output reg Md_install
);

// Md_op = 0001	op = DIV
//	   0010 op = DIVU
//	   0011 op = MFHI 
//	   0100 op = MFLO
//	   0101 op = MTHI
//	   0110 op = MTLO
//	   0111 op = MUL
//	   1000 op = MULT
//	   1001 op = MULTU

reg [31:0] Hi;
reg [31:0] Lo;
//reg [31:0] result_lo;
reg [31:0] result_hi;

reg [31:0] quotinent , quotient_temp;
reg [63:0] dividend_copy , divider_copy , diff;
reg negative_output;

wire [31:0] remainder = (!negative_output)? dividend_copy[31:0] : ~dividend_copy[31:0] + 1'b1;

reg [5:0] cnt;
wire ready = !cnt;

initial begin
	Res_out = 32'h0;
	Md_install = 1'b0;
	Hi = 32'h0;
	Lo = 32'h0;
	result_hi = 32'h0;
	cnt = 0;
	negative_output = 0;
end

always@(negedge Clk)
begin
	if(Md_op == 4'b0101)			//MTHI
		Hi <= Rs_in;
	else if(Md_op == 4'b0110)		//MTLO
		Lo <= Rs_in;
	else if(Md_op == 4'b0011)		//MFHI
		Res_out <= Hi;	
	else if(Md_op == 4'b0100)	//MFLO
		Res_out <= Lo;
	else if(Md_op == 4'b0111)		//MUL
		{result_hi , Res_out} <= $signed(Rs_in)*$signed(Rt_in);
	else if(Md_op == 4'b1000)	//MULT
		{Hi , Lo} <= $signed(Rs_in)*$signed(Rt_in);
	else if(Md_op == 4'b1001)	//MULTU
		{Hi , Lo} <= Rs_in * Rt_in;
	else if(Md_op == 4'b0001 || Md_op == 4'b0010) 	//DIV & DIVU
	begin
		if(ready)		//initial some registers
		begin
			Md_install = 1'b1;
			cnt = 6'd32;
			quotinent = 0;
			quotient_temp = 0;
			dividend_copy = (!Md_op[0] || !Rs_in[31])? {32'h0 , Rs_in} : {32'h0 , ~Rs_in + 1'b1};
			divider_copy = (!Md_op[0] || !Rt_in[31])? {1'b0 , Rt_in , 31'd0} : {1'b0 , ~Rt_in + 1'b1 , 31'd0};
			negative_output = Md_op[0] && ((Rt_in[31] && !Rs_in[31]) || (!Rt_in[31] && (Rs_in[31])));
		end
		else if(cnt > 0)	//substract
		begin
			diff = dividend_copy - divider_copy;
			quotient_temp = quotient_temp << 1;
			if(!diff[63])
			begin
				dividend_copy = diff;
				quotient_temp[0] = 1'd1;
			end
			quotinent = (!negative_output) ? quotient_temp : ~quotient_temp + 1'b1;
			divider_copy = divider_copy >> 1;
			cnt = cnt - 1'b1;
			Hi = remainder;
			Lo = quotinent;
			if(cnt == 0)
				Md_install = 1'b0;
		end
	end
	else 
		Res_out <= 32'h0;
end

endmodule
