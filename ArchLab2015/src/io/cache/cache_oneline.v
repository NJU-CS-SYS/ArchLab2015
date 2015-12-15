`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/06 16:57:22
// Design Name: 
// Module Name: cache_oneline
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


module cache_oneline(enable, index, word_sel, cmp, write, tag_in, data_in,
valid_in, byte_w_en, clk, rst, hit, dirty, tag_out, data_out, valid_out);

parameter OFFSET_WIDTH = 3;
parameter BLOCK_SZIE = 1<<OFFSET_WIDTH;
parameter INDEX_WIDTH = 7;
parameter CACHE_DEPTH = 1<<INDEX_WIDTH;
parameter TAG_WIDTH = 30 - OFFSET_WIDTH - INDEX_WIDTH;

input enable;
input [INDEX_WIDTH-1:0] index;
input [OFFSET_WIDTH-1:0] word_sel;
input cmp;
input write;
input [TAG_WIDTH-1:0] tag_in;
input [31:0] data_in;
input valid_in;
input [3:0] byte_w_en;
input clk;
input rst;
output hit;
output dirty;
output [TAG_WIDTH-1:0] tag_out;
output [31:0] data_out;
output valid_out;

assign go = enable & ~rst;
assign match = (tag_in == tag_out);

assign word0_w_en = go & write & (word_sel == 3'b000) & (match | ~cmp);
assign word1_w_en = go & write & (word_sel == 3'b001) & (match | ~cmp);
assign word2_w_en = go & write & (word_sel == 3'b010) & (match | ~cmp);
assign word3_w_en = go & write & (word_sel == 3'b011) & (match | ~cmp);
assign word4_w_en = go & write & (word_sel == 3'b100) & (match | ~cmp);
assign word5_w_en = go & write & (word_sel == 3'b101) & (match | ~cmp);
assign word6_w_en = go & write & (word_sel == 3'b110) & (match | ~cmp);
assign word7_w_en = go & write & (word_sel == 3'b111) & (match | ~cmp);

assign dirty_override = go & write & (match|~cmp);
assign tag_override = go & write & ~cmp;
assign valid_overide = go & write & ~cmp;
assign dirty_in = cmp; //cmp & write will override dirty bit

wire[31:0] word0;
wire[31:0] word1;
wire[31:0] word2;
wire[31:0] word3;
wire[31:0] word4;
wire[31:0] word5;
wire[31:0] word6;
wire[31:0] word7;

cache_mem_word #(INDEX_WIDTH) mem_word0(clk, rst, word0_w_en, data_in, index, word0, byte_w_en);
cache_mem_word #(INDEX_WIDTH) mem_word1(clk, rst, word1_w_en, data_in, index, word1, byte_w_en);
cache_mem_word #(INDEX_WIDTH) mem_word2(clk, rst, word2_w_en, data_in, index, word2, byte_w_en);
cache_mem_word #(INDEX_WIDTH) mem_word3(clk, rst, word3_w_en, data_in, index, word3, byte_w_en);
cache_mem_word #(INDEX_WIDTH) mem_word4(clk, rst, word4_w_en, data_in, index, word4, byte_w_en);
cache_mem_word #(INDEX_WIDTH) mem_word5(clk, rst, word5_w_en, data_in, index, word5, byte_w_en);
cache_mem_word #(INDEX_WIDTH) mem_word6(clk, rst, word6_w_en, data_in, index, word6, byte_w_en);
cache_mem_word #(INDEX_WIDTH) mem_word7(clk, rst, word7_w_en, data_in, index, word7, byte_w_en);

wire dirty_bit,valid_bit;

cache_mem #(INDEX_WIDTH,CACHE_DEPTH,TAG_WIDTH) mem_tag(clk, rst, tag_override, tag_in, index, tag_out);
cache_mem #(INDEX_WIDTH,CACHE_DEPTH,1) mem_dirty(clk, rst, dirty_override, dirty_in, index, dirty_bit);
cache_mem #(INDEX_WIDTH,CACHE_DEPTH,1) mem_valid(clk, rst, valid_overide, valid_in, index, valid_bit);

assign hit = go & match;
assign dirty = go & dirty_bit & (~write | ( cmp & ~match )); // ???
/*
*read : whether this line has been written;
*write & cmp : not matched  <- why ??
*/
assign valid_out = go & valid_bit & (~write | cmp);

data_sel sel0(word_sel,word0,word1,word2,word3,word4,word5,word6,word7,data_out);

endmodule
