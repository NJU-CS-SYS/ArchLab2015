`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/12/24 23:45:38
// Design Name: 
// Module Name: pipeline_test
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


module pipeline_test();

reg clk,rst;
reg [7:0] intr;
wire [31:0] mem_pc;

pipeline inst_pipeline (clk,rst,intr,mem_pc);
reg [31:0] mem_pc_reg;
initial begin
    mem_pc_reg = 32'd0;
    rst = 1;
    clk = 1;
    intr = 8'd0;
    #20;
    rst = 0;
end

always begin
    #5;
    clk = ~clk;
    if(clk && mem_pc != mem_pc_reg) begin
        $display("pc : 0x%x, %d",mem_pc[31:0],mem_pc[31:2]);
        mem_pc_reg <= mem_pc;
    end
end

endmodule
