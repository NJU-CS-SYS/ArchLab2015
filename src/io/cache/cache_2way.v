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

reg victimway_ff;
wire victimway;

victimway_sel vs0(rst, enable, cmp, valid0,valid1,dirty0,dirty1,victimway_ff,victimway);

always @ (posedge clk) begin
    victimway_ff <= victimway;
end

wire enable_to_line_0;
wire write_to_line_0;
wire hit_from_line_0;
wire dirty_from_line_0;
wire valid_from_line_0;
wire [TAG_WIDTH-1:0] tag_from_line_0;
wire [31:0] data_word_from_line_0;
wire [(32*(2**OFFSET_WIDTH)-1) : 0] data_block_from_line_0;
wire [(32*(2**OFFSET_WIDTH)-1) : 0] data_block_to_line_0 = data_block_in;

wire enable_to_line_1;
wire write_to_line_1;
wire hit_from_line_1;
wire dirty_from_line_1;
wire valid_from_line_1;
wire [TAG_WIDTH-1:0] tag_from_line_1;
wire [31:0] data_word_from_line_1;
wire [(32*(2**OFFSET_WIDTH)-1) : 0] data_block_from_line_1;
wire [(32*(2**OFFSET_WIDTH)-1) : 0] data_block_to_line_1 = data_block_in;
//input to both oneline cache :
//index, word_sel, cmp, tag_in, data_in, valid_in, byte_w_en, clk, rst

cache_oneline #(OFFSET_WIDTH,BLOCK_SIZE,INDEX_WIDTH,CACHE_DEPTH,TAG_WIDTH) c0(/*autoinst*/
    .clk                        (clk                                        ),
    .rst                        (rst                                        ),
    .enable                     (enable_to_line_0                           ),
    .cmp                        (cmp                                        ),
    .write                      (write_to_line_0                            ),
    .byte_w_en                  (byte_w_en                                  ),
    .valid_in                   (valid_in                                   ),
    .tag_in                     (tag_in                                     ),
    .index                      (index                                      ), 
    .word_sel                   (word_sel                                   ), 
    .data_in                    (data_in                                    ),
    .data_block_in              (data_block_to_line_0                       ),
    .hit                        (hit_from_line_0                            ),
    .dirty                      (dirty_from_line_0                          ),
    .valid_out                  (valid_from_line_0                          ),
    .tag_out                    (tag_from_line_0                            ),
    .data_out                   (data_word_from_line_0                      ),
    .data_wb                    (data_block_from_line_0                     ),
);

cache_oneline #(OFFSET_WIDTH,BLOCK_SIZE,INDEX_WIDTH,CACHE_DEPTH,TAG_WIDTH) c1(/*autoinst*/
    .clk                        (clk                                        ),
    .rst                        (rst                                        ),
    .enable                     (enable_to_line_0                           ),
    .cmp                        (cmp                                        ),
    .write                      (write_to_line_1                            ),
    .byte_w_en                  (byte_w_en                                  ),
    .valid_in                   (valid_in                                   ),
    .tag_in                     (tag_in                                     ),
    .index                      (index                                      ), 
    .word_sel                   (word_sel                                   ), 
    .data_in                    (data_in                                    ),
    .data_block_in              (data_block_to_line_1                       ),
    .hit                        (hit_from_line_1                            ),
    .dirty                      (dirty_from_line_1                          ),
    .valid_out                  (valid_from_line_1                          ),
    .tag_out                    (tag_from_line_1                            ),
    .data_out                   (data_word_from_line_1                      ),
    .data_wb                    (data_block_from_line_1                     ),
);


// bug ?????????????????
assign enable_to_line_0 = cmp ? enable : ~victimway;
assign enable_to_line_1 = cmp ? enable : victimway;

assign write_to_line_0 = write &(cmp ? (valid_from_line_0 & hit_from_line_0) : ~victimway_ff);
assign write_to_line_1 = write &(cmp ? (valid_from_line_1 & hit_from_line_1) : victimway_ff);

assign hit = (valid_from_line_1 & hit_from_line_1) | (valid_from_line_0 & hit_from_line_0);
assign dirty = dirty_from_line_0 & dirty_from_line_0;
//assign data_out = cmp ? ((hit0 & valid0) ? data0 : data1) : (victimway_ff ? data1 : data0);

assign data_out = (hit_from_line_0 & valid_from_line_0) ? data_word_from_line_0 : data_word_from_line_1;

assign data_wb = victimway_ff ? data_block_from_line_1 : data_block_from_line_0;
assign valid_out = valid_from_line_0 | valid_from_line_1;

//if !cmp, then tag_out is used for write back, and it should be the victimway's tag
//assign tag_out = cmp ? ((hit0&valid0) ? tag0 : tag1) : tag_in;
assign tag_out = cmp ? 
    ((hit_from_line_0&valid_from_line_0) ?tag_from_line_0 : tag_from_line_0) :
    (victimway_ff ? tag_from_line_1 : tag_from_line_0);

endmodule
