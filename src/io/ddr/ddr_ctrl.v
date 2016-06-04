// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : ddr_ctrl.v
// Author        : zyy
// Created On    : 2016-04-18 15:39
// Last Modified : 2016-05-29 19:40
// -------------------------------------------------------------------------------------------------
// Svn Info:
//   $Revision::                                                                                $:
//   $Author::                                                                                  $:
//   $Date::                                                                                    $:
//   $HeadURL::                                                                                 $:
// -------------------------------------------------------------------------------------------------
// Description:
// set signals for user interface provided by MIG, according to input 
// control signal and addr
//
// -FHDR--------------------------------------------------------------------------------------------

module ddr_ctrl(
    // ddr Inouts
    inout [15:0] ddr2_dq,
    inout [1:0]  ddr2_dqs_n,
    inout [1:0]  ddr2_dqs_p,


    // ddr Outputs
    output [12:0] ddr2_addr,
    output [2:0]  ddr2_ba,
    output        ddr2_ras_n,
    output        ddr2_cas_n,
    output        ddr2_we_n,
    output [0:0]  ddr2_ck_p,
    output [0:0]  ddr2_ck_n,
    output [0:0]  ddr2_cke,
    output [0:0]  ddr2_cs_n,
    output [1:0]  ddr2_dm,
    output [0:0]  ddr2_odt,

    // CPU input and output
    input clk_from_ip,
    input rst,
    input ram_en,
    input ram_write,
    input [29:0] ram_addr, // 4 byte aligned
    input [255:0] data_to_ram,

    output ram_rdy,
    output [255:0] block_out,
    output ui_clk,

    // debug
    output go,
    output [127:0] data_to_mig,
    output reg [255:0] buffer,
    output [26:0] addr_to_mig,
    output [127:0] data_from_mig,

    output mig_rdy,
    output mig_wdf_rdy,
    output init_calib_complete,
    output mig_data_end,
    output mig_data_valid,
    output reg reading,
    output reg writing
);

reg [29:0] last_addr;
reg [1:0] last_op; // 11 for NOP, 00 for read, 01 for write

wire [1:0] cur_op;
wire busy;
wire buf_w_en_high;
wire [2:0] cmd_to_mig;

assign cur_op[1] = !ram_en;
assign cur_op[0] = ram_write;
assign busy = ram_en & ((ram_addr != last_addr) || (cur_op != last_op));
// need to work
assign buf_w_en_high = ram_addr[2]; // highest bit of block selector
// assign buf_w_en_low = !ram_addr[4:4];
assign addr_to_mig = {ram_addr[24:0], 2'b0}; // highest 5 bits was ignored
assign cmd_to_mig = ram_write ? 3'b000 : 3'b001;
assign data_to_mig = buf_w_en_high ? data_to_ram[255:128] : data_to_ram[127:0];
assign go = mig_rdy & mig_wdf_rdy & init_calib_complete; // able to go

`define NOP 2'b11
`define OP_READ 2'b00
`define OP_WRITE 2'b01

assign ddr2_cs_n = 0;

mig_7series_0 m70 (
    // Inouts
    .ddr2_dq             ( ddr2_dq             ),
    .ddr2_dqs_n          ( ddr2_dqs_n          ),
    .ddr2_dqs_p          ( ddr2_dqs_p          ),
   // Outputs
    .ddr2_addr           ( ddr2_addr           ),
    .ddr2_ba             ( ddr2_ba             ),
    .ddr2_ras_n          ( ddr2_ras_n          ),
    .ddr2_cas_n          ( ddr2_cas_n          ),
    .ddr2_we_n           ( ddr2_we_n           ),
    .ddr2_ck_p           ( ddr2_ck_p           ),
    .ddr2_ck_n           ( ddr2_ck_n           ),
    .ddr2_cke            ( ddr2_cke            ),
    //.ddr2_cs_n                  (ddr2_cs_n                      ),
    .ddr2_dm             ( ddr2_dm             ),
    .ddr2_odt            ( ddr2_odt            ),

    .sys_clk_i           ( clk_from_ip         ),
    .clk_ref_i           ( clk_from_ip         ),

    .app_addr            ( addr_to_mig         ),
    .app_cmd             ( cmd_to_mig          ),
    .app_en              ( writing | reading   ),
    .app_wdf_data        ( data_to_mig         ),
    .app_wdf_end         ( writing             ),
    .app_wdf_mask        ( 16'h0               ),
    .app_wdf_wren        ( writing             ),
    .app_rd_data         ( data_from_mig       ),
    .app_rd_data_end     ( mig_data_end        ),
    .app_rd_data_valid   ( mig_data_valid      ),
    .app_rdy             ( mig_rdy             ),
    .app_wdf_rdy         ( mig_wdf_rdy         ),

    .app_sr_req          ( 0                   ), // nosene
    .app_ref_req         ( 0                   ), // nosene
    .app_zq_req          ( 0                   ), // nosene
    .app_sr_active       (                     ), // nosene
    .app_ref_ack         (                     ), // nosene
    .app_zq_ack          (                     ), // nosene

    .ui_clk              ( ui_clk              ),
    .ui_clk_sync_rst     (                     ), // nosene
    .init_calib_complete ( init_calib_complete ),
    .sys_rst             ( rst                 )
);

// control signal generation

always @(negedge ui_clk) begin
    if(~rst) begin
        last_op <= `NOP;
        last_addr <= 30'h3fffffff;
        writing <= 0;
        reading <= 0;
    end
    else begin
        if(writing) begin
            if(go) begin
                last_addr <= ram_addr;
                last_op <= cur_op;
                writing <= 0;
            end
        end
        else if (reading) begin
            if(go) begin
                if(mig_data_valid & ram_en) begin
                    if(buf_w_en_high) buffer[255:128] <= data_from_mig;
                    else buffer[127:0] <= data_from_mig;
                    last_addr <= ram_addr;
                    last_op <= cur_op;
                    reading <= 0;
                end
            end
        end
        else if (busy) begin
            if(ram_write) begin
                writing <= 1;
            end
            else begin
                reading <= 1;
            end
        end
    end
end

assign ram_rdy = (~busy) & (~reading) & (~ writing);
// assign block_out = buf_w_en_high ? buffer[255:128] : buffer[127:0];
assign block_out = buffer;

endmodule
