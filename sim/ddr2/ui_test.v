`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/15 15:16:47
// Design Name: 
// Module Name: ui_test
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


module ui_test();

parameter PERIOD = 2500;

//vars for user interface instantiate
reg sys_clk_i,sys_rst;

reg [26:0] app_addr;
reg [2:0] app_cmd;
reg app_en;

reg [127:0] app_wdf_data;
reg app_wdf_end;
reg [15:0] app_wdf_mask;
reg app_wdf_wren;

wire [127:0] app_rd_data;
wire app_rd_data_end;
wire app_rd_data_valid;

wire app_rdy;
wire app_wdf_rdy;

reg app_ref_req;
wire app_ref_ack;
reg app_zq_req;
wire app_zq_ack;

wire ui_clk,ui_rst;
wire init_calib_complete;

user_interface u_ui_0(
    sys_clk_i,
    sys_rst,
    app_addr,
    app_cmd,
    app_en,

    app_wdf_data,
    app_wdf_end,
    app_wdf_mask,
    app_wdf_wren,

    app_rd_data,
    app_rd_data_end,
    app_rd_data_valid,

    app_rdy,
    app_wdf_rdy,
    app_ref_req,
    app_ref_ack,
    app_zq_req,
    app_zq_ack,

    ui_clk,
    ui_rst,
    init_calib_complete
);

//vars for test
reg writen,wr_req;

always begin
    #PERIOD;
    sys_clk_i = ~sys_clk_i;
end

always @(posedge ui_clk) begin
    if(init_calib_complete) begin
        if(~wr_req && app_wdf_rdy) begin
            app_en <= 1;
            app_addr <= 27'h000ff00;
            app_cmd <= 3'b000;
            app_wdf_data <= 128'hf0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0;
            app_wdf_mask <= 16'd0;
            app_wdf_wren <= #(PERIOD*6) 1;
            app_wdf_end <= #(PERIOD*6) 1;
            wr_req <= #(PERIOD*10) 1;
        end
        else begin
            if(wr_req && app_rdy)begin
                if(~writen) begin
                    if(app_wdf_rdy) begin
                        writen <= 1;
                    end
                end
                else begin
                    app_cmd <= 3'b001;
                end
            end
        end
    end
end

initial begin
    sys_rst = 0;
    sys_clk_i = 0;
    app_addr = 27'd0;
    app_cmd = 3'b001;
    app_en = 0;
    app_ref_req = 0;
    app_zq_req = 0;
    wr_req = 0;
    writen = 0;
    #(PERIOD*4);
    sys_rst = 1;
end


endmodule
