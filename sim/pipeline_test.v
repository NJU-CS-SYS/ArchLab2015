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

pipeline inst_pipeline (clk,rst,intr);

initial begin
    rst = 1;
    clk = 1;
    intr = 8'd0;
    #20;
    rst = 0;
end

always begin
    #5;
    clk = ~clk;
end

endmodule
