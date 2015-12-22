`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/15 23:46:51
// Design Name: 
// Module Name: ci_test
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
// test interfaces for cpu
// 
//////////////////////////////////////////////////////////////////////////////////


module ci_test(
);

parameter PERIOD=8;

reg [29:0] ic_addr,dc_addr;
reg dc_read,dc_write;
reg [31:0] data_reg;
reg [3:0] dc_byte_w_en;
reg clk,rst;
wire [31:0] ic_data;
wire [31:0] dc_data;
wire mem_stall;

cpu_interface u_ci_0(
    ic_addr,
    dc_read,
    dc_write,
    dc_addr,
    data_reg,
    dc_byte_w_en,
    clk,
    rst,
    ic_data,
    dc_data,
    mem_stall
);

always begin
    #(PERIOD/2);
    clk = ~clk;
end

initial begin
    rst = 1;
    clk = 0;
    dc_read = 0;
    dc_write = 0;
    dc_byte_w_en = 4'b0000;
    ic_addr = 30'h00000010;
    #14;
    rst = 0;
    dc_write = 1;
    dc_byte_w_en = 4'b1111;
    dc_addr = 30'h00000040;
    data_reg = 32'h00000040;
    #PERIOD;
    #278;
    dc_write = 0;
    dc_read = 1;
    dc_addr = 30'h00000040;
    ic_addr = 30'h00000011;
    
    #(PERIOD*16);
    dc_write = 1;
    dc_read = 0;
    dc_addr = 30'h00000140;
    data_reg = 32'h00000140;
    #(PERIOD*40);
    dc_write = 0;
    dc_read = 1;
    dc_addr = 30'h00000140;
    
    #(PERIOD*16);
    ic_addr = 30'h00000140;
    dc_write = 1;
    dc_read = 0;
    dc_addr = 30'h00000340;
    data_reg = 32'h00000340;
    #(PERIOD*40);
    dc_write = 0;
    dc_read = 1;
    dc_addr = 30'h00000340;

    #(PERIOD*16);
    dc_write = 0;
    dc_read = 1;
    dc_addr = 30'h00000040;

    #(PERIOD*16);
    dc_write = 0;
    dc_read = 1;
    dc_addr = 30'h00000140;

    #(PERIOD*16);
    dc_write = 0;
    dc_read = 1;
    dc_addr = 30'h00000340;

end

endmodule
