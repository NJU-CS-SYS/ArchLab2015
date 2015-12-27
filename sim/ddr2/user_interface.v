`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: YaoYang Zhou
// 
// Create Date: 2015/12/15 10:28:45
// Design Name: 
// Module Name: user_interface
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
// TODO:
// connect MIG and ddr2 in this module
//////////////////////////////////////////////////////////////////////////////////


module user_interface(
    input sys_clk_i,
    input sys_rst,
    input [26:0] app_addr,
    input [2:0] app_cmd,
    input app_en,

    input [127:0] app_wdf_data,
    input app_wdf_end,
    input [15:0] app_wdf_mask,
    input app_wdf_wren,

    output [127:0] app_rd_data,
    output app_rd_data_end,
    output app_rd_data_valid,

    output app_rdy,
    output app_wdf_rdy,

    input app_ref_req,
    output app_ref_ack,

    input app_zq_req,
    output app_zq_ack,

    output ui_clk,
    output ui_clk_sync_rst,
    output init_calib_complete
);

//wire def:
//for mem:
wire [15:0] ddr2_dq;
wire [1:0] ddr2_dqs_n;
wire [1:0] ddr2_dqs_p;
wire [12:0] ddr2_addr;
wire [2:0] ddr2_ba;
wire ddr2_ras_n;
wire ddr2_cas_n;
wire ddr2_we_n;
wire ddr2_ck_p;
wire ddr2_ck_n;
wire ddr2_cke;
wire ddr2_cs_n;
wire [1:0] ddr2_dm;
wire ddr2_odt;
//for ui

/*
*instantiate mig here
*/
mig_7series_0 u_mig_7series_0(
    //system clock
    .sys_clk_i(sys_clk_i),
    //Memory interface ports
    .ddr2_dq(ddr2_dq),
    .ddr2_dqs_n(ddr2_dqs_n),
    .ddr2_dqs_p(ddr2_dqs_p),
    .ddr2_addr(ddr2_addr),
    .ddr2_ba(ddr2_ba),
    .ddr2_ras_n(ddr2_ras_n),
    .ddr2_cas_n(ddr2_cas_n),
    .ddr2_we_n(ddr2_we_n),
    .ddr2_ck_p(ddr2_ck_p),
    .ddr2_ck_n(ddr2_ck_n),
    .ddr2_cke(ddr2_cke),
    .ddr2_cs_n(ddr2_cs_n),
    .ddr2_dm(ddr2_dm),
    .ddr2_odt(ddr2_odt),
    //User interface ports
    .app_addr(app_addr),
    .app_cmd(app_cmd),
    .app_en(app_en),
    .app_wdf_data(app_wdf_data),
    .app_wdf_end(app_wdf_end),
    .app_wdf_mask(app_wdf_mask),
    .app_wdf_wren(app_wdf_wren),
    .app_rd_data(app_rd_data),
    .app_rd_data_end(app_rd_data_end),
    .app_rd_data_valid(app_rd_data_valid),
    .app_rdy(app_rdy),
    .app_wdf_rdy(app_wdf_rdy),
    .app_sr_req(1'b0),
    .app_ref_req(app_ref_req),
    .app_zq_req(app_zq_req),
    .app_sr_active(),
    .app_ref_ack(app_ref_ack),
    .app_zq_ack(app_zq_ack),

    .ui_clk(ui_clk),
    .ui_clk_sync_rst(ui_clk_sync_rst),
    .init_calib_complete(init_calib_complete),
    .sys_rst(sys_rst)
);

ddr2 u_ddr2_0(
    .ck(ddr2_ck_p),
    .ck_n(ddr2_ck_n),
    .cke(ddr2_cke),
    .cs_n(ddr2_cs_n),
    .ras_n(ddr2_ras_n),
    .cas_n(ddr2_cas_n),
    .we_n(ddr2_we_n),
    .dm_rdqs(ddr2_dm),//data_mask
    .ba(ddr2_ba),
    .addr(ddr2_addr),
    .dq(ddr2_dq),
    .dqs(ddr2_dqs_p),
    .dqs_n(ddr2_dqs_n),
    .rdqs_n(),
    .odt(ddr2_odt)
);


endmodule
