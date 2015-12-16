`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NJU_CS_COD_2015
// Engineer: Yueqi Chen(yueqichen.0x0@gmail.com)
// 
// Create Date: 2015/12/05 00:05:33
// Design Name: adder
// Module Name: adder
// Project Name: pipeline cpu
// Target Devices: xc7a100tcsg324-1
// Tool Versions: 0.0
// Description:  adder with carry 
// 
// Dependencies: none
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adder(
	input [31:0] A_in , B_in,
	input Cin,
	output reg [31:0] O_out,
	output reg Zero , Carry , Overflow , Negative
);

	reg [31:0] b_in_not;
	always@(*)
	begin
		if(Cin == 0)
			b_in_not = B_in ^ 32'h00000000;
		else 
			b_in_not = B_in ^ 32'hffffffff;

		{Carry ,O_out} = A_in + b_in_not + Cin;
		if(O_out == 0)
			Zero = 1;
		else 
			Zero = 0;
		Overflow = ((~A_in[31])&(~b_in_not[31])&O_out[31]) | (A_in[31]&b_in_not[31]&(~O_out[31]));
		Negative = O_out[31];
	end
endmodule
