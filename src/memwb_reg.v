`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Nanjing University CS 2013
// Engineer: Jiyuan Liu
// 
// Create Date: 2015/12/08 18:44:14
// Design Name: 
// Module Name: memwb_reg
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


module memwb_reg(
    input clk,
    input reset,
    input mem_stall,
    input exmem_mem_r,
    input exmem_reg_w,
    input [3:0] reg_byte_w_en_in,
    input [4:0] exmem_rd_addr,
    input [31:0] mem_data,
    input [31:0] ex_data,
    input [4:0] exmem_cp0_dst_addr,
    input exmem_cp0_w_en,
    output reg memwb_mem_r,
    output reg memwb_reg_w,
    output reg [3:0] reg_byte_w_en_out,
    output reg [4:0] memwb_rd_addr,
    output reg [31:0] memwb_memdata,
    output reg [31:0] memwb_exdata,
    output reg [4:0] memwb_cp0_dst_addr,
    output reg memwb_cp0_w_en
    );

    always@(negedge clk) begin
        if (reset) begin
            memwb_mem_r         <= 0;
            memwb_reg_w         <= 0;
            reg_byte_w_en_out   <= 0;
            memwb_rd_addr       <= 0;
            memwb_memdata       <= 0;
            memwb_exdata        <= 0;
            memwb_cp0_dst_addr  <= 0;
            memwb_cp0_w_en      <= 0;
        end
        else if ( !mem_stall ) begin
            memwb_mem_r         <= exmem_mem_r;
            memwb_reg_w         <= exmem_reg_w;
            reg_byte_w_en_out   <= reg_byte_w_en_in;
            memwb_rd_addr       <= exmem_rd_addr;
            memwb_memdata       <= mem_data;
            memwb_exdata        <= ex_data;
            memwb_cp0_dst_addr  <= exmem_cp0_dst_addr;
            memwb_cp0_w_en      <= exmem_cp0_w_en;
        end
    end
endmodule
