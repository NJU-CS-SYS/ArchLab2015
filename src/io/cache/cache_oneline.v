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


module cache_oneline(/*autoarg*/
    //Inputs
    clk, rst, enable, cmp, write, byte_w_en, 
    valid_in, tag_in, index, word_sel, data_in, 

    //Outputs
    hit, dirty, valid_out, tag_out, data_out, 
    data_wb, data_block_in
);

parameter OFFSET_WIDTH = 3;
parameter BLOCK_SZIE = 1<<OFFSET_WIDTH;
parameter INDEX_WIDTH = 7;
parameter CACHE_DEPTH = 1<<INDEX_WIDTH;
parameter TAG_WIDTH = 30 - OFFSET_WIDTH - INDEX_WIDTH;

// system:
input clk;
input rst;

// control:
input enable;
input cmp;
input write;
input [3:0] byte_w_en;

// data and cache match related
input valid_in;
input [TAG_WIDTH-1:0] tag_in;
input [INDEX_WIDTH-1:0] index;
input [OFFSET_WIDTH-1:0] word_sel;
input [31:0] data_in;
input [(32*(2**OFFSET_WIDTH)-1) : 0] data_block_in;

output hit;
output dirty;
output valid_out;
output [TAG_WIDTH-1:0] tag_out;
output [31:0] data_out;
output [(32*(2**OFFSET_WIDTH)-1) : 0] data_wb;

assign go = enable & ~rst;
assign match = (tag_in == tag_out);

assign word0_w_en = go & write & (word_sel == 3'b000) & match;
assign word1_w_en = go & write & (word_sel == 3'b001) & match;
assign word2_w_en = go & write & (word_sel == 3'b010) & match;
assign word3_w_en = go & write & (word_sel == 3'b011) & match;
assign word4_w_en = go & write & (word_sel == 3'b100) & match;
assign word5_w_en = go & write & (word_sel == 3'b101) & match;
assign word6_w_en = go & write & (word_sel == 3'b110) & match;
assign word7_w_en = go & write & (word_sel == 3'b111) & match;

assign dirty_override = go & write & (match|~cmp);
assign tag_override = go & write & ~cmp;
assign valid_overide = go & write & ~cmp;
assign dirty_in = cmp; //cmp & write will override dirty bit

wire [31:0] word_from_word_0;
wire [31:0] word_from_word_1;
wire [31:0] word_from_word_2;
wire [31:0] word_from_word_3;
wire [31:0] word_from_word_4;
wire [31:0] word_from_word_5;
wire [31:0] word_from_word_6;
wire [31:0] word_from_word_7;

wire [31:0] word_to_word_0 = ~cmp ? data_block_in[1*32-1 : 0*32] : data_in;
wire [31:0] word_to_word_1 = ~cmp ? data_block_in[2*32-1 : 1*32] : data_in;
wire [31:0] word_to_word_2 = ~cmp ? data_block_in[3*32-1 : 2*32] : data_in;
wire [31:0] word_to_word_3 = ~cmp ? data_block_in[4*32-1 : 3*32] : data_in;
wire [31:0] word_to_word_4 = ~cmp ? data_block_in[5*32-1 : 4*32] : data_in;
wire [31:0] word_to_word_5 = ~cmp ? data_block_in[6*32-1 : 5*32] : data_in;
wire [31:0] word_to_word_6 = ~cmp ? data_block_in[7*32-1 : 6*32] : data_in;
wire [31:0] word_to_word_7 = ~cmp ? data_block_in[8*32-1 : 7*32] : data_in;

wire [3:0] byte_w_en_to_word = cmp ? byte_w_en : 4'b1111;

cache_mem_word #(INDEX_WIDTH) mem_word0(
    clk,
    rst,
    word0_w_en,
    word_to_word_0,
    index,
    word_from_word_0,
    byte_w_en_to_word
);
cache_mem_word #(INDEX_WIDTH) mem_word1(
    clk,
    rst,
    word1_w_en,
    word_to_word_1,
    index,
    word_from_word_1,
    byte_w_en_to_word
);
cache_mem_word #(INDEX_WIDTH) mem_word2(
    clk,
    rst,
    word2_w_en,
    word_to_word_2,
    index,
    word_from_word_2,
    byte_w_en_to_word
);
cache_mem_word #(INDEX_WIDTH) mem_word3(
    clk,
    rst,
    word3_w_en,
    word_to_word_3,
    index,
    word_from_word_3,
    byte_w_en_to_word
);
cache_mem_word #(INDEX_WIDTH) mem_word4(
    clk,
    rst,
    word4_w_en,
    word_to_word_4,
    index,
    word_from_word_4,
    byte_w_en_to_word
);
cache_mem_word #(INDEX_WIDTH) mem_word5(
    clk,
    rst,
    word5_w_en,
    word_to_word_5,
    index,
    word_from_word_5,
    byte_w_en_to_word
);
cache_mem_word #(INDEX_WIDTH) mem_word6(
    clk,
    rst,
    word6_w_en,
    word_to_word_6,
    index,
    word_from_word_6,
    byte_w_en_to_word
);
cache_mem_word #(INDEX_WIDTH) mem_word7(
    clk,
    rst,
    word7_w_en,
    word_to_word_7,
    index,
    word_from_word_7,
    byte_w_en_to_word
);

wire dirty_bit,valid_bit;

cache_mem #(INDEX_WIDTH,CACHE_DEPTH,TAG_WIDTH) mem_tag(/*autoinst*/
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .write                      (tag_override                   ),
    .data_in                    (tag_in                         ),
    .addr                       (index                          ),
    .data_out                   (tag_out                        )
);

cache_mem #(INDEX_WIDTH,CACHE_DEPTH,1) mem_dirty(/*autoinst*/
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .write                      (dirty_override                 ),
    .data_in                    (dirty_in                       ),
    .addr                       (index                          ),
    .data_out                   (dirty_bit                      )
);

cache_vmem #(INDEX_WIDTH,CACHE_DEPTH,1) mem_valid(/*autoinst*/
    .clk                        (clk                            ),
    .rst                        (rst                            ),
    .write                      (valid_overide                  ),
    .data_in                    (valid_in                       ),
    .addr                       (index                          ),  
    .data_out                   (valid_bit                      )
);

assign hit = go & match;
assign dirty = go & dirty_bit & (~write | ( cmp & ~match )); // ???
/*
*read : whether this line has been written;
*write & cmp : not matched  <- why ??
*/
assign valid_out = go & valid_bit & (~write | cmp);

data_sel sel0(word_sel,word_from_word_0,word_from_word_1,word_from_word_2,word_from_word_3,word_from_word_4,word_from_word_5,word_from_word_6,word_from_word_7,data_out);

assign data_wb = {word_from_word_0, word_from_word_1, word_from_word_2, word_from_word_3,
    word_from_word_4, word_from_word_5, word_from_word_6, word_from_word_7};

endmodule
