// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : ddr_traffic.v
// Author        : zyy
// Created On    : 2016-04-19 08:10
// Last Modified : 2016-04-19 14:16
// -------------------------------------------------------------------------------------------------
// Svn Info:
//   $Revision::                                                                                $:
//   $Author::                                                                                  $:
//   $Date::                                                                                    $:
//   $HeadURL::                                                                                 $:
// -------------------------------------------------------------------------------------------------
// Description:
//
//
// -FHDR--------------------------------------------------------------------------------------------

module ddr_traffic(
    // ddr Inouts
    inout [15:0]                         ddr2_dq,
    inout [1:0]                        ddr2_dqs_n,
    inout [1:0]                        ddr2_dqs_p,

    // CPU input and output
    input clk_from_e3,
    input rst,

    output reg [7:0] led,

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

reg writing;
reg reading;
reg [2:0] status;
reg [29:0] addr_base;
reg [31:0] counter;
reg slow_clk;

wire [255:0] data_from_ram;
wire ui_clk;
wire ram_rdy;
wire clk_from_ip;

/* combination logic */
reg ram_en;
reg ram_write;
reg [7:0] data_to_ram;

ddr_ctrl ddr0(
    // Inouts
    .ddr2_dq                    (ddr2_dq                        ),
    .ddr2_dqs_n                 (ddr2_dqs_n                     ),
    .ddr2_dqs_p                 (ddr2_dqs_p                     ),

    // others
    .clk_from_ip                (clk_from_ip                    ),
    .rst                        (rst                            ),
    .ram_en                     (ram_en                         ),
    .ram_write                  (ram_write                      ),
    .ram_addr                   (addr_base + status             ),
    .data_to_ram                ({248'd0, data_to_ram}          ),

    .ram_rdy                    (ram_rdy                        ),
    .block_out                  (data_from_ram                  ),
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

clk_wiz_0 clkw0(
    .clk_in1(clk_from_e3),
    .clk_out1(clk_from_ip),
    .resetn(rst),
    .locked()
);

initial begin
    slow_clk <= 0;
    addr_base <= 30'd0;
    status <= 3'd0;
end

always @ (*) begin
    if(writing) begin
        ram_en = 1;
        ram_write = 1;
    end
    else if(reading) begin
        ram_en = 1;
        ram_write = 0;
    end
    else begin
        ram_en = 0;
        ram_write = 0;
    end
    case(status)
        3'd0:
            data_to_ram = 8'b00000000;
        3'd1:
            data_to_ram = 8'b00000001;
        3'd2:
            data_to_ram = 8'b00000010;
        3'd3:
            data_to_ram = 8'b00000100;
        3'd4:
            data_to_ram = 8'b00001000;
        3'd5:
            data_to_ram = 8'b00010000;
        3'd6:
            data_to_ram = 8'b00100000;
        3'd7:
            data_to_ram = 8'b01000000;
    endcase
end

always @ (posedge ui_clk) begin
    if(~rst) begin
        led <= 8'd0;
        counter <= 32'd0;
    end
    else begin
        if(counter == 32'd50000000) begin
            counter <= 0;
            slow_clk <= ~slow_clk;
            writing <= 1;
            reading <= 0;
        end
        else begin
            counter <= counter + 1;
            if(writing & ram_rdy) begin
                writing <= 0;
                reading <= 1;
            end
            if(reading & ram_rdy) begin
                led <= data_from_ram[7:0];
                reading <= 0;
            end
        end
    end
end

always @ (posedge slow_clk) begin
    if(~rst) begin
        addr_base <= 30'd0;
    end
    else begin
        status <= status + 1;
        addr_base <= addr_base + 32;
    end
end

endmodule
