`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/09/19 16:46:19
// Design Name: 
// Module Name: alu
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

//This MIPS ALU is designed according to the given logic

module alu(
input [31:0] A,
input [31:0] B,
input [3:0] op,
output [31:0] alu_out,
output ZF_out,OF_out,LF_out
);
wire [2:0] ctrl;
// some logic operation outputs
wire [31:0] and32 = A & B;
wire [31:0] or32 = A | B;
wire [31:0] xor32 = A ^ B;
wire [31:0] nor32 = ~or32;
wire [31:0] A_xor_op0 = A ^{32{op[0]}}; //for leading zeros
wire [31:0] B_xor_op0 = B ^{32{op[0]}}; //for adder
wire [31:0] se = op[0] ? {{16{B[15]}},B[15:0]}: {{24{B[7]}},B[7:0]} ; // sign extend
wire [31:0] slt; // set less than
wire [31:0] prefix0; //ALU's counting leading zeros output
wire less_sel = !op[3] && op[2] && op[1] &&op[0]; //if comparing 2 uint,then Less flag is related to CF,orit's related to NF and OF
wire [4:0] mediate_leadingz; //leading zeros module's output


/*autodef*/
wire                                    CF;
wire                                    NF;
wire                                    OF;
wire [31:0]                             S;
wire                                    ZF;


//3 ctrl bits
assign ctrl[2] = !op[3]&&!op[1] || !op[3]&&op[2]&&op[0] || op[3]&&op[1];
assign ctrl[1] = !op[3]&&!op[2]&&!op[1] || op[3]&&!op[2]&&!op[0] ||
    op[2]&&op[1]&&!op[0] || op[3]&&op[1];
assign ctrl[0] = !op[2]&&!op[1] || !op[3]&&op[2]&&op[0] || op[3]&&op[2]&&op[1];

adder adder(/*autoinst*/
    .A                          (A[31:0]                        ),
    .B                          (B_xor_op0                        ),
    .cin                        (op[0]                            ),
    .ZF                         (ZF                             ),
    .CF                         (CF                             ),
    .OF                         (OF                             ),
    .NF                         (NF                             ),
    .S                          (S[31:0]                        )
);
leadingz leadingz(/*autoinst*/
    .A                          (A_xor_op0[31:0]                        ),
    .res                        (mediate_leadingz[4:0]                      )
);


assign LF_out = less_sel ? !CF : NF^OF;  
assign ZF_out = ZF;
assign OF_out = OF && op[3] && op[2] && op[1];//OF_out is valid during executing instruction 14 & 15
assign prefix0[5:0] = A_xor_op0 == 32'd0 ? 6'b100000 : {1'b0,mediate_leadingz[4:0]} ;
//if 32 bits of input are all 0s,then lower 6 bits of prefix0 are 6'b100000;
assign prefix0[31:6] = 26'd0;
assign slt = LF_out ? 32'd1 : 32'd0;

assign alu_out = ctrl==3'b000 ? prefix0 :
    (ctrl==3'b001 ? xor32 :
    (ctrl==3'b010 ? or32 :
    (ctrl==3'b011 ? nor32 :
    (ctrl==3'b100 ? and32 :
    (ctrl==3'b101 ? slt :
    (ctrl==3'b110 ? se : S
))))));

endmodule
