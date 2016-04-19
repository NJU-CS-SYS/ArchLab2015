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
    // ddr Inouts
    inout [15:0]                         ddr2_dq,
    inout [1:0]                        ddr2_dqs_n,
    inout [1:0]                        ddr2_dqs_p,

    input rst,
    input [29:0] ic_addr,
    input dmem_read_in, 
    input dmem_write_in,
    input [29:0] dmem_addr,
    input [31:0] data_from_reg,
    input [3:0] dc_byte_w_en,
    input clk_from_ip,

    output ui_clk,
    output [31:0] ic_data_out,
    output [31:0] dmem_data_out,
    output mem_stall,

    // ddr Outputs
    output [12:0]                       ddr2_addr,
    output [2:0]                      ddr2_ba,
    output                                       ddr2_ras_n,
    output                                       ddr2_cas_n,
    output                                       ddr2_we_n,
    output [0:0]                        ddr2_ck_p,
    output [0:0]                        ddr2_ck_n,
    output [0:0]                       ddr2_cke,
    output [0:0]           ddr2_cs_n,
    output [1:0]                        ddr2_dm,
    output [0:0]                       ddr2_odt
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
    .clk             ( ui_clk               ),
    .rst             ( ~rst                 ), // !! make rst seem low active
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

ddr_ctrl ddr_ctrl_0(
    // Inouts
    .ddr2_dq                    (ddr2_dq                        ),
    .ddr2_dqs_n                 (ddr2_dqs_n                     ),
    .ddr2_dqs_p                 (ddr2_dqs_p                     ),

    // original signals
    .clk_from_ip                (clk_from_ip                    ),
    .rst                        (rst                            ),
    .ram_en                     (ram_en                         ),
    .ram_write                  (ram_write                      ),
    .ram_addr                   (ram_addr[32:3]                 ),
    .data_to_ram                (block_from_dc_to_ram           ),

    .ram_rdy                    (ram_rdy                        ),
    .block_out                  (block_from_ram                 ),
    .ui_clk                     (ui_clk                         ),
    // Outputs
    .ddr2_addr                  (ddr2_addr                      ),
    .ddr2_ba                    (ddr2_ba                        ),
    .ddr2_ras_n                 (ddr2_ras_n                     ),
    .ddr2_cas_n                 (ddr2_cas_n                     ),
    .ddr2_we_n                  (ddr2_we_n                      ),
    .ddr2_ck_p                  (ddr2_ck_p                      ),
    .ddr2_ck_n                  (ddr2_ck_n                      ),
    .ddr2_cke                   (ddr2_cke                       ),
    .ddr2_cs_n                  (ddr2_cs_n                      ),
    .ddr2_dm                    (ddr2_dm                        ),
    .ddr2_odt                   (ddr2_odt                       )
);


endmodule
