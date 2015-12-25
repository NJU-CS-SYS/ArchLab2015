`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/15 20:53:43
// Design Name: 
// Module Name: ram_top
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


module ram_top(
    input [11:0] ram_addr,
    input [31:0] data_to_ram,
    input clk,
    input ram_en,
    input ram_write,
    input rst,
    output ram_rdy,
    output [31:0] data_from_ram
);
xilinx_single_port_ram_no_change u_bram_0(
    .addra(ram_addr),
    .dina(data_to_ram),
    .clka(clk),
    .wea(ram_write),
    .ena(ram_en),
    .rsta(1'b0),
    .regcea(1'b1),
    .douta(data_from_ram)
);

reg ready;
reg last_is_disen;
always @ (posedge clk) begin
    if(rst) begin
        ready <= 0;
        last_is_disen <= 1;
    end
    else begin 
        if(~ram_en) begin
            last_is_disen <= 1;
            ready <= 0;
        end
        else begin
            last_is_disen <= 0;
            if(~last_is_disen) begin
                ready = ~ready;
            end
        end
    end
end
assign ram_rdy = ready;
endmodule
