`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NJU_CS_COD_2015
// Engineer: Yueqi Chen (yueqichen.0x0@gmail.com)
// 
// Create Date: 2015/12/05 11:47:09
// Design Name:barrel shifter 
// Module Name: barrel shifter
// Project Name: pipeline cpu
// Target Devices: xc7a100tcsg324-1
// Tool Versions: 0.0
// Description: barrel shifter
// 
// Dependencies: none
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module barrel_shifter
#(parameter lo_l = 0 , parameter lo_r = 1 , parameter al_r = 2 , parameter ci_r = 3)
(
	input [31:0] Shift_in,
	input [4:0] Shift_amount,
	input [1:0] Shift_op,
	output reg [31:0] Shift_out	
);
	reg [31:0] inter1;
	reg [31:0] inter2;
    	always@(*)
    	begin
    	   inter1 = 32'h0;
    	   inter2 = 32'h0;
    		Shift_out = Shift_in;
		case(Shift_op)
	 	lo_l: Shift_out = Shift_in << Shift_amount;
		lo_r: Shift_out = Shift_in >> Shift_amount;
		al_r: Shift_out = $signed(Shift_in) >>> Shift_amount;
		ci_r: begin 
			if(Shift_amount[4] == 1'b1) Shift_out = {Shift_out[15:0] , Shift_out[31:16]};
			if(Shift_amount[3] == 1'b1) Shift_out = {Shift_out[7:0] , Shift_out[31:8]};
			if(Shift_amount[2] == 1'b1) Shift_out = {Shift_out[3:0] , Shift_out[31:4]};
			if(Shift_amount[1] == 1'b1) Shift_out = {Shift_out[1:0] , Shift_out[31:2]};
			if(Shift_amount[0] == 1'b1) Shift_out = {Shift_out[0] , Shift_out[31:1]};
			
			end
		endcase
	end

endmodule
