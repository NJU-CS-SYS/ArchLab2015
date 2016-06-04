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

    output reg ram_rdy,
    output ui_clk,

    // debug
    output go,
    output reg [127:0] data_to_mig,
    output reg [255:0] buffer,
    output reg [26:0] addr_to_mig,
    output [127:0] data_from_mig,

    output mig_rdy,
    output mig_wdf_rdy,
    output init_calib_complete,
    output mig_data_end,
    output mig_data_valid,
    output reg app_en,
    output reg app_wdf_wren,
    output reg [2:0] ddr_ctrl_status
);

reg [2:0] cmd_to_mig;
assign go = mig_rdy & mig_wdf_rdy & init_calib_complete; // able to go


`define DDR_STAT_NORM 3'b000
`define DDR_STAT_W1 3'b001
`define DDR_STAT_W2 3'b010
`define DDR_STAT_R1 3'b011
`define DDR_STAT_R2 3'b100

reg [2:0] ddr_ctrl_status_next;
reg [2:0] ddr_ctrl_status_last;
reg app_wdf_end;

always @ (*) begin
    app_en = 1;
    app_wdf_end = 1;
    app_wdf_wren = 0;
    addr_to_mig = {ram_addr[24:3], 5'b00000};
    case(ddr_ctrl_status)
        `DDR_STAT_R1:
        begin
            data_to_mig = data_to_ram[127:0];
            cmd_to_mig = 3'b001;
            ddr_ctrl_status_next = `DDR_STAT_R2;
            ram_rdy = 0;
        end

        `DDR_STAT_R2:
        begin
            addr_to_mig = {ram_addr[24:3], 5'b10000};
            data_to_mig = data_to_ram[127:0];
            cmd_to_mig = 3'b001;
            ddr_ctrl_status_next = `DDR_STAT_NORM;
            ram_rdy = 0;
        end

        `DDR_STAT_W1:
        begin
            app_wdf_wren = 1;
            cmd_to_mig = 3'b000;
            data_to_mig = data_to_ram[127:0];
            ddr_ctrl_status_next = `DDR_STAT_W2;
            ram_rdy = 0;
        end

        `DDR_STAT_W2:
        begin
            addr_to_mig = {ram_addr[24:3], 5'b10000};
            app_wdf_wren = 1;
            cmd_to_mig = 3'b000;
            data_to_mig = data_to_ram[255:128];
            ddr_ctrl_status_next = `DDR_STAT_NORM;
            ram_rdy = 0;
        end

        default:
        begin
            app_en = 0;
            cmd_to_mig = 3'b001;
            data_to_mig = data_to_ram[127:0];

            if(ram_en && (ddr_ctrl_status_last == `DDR_STAT_NORM)) begin
                ram_rdy = 0;
                if(ram_write) begin
                    ddr_ctrl_status_next = `DDR_STAT_W1;
                end
                else begin
                    ddr_ctrl_status_next = `DDR_STAT_R1;
                end
            end
            else begin
                ddr_ctrl_status_next = `DDR_STAT_NORM;
                ram_rdy = 1;
            end
        end
    endcase
end


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

initial begin
    ddr_ctrl_status = `DDR_STAT_NORM;
    ddr_ctrl_status_last = `DDR_STAT_NORM;
end

always @(negedge ui_clk) begin
    if(~rst) begin
        ddr_ctrl_status = `DDR_STAT_NORM;
    end
    else begin
        if(go & ram_en) begin
            case (ddr_ctrl_status)
                `DDR_STAT_R1:
                begin
                    if(mig_data_valid) begin
                        buffer[127:0] <= data_from_mig;
                        ddr_ctrl_status_last <= ddr_ctrl_status;
                        ddr_ctrl_status <= ddr_ctrl_status_next;
                    end
                end

                `DDR_STAT_R2:
                begin
                    if(mig_data_valid) begin
                        buffer[255:128] <= data_from_mig;
                        ddr_ctrl_status_last <= ddr_ctrl_status;
                        ddr_ctrl_status <= ddr_ctrl_status_next;
                    end
                end

                default:
                begin
                    ddr_ctrl_status_last <= ddr_ctrl_status;
                    ddr_ctrl_status <= ddr_ctrl_status_next;
                end
            endcase
        end
    end
end

endmodule
