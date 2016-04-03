`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/08 10:07:27
// Design Name: 
// Module Name: cache_manage_unit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:
//   Cache 顶层模块，除了连接 cache 各部件外，还负责进行最终的状态转移
//   以及阻塞信号的生成。
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "status.vh"

module cache_manage_unit(/*autoarg*/
    //Inputs
    rst, dc_read_in, dc_write_in, dc_byte_w_en_in, 
    ic_addr, dc_addr, data_from_reg, clk, 
    ram_ready, block_from_ram, 

    //Outputs
    mem_stall, dc_data_out, ic_data_out, 
    ram_en_out, ram_write_out, ram_addr_out, 
    dc_data_wb
);
parameter OFFSET_WIDTH = 3;
parameter BLOCK_SIZE = 1<<OFFSET_WIDTH;
parameter INDEX_WIDTH = 6;
parameter CACHE_DEPTH = 1<<INDEX_WIDTH;
parameter TAG_WIDTH = 30 - OFFSET_WIDTH - INDEX_WIDTH;

//from cpu
input rst;
input dc_read_in;
input dc_write_in;
input [3:0] dc_byte_w_en_in;
input [29:0] ic_addr;
input [29:0] dc_addr;
input [31:0] data_from_reg;
//from ram
input clk;
input ram_ready;        //inform control unit to do next action
input [(32*(2**OFFSET_WIDTH)-1) : 0] block_from_ram;
//to cpu
output mem_stall;
output [31:0] dc_data_out;
output [31:0] ic_data_out;
//to ram
output ram_en_out;
output ram_write_out;
output [29:0] ram_addr_out;
output [(32*(2**OFFSET_WIDTH)-1) : 0] dc_data_wb;

reg  [2:0] status;       // Cache 当前状态，表明 cache 是否*已经*发生缺失以及缺失类型，具体取值参见 status.vh.
wire [2:0] status_next;  // 由 cache control 生成的次态信号

reg  [2:0] counter;      // 块内偏移指针/迭代器，用于载入块时逐字写入。
wire [2:0] counter_next; // 由 cache control 决定的下一周期迭代器的值

reg write_after_load;

wire [3:0] byte_w_en_to_ic, byte_w_en_to_dc;

wire loading_ic = status ==`STAT_IC_MISS || status == `STAT_DOUBLE_MISS;
// for simple coherence

wire enable_to_ic, cmp_to_ic, write_to_ic, valid_to_ic;
wire enable_to_dc, cmp_to_dc, write_to_dc, valid_to_dc;

wire [OFFSET_WIDTH-1:0] ic_word_sel, dc_word_sel;

wire [31:0] word_to_ic;
wire [31:0] word_from_ic;
wire [31:0] word_to_dc;
wire [31:0] word_from_dc;

wire [(32*(2**OFFSET_WIDTH) - 1) : 0] block_to_ic;
wire [(32*(2**OFFSET_WIDTH) - 1) : 0] block_to_dc;
wire [(32*(2**OFFSET_WIDTH) - 1) : 0] block_from_dc;

wire [OFFSET_WIDTH-1:0] ic_offset;
wire [OFFSET_WIDTH-1:0] dc_offset;

wire [INDEX_WIDTH-1:0] index_to_ic;
wire [INDEX_WIDTH-1:0] index_to_dc;

wire [TAG_WIDTH-1:0] tag_to_ic;
wire [TAG_WIDTH-1:0] tag_to_dc;
wire [TAG_WIDTH-1:0] tag_from_ic;
wire [TAG_WIDTH-1:0] tag_from_dc;// tag from & to cache

wire [29:0] ram_addr_dc;
wire [29:0] ram_addr_dc_wb;
wire [1:0] ram_addr_sel;
wire [29:0] ram_addr_ic;

// 提取 I-cache 访问请求的信息
assign tag_to_ic = ic_addr[29:29-TAG_WIDTH+1];
assign index_to_ic = ic_addr[29-TAG_WIDTH:OFFSET_WIDTH];
assign ic_offset = ic_addr[OFFSET_WIDTH-1:0];

// 提取 D-cache 访问请求的信息
// when load block for instruction cache, if target block is in data_cache
// it should be loaded from data_cache.
assign tag_to_dc = (~loading_ic) ? dc_addr[29:29-TAG_WIDTH+1] : tag_to_ic;
assign index_to_dc = (~loading_ic) ? dc_addr[29-TAG_WIDTH:OFFSET_WIDTH] : index_to_ic;
assign dc_offset =  dc_addr[OFFSET_WIDTH-1:0];


// 发送给 ram 的地址来源:
//   00: ram_addr_ic
//   01: ram_addr_dc
//   1x: ram_addr_dc_wb
assign ram_addr_ic = {tag_to_ic, index_to_ic, counter};
assign ram_addr_dc = {tag_to_dc, index_to_dc, counter};
assign ram_addr_dc_wb = {tag_from_dc ,index_to_dc ,counter};//write back
assign ram_addr_out = ram_addr_sel[1] ?
    ram_addr_dc_wb :
    (ram_addr_sel[0] ? ram_addr_dc : ram_addr_ic);


// TODO 大部分 wire 变量没有被复用，可以简化。
assign dc_data_out = word_from_dc;
assign ic_data_out = word_from_ic;
assign dc_data_wb = block_from_dc;
assign word_to_ic = 32'd0;  // I-cache 不需要来自 CPU 的写操作
assign word_to_dc = data_from_reg;
assign block_to_ic = block_from_ram;
assign block_to_dc = block_from_ram;

wire hit_from_ic, valid_from_ic;
wire hit_from_dc, valid_from_dc, dirty_from_dc; // 5 outputs of i&d cache

wire [2:0] word_sel_to_ic;
wire [2:0] word_sel_to_dc;

// 控制单元，大部分控制信号在这里生成。
cache_control cctrl (
    dc_read_in, dc_write_in, ic_offset, dc_offset, dc_byte_w_en_in, 
    hit_from_ic, valid_from_ic,/*ic's output*/
    hit_from_dc, dirty_from_dc, valid_from_dc,/*dc's output*/
    status, counter,/*status*/

    enable_to_ic, word_sel_to_ic, cmp_to_ic, write_to_ic,
    byte_w_en_to_ic, valid_to_ic,/*to ic*/

    enable_to_dc, word_sel_to_dc, cmp_to_dc, write_to_dc,
    byte_w_en_to_dc, valid_to_dc,/*to dc*/

    ram_addr_sel, ram_en_out, ram_write_out,
    status_next, counter_next
);

// Instruction Cache
cache_2ways ic(/*autoinst*/
    .clk                        (clk),
    .rst                        (rst),
    .enable                     (enable_to_ic),
    .cmp                        (cmp_to_ic),
    .write                      (write_to_ic),
    .byte_w_en                  (byte_w_en_to_ic),
    .valid_in                   (valid_to_ic),
    .tag_in                     (tag_to_ic),
    .index                      (index_to_ic),
    .word_sel                   (word_sel_to_ic),
    .data_in                    (word_to_ic),
    .data_block_in              (block_to_ic),
    .hit                        (hit_from_ic),
    .dirty                      (),
    .valid_out                  (valid_from_ic),
    .tag_out                    (tag_from_ic),
    .data_out                   (word_from_ic),
    .data_wb                    ()
);

// Data cache
cache_2ways dc(/*autoinst*/
    .clk                        (clk),
    .rst                        (rst),
    .enable                     (enable_to_dc),
    .cmp                        (cmp_to_dc),
    .write                      (write_to_dc),
    .byte_w_en                  (byte_w_en_to_dc),
    .valid_in                   (valid_to_dc),
    .tag_in                     (tag_to_dc),
    .index                      (index_to_dc),
    .word_sel                   (word_sel_to_dc),
    .data_in                    (word_to_dc),
    .data_block_in              (block_to_dc),
    .hit                        (hit_from_dc),
    .dirty                      (dirty_from_dc),
    .valid_out                  (valid_from_dc),
    .tag_out                    (tag_from_dc),
    .data_out                   (word_from_dc),
    .data_wb                    (block_from_dc)
);

// 状态转移逻辑
always @(posedge clk) begin
    if(rst) begin
        status <= `STAT_NORMAL;
        counter <= 3'd7;
        write_after_load <= 0;
    end
    else begin
        if(status == `STAT_NORMAL) begin
            status <= status_next;
            counter <= counter_next;
            write_after_load <= 0;
        end
        else begin
            if(dc_write_in) begin
                write_after_load <= 1;
            end
            // loading_ic && hit_from_ic 在如下场景下有意义：
            // 如果 I-cache 缺失的数据在 D-cache 中已经存在并被载入，
            // 那么就不需要等待存储器准备好，而尽早地结束阻塞状态。
            // 其他情况下，ram_ready 至少对于 counter 的更新是必要的。
            if(ram_ready || (loading_ic && hit_from_ic)) begin
                status <= status_next;
                counter <= counter_next;
            end
        end
    end
end

assign mem_stall = 
    (status != `STAT_NORMAL) ||          // Cache 处于缺失处理过程中
    (status_next != `STAT_NORMAL) ||     // 本周期访问 cache 发生 miss
    write_after_load ;                   // 为写操作续一个周期


endmodule
