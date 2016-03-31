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
// use victimway to mux the data, valid, and dirty bits from the two
// cache modules
//
//////////////////////////////////////////////////////////////////////////////////


module cache_2ways(
    enable,
    index,
    word_sel,
    cmp,
    write,
    tag_in,
    data_in,
    valid_in,
    byte_w_en,
    clk,
    rst,
    hit,
    dirty,
    tag_out,
    data_out,
    data_wb,
    valid_out
);

parameter OFFSET_WIDTH = 3;
parameter BLOCK_SIZE = 1<<OFFSET_WIDTH;
parameter INDEX_WIDTH = 6;
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
output [(32*(2**OFFSET_WIDTH)-1) : 0] data_wb;
output valid_out;

reg victimway_ff;
wire victimway,valid0,valid1,dirty0,dirty1;
wire [31:0] data0,data1;
wire [TAG_WIDTH-1:0] tag0,tag1;
wire write0,write1;
wire [(32*(2**OFFSET_WIDTH)-1) : 0] data_wb_1;
wire [(32*(2**OFFSET_WIDTH)-1) : 0] data_wb_0;

victimway_sel vs0(rst, enable, cmp, valid0,valid1,dirty0,dirty1,victimway_ff,victimway);

always @ (posedge clk) begin
    victimway_ff <= victimway;
end

//input to both oneline cache :
//index, word_sel, cmp, tag_in, data_in, valid_in, byte_w_en, clk, rst
//input different :

cache_oneline 
#(OFFSET_WIDTH,BLOCK_SIZE,INDEX_WIDTH,CACHE_DEPTH,TAG_WIDTH) c0(
    enable0,
    index,
    word_sel,
    cmp,
    write0,
    tag_in,
    data_in,
    valid_in,
    byte_w_en,
    clk,
    rst,
    hit0,
    dirty0,
    tag0,
    data_wb_0,
    data0,
    valid0
);

cache_oneline 
#(OFFSET_WIDTH,BLOCK_SIZE,INDEX_WIDTH,CACHE_DEPTH,TAG_WIDTH) c1(
    enable1,
    index,
    word_sel,
    cmp,
    write1,
    tag_in,
    data_in,
    valid_in,
    byte_w_en,
    clk,
    rst,
    hit1,
    dirty1,
    tag1,
    data_wb_1,
    data1,
    valid1
);

// bug ?????????????????
assign enable0 = cmp ? enable : ~victimway;
assign enable1 = cmp ? enable : victimway;

assign write0 = write &(cmp ? (valid0 & hit0) : ~victimway_ff);
assign write1 = write &(cmp ? (valid1 & hit1) : victimway_ff);
//assign write1 = cmp ? (write & valid1 &  hit1) : victimway_ff;

assign hit = (valid1 & hit1) | (valid0 & hit0);
assign dirty = dirty0 & dirty1;
//assign data_out = cmp ? ((hit0 & valid0) ? data0 : data1) : (victimway_ff ? data1 : data0);
assign data_out = ((hit0 & valid0) ? data0 : data1);
assign data_wb = victimway_ff ? data_wb_1 : data_wb_0;
assign valid_out = valid0 | valid1;
//if !cmp, then tag_out is used for write back, and it should be the victimway's tag
//assign tag_out = cmp ? ((hit0&valid0) ? tag0 : tag1) : tag_in;
assign tag_out = cmp ? ((hit0&valid0) ? tag0 : tag1) : (victimway_ff ? tag1 : tag0);


endmodule
