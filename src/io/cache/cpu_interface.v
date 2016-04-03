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
    input [31:0] data_from_reg,
    input [3:0] dc_byte_w_en,
    input clk,
    input rst,
    output [31:0] ic_data_out,
    output [31:0] dmem_data_out,
    output mem_stall
);
localparam TIMER_PORT   = 32'h00004000;
localparam KBD_PORT     = 32'h00004010;

wire [255:0] block_from_ram;
wire ram_rdy;
wire ram_en;
wire ram_write;
wire [29:0] ram_addr;
wire [255:0] block_from_dc_to_ram;

reg dc_read_in, dc_write_in;

always @ (*) begin
    dc_read_in = dmem_read_in;
    dc_write_in = dmem_write_in;
/*
    if(dmem_addr == TIMER_PORT[31:2]) begin
        dc_read_in = 0;
        dc_write_in = 0;
    end
    else if(dmem_addr == KBD_PORT[31:2]) begin
        dc_read_in = 0;
        dc_write_in = 0;
    end
    */
end

cache_manage_unit u_cm_0 (
    .clk             ( clk                  ),
    .rst             ( rst                  ),
    .dc_read_in      ( dc_read_in           ),
    .dc_write_in     ( dc_write_in          ),
    .dc_byte_w_en_in ( dc_byte_w_en         ),
    .ic_addr         ( ic_addr              ),
    .dc_addr         ( dmem_addr            ),
    .data_from_reg   ( data_from_reg        ),

    .ram_ready       ( ram_rdy              ),
    .block_from_ram  ( block_from_ram       ),

    .mem_stall       ( mem_stall            ),
    .dc_data_out     ( dmem_data_out        ),
    .ic_data_out     ( ic_data_out          ),

    .ram_en_out      ( ram_en               ),
    .ram_write_out   ( ram_write            ),
    .ram_addr_out    ( ram_addr             ),
    .dc_data_wb      ( block_from_dc_to_ram )
);

ram_top u_ram_0(
    rst,
    ram_en,
    ram_write,
    ram_addr[13:3],
    block_from_dc_to_ram,

    clk,
    ram_rdy,
    block_from_ram
);


endmodule
