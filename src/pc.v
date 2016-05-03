`timescale 1ns / 1ps

/**
 * @brief PC 模块
 * @author whz
 */

`include "common.vh"

module PC(
    input clk,
    input reset,
    input stall,
    input [`PC_BUS] pc_in,
    output reg [`PC_BUS] pc_out
    );

    always @(negedge clk or posedge reset) begin
        if (reset) pc_out <= `PC_WIDTH'hf0000000; //loader address
        else if (stall) pc_out <= pc_out;
        else pc_out <= pc_in;
    end

endmodule
