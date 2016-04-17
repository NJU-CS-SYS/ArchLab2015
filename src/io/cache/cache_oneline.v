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
//   直接映射 cache, 在这一层决定了 data block 的大小
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
parameter BLOCK_SIZE   = 1 << OFFSET_WIDTH;
parameter INDEX_WIDTH  = 7;
parameter CACHE_DEPTH  = 1 << INDEX_WIDTH;
parameter TAG_WIDTH    = 30 - OFFSET_WIDTH - INDEX_WIDTH;
parameter ADDR_WIDTH   = TAG_WIDTH + INDEX_WIDTH + OFFSET_WIDTH;
parameter DATA_WIDTH   = 32;
parameter BLOCK_WIDTH  = BLOCK_SIZE * DATA_WIDTH;
// Keep compatible with the upper module,
// I like the TAG_WIDTH being the final one to be determined.

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
input [TAG_WIDTH    - 1 : 0] tag_in;
input [INDEX_WIDTH  - 1 : 0] index;
input [OFFSET_WIDTH - 1 : 0] word_sel;
input [DATA_WIDTH   - 1 : 0] data_in;
input [BLOCK_WIDTH  - 1 : 0] data_block_in;

output hit;
output dirty;
output valid_out;
output [TAG_WIDTH - 1 : 0] tag_out;
output reg [DATA_WIDTH - 1 : 0] data_out;
output [BLOCK_WIDTH - 1 : 0] data_wb;

// actual enable
assign go = enable & ~rst;

// tag match
assign match = (tag_in == tag_out);

// dirty bit write enable
assign dirty_override = go & write & (match | ~cmp);

// valid bit write enable
assign valid_overide = go & write & ~cmp;

// tag write enable
assign tag_override = go & write & ~cmp;

// 读访问时，虽然 cmp 为 1，但是 dirty_override 为 0, 所以不会产生影响。
// 写访问时，将 dirty bit 修改成 1.
// 载入时，cmp 为 0，但是 dirty_override 为 1, 所以 dirty bit 按照期望修改成 0.
assign dirty_in = cmp; //cmp & write will override dirty bit

// 选择写访问的字节写使能，还是载入时的全写。
wire [3:0] byte_w_en_to_word = cmp ? byte_w_en : 4'b1111;

wire word_wen[BLOCK_SIZE - 1 : 0];

wire [DATA_WIDTH - 1 : 0] word_in  [BLOCK_SIZE - 1 : 0];
wire [DATA_WIDTH - 1 : 0] word_out [BLOCK_SIZE - 1 : 0];

genvar word_index;
generate
    for (word_index = 0; word_index < BLOCK_SIZE; word_index = word_index + 1) begin: cache_word
        assign word_wen[word_index] = go & write & ((word_sel == word_index) & (match) | ~cmp);
        assign word_in[word_index]  = cmp ? data_in : data_block_in[word_index * DATA_WIDTH +: DATA_WIDTH];

        cache_mem_word #(INDEX_WIDTH) word_instance (
            clk,
            rst,
            word_wen[word_index],
            word_in[word_index],
            index,
            word_out[word_index],
            byte_w_en_to_word
        );

        assign data_wb[word_index * DATA_WIDTH +: DATA_WIDTH] = word_out[word_index];
    end
endgenerate

// As word_sel is not a one-hot selector, the configurable multiplexer using a for loop referred at
// http://stackoverflow.com/questions/19875899/how-to-define-a-parameterized-multiplexer-using-systemverilog
// is generated with overhead somewhat. So we prefer a switch statement in always block, anyway,
// reduce the lines of code is the primary task.
always @ (*) begin
    case (word_sel)
    0: data_out = word_out[0];
    1: data_out = word_out[1];
    2: data_out = word_out[2];
    3: data_out = word_out[3];
    4: data_out = word_out[4];
    5: data_out = word_out[5];
    6: data_out = word_out[6];
    7: data_out = word_out[7];
    endcase
end
/*
integer i;
always @ (*) begin
    data_out = 32'dz;
    for (i = 0; i < 8; i = i + 1) begin
        if (i == word_sel) begin
            data_out = word_out[i];
        end
    end
end
*/

cache_vmem #(INDEX_WIDTH,CACHE_DEPTH,TAG_WIDTH) mem_tag(/*autoinst*/
    .clk      ( clk          ),
    .rst      ( rst          ),
    .write    ( tag_override ),
    .data_in  ( tag_in       ),
    .addr     ( index        ),
    .data_out ( tag_out      )
);

wire dirty_bit;

cache_vmem #(INDEX_WIDTH,CACHE_DEPTH,1) mem_dirty(/*autoinst*/
    .clk      ( clk            ),
    .rst      ( rst            ),
    .write    ( dirty_override ),
    .data_in  ( dirty_in       ),
    .addr     ( index          ),
    .data_out ( dirty_bit      )
);

wire valid_bit;

cache_vmem #(INDEX_WIDTH,CACHE_DEPTH,1) mem_valid(/*autoinst*/
    .clk      ( clk           ),
    .rst      ( rst           ),
    .write    ( valid_overide ),
    .data_in  ( valid_in      ),
    .addr     ( index         ),
    .data_out ( valid_bit     )
);

assign hit = go & match;

// Read:  expose the dirty bit
// Write: expose the dirty bit if not matched
// Load:  not expose the dirty bit
// 写入的场合，不需要外界知道脏位信息，而且其也正被更新。
// 其他场合，暴露脏位信息，用于决定 victimway
assign dirty = go & dirty_bit & (~write | ( cmp & ~match ));

// Read & Write:  expose the valid bit
// Load: not expose the valid bit, because updating ?
assign valid_out = go & valid_bit & (~write | cmp);

endmodule
