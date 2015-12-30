`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/30 18:04:59
// Design Name: 
// Module Name: test_muldiv
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_muldiv();
reg [3:0] md_op;
reg [31:0] rs_in;
reg [31:0] rt_in;
reg clk;
wire [31:0] res_out;
wire md_install;
integer i;

muldiv t1(
	.Md_op(md_op),
	.Rs_in(rs_in),
	.Rt_in(rt_in),
	.Clk(clk),
	.Res_out(res_out),
	.Md_install(md_install)
);

initial begin
	md_op = 4'b0000;
	rs_in = 32'h12345678;
	rt_in = 32'h12345678;
	clk = 1'b1;
	#1
	clk = 1'b0;
	#1
	if(res_out != 0 || md_install == 1)
		$stop;
	clk = 1;
	#1
	md_op = 4'b0111;		//MUL
	rs_in = 32'h12345678;
	rt_in = 32'h2;
	clk = 1'b0;
	#1
	if(res_out != 32'h2468acf0 || md_install == 1)
		$stop;
	clk = 1;
	#1
	md_op = 4'b1000;        //MULT and signed
	rs_in = 32'h87654321;
	rt_in = 32'h2;
	clk = 1'b0;
	#1
	if(t1.Hi != 32'hffffffff || t1.Lo != 32'h0eca8642 || md_install == 1)
		$stop;
	clk = 1;
	#1
	md_op = 4'b1000;	//MULT and unsigned
	rs_in = 32'h12345678;
	rt_in = 32'h2;
	clk = 1'b0;
	#1
	if(t1.Hi != 0 || t1.Lo != 32'h2468acf0 || md_install == 1)
		$stop;
	clk = 1;
	#1
	md_op = 4'b1001;	//MULTU
	rs_in = 32'h87654321;
	rt_in = 32'h2;
	clk = 1'b0;
	#1
	if(t1.Hi != 32'h1 || t1.Lo != 32'h0eca8642 || md_install == 1)
		$stop;
	clk = 1'b1;
	#1
	md_op = 4'b0011;	//MFHI
	rs_in = 32'h0;
	rt_in = 32'h0;
	clk = 1'b0;
	#1
	if(res_out != 32'h1 || md_install == 1)
		$stop;
	clk = 1'b1;
	#1
	md_op = 4'b0100;	//MFLO
	rs_in = 32'h0;
	rt_in = 32'h0;
	clk = 1'b0;
	#1
	if(res_out != 32'h0eca8642 || md_install == 1)
		$stop;
	clk = 1'b1;
	#1
	md_op = 4'b0010;		//DIVU
	rs_in = 32'h87654321;
	rt_in = 32'h2;
	clk = 1'b0;
	i = 0;
	#1
	while(i < 32)
	begin
		clk = 1'b1;
		#1
		clk = 1'b0;
		#1
		i = i + 1;
	end
	if(t1.Hi != 1 || t1.Lo != 32'h43b2a190 || md_install == 1)
	   $stop;
	clk = 1'b1;
	#1
	md_op = 4'b0001;       //DIV
	rs_in = 32'h87654321;
	rt_in = 32'h2;
	clk = 1'b0;
	i = 0;
	#1
    	while(i < 32)
	begin
        	clk = 1'b1;
        	#1
        	clk = 1'b0;
        	#1
	        i = i + 1;
	end
	if(t1.Hi != 32'hfffffffd || t1.Lo != 32'hc3b2a191 || md_install == 1)
	   $stop;
	$stop;

	end
endmodule
