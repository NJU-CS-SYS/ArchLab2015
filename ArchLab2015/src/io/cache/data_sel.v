`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/06 18:30:49
// Design Name: 
// Module Name: data_sel
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


module data_sel(sel,word0,word1,word2,word3,word4,word5,word6,word7,word_out);

input [2:0] sel;
input [31:0] word0;
input [31:0] word1;
input [31:0] word2;
input [31:0] word3;
input [31:0] word4;
input [31:0] word5;
input [31:0] word6;
input [31:0] word7;
output [31:0] word_out;

reg [31:0] word_reg;

always @(sel or word0 or word1 or word2 or word3 or word4 or word5 or word6 or word7)begin
    case(sel)
        3'b000:word_reg = word0;
        3'b001:word_reg = word1;
        3'b010:word_reg = word2;
        3'b011:word_reg = word3;
        3'b100:word_reg = word4;
        3'b101:word_reg = word5;
        3'b110:word_reg = word6;
        3'b111:word_reg = word7;
    endcase
end

assign word_out = word_reg;

endmodule
