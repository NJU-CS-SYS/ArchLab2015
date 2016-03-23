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
    input dmem_read_in, 
    input dmem_write_in,
    input [29:0] dmem_addr,
    input [31:0] data_reg,
    input [3:0] dc_byte_w_en,
    input clk,
    input rst,
    output [31:0] ic_data_out,
    output [31:0] dmem_data_out,
    output mem_stall
);
localparam TIMER_PORT   = 32'h00004000;
localparam KBD_PORT     = 32'h00004010;

wire [31:0] data_from_ram;
wire ram_rdy;
wire ram_en;
wire ram_write;
wire [29:0] ram_addr;
reg dc_read_in, dc_write_in;
wire [31:0] data_from_dc_to_ram;

always @ (*) begin
    dc_read_in = dmem_read_in;
    dc_write_in = dmem_write_in;

    if(dmem_addr == TIMER_PORT[31:2]) begin
        dc_read_in = 0;
        dc_write_in = 0;
    end
    else if(dmem_addr == KBD_PORT[31:2]) begin
        dc_read_in = 0;
        dc_write_in = 0;
    end
end

cache_manage_unit u_cm_0(
    ic_addr,
    data_from_ram,
    dc_read_in,
    dc_write_in,
    dmem_addr,
    data_reg,
    dc_byte_w_en,
    clk,
    rst,
    ram_rdy,
    ic_data_out,
    data_from_dc_to_ram,
    mem_stall,
    ram_en,
    ram_write,
    ram_addr
);

ram_top u_ram_0(
    ram_addr[13:0],
    data_from_dc_to_ram,
    clk,
    ram_en,
    ram_write,
    rst,
    ram_rdy,
    data_from_ram
);

assign dmem_data_out = data_from_dc_to_ram;

endmodule
