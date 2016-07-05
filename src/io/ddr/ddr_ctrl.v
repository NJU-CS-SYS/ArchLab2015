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
    input clk_ci,
    input rst,
    input ram_en,
    input ram_write,
    input [29:0] ram_addr, // 4 byte aligned
    input [255:0] data_to_ram,

    output ram_rdy,
    output ui_clk,

    // debug
    output go,
    output [127:0] data_to_mig,
    output [255:0] buffer,
    output [255:0] wb_buffer,
    output [26:0] addr_to_mig,
    output [127:0] data_from_mig,

    output mig_rdy,
    output mig_wdf_rdy,
    output init_calib_complete,
    output mig_data_end,
    output mig_data_valid,
    output app_en,
    output app_wdf_wren,
    output [3:0] ddr_ctrl_status
);

wire [2:0] cmd_to_mig;
reg [2:0] ddr_ctrl_status_next;
wire app_wdf_end;
assign ddr2_cs_n = 0;
assign wb_buffer = 0;
assign go = 0;

DDRControlModule DDRControlModule(
    .clk(ui_clk),
    .reset(~rst),
    .io_init_calib_complete(init_calib_complete),
    .io_mig_data_valid(mig_data_valid),
    .io_mig_rdy(mig_rdy),
    .io_mig_wdf_rdy(mig_wdf_rdy),
    .io_data_from_mig(data_from_mig),
    .io_ram_en(ram_en),
    .io_ram_write(ram_write),
    .io_ram_addr(ram_addr),
    .io_data_to_ram(data_to_ram),
    .io_cmd_to_mig(cmd_to_mig),
    .io_app_en(app_en),
    .io_ram_rdy(ram_rdy),
    .io_app_wdf_wren(app_wdf_wren),
    .io_app_wdf_end(app_wdf_end),
    .io_addr_to_mig(addr_to_mig),
    .io_data_to_mig(data_to_mig),
    .io_data_to_cpu(buffer),
    .io_state_to_cpu(ddr_ctrl_status)
);

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
    .app_en              ( app_en              ),
    .app_wdf_data        ( data_to_mig         ),
    .app_wdf_end         ( app_wdf_end         ),
    .app_wdf_mask        ( 16'h0               ),
    .app_wdf_wren        ( app_wdf_wren        ),
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

endmodule
