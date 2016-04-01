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
    input rst,
    input ram_en,
    input ram_write,
    input [13:0] ram_addr,
    input [255:0] data_to_ram,

    output clk,
    output ram_rdy,
    output reg [255:0] block_out
);
xilinx_single_port_ram_no_change u_bram_0(
    .addra({{ram_addr[13:3]}, {count[2:0]}} ),
    .dina(data_to_bram),
    .clka(clk),
    .wea(ram_write),
    .ena(ram_en),
    .rsta(1'b0),
    .regcea(1'b1),
    .douta(data_from_bram)
);

reg ready;
reg last_is_disen;
reg [31:0] count;
wire [31:0] data_to_bram = data_to_ram[((count + 1) << 5) - 1 : (count<<5)];
reg [255:0] buffer;

always @ (posedge clk) begin
    if(rst) begin
        ready <= 0;
        last_is_disen <= 1;
        count = 32'd0;
    end
    else begin 
        if(~ram_en) begin
            last_is_disen <= 1;
            ready <= 0;
            count = 32'd0;
        end
        else begin
            last_is_disen <= 0;
            if(~last_is_disen) begin
                count <= count + 1;
                buffer[((count + 1) << 5) - 1 : (count<<5)] <= data_from_bram;
            end
            if(~last_is_disen && count == 32'd8) begin
                ready = ~ready;
            end
        end
    end
end
assign ram_rdy = ready;

endmodule
