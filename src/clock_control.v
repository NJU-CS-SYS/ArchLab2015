`timescale 1ns / 1ps


module clock_control(
    input clk_in1,
    input ui_clk_from_ddr,
    input [7:6] SW,
    input manual_clk,
    output clk_to_ddr,
    output clk_to_pixel,
    output ui_clk_used,
    output reg sync_manual_clk
);

ddr_clock_gen dcg(
    .clk_in1(clk_in1),
    .clk_out1(clk_to_ddr),
    .clk_out2(clk_to_pixel)
);

reg slow_clk;
reg fast_clk;  // 32 times slow than ui_clk_from_ddr
reg [21:0] slow_clk_counter;
reg [1:0] fast_clk_counter;
always @ (posedge ui_clk_from_ddr) begin
    sync_manual_clk <= manual_clk;
    slow_clk_counter <= slow_clk_counter + 1;
    fast_clk_counter <= fast_clk_counter + 1;
    if (slow_clk_counter == 0) begin
        slow_clk <= ~slow_clk;
    end
    if (fast_clk_counter == 0) begin
        fast_clk <= ~fast_clk;
    end
end

assign ui_clk_used = SW[6] ?
    (SW[7] ? ui_clk_from_ddr : sync_manual_clk) :
    (SW[7] ? slow_clk : fast_clk);

endmodule
