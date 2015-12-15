`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/08 15:12:30
// Design Name: 
// Module Name: cache_manage_test
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


module cache_manage_test();

reg [29:0] ic_addr, dc_addr;
reg [31:0] data_ram, data_reg;
reg dc_write, dc_read, clk, rst;
reg ram_ready;
reg [3:0] dc_byte_w_en;

wire [31:0] dc_data,ic_data;
wire [29:0] ram_addr;
wire mem_stall, ram_en, ram_write;

cache_manage_unit cmu(ic_addr, data_ram, dc_read, dc_write, dc_addr, data_reg,
    dc_byte_w_en, clk, rst, ram_ready,
    ic_data, dc_data, mem_stall,
    ram_en, ram_write, ram_addr);

initial begin
    clk = 0;
    rst = 1;#10;
    rst = 0;#2;

    ic_addr = 30'h00000000;
    dc_addr = 30'h00000000;
    dc_write = 0;
    dc_read = 0;
    ram_ready = 0;
    dc_byte_w_en = 4'b0000;
    #4;
    data_ram = 32'hf0f0f0f0;
    ram_ready = 1;
    #7;
    #10;
    data_ram = 32'hffff000;
    ram_ready = 1;
    #6;
    #10;
    data_ram = 32'hff00ff0;
    ram_ready = 1;
    #32;
    ic_addr = 30'h08000000;
    ram_ready = 0;
    #10;
    data_ram = 32'h55555555;
    ram_ready = 1;


end
always begin
    clk = ~clk;#4;
end


endmodule
