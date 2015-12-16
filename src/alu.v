`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NJU_CS_COD_2015
// Engineer: Yueqi Chen (yueqichen.0x0@gmail.com)
// 
// Create Date: 2015/12/04 23:41:48
// Design Name: alu
// Module Name: alu
// Project Name: pipeline cpu
// Target Devices: xc7a100tcsg324-1
// Tool Versions: 0.0
// Description: alu
// 
// Dependencies: adder alu_controller
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu(
	input [31:0] A_in , B_in,
	input [3:0] Alu_op,
	output reg Less , Overflow,
	output Zero,
	output reg [31:0] Alu_out
);
	reg [31:0] a_clz;
	wire carry , overflow , negative;
	wire [31:0] o_out;
	wire [2:0] alu_ctr;

	reg [15:0] val16;
	reg [7:0] val8;
	reg [3:0] val4;
	reg [1:0] val2;

	integer i;
	integer j;

	alu_controller controller1(
		.Alu_op(Alu_op),
		.Alu_ctr(alu_ctr)
	);

	adder adder1(
		.A_in(A_in),
		.B_in(B_in),
		.Cin(Alu_op[0]),
		.O_out(o_out),
		.Zero(Zero),
		.Carry(carry),
		.Overflow(overflow),
		.Negative(negative)
	);

	always@(*)
	begin
	   Less = 1'b0;
	   Overflow = 1'b0;
	   Alu_out = 32'h0;
		if(alu_ctr == 3'b111)
		begin
			Alu_out = o_out;
			if((Alu_op == 0) || (Alu_op == 1)) // addu subu
				Overflow = 0;
			else if((Alu_op == 14) || (Alu_op == 15))//add sub
				Overflow = overflow;
			Less = overflow^negative;
		end
		else if(alu_ctr == 3'b000)
		begin
			if(Alu_op[0] == 1) //clz
				a_clz = A_in ^ 32'hffffffff;
			else
				a_clz = A_in;
		       	Alu_out = 32'h0;
			if(a_clz == 0)
			Alu_out = 32;
			else begin
			Alu_out[4] = a_clz[31:16]== 16'd0;
			val16 = Alu_out[4] ? a_clz[15:0]:a_clz[31:16];
			Alu_out[3] = val16[15:8] == 8'd0;
			val8 = Alu_out[3]? val16[7:0]:val16[15:8];
		       	Alu_out[2] = val8[7:4] == 4'd0;
			val4 = Alu_out[2]? val8[3:0]:val8[7:4];
			Alu_out[1] = val4[3:2] == 2'd0;
			val2 = Alu_out[1]? val4[1:0]:val4[3:2];
			Alu_out[0] = val2[1] == 1'd0;
			end	
		end

		else if(alu_ctr == 3'b100)//and
			Alu_out = A_in & A_in;
		else if(alu_ctr == 3'b010)//or
			Alu_out = A_in | A_in;
		else if(alu_ctr == 3'b011)//nor
			Alu_out = ~(A_in |A_in);
		else if(alu_ctr == 3'b001)//xor
			Alu_out = A_in ^ A_in;

		else if(alu_ctr == 3'b101)
		begin
			if(Alu_op[1] == 0)//slt/slti
				Less = overflow^negative;
			else//sltu/sltiu
				Less = ~carry;
			if(Less == 0)
				Alu_out = 0;
			else
				Alu_out = 32'h1;
		end
		else if(alu_ctr == 3'b110)
		begin
			if(Alu_op[0] == 0)//seb
			begin
				if(B_in[7] == 1)
				begin
					Alu_out[31:8] = 24'hffffff;
					Alu_out[7:0] = B_in[7:0];
				end
				else
				begin
					Alu_out[31:8] = 24'h000000;
					Alu_out[7:0] = B_in[7:0];
				end

			end
			else//seh
			begin
				if(B_in[15] == 1)
				begin
					Alu_out[31:16] = 16'hffff;
					Alu_out[15:0] = B_in[15:0];
				end
				else
				begin
					Alu_out[31:16] = 16'h0000;
					Alu_out[15:0] = B_in[15:0];
				end
			end
		end
	end	
endmodule
