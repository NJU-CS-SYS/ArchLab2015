// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : ddr_ctrl.v
// Author        : zyy
// Created On    : 2016-04-18 15:39
// Last Modified : 2016-04-18 17:19
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
    input clk_from_ip,
    input rst,
    input ram_en,
    input ram_write,
    input [29:0] ram_addr, // 4 byte aligned
    input [255:0] data_to_ram,

    output ram_rdy,
    output [255:0] block_out
);

reg [255:0] buffer;
reg [29:0] last_addr;
reg [1:0] last_op; // 11 for NOP, 00 for read, 01 for write

wire [1:0] cur_op;
wire working;
wire buf_w_en_high;
wire buf_w_en_low;
wire [26:0] addr_to_mig;
wire [2:0] cmd_to_mig;
wire [127:0] data_to_mig;
wire [127:0] data_from_mig;
wire mig_rdy;
wire mig_data_valid;
wire mig_wdf_rdy;
wire init_calib_complete;
wire go;

assign cur_op[1] = !ram_en;
assign cur_op[0] = ram_write;
assign working = ram_en & ((ram_addr != last_addr) || (cur_op != last_op)); // need to work
assign buf_w_en_high = ram_addr[4:4];
assign buf_w_en_low = !ram_addr[4:4]; // highest bit of block selector
assign addr_to_mig = {ram_addr[24:0], 2'b0}; // highest 5 bits was ignored
assign cmd_to_mig = ram_write ? 3'b000 : 3'b001; 
assign data_to_mig = buf_w_en_high ? data_to_ram[255:128] : data_to_ram[127:0];
assign go = mig_rdy & mig_wdf_rdy & init_calib_complete; // able to go

`define NOP 2'b11
`define OP_READ 2'b00
`define OP_WRITE 2'b01

mig_7series_0 m70(/*autoinst*/
    
    .sys_clk_i                  (clk_from_ip                    ),  

    .app_addr                   (addr_to_mig                    ),
    .app_cmd                    (cmd_to_mig                     ),
    .app_en                     (working                        ),  
    .app_wdf_data               (data_to_mig                    ),  
    .app_wdf_end                (go & working & ram_write       ),
    .app_wdf_mask               (16'h0                          ),  
    .app_wdf_wren               (go & working & ram_write       ),  
    .app_rd_data                (data_from_mig                  ),
    .app_rd_data_end            (                               ),  // nosense
    .app_rd_data_valid          (mig_data_valid                 ),  
    .app_rdy                    (mig_rdy                        ),  
    .app_wdf_rdy                (mig_wdf_rdy                    ),  
    .app_sr_req                 (0                              ),  // nosene    
    .app_ref_req                (0                              ),  // nosene    
    .app_zq_req                 (0                              ),  // nosene    
    .app_sr_active              (                               ),  // nosene
    .app_ref_ack                (                               ),  // nosene 
    .app_zq_ack                 (                               ),  // nosene  
    .ui_clk                     (ui_clk                         ),  
    .ui_clk_sync_rst            (                               ),  // nosene    
    .init_calib_complete        (init_calib_complete            ),  
    .sys_rst                    (rst                            )   
);

// control signal generation
always @(*) begin
end

always @(ui_clk) begin
    if(rst) begin
        last_op = NOP;
        last_addr = 30'h3fffffff;
    end
    else begin
        if(
    end
end

endmodule

