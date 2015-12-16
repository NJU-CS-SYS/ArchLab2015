`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/15 21:16:02
// Design Name: 
// Module Name: cpu_interface
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


module cpu_interface(
    input [29:0] ic_addr,
    input dc_read_in,
    input dc_write_in,
    input [29:0] dc_addr,
    input [31:0] data_reg,
    input [3:0] dc_byte_w_en,
    input clk,
    input rst,
    output [31:0] ic_data_out,
    output [31:0] dc_data_out,
    output mem_stall
);

wire [31:0] data_from_ram;
wire ram_rdy;
wire ram_en;
wire ram_write;
wire [29:0] ram_addr;

cache_manage_unit u_cm_0(
    ic_addr,
    data_from_ram,
    dc_read_in,
    dc_write_in,
    dc_addr,
    data_reg,
    dc_byte_w_en,
    clk,
    rst,
    ram_rdy,
    ic_data_out,
    dc_data_out,
    mem_stall,
    ram_en,
    ram_write,
    ram_addr
);

ram_top u_ram_0(
    ram_addr[8:0],
    dc_data_out,
    clk,
    ram_en,
    ram_write,
    rst,
    ram_rdy,
    data_from_ram
);












endmodule
