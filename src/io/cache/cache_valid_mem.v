`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/06 16:02:11
// Design Name: 
// Module Name: cache_mem
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
// when we flush cache, only valid bit are supposed to be invalidated,
// in the previous implemetation, I zeroed all the cache mem, which might 
// cause high temperature after implementation
// 
//////////////////////////////////////////////////////////////////////////////////


module cache_vmem(clk, rst, write, data_in, addr, data_out);
parameter ADDR_WIDTH = 8;
parameter MEM_DEPTH = 1<<ADDR_WIDTH;
parameter DATA_WIDTH = 8;

input clk;
input rst;
input write;  // write enable
input [DATA_WIDTH-1:0] data_in;
input [ADDR_WIDTH-1:0] addr;
output [DATA_WIDTH-1:0] data_out;

reg [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0];
reg [ADDR_WIDTH-1+1:0] i;

//assign data_out = (write | rst) ? 32'b0 : mem[addr];
assign data_out = mem[addr];

always @(posedge clk) begin
    if(rst) begin
        for(i=0;i<MEM_DEPTH;i=i+1) begin
            mem[i] <= 0;
        end
    end
    if(!rst && write) begin
        mem[addr] <= data_in;
    end
end

endmodule
