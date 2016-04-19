// +FHDR--------------------------------------------------------------------------------------------
// Copyright (c) 2016 Xxx.
// -------------------------------------------------------------------------------------------------
// Filename      : ddr_traffic.v
// Author        : zyy
// Created On    : 2016-04-19 08:10
// Last Modified : 2016-04-19 08:57
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
    input clk_from_ip,
    input rst,

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

reg written;
reg read;
reg writing;
reg reading;
reg [7:0] led;
reg [2:0] status;
reg [29:0] addr_base;
reg [31:0] counter;
reg slow_clk;

wire [255:0] data_from_ram;
wire ui_clk;
wire ram_rdy;

/* combination logic */
reg ram_en;
reg ram_write;

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
    .data_to_ram                ({248'd0, status}               ),

    .ram_rdy                    (ram_rdy                        ),
    .block_out                  (data_from_ram                  ),
    ,ui_clk                     (ui_clk                         ),
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
end

always @ (posedge ui_clk) begin
    if(rst) begin
        addr_base <= 30'd0;
        counter <= 32'd0;
        written<= 0;
        led <= 7'd0;
        slow_clk <= 0;
    end
    else begin
        if(counter == 32'd50000000) begin
            counter <= 0;
            slow_clk <= ~slow_clk;
            written <= 0;
            read <= 0;
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
    status <= status + 1;
    addr_base <= addr_base + 8;
end

endmodule
