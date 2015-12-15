`timescale 1ns / 1ps

/**
 * @brief PC 模块
 * @author whz
 */

`define PC_WIDTH 32
`define PC_BUS (`PC_WIDTH - 1):0

module PC(
    input clk,
    input reset,
    input stall,
    input [`PC_BUS] pc_in,
    output reg [`PC_BUS] pc_out
    );

    always @(negedge clk or posedge reset) begin
        if (reset) pc_out <= `PC_WIDTH'd0;
        else if (stall) pc_out <= pc_out;
        else pc_out <= pc_in;
    end

endmodule

`undef PC_WIDTH
`undef PC_BUS
