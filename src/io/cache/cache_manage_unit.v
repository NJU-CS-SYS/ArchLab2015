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
// 
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
    ram_ready, data_from_ram, 

    //Outputs
    mem_stall, dc_data_out, ic_data_out, 
    ram_en_out, ram_write_out, ram_addr_out
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
input [(32*(2**OFFSET_WIDTH)-1) : 0] data_from_ram;
//to cpu
output mem_stall;
output [31:0] dc_data_out;
output [31:0] ic_data_out;
//to ram
output ram_en_out;
output ram_write_out;
output [29:0] ram_addr_out;
output [(32*(2**OFFSET_WIDTH)-1) : 0] dc_data_wb;

reg [2:0] status,counter;
reg write_after_load;

wire ic_enable, ic_cmp, ic_write, ic_data_sel, ic_valid_2ic;
wire dc_enable, dc_cmp, dc_write, dc_data_sel, dc_valid_2dc;
wire [OFFSET_WIDTH-1:0] ic_word_sel, dc_word_sel;
wire [2:0] status_next, counter_next;
wire [3:0] ic_byte_w_en, dc_byte_w_en;
wire [31:0] ic_data2ic, dc_data2dc;
wire [29:0] ram_addr_ic, ram_addr_dc ,ram_addr_dc_wb;
wire [1:0] ram_addr_sel;

wire [OFFSET_WIDTH-1:0] ic_offset, dc_offset;
wire [INDEX_WIDTH-1:0] ic_index, dc_index;
wire [TAG_WIDTH-1:0] ic_tag, dc_tag, ic_tag_out, dc_tag_out;// tag from & to cache
wire loading_ic = status ==`STAT_IC_MISS || status == `STAT_DOUBLE_MISS;
// for simple coherence

assign ic_tag = ic_addr[29:29-TAG_WIDTH+1];
assign dc_tag = (~loading_ic) ? dc_addr[29:29-TAG_WIDTH+1] : ic_tag;
// when load block for instruction cache, if target block is in data_cache
// it should be loaded from data_cache

assign ic_index = ic_addr[29-TAG_WIDTH:OFFSET_WIDTH];
assign dc_index = (~loading_ic) ? dc_addr[29-TAG_WIDTH:OFFSET_WIDTH] : ic_index;
assign ic_offset = ic_addr[OFFSET_WIDTH-1:0];
assign dc_offset =  dc_addr[OFFSET_WIDTH-1:0];
assign ram_addr_ic = {ic_tag,ic_index,counter};
assign ram_addr_dc = {dc_tag,dc_index,counter};
assign ram_addr_dc_wb = {dc_tag_out,dc_index,counter};//write back
assign ram_addr_out = ram_addr_sel[1] ? ram_addr_dc_wb : (ram_addr_sel[0] ? ram_addr_dc : ram_addr_ic);

wire hit_from_ic, valid_from_ic; //ic_dirty is useless
wire hit_from_dc, valid_from_dc, dirty_from_dc; // 6 output of i&d cache


cache_control cctrl (
    dc_read_in, dc_write_in, ic_offset, dc_offset, dc_byte_w_en_in, 
    hit_from_ic, valid_from_ic,/*ic's output*/
    hit_from_ic, dirty_from_dc, valid_from_dc,/*dc's output*/
    status, counter,/*status*/

    enable_to_ic, word_sel_to_ic, cmp_to_ic, write_to_ic,
    data_sel_to_ic, byte_w_en_to_ic, valid_to_ic,/*to ic*/

    enable_to_dc, word_sel_to_ic, cmp_to_dc, write_to_dc,
    dc_data_sel, dc_byte_w_en, dc_valid_2dc,/*to dc*/

    ram_addr_sel, ram_en_out, ram_write_out,
    status_next, counter_next
);

assign ic_data2ic = ic_data_sel ? data_ram : dc_data_out; //0:load from dc
assign dc_data2dc = dc_data_sel ? data_ram : data_reg;

cache_2ways ic(/*autoinst*/
    .clk                        (clk),
    .rst                        (rst),
    .enable                     (enable_to_ic),
    .cmp                        (cmp_to_ic),
    .write                      (write_to_dc),
    .byte_w_en                  (byte_w_en_to_ic),
    .valid_in                   (valid_to_ic),
    .tag_in                     (tag_to_ic),
    .index                      (index_to_ic),
    .word_sel                   (word_sel_to_ic),
    .data_in                    (wotd_to_ic),
    .data_block_in              (block_to_ic),
    .hit                        (hit_from_ic),
    .dirty                      (),
    .valid_out                  (valid_from_ic),
    .tag_out                    (tag_from_dc),
    .data_out                   (word_from_ic),
    .data_wb                    ()
);

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
            if(ram_ready || (loading_ic && dc_hit)) begin
                status <= status_next;
                counter <= counter_next;
            end
        end
    end
end

assign mem_stall = (status != `STAT_NORMAL) || (status_next != `STAT_NORMAL) || write_after_load ;


endmodule
