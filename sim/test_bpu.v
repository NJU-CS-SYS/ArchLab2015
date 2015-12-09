`timescale 1ns / 1ps

/**
 * @brief BPU 测试模块
 * @author whz
 */

module test_bpu();

    reg clk;
    reg reset;
    reg [31:0] current_pc;
    reg [31:0] tag_pc;
    reg [31:0] next_pc;
    reg bpu_w_en;
    wire [31:0] predicted_pc;

    always @(*) #10 clk <= !clk;

    bpu bpu(
        .clk(clk),
        .reset(reset),
        .current_pc(current_pc),
        .tag_pc(tag_pc),
        .next_pc(next_pc),
        .bpu_w_en(bpu_w_en),
        .predicted_pc(predicted_pc)
    );

    initial begin
        clk = 0;
        reset = 0;
        current_pc = 0;
        tag_pc = 0;
        next_pc = 0;
        bpu_w_en = 0;
        #5 reset = 1'b1;
        #5 reset = 1'b0;
        #5 bpu_w_en = 1;
        next_pc = 32'hc0c0c0c0;
        #10
        next_pc = 32'ha5a5a5ac;
    end

endmodule
