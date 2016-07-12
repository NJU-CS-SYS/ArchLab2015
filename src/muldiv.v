`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NJU_CS_COD_2015
// Engineer: Yueqi Chen (yueqichen.0x0@gmail.com), Wei Dai
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

reg [31:0] Y;
reg [31:0] _Y;
reg [31:0] R;
reg [31:0] Q;
reg [63:0] X;
reg negative_output;
reg multiplied, divided;
reg [31:0] calculated_res;
reg [63:0] res_MUL;
reg [63:0] res_MUL_temp;
reg MUL_signed;
reg [31:0] MUL_Rs;
reg [31:0] MUL_Rt;




//wire [31:0] remainder = (!negative_output)? dividend_copy[31:0] : ~dividend_copy[31:0] + 1'b1;

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
        MUL_Rs = Rs_in[31] ? ~Rs_in + 32'b1 : Rs_in;
        MUL_Rt = Rt_in[31] ? ~Rt_in + 32'b1 : Rt_in;
		res_MUL_temp = MUL_Rs * MUL_Rt;
		MUL_signed = (Rs_in[31] & ~Rt_in[31])|(~Rs_in[31] & Rt_in[31]);
		res_MUL = MUL_signed ? ~res_MUL_temp + 1 : res_MUL_temp;
		Hi <= res_MUL[63:32];
		Lo <= res_MUL[31:0];
    end
    else if(Md_op == 4'b1001) begin	//MULTU
        divided <= 0;
        multiplied <= 1;
		{Hi , Lo} = Rs_in * Rt_in;
    end
	else if(Md_op == 4'b0001) 	//DIV
	begin
	    multiplied <= 0;
	    if(Rs_in == Rt_in)
	    begin
            divided <= 1;
            Hi <= 32'b0;
            Lo <= 32'b1;
		end
		else if(ready&&!divided)		//initial some registers
		begin
			cnt = 6'd32;
			X = (Md_op[0] && Rs_in[31])?{32'hffffffff,Rs_in}:{32'b0,Rs_in};
			Y = Rt_in;
			_Y = ~Y + 32'b1;
			if(Md_op[0] && ((Rs_in[31] && !Rt_in[31])||(!Rs_in[31]&&Rt_in[31])))//不同号
                R = X[63:32] + Y;
            else
                R = X[63:32] + _Y;
            Q = X[31:0];
		end
		else if(cnt > 0)	//substract
		begin
			if((R[31] && !Y[31]) || (!R[31] && Y[31]))//不同号
			begin
                R = {R[30:0],Q[31]} + Y;
                Q = {Q[30:0],1'b0};
            end
            else
            begin
                R = {R[30:0],Q[31]} + _Y;
                Q = {Q[30:0],1'b1};
            end
            if((R[31] && !X[63]) || (!R[31] && X[63]))
            begin
                if(Md_op[0] && ((X[31] && !Y[31])||(!X[31]&&Y[31])))//不同号
                begin
                    Hi <= R + _Y;
                    Lo <= {Q[30:0],!((R[31] && !Y[31]) || (!R[31] && Y[31]))} + 32'b1;
                end
                else
                begin
                    Hi <= R + Y;
                    Lo <= {Q[30:0],!((R[31] && !Y[31]) || (!R[31] && Y[31]))};
                end
            end
            else
            begin
                if(Md_op[0] && ((X[31] && !Y[31])||(!X[31]&&Y[31])))//不同号
                begin
                    Hi <= R;
                    Lo <= {Q[30:0],!((R[31] && !Y[31]) || (!R[31] && Y[31]))} + 32'b1;
                end
                else
                begin
                    Hi <= R;
                    Lo <= {Q[30:0],!((R[31] && !Y[31]) || (!R[31] && Y[31]))};
                end
            end
			cnt <= cnt - 1'b1;
            if(cnt == 1) divided <= 1;
		end
	end
	else if(Md_op == 4'b0010) 	// DIVU
        begin
        multiplied <= 0;
        if(ready&&!divided)        //initial some registers
        begin
            cnt = 6'd32;
            X[63] = 1'b1;
            Y = Rt_in;
            _Y = ~Y + 32'b1;
            R = Rs_in[31];
            Q = {Rs_in[30:0],1'b0};
        end
        else if(cnt > 0)    //substract
        begin
            if({R[30:0],Q[31]} >= Y)
            begin
                R <= {R[30:0],Q[31]} + _Y;
                Q <= {Q[30:0],1'b1};
                Hi <= R;
                Lo <= Q;
            end
            else
            begin
                R <= {R[30:0],Q[31]};
                Q <= {Q[30:0],1'b0};
                Hi <= R;
                Lo <= Q;
            end
            cnt <= cnt - 1'b1;
            if(cnt == 1) divided <= 1;
        end
    end
    else begin
        calculated_res <= 32'h0;
        multiplied <= 0;
        divided <= 0;
    end
end

endmodule
