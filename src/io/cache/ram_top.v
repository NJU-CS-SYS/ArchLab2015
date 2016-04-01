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
    input [10:0] ram_addr,
    input [255:0] data_to_ram,

    input clk,
    output ram_rdy,
    output [255:0] block_out
);

reg ready;
reg last_is_disen;
reg [31:0] count;
reg [255:0] buffer;
reg [31:0] data_to_bram;
wire [31:0] data_from_bram;

xilinx_single_port_ram_no_change u_bram_0(
    .addra({{ram_addr[10:0]}, {count[2:0]}} ),
    .dina(data_to_bram),
    .clka(clk),
    .wea(ram_write),
    .ena(ram_en),
    .rsta(1'b0),
    .regcea(1'b1),
    .douta(data_from_bram)
);


always @(*) begin
    if(count == 32'd0) begin
        data_to_bram = data_to_ram[(0 + 1)*32 - 1 : 32*0];
    end
    else if(count == 32'd1) begin
        data_to_bram = data_to_ram[(1 + 1)*32 - 1 : 32*1];
    end
    else if(count == 32'd2) begin
        data_to_bram = data_to_ram[(2 + 1)*32 - 1 : 32*2];
    end
    else if(count == 32'd3) begin
        data_to_bram = data_to_ram[(3 + 1)*32 - 1 : 32*3];
    end
    else if(count == 32'd4) begin
        data_to_bram = data_to_ram[(4 + 1)*32 - 1 : 32*4];
    end
    else if(count == 32'd5) begin
        data_to_bram = data_to_ram[(5 + 1)*32 - 1 : 32*5];
    end
    else if(count == 32'd6) begin
        data_to_bram = data_to_ram[(6 + 1)*32 - 1 : 32*6];
    end
    else begin
        data_to_bram = data_to_ram[(7 + 1)*32 - 1 : 32*7];
    end
end

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
                if(count == 32'd0) begin
                    buffer[(0 + 1)*32 - 1 : 32*0] = data_from_bram;
                end
                else if(count == 32'd1) begin
                    buffer[(1 + 1)*32 - 1 : 32*1] = data_from_bram;
                end
                else if(count == 32'd2) begin
                    buffer[(2 + 1)*32 - 1 : 32*2] = data_from_bram;
                end
                else if(count == 32'd3) begin
                    buffer[(3 + 1)*32 - 1 : 32*3] = data_from_bram;
                end
                else if(count == 32'd4) begin
                    buffer[(4 + 1)*32 - 1 : 32*4] = data_from_bram;
                end
                else if(count == 32'd5) begin
                    buffer[(5 + 1)*32 - 1 : 32*5] = data_from_bram;
                end
                else if(count == 32'd6) begin
                    buffer[(6 + 1)*32 - 1 : 32*6] = data_from_bram;
                end
                else begin
                    buffer[(7 + 1)*32 - 1 : 32*7] = data_from_bram;
                end
            end
            if(~last_is_disen && count == 32'd8) begin
                ready = ~ready;
            end
        end
    end
end
assign ram_rdy = ready;
assign block_out = buffer;

endmodule
