`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/07 09:14:01
// Design Name: 
// Module Name: cache_test
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


module cache_test();

parameter OFFSET_WIDTH = 3;
parameter BLOCK_SIZE = 1<<OFFSET_WIDTH;
parameter INDEX_WIDTH = 6;
parameter CACHE_DEPTH = 1<<INDEX_WIDTH;
parameter TAG_WIDTH = 30 - OFFSET_WIDTH - INDEX_WIDTH;

reg enable,cmp,write,clk,rst;
reg [31:0] data_in;
reg valid_in;
reg [3:0] byte_w_en;
reg [29:0] addr;
wire [OFFSET_WIDTH-1:0] word_sel;
wire [INDEX_WIDTH-1:0] index;
wire [TAG_WIDTH-1:0] tag_in;


assign tag_in = addr[29:29-TAG_WIDTH+1];
assign index = addr[29-TAG_WIDTH:OFFSET_WIDTH];
assign word_sel = addr[OFFSET_WIDTH-1:0];

wire hit,dirty;
wire [TAG_WIDTH-1:0] tag_out;
wire [31:0] data_out;
wire valid_out;

cache_2ways cache2w(enable, index, word_sel, cmp, write, tag_in, data_in, valid_in,
    byte_w_en, clk, rst, hit, dirty, tag_out, data_out, valid_out);

initial begin
    clk = 0;
    rst = 1;#4;
    clk = 1;#4;

    clk = 0;
    rst = 0;
    write = 0;
    cmp = 0;
    enable = 0;#4;
    clk = 1;#4;

    clk = 0;#2;
    addr = 30'h00000000;
    data_in = 32'hc5c5c5c5;
    write = 1;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 0;#2;
    clk = 1;#4;

    clk = 0;#2;
    addr = 30'h00000001;
    data_in = 32'hc5c5c5c5;
    write = 1;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 0;#2;
    clk = 1;#4;

    clk = 0;#2;
    addr = 30'h00000002;
    data_in = 32'hc5c5c5c5;
    write = 1;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 0;#2;
    clk = 1;#4;

    clk = 0;#2;
    addr = 30'h00000003;
    data_in = 32'hc5c5c5c5;
    write = 1;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 0;#2;
    clk = 1;#4;

    clk = 0;#2;
    addr = 30'h00000000;
    data_in = 32'hc5c5c5c5;
    write = 0;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 1;#2;
    clk = 1;#4;

    clk = 0;#2;
    addr = 30'h00000010;
    data_in = 32'hc5c5c5c5;
    write = 0;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 1;#2;
    clk = 1;#4;

    clk = 0;#2;
    addr = 30'h00000001;
    data_in = 32'hf0f0f0f0;
    write = 1;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 1;#2;
    clk = 1;#4;

    clk = 0;#2;
    addr = 30'h00000002;
    data_in = 32'hc5c5c5c5;
    write = 0;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 1;#2;
    clk = 1;#4;

    clk = 0;#2;
    addr = 30'h00000001;
    data_in = 32'hc5c5c5c5;
    write = 0;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 1;#2;
    clk = 1;#4;

//miss and load:
    clk = 0;#2;
    addr = 30'h00010001;
    data_in = 32'hc5c5c5c5;
    write = 1;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 1;#2;
    clk = 1;#4;

    clk = 0;#2;
    addr = 30'h00010001;
    data_in = 32'hc5c5c5c5;
    write = 1;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 0;#2;
    clk = 1;#4;     //load to line 1 because of invalidation of line 1
    
    clk = 0;#2;
    addr = 30'h00010001;
    data_in = 32'hc5c5c5c5;
    write = 0;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 1;#2;
    clk = 1;#4;

    clk = 0;#2;
    addr = 30'h00020001;
    data_in = 32'h48484848;
    write = 1;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 1;#2;
    clk = 1;#4;

    clk = 0;#2;
    addr = 30'h00020001;
    data_in = 32'h48484848;
    write = 1;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 0;#2;
    clk = 1;#4;     //load to line 1 because line 0 is dirty
    
    clk = 0;#2;
    addr = 30'h00020001;
    data_in = 32'h48484848;
    write = 0;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 1;#2;
    clk = 1;#4;

    clk = 0;#2;
    addr = 30'h00020001;
    data_in = 32'hb2b2b2b2;
    write = 1;      //write line 1 to make it dirty
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 1;#2;
    clk = 1;#4;     

    clk = 0;#2;
    addr = 30'h00030001;
    data_in = 32'ha7a7a7a7;
    write = 1;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 1;#2;
    clk = 1;#4;

    clk = 0;#2;
    addr = 30'h00030001;
    data_in = 32'ha7a7a7a7;
    write = 1;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 0;#2;
    clk = 1;#4;     //load to line 0 by victimway_ff
    
    clk = 0;#2;
    addr = 30'h00030001;
    data_in = 32'ha7a7a7a7;
    write = 0;
    byte_w_en = 4'b1111;
    valid_in = 1;
    enable = 1;
    cmp = 1;#2;
    clk = 1;#4;

end



endmodule
