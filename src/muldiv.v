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
	output [31:0] Res_out,
	output Md_stall
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
reg multiplied, divided;
reg [31:0] calculated_res;

wire [31:0] remainder = (!negative_output)? dividend_copy[31:0] : ~dividend_copy[31:0] + 1'b1;

reg [5:0] cnt;
wire multiplying = (Md_op == 4'b0111) || (Md_op == 4'b1000) || (Md_op == 4'b1001);
wire dividing = (Md_op == 4'b0001) || (Md_op == 4'b0010);
wire ready = !cnt && !(multiplying && !multiplied);
wire [31:0] wired_res = Md_op == 4'b0100 ? Lo : Hi;
assign Res_out = dividing|multiplying ? calculated_res : wired_res;

assign Md_stall = (multiplying && !multiplied) || (dividing && !divided);

initial begin
	calculated_res = 32'h0;
	Hi = 32'h0;
	Lo = 32'h0;
	result_hi = 32'h0;
	cnt = 0;
	negative_output = 0;
    multiplied = 1'b0;
    divided = 1'b0;
end

always@(negedge Clk)
begin
    if(Md_op == 4'b0101) begin			//MTHI
        divided <= 0;
        multiplied <= 0;
		Hi <= Rs_in;
    end
    else if(Md_op == 4'b0110) begin		//MTLO
        divided <= 0;
        multiplied <= 0;
		Lo <= Rs_in;
    end
    else if(Md_op == 4'b0011) begin		//MFHI
        divided <= 0;
        multiplied <= 0;
    end
    else if(Md_op == 4'b0100) begin	//MFLO
        divided <= 0;
        multiplied <= 0;
    end
    else if(Md_op == 4'b0111) begin		//MUL
        divided <= 0;
        multiplied <= 1;
		{result_hi , calculated_res} <= $signed(Rs_in)*$signed(Rt_in);
    end
    else if(Md_op == 4'b1000) begin	//MULT
        divided <= 0;
        multiplied <= 1;
		{Hi , Lo} <= $signed(Rs_in)*$signed(Rt_in);
    end
    else if(Md_op == 4'b1001) begin	//MULTU
        divided <= 0;
        multiplied <= 1;
		{Hi , Lo} <= Rs_in * Rt_in;
    end
	else if(Md_op == 4'b0001 || Md_op == 4'b0010) 	//DIV & DIVU
	begin
        multiplied <= 0;
		if(ready)		//initial some registers
		begin
			cnt = 6'd32;
			quotinent = 0;
			quotient_temp = 0;
			dividend_copy = (!Md_op[0] || !Rs_in[31])? {32'h0 , Rs_in} : {32'h0 , ~Rs_in + 1'b1};
			divider_copy = (!Md_op[0] || !Rt_in[31])? {1'b0 , Rt_in , 31'd0} : {1'b0 , ~Rt_in + 1'b1 , 31'd0};
			negative_output = Md_op[0] && ((Rt_in[31] && !Rs_in[31]) || (!Rt_in[31] && (Rs_in[31])));
            if(diff[31:0] == 0) begin
                Hi <= diff[31:0];
            end
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
			cnt <= cnt - 1'b1;
			Hi <= remainder;
			Lo <= quotinent;
            if(cnt == 1) divided <= 1;
		end
	end
    else begin
        calculated_res <= 32'h0;
    end
end

endmodule
