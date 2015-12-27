`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/06 16:28:46
// Design Name: 
// Module Name: cache_mem_word
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

// Get the 4 bytes of a word parallelly
module cache_mem_word(clk, rst, write, data_in, addr, data_out, byte_w_en);

parameter ADDR_WIDTH = 8;
parameter MEM_DEPTH = 1<<ADDR_WIDTH;

input clk;
input rst;
input write;
input [31:0] data_in;
input [ADDR_WIDTH-1:0] addr;
input [3:0] byte_w_en;
output [31:0] data_out;

wire[7:0] byte_out[3:0];

cache_mem #(ADDR_WIDTH,MEM_DEPTH,8) byte0(clk,rst,write&&byte_w_en[0],data_in[7:0],addr,byte_out[0]);
cache_mem #(ADDR_WIDTH,MEM_DEPTH,8) byte1(clk,rst,write&&byte_w_en[1],data_in[15:8],addr,byte_out[1]);
cache_mem #(ADDR_WIDTH,MEM_DEPTH,8) byte2(clk,rst,write&&byte_w_en[2],data_in[23:16],addr,byte_out[2]);
cache_mem #(ADDR_WIDTH,MEM_DEPTH,8) byte3(clk,rst,write&&byte_w_en[3],data_in[31:24],addr,byte_out[3]);

assign data_out = {byte_out[3],byte_out[2],byte_out[1],byte_out[0]};

endmodule
