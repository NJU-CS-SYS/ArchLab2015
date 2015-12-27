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

module cache_manage_unit(ic_addr, data_ram, dc_read_in, dc_write_in, dc_addr, data_reg,
    dc_byte_w_en_in, clk, rst,ram_ready,
    ic_data_out, dc_data_out, mem_stall,
    ram_en_out,ram_write_out,ram_addr_out
);
parameter OFFSET_WIDTH = 3;
parameter BLOCK_SIZE = 1<<OFFSET_WIDTH;
parameter INDEX_WIDTH = 6;
parameter CACHE_DEPTH = 1<<INDEX_WIDTH;
parameter TAG_WIDTH = 30 - OFFSET_WIDTH - INDEX_WIDTH;

input [29:0] ic_addr,dc_addr;
input [31:0] data_ram,data_reg;//data_from_ram, data_from_reg
input dc_write_in,dc_read_in,clk,rst;
input ram_ready;
input [3:0] dc_byte_w_en_in;
output [31:0] dc_data_out,ic_data_out;
output mem_stall,ram_en_out,ram_write_out;
output [29:0] ram_addr_out;

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
wire [TAG_WIDTH-1:0] ic_tag, dc_tag, ic_tag_out, dc_tag_out;
wire loading_ic = status ==`STAT_IC_MISS || status == `STAT_DOUBLE_MISS;
assign ic_tag = ic_addr[29:29-TAG_WIDTH+1];
assign dc_tag = (~loading_ic) ? dc_addr[29:29-TAG_WIDTH+1] : ic_tag;
assign ic_index = ic_addr[29-TAG_WIDTH:OFFSET_WIDTH];
assign dc_index = (~loading_ic) ? dc_addr[29-TAG_WIDTH:OFFSET_WIDTH] : ic_index;
assign ic_offset = ic_addr[OFFSET_WIDTH-1:0];
assign dc_offset =  dc_addr[OFFSET_WIDTH-1:0];
assign ram_addr_ic = {ic_tag,ic_index,counter};
assign ram_addr_dc = {dc_tag,dc_index,counter};
assign ram_addr_dc_wb = {dc_tag_out,dc_index,counter};//write back
assign ram_addr_out = ram_addr_sel[1] ? ram_addr_dc_wb : (ram_addr_sel[0] ? ram_addr_dc : ram_addr_ic);

wire ic_hit, ic_valid, ic_dirty; //ic_dirty is useless
wire dc_hit, dc_valid, dc_dirty; // 6 output of i&d cache


cache_control cctrl (dc_read_in, dc_write_in, ic_offset, dc_offset, dc_byte_w_en_in, 
    ic_hit, ic_valid,/*ic's output*/
    dc_hit, dc_dirty, dc_valid,/*dc's output*/
    status, counter,/*status*/
    ic_enable, ic_word_sel, ic_cmp, ic_write, ic_data_sel, ic_byte_w_en, ic_valid_2ic,/*to ic*/
    dc_enable, dc_word_sel, dc_cmp, dc_write, dc_data_sel, dc_byte_w_en, dc_valid_2dc,/*to dc*/
    ram_addr_sel, ram_en_out, ram_write_out,
    status_next, counter_next
);

assign ic_data2ic = ic_data_sel ? data_ram : dc_data_out; //0:load from dc
assign dc_data2dc = dc_data_sel ? data_ram : data_reg;

cache_2ways ic(ic_enable, ic_index, ic_word_sel, ic_cmp, ic_write, ic_tag, ic_data2ic,
    ic_valid_2ic, ic_byte_w_en, clk, rst, ic_hit, ic_dirty, ic_tag_out, ic_data_out, ic_valid);
    
cache_2ways dc(dc_enable, dc_index, dc_word_sel, dc_cmp, dc_write, dc_tag, dc_data2dc,
    dc_valid_2dc, dc_byte_w_en, clk, rst, dc_hit, dc_dirty, dc_tag_out, dc_data_out, dc_valid);


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
